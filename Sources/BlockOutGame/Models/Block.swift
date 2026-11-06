import Foundation

public struct Block: Identifiable, Codable, Equatable, Sendable {
    public let id: String
    public var color: BlockColor
    public var x: Int
    public var y: Int
    public var width: Int
    public var height: Int
    public var direction: SlideDirection
    public var symbol: String?
    public var isEscaped: Bool
    public var escapeProgress: Float
    public var escapeSide: ExitSide?

    public init(
        id: String = UUID().uuidString,
        color: BlockColor,
        x: Int,
        y: Int,
        width: Int,
        height: Int,
        direction: SlideDirection? = nil,
        symbol: String? = nil,
        isEscaped: Bool = false,
        escapeProgress: Float = 0,
        escapeSide: ExitSide? = nil
    ) {
        self.id = id
        self.color = color
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.direction = direction ?? (width > height ? .horizontal : (height > width ? .vertical : .all))
        self.symbol = symbol
        self.isEscaped = isEscaped
        self.escapeProgress = escapeProgress
        self.escapeSide = escapeSide
    }

    public func occupies(checkX: Int, checkY: Int) -> Bool {
        if isEscaped { return false }
        return checkX >= x && checkX < (x + width) && checkY >= y && checkY < (y + height)
    }

    public func getAllOccupiedCells() -> [(x: Int, y: Int)] {
        if isEscaped { return [] }
        var cells: [(x: Int, y: Int)] = []
        for col in x..<(x + width) {
            for row in y..<(y + height) {
                cells.append((col, row))
            }
        }
        return cells
    }

    public func copyWithPosition(newX: Int, newY: Int) -> Block {
        var copy = self
        copy.x = newX
        copy.y = newY
        return copy
    }
}

