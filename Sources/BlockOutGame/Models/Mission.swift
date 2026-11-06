import Foundation

public struct Mission: Identifiable, Codable, Equatable, Sendable {
    public let id: String
    public var title: String
    public var description: String
    public var target: Int
    public var current: Int
    public var rewardCoins: Int
    public var isClaimed: Bool

    public init(
        id: String,
        title: String,
        description: String,
        target: Int,
        current: Int,
        rewardCoins: Int,
        isClaimed: Bool = false
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.target = target
        self.current = current
        self.rewardCoins = rewardCoins
        self.isClaimed = isClaimed
    }

    public var isComplete: Bool {
        current >= target
    }

    public var progressRatio: Double {
        guard target > 0 else { return 0 }
        return min(1.0, Double(current) / Double(target))
    }
}

