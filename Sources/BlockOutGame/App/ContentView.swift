import SwiftUI

public enum AppScreen: Equatable {
    case home
    case game(levelId: Int)
    case levelSelect
    case themes
    case missions
}

public struct ContentView: View {
    @StateObject private var prefManager = PreferencesManager.shared
    @StateObject private var soundManager = SoundManager.shared

    @State private var progress: GameProgress = GameProgress()
    @State private var currentScreen: AppScreen = .home
    @State private var showSettingsDialog: Bool = false

    public init() {}

    public var body: some View {
        ZStack {
            Color(hex: 0x101226).ignoresSafeArea()

            switch currentScreen {
            case .home:
                HomeScreen(
                    progress: progress,
                    onContinueLevel: { lvlId in
                        soundManager.playClick()
                        currentScreen = .game(levelId: lvlId)
                    },
                    onDailyPuzzle: { _ in
                        soundManager.playClick()
                        currentScreen = .game(levelId: 9999)
                    },
                    onLevelSelect: {
                        soundManager.playClick()
                        currentScreen = .levelSelect
                    },
                    onThemes: {
                        soundManager.playClick()
                        currentScreen = .themes
                    },
                    onMissions: {
                        soundManager.playClick()
                        currentScreen = .missions
                    },
                    onSettings: {
                        soundManager.playClick()
                        showSettingsDialog = true
                    }
                )

            case .game(let levelId):
                let level = (levelId == 9999)
                    ? LevelRepository.getDailyPuzzle()
                    : LevelRepository.getLevel(id: levelId)

                GamePlayScreen(
                    level: level,
                    progress: progress,
                    soundManager: soundManager,
                    onLevelCompleted: { lvlId, stars, coins, score in
                        var updatedStars = progress.starsPerLevel
                        let existingStars = updatedStars[lvlId] ?? 0
                        if stars > existingStars {
                            updatedStars[lvlId] = stars
                        }

                        let newMax = (lvlId < 9999 && lvlId >= progress.unlockedLevelMax)
                            ? lvlId + 1
                            : progress.unlockedLevelMax

                        var updatedHighScores = progress.highScoresPerLevel
                        let prevHigh = updatedHighScores[lvlId] ?? 0
                        if score > prevHigh {
                            updatedHighScores[lvlId] = score
                        }

                        let updated = GameProgress(
                            currentLevelId: (lvlId < 9999) ? lvlId + 1 : progress.currentLevelId,
                            unlockedLevelMax: newMax,
                            starsPerLevel: updatedStars,
                            highScoresPerLevel: updatedHighScores,
                            totalScore: progress.totalScore + score,
                            totalCoins: progress.totalCoins + coins,
                            totalStars: updatedStars.values.reduce(0, +),
                            undoCount: progress.undoCount,
                            hintCount: progress.hintCount,
                            extraMovesCount: progress.extraMovesCount,
                            hammerCount: progress.hammerCount,
                            activeThemeId: progress.activeThemeId,
                            soundEnabled: progress.soundEnabled,
                            musicEnabled: progress.musicEnabled,
                            hapticEnabled: progress.hapticEnabled
                        )
                        updateProgress(updated)
                    },
                    onProgressUpdated: { updated in
                        updateProgress(updated)
                    },
                    onBackToHome: {
                        soundManager.playClick()
                        currentScreen = .home
                    },
                    onNextLevel: { nextId in
                        currentScreen = .game(levelId: nextId)
                    }
                )

            case .levelSelect:
                LevelSelectScreen(
                    progress: progress,
                    onLevelSelected: { lvlId in
                        soundManager.playClick()
                        currentScreen = .game(levelId: lvlId)
                    },
                    onBack: {
                        soundManager.playClick()
                        currentScreen = .home
                    }
                )

            case .themes:
                ThemesScreen(
                    progress: progress,
                    prefManager: prefManager,
                    onProgressUpdated: { updated in
                        updateProgress(updated)
                    },
                    onBack: {
                        soundManager.playClick()
                        currentScreen = .home
                    }
                )

            case .missions:
                MissionsScreen(
                    progress: progress,
                    prefManager: prefManager,
                    onProgressUpdated: { updated in
                        updateProgress(updated)
                    },
                    onBack: {
                        soundManager.playClick()
                        currentScreen = .home
                    }
                )
            }

            if showSettingsDialog {
                SettingsDialog(
                    soundEnabled: soundManager.soundEnabled,
                    musicEnabled: soundManager.musicEnabled,
                    hapticEnabled: soundManager.hapticEnabled,
                    onSoundToggle: { val in
                        var updated = progress
                        updated.soundEnabled = val
                        updateProgress(updated)
                    },
                    onMusicToggle: { val in
                        var updated = progress
                        updated.musicEnabled = val
                        updateProgress(updated)
                    },
                    onHapticToggle: { val in
                        var updated = progress
                        updated.hapticEnabled = val
                        updateProgress(updated)
                    },
                    onDismiss: {
                        showSettingsDialog = false
                    }
                )
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            let loaded = prefManager.loadProgress()
            self.progress = loaded
            soundManager.soundEnabled = loaded.soundEnabled
            soundManager.musicEnabled = loaded.musicEnabled
            soundManager.hapticEnabled = loaded.hapticEnabled
            HapticManager.shared.isEnabled = loaded.hapticEnabled
        }
    }

    private func updateProgress(_ newProgress: GameProgress) {
        progress = newProgress
        prefManager.saveProgress(newProgress)
        soundManager.soundEnabled = newProgress.soundEnabled
        soundManager.musicEnabled = newProgress.musicEnabled
        soundManager.hapticEnabled = newProgress.hapticEnabled
        HapticManager.shared.isEnabled = newProgress.hapticEnabled
    }
}

