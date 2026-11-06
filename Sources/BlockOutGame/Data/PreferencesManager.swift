import Foundation
import Combine

public final class PreferencesManager: ObservableObject {
    public static let shared = PreferencesManager()

    private let userDefaults: UserDefaults
    private let keyProgress = "key_block_out_progress"
    private let keyMissions = "key_block_out_missions"
    private let keyThemes = "key_block_out_themes"

    public init(defaults: UserDefaults = .standard) {
        self.userDefaults = defaults
    }

    public func loadProgress() -> GameProgress {
        guard let data = userDefaults.data(forKey: keyProgress) else {
            return GameProgress()
        }
        do {
            return try JSONDecoder().decode(GameProgress.self, from: data)
        } catch {
            return GameProgress()
        }
    }

    public func saveProgress(_ progress: GameProgress) {
        if let data = try? JSONEncoder().encode(progress) {
            userDefaults.set(data, forKey: keyProgress)
        }
    }

    public func loadMissions() -> [Mission] {
        guard let data = userDefaults.data(forKey: keyMissions),
              let list = try? JSONDecoder().decode([Mission].self, from: data),
              !list.isEmpty else {
            return defaultMissions
        }
        return list
    }

    public func saveMissions(_ missions: [Mission]) {
        if let data = try? JSONEncoder().encode(missions) {
            userDefaults.set(data, forKey: keyMissions)
        }
    }

    public var defaultMissions: [Mission] {
        [
            Mission(id: "m1", title: "Puzzle Apprentice", description: "Solve 3 adventure puzzle levels", target: 3, current: 0, rewardCoins: 50),
            Mission(id: "m2", title: "Path Finder", description: "Solve 10 adventure puzzle levels", target: 10, current: 0, rewardCoins: 150),
            Mission(id: "m3", title: "Swift Thinker", description: "Win 3 levels using 5 moves or fewer", target: 3, current: 0, rewardCoins: 80),
            Mission(id: "m4", title: "Par Perfection", description: "Win 5 levels within par move threshold", target: 5, current: 0, rewardCoins: 100),
            Mission(id: "m5", title: "Starlight Collector", description: "Amass a total of 15 gold stars", target: 15, current: 0, rewardCoins: 60),
            Mission(id: "m6", title: "Daily Adventurer", description: "Complete today's Daily Challenge", target: 1, current: 0, rewardCoins: 100)
        ]
    }

    public func getAvailableThemes() -> [ThemeItem] {
        [
            ThemeItem(
                id: "midnight_glow",
                name: "Midnight Glow",
                description: "Sleek nighttime starry sky with maximum contrast",
                price: 0,
                isUnlocked: true,
                backgroundStartColorHex: 0x12132A,
                backgroundEndColorHex: 0x1E1F42,
                boardBgColorHex: 0x1C1E3D,
                boardBorderColorHex: 0x2F3261
            ),
            ThemeItem(
                id: "sunny_meadow",
                name: "Sunny Meadow",
                description: "Cheerful blue skies and spring green pastures",
                price: 100,
                isUnlocked: false,
                backgroundStartColorHex: 0x1E3A8A,
                backgroundEndColorHex: 0x047857,
                boardBgColorHex: 0x172554,
                boardBorderColorHex: 0x1E40AF
            ),
            ThemeItem(
                id: "candy_cloud",
                name: "Candy Cloud",
                description: "Dreamy cotton candy skies and pastel clouds",
                price: 150,
                isUnlocked: false,
                backgroundStartColorHex: 0x4A154B,
                backgroundEndColorHex: 0x701A75,
                boardBgColorHex: 0x3B0764,
                boardBorderColorHex: 0x6B21A8
            ),
            ThemeItem(
                id: "coral_sunset",
                name: "Coral Sunset",
                description: "Warm glowing sunset rays and desert horizons",
                price: 180,
                isUnlocked: false,
                backgroundStartColorHex: 0x431407,
                backgroundEndColorHex: 0x9A3412,
                boardBgColorHex: 0x2A0D05,
                boardBorderColorHex: 0x7C2D12
            ),
            ThemeItem(
                id: "underwater_world",
                name: "Underwater World",
                description: "Deep ocean luminescence with vibrant coral reefs",
                price: 200,
                isUnlocked: false,
                backgroundStartColorHex: 0x082F49,
                backgroundEndColorHex: 0x0C4A6E,
                boardBgColorHex: 0x041E33,
                boardBorderColorHex: 0x0369A1
            )
        ]
    }
}

