import Foundation

public struct DragLimits: Equatable, Sendable {
    public let minXOnBoard: Int
    public let maxXOnBoard: Int
    public let minYOnBoard: Int
    public let maxYOnBoard: Int
    public let canEscapeLeft: Bool
    public let canEscapeRight: Bool
    public let canEscapeTop: Bool
    public let canEscapeBottom: Bool

    public init(
        minXOnBoard: Int,
        maxXOnBoard: Int,
        minYOnBoard: Int,
        maxYOnBoard: Int,
        canEscapeLeft: Bool,
        canEscapeRight: Bool,
        canEscapeTop: Bool,
        canEscapeBottom: Bool
    ) {
        self.minXOnBoard = minXOnBoard
        self.maxXOnBoard = maxXOnBoard
        self.minYOnBoard = minYOnBoard
        self.maxYOnBoard = maxYOnBoard
        self.canEscapeLeft = canEscapeLeft
        self.canEscapeRight = canEscapeRight
        self.canEscapeTop = canEscapeTop
        self.canEscapeBottom = canEscapeBottom
    }
}

public struct MoveResult: Equatable, Sendable {
    public let blockId: String
    public let oldX: Int
    public let oldY: Int
    public let newX: Int
    public let newY: Int
    public let escaped: Bool
    public let escapeSide: ExitSide?
    public let scoreEarned: Int
    public let comboMultiplier: Int
}

public final class GameEngine: ObservableObject {
    public let level: Level
    public let gridWidth: Int
    public let gridHeight: Int

    @Published public private(set) var blocks: [Block] = []
    @Published public private(set) var doors: [ExitDoor] = []
    @Published public private(set) var obstacles: [Obstacle] = []
    @Published public private(set) var movesMade: Int = 0
    @Published public var extraMovesAdded: Int = 0

    @Published public private(set) var isWon: Bool = false
    @Published public private(set) var isGameOver: Bool = false

    @Published public private(set) var currentScore: Int = 0
    @Published public private(set) var comboMultiplier: Int = 1
    @Published public private(set) var movesBonus: Int = 0
    @Published public private(set) var levelClearBonus: Int = 0

    public var onBlockEscaped: ((Block, ExitSide) -> Void)?
    public var onLevelWon: (() -> Void)?

    private var lastEscapeTime: Date?
    private let comboWindowSeconds: TimeInterval = 3.8
    private var undoStack: [[Block]] = []

    public var maxMoves: Int {
        level.maxMoves + extraMovesAdded
    }

    public var remainingBlocks: Int {
        blocks.filter { !$0.isEscaped }.count
    }

    public var totalBlocks: Int {
        blocks.count
    }

    public var starsEarned: Int {
        guard isWon else { return 0 }
        if movesMade <= level.parMoves {
            return 3
        } else if movesMade <= (level.parMoves + max(1, (maxMoves - level.parMoves) / 2)) {
            return 2
        } else {
            return 1
        }
    }

    public init(
        level: Level,
        onBlockEscaped: ((Block, ExitSide) -> Void)? = nil,
        onLevelWon: (() -> Void)? = nil
    ) {
        self.level = level
        self.gridWidth = level.gridWidth
        self.gridHeight = level.gridHeight
        self.doors = level.doors
        self.obstacles = level.obstacles
        self.onBlockEscaped = onBlockEscaped
        self.onLevelWon = onLevelWon

        // Enforce 100% overlap-free block positioning
        var occupied = Set<String>()
        for obs in obstacles {
            for ox in obs.x..<(obs.x + obs.width) {
                for oy in obs.y..<(obs.y + obs.height) {
                    occupied.insert("\(ox),\(oy)")
                }
            }
        }

        var sanitized: [Block] = []
        for raw in level.blocks {
            let clampedX = max(0, min(raw.x, gridWidth - raw.width))
            let clampedY = max(0, min(raw.y, gridHeight - raw.height))
            var blk = raw
            blk.x = clampedX
            blk.y = clampedY

            let myCells = blk.getAllOccupiedCells()
            let hasOverlap = myCells.contains { occupied.contains("\($0.x),\($0.y)") }

            if hasOverlap {
                var placed = false
                for r in 0...(max(0, gridHeight - blk.height)) {
                    for c in 0...(max(0, gridWidth - blk.width)) {
                        var testCells: [(x: Int, y: Int)] = []
                        for tc in c..<(c + blk.width) {
                            for tr in r..<(tr + blk.height) {
                                testCells.append((tc, tr))
                            }
                        }
                        if testCells.allSatisfy({ !occupied.contains("\($0.x),\($0.y)") }) {
                            blk.x = c
                            blk.y = r
                            sanitized.append(blk)
                            for cell in testCells { occupied.insert("\(cell.x),\(cell.y)") }
                            placed = true
                            break
                        }
                    }
                    if placed { break }
                }
                if !placed {
                    sanitized.append(blk)
                }
            } else {
                sanitized.append(blk)
                for cell in myCells { occupied.insert("\(cell.x),\(cell.y)") }
            }
        }
        self.blocks = sanitized
    }

