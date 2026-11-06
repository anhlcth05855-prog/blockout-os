import Foundation

public struct ExitDoor: Identifiable, Codable, Equatable, Sendable {
    public let id: String
    public var side: ExitSide
    public var index: Int // column for top/bottom, row for left/right
    public var color: BlockColor
    public var widthCells: Int

    public init(
        id: String = UUID().uuidString,
        side: ExitSide,
        index: Int,
        color: BlockColor,
        widthCells: Int = 1
    ) {
        self.id = id
        self.side = side
        self.index = index
        self.color = color
        self.widthCells = max(1, widthCells)
    }

    public func covers(gridIndex: Int) -> Bool {
        return gridIndex >= index && gridIndex < (index + widthCells)
    }
}

