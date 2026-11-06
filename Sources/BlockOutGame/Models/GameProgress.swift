import Foundation

public struct GameProgress: Codable, Equatable, Sendable {
    public var currentLevelId: Int
    public var unlockedLevelMax: Int
    public var starsPerLevel: [Int: Int]
    public var highScoresPerLevel: [Int: Int]
    public var totalScore: Int
    public var totalCoins: Int
    public var totalStars: Int
    public var undoCount: Int
    public var hintCount: Int
    public var extraMovesCount: Int
    public var hammerCount: Int
    public var activeThemeId: String
    public var soundEnabled: Bool
    public var musicEnabled: Bool
    public var hapticEnabled: Bool

    public init(
        currentLevelId: Int = 1,
        unlockedLevelMax: Int = 1,
        starsPerLevel: [Int: Int] = [:],
        highScoresPerLevel: [Int: Int] = [:],
        totalScore: Int = 0,
        totalCoins: Int = 200,
        totalStars: Int = 0,
        undoCount: Int = 5,
        hintCount: Int = 3,
        extraMovesCount: Int = 3,
        hammerCount: Int = 3,
        activeThemeId: String = "midnight_glow",
        soundEnabled: Bool = true,
        musicEnabled: Bool = true,
        hapticEnabled: Bool = true
    ) {
        self.currentLevelId = currentLevelId
        self.unlockedLevelMax = unlockedLevelMax
        self.starsPerLevel = starsPerLevel
        self.highScoresPerLevel = highScoresPerLevel
        self.totalScore = totalScore
        self.totalCoins = totalCoins
        self.totalStars = totalStars
        self.undoCount = undoCount
        self.hintCount = hintCount
        self.extraMovesCount = extraMovesCount
        self.hammerCount = hammerCount
        self.activeThemeId = activeThemeId
        self.soundEnabled = soundEnabled
        self.musicEnabled = musicEnabled
        self.hapticEnabled = hapticEnabled
    }
}

