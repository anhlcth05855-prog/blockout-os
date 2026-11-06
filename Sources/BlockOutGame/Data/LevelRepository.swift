import Foundation

public enum LevelRepository {

    public static let baseLevels: [Level] = [
        // Level 1: Tutorial - First Escape
        Level(
            id: 1,
            name: "First Escape",
            description: "Slide the blocks directly out to matching doors!",
            difficulty: "EASY",
            world: 1,
            gridWidth: 5,
            gridHeight: 5,
            blocks: [
                Block(id: "b1", color: .blue, x: 1, y: 0, width: 1, height: 3, direction: .vertical),
                Block(id: "b2", color: .red, x: 3, y: 2, width: 1, height: 3, direction: .vertical)
            ],
            doors: [
                ExitDoor(id: "d1", side: .top, index: 1, color: .blue, widthCells: 2),
                ExitDoor(id: "d2", side: .bottom, index: 2, color: .red, widthCells: 2)
            ],
            maxMoves: 15,
            parMoves: 2,
            timeSeconds: 300
        ),

        // Level 2: Two Pathways
        Level(
            id: 2,
            name: "Two Pathways",
            description: "Swipe blocks into their matching exit gates!",
            difficulty: "EASY",
            world: 1,
            gridWidth: 5,
            gridHeight: 5,
            blocks: [
                Block(id: "b1", color: .green, x: 1, y: 2, width: 1, height: 3, direction: .vertical),
                Block(id: "b2", color: .orange, x: 3, y: 1, width: 1, height: 3, direction: .vertical)
            ],
            doors: [
                ExitDoor(id: "d1", side: .top, index: 1, color: .green, widthCells: 2),
                ExitDoor(id: "d2", side: .bottom, index: 2, color: .orange, widthCells: 2)
            ],
            maxMoves: 15,
            parMoves: 2,
            timeSeconds: 300
        ),

        // Level 3: Dual Gateways
        Level(
            id: 3,
            name: "Dual Gateways",
            description: "Coordinate moves to clear exits for all blocks.",
            difficulty: "NORMAL",
            world: 1,
            gridWidth: 5,
            gridHeight: 5,
            blocks: [
                Block(id: "b1", color: .blue, x: 0, y: 0, width: 1, height: 2, direction: .vertical),
                Block(id: "b2", color: .red, x: 2, y: 2, width: 1, height: 3, direction: .vertical),
                Block(id: "b3", color: .yellow, x: 3, y: 1, width: 1, height: 3, direction: .vertical)
            ],
            doors: [
                ExitDoor(id: "d1", side: .left, index: 0, color: .blue, widthCells: 2),
                ExitDoor(id: "d2", side: .top, index: 2, color: .red, widthCells: 2),
                ExitDoor(id: "d3", side: .right, index: 1, color: .yellow, widthCells: 3),
                ExitDoor(id: "d4", side: .bottom, index: 1, color: .red, widthCells: 2)
            ],
            maxMoves: 20,
            parMoves: 3,
            timeSeconds: 300
        ),

        // Level 4: Rock Obstacle Intro
        Level(
            id: 4,
            name: "Rock Outskirts",
            description: "Navigate around heavy rocks or destroy them using the Hammer booster!",
            difficulty: "NORMAL",
            world: 1,
            gridWidth: 5,
            gridHeight: 5,
            blocks: [
                Block(id: "b1", color: .cyan, x: 1, y: 1, width: 1, height: 2, direction: .vertical, symbol: "diamond"),
                Block(id: "b2", color: .yellow, x: 2, y: 3, width: 2, height: 1, direction: .horizontal, symbol: "star"),
                Block(id: "b3", color: .pink, x: 3, y: 0, width: 1, height: 2, direction: .vertical, symbol: "circle")
            ],
            doors: [
                ExitDoor(id: "d1", side: .top, index: 1, color: .cyan),
                ExitDoor(id: "d2", side: .right, index: 3, color: .yellow),
                ExitDoor(id: "d3", side: .bottom, index: 3, color: .pink)
            ],
            obstacles: [
                Obstacle(id: "obs1", x: 2, y: 1, type: .rock)
            ],
            maxMoves: 24,
            parMoves: 9,
            timeSeconds: 180
        ),

        // Level 5: Grid Lock
        Level(
            id: 5,
            name: "Grid Lock",
            description: "Space is tight. Every move counts towards 3 stars.",
            difficulty: "NORMAL",
            world: 1,
            gridWidth: 6,
            gridHeight: 6,
            blocks: [
                Block(id: "b1", color: .blue, x: 1, y: 0, width: 1, height: 3, direction: .vertical, symbol: "diamond"),
                Block(id: "b2", color: .red, x: 2, y: 1, width: 3, height: 1, direction: .horizontal, symbol: "star"),
                Block(id: "b3", color: .green, x: 0, y: 4, width: 3, height: 1, direction: .horizontal, symbol: "square"),
                Block(id: "b4", color: .orange, x: 4, y: 2, width: 1, height: 3, direction: .vertical, symbol: "circle"),
                Block(id: "b5", color: .white, x: 2, y: 3, width: 2, height: 1, direction: .horizontal, symbol: "cross")
            ],
            doors: [
                ExitDoor(id: "d1", side: .top, index: 1, color: .blue),
                ExitDoor(id: "d2", side: .right, index: 1, color: .red),
                ExitDoor(id: "d3", side: .left, index: 4, color: .green),
                ExitDoor(id: "d4", side: .bottom, index: 4, color: .orange),
                ExitDoor(id: "d5", side: .right, index: 3, color: .white)
            ],
            maxMoves: 30,
            parMoves: 12,
            timeSeconds: 200
        ),

        // Level 36: The Canyon Mill (From the user's screenshot)
        Level(
            id: 36,
            name: "The Canyon Mill",
            description: "Rotating four-quadrant mill mechanisms driving canyon gates.",
            difficulty: "ADEPT",
            world = 1,
            gridWidth: 6,
            gridHeight: 6,
            blocks: [
                Block(id: "b_blue", color: .blue, x: 1, y: 0, width: 1, height: 3, direction: .vertical, symbol: "diamond"),
                Block(id: "b_white", color: .white, x: 0, y: 3, width: 1, height: 3, direction: .vertical, symbol: "cross"),
                Block(id: "b_black", color: .black, x: 2, y: 3, width: 1, height: 3, direction: .vertical, symbol: "star"),
                Block(id: "b_purple", color: .purple, x: 3, y: 3, width: 1, height: 3, direction: .vertical, symbol: "square"),
                Block(id: "b_red", color: .pink, x: 5, y: 2, width: 1, height: 1, direction: .horizontal, symbol: "circle"),
                Block(id: "b_green", color: .green, x: 4, y: 4, width: 1, height: 1, direction: .horizontal, symbol: "circle"),
                Block(id: "b_orange", color: .orange, x: 5, y: 1, width: 1, height: 1, direction: .horizontal, symbol: "star")
            ],
            doors: [
                // Top doors
                ExitDoor(id: "d_top_white", side: .top, index: 0, color: .white),
                ExitDoor(id: "d_top_blue", side: .top, index: 1, color: .blue),
                ExitDoor(id: "d_top_black", side: .top, index: 2, color: .black),
                ExitDoor(id: "d_top_purple", side: .top, index: 3, color: .purple),
                ExitDoor(id: "d_top_green", side: .top, index: 4, color: .green),
                // Left doors
                ExitDoor(id: "d_left_pink", side: .left, index: 2, color: .pink),
                ExitDoor(id: "d_left_green", side: .left, index: 4, color: .green),
                // Right doors
                ExitDoor(id: "d_right_orange", side: .right, index: 1, color: .orange)
            ],
            maxMoves: 34,
            parMoves: 18,
            timeSeconds: 161
        )
    ]