    public func getBlock(id: String) -> Block? {
        blocks.first { $0.id == id }
    }

    public func calculateLimits(block: Block) -> DragLimits {
        if block.isEscaped {
            return DragLimits(
                minXOnBoard: block.x, maxXOnBoard: block.x,
                minYOnBoard: block.y, maxYOnBoard: block.y,
                canEscapeLeft: false, canEscapeRight: false, canEscapeTop: false, canEscapeBottom: false
            )
        }

        let curX = max(0, min(block.x, gridWidth - block.width))
        let curY = max(0, min(block.y, gridHeight - block.height))

        let otherBlocks = blocks.filter { $0.id != block.id && !$0.isEscaped }
        let activeObstacles = obstacles.filter { !$0.isDestroyed }

        var minX = curX
        var maxX = curX
        var minY = curY
        var maxY = curY

        if block.direction.canMoveHorizontal {
            // Check sliding LEFT
            var testX = curX - 1
            while testX >= 0 {
                if isAreaBlocked(startX: testX, startY: curY, width: 1, height: block.height, others: otherBlocks, obs: activeObstacles) {
                    break
                }
                minX = testX
                testX -= 1
            }

            // Check sliding RIGHT
            testX = curX + 1
            while testX + block.width <= gridWidth {
                if isAreaBlocked(startX: testX + block.width - 1, startY: curY, width: 1, height: block.height, others: otherBlocks, obs: activeObstacles) {
                    break
                }
                maxX = testX
                testX += 1
            }
        }

        if block.direction.canMoveVertical {
            // Check sliding UP
            var testY = curY - 1
            while testY >= 0 {
                if isAreaBlocked(startX: curX, startY: testY, width: block.width, height: 1, others: otherBlocks, obs: activeObstacles) {
                    break
                }
                minY = testY
                testY -= 1
            }

            // Check sliding DOWN
            testY = curY + 1
            while testY + block.height <= gridHeight {
                if isAreaBlocked(startX: curX, startY: testY + block.height - 1, width: block.width, height: 1, others: otherBlocks, obs: activeObstacles) {
                    break
                }
                maxY = testY
                testY += 1
            }
        }

        // Can escape LEFT: path to left edge (col 0) is clear, and matching door exists covering all rows
        let canEscapeLeft = block.direction.canMoveHorizontal && (minX == 0) && (curY..<(curY + block.height)).allSatisfy { row in
            doors.contains { $0.side == .left && $0.color == block.color && $0.covers(gridIndex: row) }
        }

        // Can escape RIGHT: path to right edge is clear, and matching door exists covering all rows
        let canEscapeRight = block.direction.canMoveHorizontal && (maxX + block.width == gridWidth) && (curY..<(curY + block.height)).allSatisfy { row in
            doors.contains { $0.side == .right && $0.color == block.color && $0.covers(gridIndex: row) }
        }

        // Can escape TOP: path to top edge (row 0) is clear, and matching door exists covering all columns
        let canEscapeTop = block.direction.canMoveVertical && (minY == 0) && (curX..<(curX + block.width)).allSatisfy { col in
            doors.contains { $0.side == .top && $0.color == block.color && $0.covers(gridIndex: col) }
        }

        // Can escape BOTTOM: path to bottom edge is clear, and matching door exists covering all columns
        let canEscapeBottom = block.direction.canMoveVertical && (maxY + block.height == gridHeight) && (curX..<(curX + block.width)).allSatisfy { col in
            doors.contains { $0.side == .bottom && $0.color == block.color && $0.covers(gridIndex: col) }
        }

        return DragLimits(
            minXOnBoard: minX,
            maxXOnBoard: maxX,
            minYOnBoard: minY,
            maxYOnBoard: maxY,
            canEscapeLeft: canEscapeLeft,
            canEscapeRight: canEscapeRight,
            canEscapeTop: canEscapeTop,
            canEscapeBottom: canEscapeBottom
        )
    }

