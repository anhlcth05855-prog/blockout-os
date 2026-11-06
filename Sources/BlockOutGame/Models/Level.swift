import Foundation

public struct Level: Identifiable, Codable, Equatable, Sendable {
    public let id: Int
    public var name: String
    public var description: String
    public var difficulty: String // EASY, NORMAL, ADEPT, HARD, SUPER HARD
    public var world: Int
    public var gridWidth: Int
    public var gridHeight: Int
    public var blocks: [Block]
    public var doors: [ExitDoor]
    public var obstacles: [Obstacle]
    public var maxMoves: Int
    public var parMoves: Int
    public var timeSeconds: Int

    public init(
        id: Int,
        name: String,
        description: String = "",
        difficulty: String = "NORMAL",
        world: Int = 1,
        gridWidth: Int = 6,
        gridHeight: Int = 6,
        blocks: [Block],
        doors: [ExitDoor],
        obstacles: [Obstacle] = [],
        maxMoves: Int = 30,
        parMoves: Int = 20,
        timeSeconds: Int = 180
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.difficulty = difficulty
        self.world = world
        self.gridWidth = gridWidth
        self.gridHeight = gridHeight
        self.blocks = blocks
        self.doors = doors
        self.obstacles = obstacles
        self.maxMoves = maxMoves
        self.parMoves = parMoves
        self.timeSeconds = timeSeconds
    }
}