    public static func getAllLevels() -> [Level] {
        var list: [Level] = []
        list.append(contentsOf: baseLevels.filter { $0.id <= 5 })

        for lvl in 6...35 {
            list.append(generateGuaranteedNonOverlappingLevel(id: lvl))
        }

        if let lvl36 = baseLevels.first(where: { $0.id == 36 }) {
            list.append(lvl36)
        }

        return list.sorted { $0.id < $1.id }
    }

    public static func getLevel(id: Int) -> Level {
        let all = getAllLevels()
        return all.first { $0.id == id } ?? all.first!
    }

    public static func getDailyPuzzle() -> Level {
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinal(of: .day, in: .year, for: Date()) ?? 1
        let year = calendar.component(.year, from: Date())
        var rng = LinearCongruentialGenerator(seed: UInt64(year * 366 + dayOfYear))

        var colors: [BlockColor] = [.blue, .red, .green, .yellow, .purple, .orange]
        colors.shuffle(using: &rng)

        let blocks = [
            Block(id: "daily_1", color: colors[0], x: 1, y: 1, width: 1, height: 3, direction: .vertical, symbol: "star"),
            Block(id: "daily_2", color: colors[1], x: 2, y: 2, width: 2, height: 1, direction: .horizontal, symbol: "diamond"),
            Block(id: "daily_3", color: colors[2], x: 4, y: 0, width: 1, height: 2, direction: .vertical, symbol: "circle"),
            Block(id: "daily_4", color: colors[3], x: 0, y: 4, width: 3, height: 1, direction: .horizontal, symbol: "square")
        ]

        let doors = [
            ExitDoor(id: "d_daily_1", side: .top, index: 1, color: colors[0]),
            ExitDoor(id: "d_daily_2", side: .right, index: 2, color: colors[1]),
            ExitDoor(id: "d_daily_3", side: .bottom, index: 4, color: colors[2]),
            ExitDoor(id: "d_daily_4", side: .left, index: 4, color: colors[3])
        ]

        return Level(
            id: 9999,
            name: "Daily Challenge",
            description: "A fresh deterministic daily puzzle! Earn +100 coins & stars.",
            difficulty: "ADEPT",
            world: 1,
            gridWidth: 6,
            gridHeight: 6,
            blocks: blocks,
            doors: doors,
            maxMoves: 28,
            parMoves: 14,
            timeSeconds: 180
        )
    }