    private func isAreaBlocked(startX: Int, startY: Int, width: Int, height: Int, others: [Block], obs: [Obstacle]) -> Bool {
        for x in startX..<(startX + width) {
            for y in startY..<(startY + height) {
                if others.contains(where: { $0.occupies(checkX: x, checkY: y) }) { return true }
                if obs.contains(where: { $0.occupies(checkX: x, checkY: y) }) { return true }
            }
        }
        return false
    }

    public func applyMove(
        blockId: String,
        deltaCellsX: Float,
        deltaCellsY: Float,
        isFling: Bool = false,
        forceEscape: Bool = false
    ) -> MoveResult? {
        guard let block = getBlock(id: blockId), !block.isEscaped else { return nil }

        let curX = max(0, min(block.x, gridWidth - block.width))
        let curY = max(0, min(block.y, gridHeight - block.height))

        let limits = calculateLimits(block: block)

        var newX = curX
        var newY = curY
        var escaped = false
        var escapeSide: ExitSide? = nil

        let escapeSensitivity: Float = 0.20

        // Check horizontal movement
        if block.direction.canMoveHorizontal {
            if (forceEscape || deltaCellsX <= -escapeSensitivity || isFling) && limits.canEscapeLeft && deltaCellsX < 0 {
                escaped = true
                escapeSide = .left
                newX = -block.width
            } else if (forceEscape || deltaCellsX >= escapeSensitivity || isFling) && limits.canEscapeRight && deltaCellsX > 0 {
                escaped = true
                escapeSide = .right
                newX = gridWidth
            } else if isFling && deltaCellsX < 0 {
                newX = limits.minXOnBoard
            } else if isFling && deltaCellsX > 0 {
                newX = limits.maxXOnBoard
            } else {
                let targetX = Float(curX) + deltaCellsX
                newX = max(limits.minXOnBoard, min(Int(round(targetX)), limits.maxXOnBoard))
            }
        }

        // Check vertical movement
        if block.direction.canMoveVertical && !escaped {
            if (forceEscape || deltaCellsY <= -escapeSensitivity || isFling) && limits.canEscapeTop && deltaCellsY < 0 {
                escaped = true
                escapeSide = .top
                newY = -block.height
            } else if (forceEscape || deltaCellsY >= escapeSensitivity || isFling) && limits.canEscapeBottom && deltaCellsY > 0 {
                escaped = true
                escapeSide = .bottom
                newY = gridHeight
            } else if isFling && deltaCellsY < 0 {
                newY = limits.minYOnBoard
            } else if isFling && deltaCellsY > 0 {
                newY = limits.maxYOnBoard
            } else {
                let targetY = Float(curY) + deltaCellsY
                newY = max(limits.minYOnBoard, min(Int(round(targetY)), limits.maxYOnBoard))
            }
        }

        // If no movement happened
        if !escaped && newX == curX && newY == curY {
            return nil
        }

        // Record undo state
        undoStack.append(blocks)
        if undoStack.count > 30 { undoStack.removeFirst() }

        var scoreEarned = 0
        if escaped {
            let now = Date()
            if let last = lastEscapeTime, now.timeIntervalSince(last) <= comboWindowSeconds {
                comboMultiplier = min(5, comboMultiplier + 1)
            } else {
                comboMultiplier = 1
            }
            lastEscapeTime = now

            let basePoints = block.width * block.height * 100
            scoreEarned = basePoints * comboMultiplier
            currentScore += scoreEarned
        }

        var updatedBlock = block
        updatedBlock.x = newX
        updatedBlock.y = newY
        updatedBlock.isEscaped = escaped
        updatedBlock.escapeSide = escapeSide

        if let idx = blocks.firstIndex(where: { $0.id == blockId }) {
            blocks[idx] = updatedBlock
        }
        movesMade += 1

        if escaped, let side = escapeSide {
            onBlockEscaped?(updatedBlock, side)
        }

        checkWinState()

        return MoveResult(
            blockId: blockId,
            oldX: curX,
            oldY: curY,
            newX: newX,
            newY: newY,
            escaped: escaped,
            escapeSide: escapeSide,
            scoreEarned: scoreEarned,
            comboMultiplier: comboMultiplier
        )
    }

