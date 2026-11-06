import Foundation

public enum ObstacleType: String, Codable, CaseIterable, Sendable {
    case rock
    case lock
    case crate
}

public struct Obstacle: Identifiable, Codable, Equatable, Sendable {
    public let id: String
    public var x: Int
    public var y: Int
    public var width: Int
    public var height: Int
    public var type: ObstacleType
    public var isDestroyed: Bool

    public init(
        id: String = UUID().uuidString,
        x: Int,
        y: Int,
        width: Int = 1,
        height: Int = 1,
        type: ObstacleType = .rock,
        isDestroyed: Bool = false
    ) {
        self.id = id
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.type = type
        self.isDestroyed = isDestroyed
    }

    public func occupies(checkX: Int, checkY: Int) -> Bool {
        if isDestroyed { return false }
        return checkX >= x && checkX < (x + width) && checkY >= y && checkY < (y + height)
    }
}