    private static func generateGuaranteedNonOverlappingLevel(id: Int) -> Level {
        var rng = LinearCongruentialGenerator(seed: UInt64(id * 7919))
        let gridW = 6
        let gridH = 6

        let diffName: String
        if id < 12 { diffName = "NORMAL" }
        else if id < 22 { diffName = "ADEPT" }
        else if id < 30 { diffName = "HARD" }
        else { diffName = "SUPER HARD" }

        var availableColors: [BlockColor] = [
            .blue, .red, .green, .yellow, .purple, .orange, .white, .black, .pink, .cyan
        ]
        availableColors.shuffle(using: &rng)

        var gridOccupied = Array(repeating: Array(repeating: false, count: gridW), count: gridH)
        var obstacles: [Obstacle] = []

        if id > 10 && id % 3 == 0 {
            let ox = 2
            let oy = 2
            obstacles.append(Obstacle(id: "obs_\(id)", x: ox, y: oy, type: .rock))
            gridOccupied[oy][ox] = true
        }

        var blocks: [Block] = []
        var doors: [ExitDoor] = []
        let symbols = ["star", "diamond", "square", "circle", "cross"]
        let targetCount = max(4, min(7, 4 + (id % 4)))

        for i in 0..<targetCount {
            let color = availableColors[i % availableColors.count]
            let isVertical = (i % 2 == 0)
            let len = (rng.next() % 2 == 0) ? 2 : 3

            let w = isVertical ? 1 : len
            let h = isVertical ? len : 1

            var validPositions: [(x: Int, y: Int)] = []
            for r in 0...(gridH - h) {
                for c in 0...(gridW - w) {
                    var fits = true
                    for checkR in r..<(r + h) {
                        for checkC in c..<(c + w) {
                            if gridOccupied[checkR][checkC] {
                                fits = false
                                break
                            }
                        }
                        if !fits { break }
                    }
                    if fits {
                        validPositions.append((c, r))
                    }
                }
            }

            if !validPositions.isEmpty {
                let chosenIdx = Int(rng.next() % UInt64(validPositions.count))
                let (chosenX, chosenY) = validPositions[chosenIdx]

                for checkR in chosenY..<(chosenY + h) {
                    for checkC in chosenX..<(chosenX + w) {
                        gridOccupied[checkR][checkC] = true
                    }
                }

                blocks.append(
                    Block(
                        id: "b_\(id)_\(i)",
                        color: color,
                        x: chosenX,
                        y: chosenY,
                        width: w,
                        height: h,
                        direction: isVertical ? .vertical : .horizontal,
                        symbol: symbols[i % symbols.count]
                    )
                )

                let side: ExitSide
                if isVertical {
                    side = (chosenY < gridH / 2) ? .top : .bottom
                } else {
                    side = (chosenX < gridW / 2) ? .left : .right
                }

                let doorIndex = side.isVertical ? chosenX : chosenY
                doors.removeAll { $0.side == side && $0.index == doorIndex }
                doors.append(ExitDoor(id: "d_\(id)_\(i)", side: side, index: doorIndex, color: color))
            }
        }

        return Level(
            id: id,
            name: "Level \(id): \(getLevelTitle(id))",
            description: "Navigate color gates, avoid block collisions and clear the board.",
            difficulty: diffName,
            world: 1,
            gridWidth: gridW,
            gridHeight: gridH,
            blocks: blocks,
            doors: doors,
            obstacles: obstacles,
            maxMoves: 25 + (id % 12),
            parMoves: 12 + (id % 6),
            timeSeconds: 150 + (id % 50)
        )
    }

    private static func getLevelTitle(_ id: Int) -> String {
        let titles = [
            "Neon Outskirts", "Sapphire Crossing", "Emerald Maze", "Amber Switchback",
            "Obsidian Chamber", "Crimson Flow", "Prism Junction", "Lego Bastion",
            "Midnight Shuffle", "Velvet Gateway", "Starlight Labyrinth", "Cobalt Trench",
            "Iron Spire", "Crystal Tunnel", "Topaz Spiral", "Quartz Matrix"
        ]
        return titles[(id - 1) % titles.count]
    }
}

/// Simple pseudorandom generator for deterministic level layouts
public struct LinearCongruentialGenerator: RandomNumberGenerator {
    private var state: UInt64
    public init(seed: UInt64) { self.state = seed }
    public mutating func next() -> UInt64 {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return state
    }
}