    public func tryQuickEscape(blockId: String) -> MoveResult? {
        guard let block = getBlock(id: blockId), !block.isEscaped else { return nil }
        let limits = calculateLimits(block: block)

        if limits.canEscapeLeft {
            return applyMove(blockId: blockId, deltaCellsX: -1, deltaCellsY: 0, forceEscape: true)
        }
        if limits.canEscapeRight {
            return applyMove(blockId: blockId, deltaCellsX: 1, deltaCellsY: 0, forceEscape: true)
        }
        if limits.canEscapeTop {
            return applyMove(blockId: blockId, deltaCellsX: 0, deltaCellsY: -1, forceEscape: true)
        }
        if limits.canEscapeBottom {
            return applyMove(blockId: blockId, deltaCellsX: 0, deltaCellsY: 1, forceEscape: true)
        }
        return nil
    }

    private func checkWinState() {
        if blocks.allSatisfy({ $0.isEscaped }) {
            isWon = true
            movesBonus = max(0, (maxMoves - movesMade)) * 50
            levelClearBonus = level.id * 150
            currentScore += movesBonus + levelClearBonus
            onLevelWon?()
        } else if movesMade >= maxMoves {
            isGameOver = true
        }
    }

    public func calculateFinalScoreWithTime(remainingSeconds: Int) -> Int {
        let timeBonus = remainingSeconds * 10
        return currentScore + timeBonus
    }

    public func undo() -> Bool {
        guard !undoStack.isEmpty else { return false }
        blocks = undoStack.removeLast()
        if movesMade > 0 { movesMade -= 1 }
        comboMultiplier = 1
        isWon = false
        isGameOver = false
        return true
    }

    public func addExtraMoves(count: Int = 5) {
        extraMovesAdded += count
        if isGameOver && movesMade < maxMoves {
            isGameOver = false
        }
    }

    public func destroyObstacle(obstacleId: String) -> Bool {
        guard let idx = obstacles.firstIndex(where: { $0.id == obstacleId && !$0.isDestroyed }) else { return false }
        obstacles[idx].isDestroyed = true
        return true
    }

    public func destroyAnyObstacle() -> Bool {
        guard let first = obstacles.first(where: { !$0.isDestroyed }) else { return false }
        return destroyObstacle(obstacleId: first.id)
    }

    public func findHintMove() -> (block: Block, delta: (x: Float, y: Float))? {
        // 1. Look for any block that can immediately escape
        for b in blocks.filter({ !$0.isEscaped }) {
            let limits = calculateLimits(block: b)
            if limits.canEscapeLeft { return (b, (Float(-b.width - b.x - 1), 0)) }
            if limits.canEscapeRight { return (b, (Float(gridWidth - b.x + 1), 0)) }
            if limits.canEscapeTop { return (b, (0, Float(-b.height - b.y - 1))) }
            if limits.canEscapeBottom { return (b, (0, Float(gridHeight - b.y + 1))) }
        }

        // 2. Look for any block that can move to unblock an exit path
        for b in blocks.filter({ !$0.isEscaped }) {
            let limits = calculateLimits(block: b)
            if b.direction.canMoveHorizontal {
                if limits.maxXOnBoard > b.x { return (b, (Float(limits.maxXOnBoard - b.x), 0)) }
                if limits.minXOnBoard < b.x { return (b, (Float(limits.minXOnBoard - b.x), 0)) }
            }
            if b.direction.canMoveVertical {
                if limits.maxYOnBoard > b.y { return (b, (0, Float(limits.maxYOnBoard - b.y))) }
                if limits.minYOnBoard < b.y { return (b, (0, Float(limits.minYOnBoard - b.y))) }
            }
        }
        return nil
    }
}

