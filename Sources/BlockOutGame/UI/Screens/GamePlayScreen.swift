import SwiftUI

public struct GamePlayScreen: View {
    public let level: Level
    public let progress: GameProgress
    public let soundManager: SoundManager
    public let onLevelCompleted: (Int, Int, Int, Int) -> Void
    public let onProgressUpdated: (GameProgress) -> Void
    public let onBackToHome: () -> Void
    public let onNextLevel: (Int) -> Void

    @StateObject private var engine: GameEngine
    @State private var remainingSeconds: Int
    @State private var isHammerActive: Bool = false
    @State private var showSettings: Bool = false
    @State private var timerActive: Bool = true

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    public init(
        level: Level,
        progress: GameProgress,
        soundManager: SoundManager,
        onLevelCompleted: @escaping (Int, Int, Int, Int) -> Void,
        onProgressUpdated: @escaping (GameProgress) -> Void,
        onBackToHome: @escaping () -> Void,
        onNextLevel: @escaping (Int) -> Void
    ) {
        self.level = level
        self.progress = progress
        self.soundManager = soundManager
        self.onLevelCompleted = onLevelCompleted
        self.onProgressUpdated = onProgressUpdated
        self.onBackToHome = onBackToHome
        self.onNextLevel = onNextLevel

        _engine = StateObject(wrappedValue: GameEngine(level: level))
        _remainingSeconds = State(initialValue: level.timeSeconds)
    }

    private var activeTheme: ThemeItem {
        let themes = PreferencesManager.shared.getAvailableThemes()
        return themes.first { $0.id == progress.activeThemeId } ?? themes.first!
    }

    public var body: some View {
        ZStack {
            // Theme background gradient
            LinearGradient(
                colors: [activeTheme.backgroundStartColor, activeTheme.backgroundEndColor],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                TopBar(
                    levelName: level.name,
                    difficulty: level.difficulty,
                    totalStars: progress.totalStars,
                    totalCoins: progress.totalCoins,
                    movesMade: engine.movesMade,
                    maxMoves: engine.maxMoves,
                    parMoves: level.parMoves,
                    remainingSeconds: remainingSeconds,
                    onSettingsTapped: {
                        soundManager.playClick()
                        showSettings = true
                    }
                )

                Spacer()

                GameBoardCanvas(
                    engine: engine,
                    activeTheme: activeTheme,
                    isHammerActive: isHammerActive,
                    onMoveMade: {
                        soundManager.playSlide()
                        HapticManager.shared.lightTap()
                    },
                    onBlockEscaped: { block, side in
                        soundManager.playBlockEscape()
                        if engine.comboMultiplier > 1 {
                            soundManager.playCombo(multiplier: engine.comboMultiplier)
                        }
                        HapticManager.shared.mediumTap()
                    },
                    onHammerBlock: { blockId in
                        soundManager.playHammerSmash()
                        HapticManager.shared.heavyTap()
                        _ = engine.applyMove(blockId: blockId, deltaCellsX: -1, deltaCellsY: 0, forceEscape: true)
                        isHammerActive = false
                        var updated = progress
                        updated.hammerCount = max(0, updated.hammerCount - 1)
                        onProgressUpdated(updated)
                    },
                    onHammerObstacle: { obsId in
                        soundManager.playHammerSmash()
                        HapticManager.shared.heavyTap()
                        _ = engine.destroyObstacle(obstacleId: obsId)
                        isHammerActive = false
                        var updated = progress
                        updated.hammerCount = max(0, updated.hammerCount - 1)
                        onProgressUpdated(updated)
                    }
                )
                .padding(.vertical, 6)

                Spacer()

                BoosterBar(
                    undoCount: progress.undoCount,
                    hintCount: progress.hintCount,
                    extraMovesCount: progress.extraMovesCount,
                    hammerCount: progress.hammerCount,
                    isHammerActive: isHammerActive,
                    onUndo: {
                        if progress.undoCount > 0 && engine.undo() {
                            soundManager.playClick()
                            HapticManager.shared.lightTap()
                            var updated = progress
                            updated.undoCount = max(0, updated.undoCount - 1)
                            onProgressUpdated(updated)
                        }
                    },
                    onHint: {
                        if progress.hintCount > 0 {
                            if let hint = engine.findHintMove() {
                                soundManager.playClick()
                                HapticManager.shared.mediumTap()
                                _ = engine.applyMove(blockId: hint.block.id, deltaCellsX: hint.delta.x, deltaCellsY: hint.delta.y)
                                var updated = progress
                                updated.hintCount = max(0, updated.hintCount - 1)
                                onProgressUpdated(updated)
                            }
                        }
                    },
                    onAddMoves: {
                        if progress.extraMovesCount > 0 {
                            soundManager.playClick()
                            HapticManager.shared.mediumTap()
                            engine.addExtraMoves(count: 5)
                            var updated = progress
                            updated.extraMovesCount = max(0, updated.extraMovesCount - 1)
                            onProgressUpdated(updated)
                        }
                    },
                    onHammerToggle: {
                        if progress.hammerCount > 0 {
                            soundManager.playClick()
                            HapticManager.shared.mediumTap()
                            isHammerActive.toggle()
                        }
                    }
                )
            }

            // Win Dialog
            if engine.isWon {
                let stars = engine.starsEarned
                let finalScore = engine.calculateFinalScoreWithTime(remainingSeconds: remainingSeconds)
                let coinsEarned = stars * 25 + (level.id == 9999 ? 100 : 0)

                WinDialog(
                    stars: stars,
                    score: finalScore,
                    coins: coinsEarned,
                    movesMade: engine.movesMade,
                    parMoves: level.parMoves,
                    onNextLevel: {
                        soundManager.playClick()
                        let nextId = level.id == 9999 ? 1 : (level.id % 36 + 1)
                        onLevelCompleted(level.id, stars, coinsEarned, finalScore)
                        onNextLevel(nextId)
                    },
                    onReplay: {
                        soundManager.playClick()
                        onNextLevel(level.id)
                    },
                    onHome: {
                        soundManager.playClick()
                        onLevelCompleted(level.id, stars, coinsEarned, finalScore)
                        onBackToHome()
                    }
                )
            }

            // Game Over Dialog
            if engine.isGameOver && !engine.isWon {
                GameOverDialog(
                    movesMade: engine.movesMade,
                    onAddMoves: {
                        soundManager.playClick()
                        engine.addExtraMoves(count: 5)
                    },
                    onRetry: {
                        soundManager.playClick()
                        onNextLevel(level.id)
                    },
                    onHome: {
                        soundManager.playClick()
                        onBackToHome()
                    }
                )
            }

            // Settings Dialog
            if showSettings {
                SettingsDialog(
                    soundEnabled: soundManager.soundEnabled,
                    musicEnabled: soundManager.musicEnabled,
                    hapticEnabled: soundManager.hapticEnabled,
                    onSoundToggle: { val in
                        soundManager.soundEnabled = val
                        var updated = progress
                        updated.soundEnabled = val
                        onProgressUpdated(updated)
                    },
                    onMusicToggle: { val in
                        soundManager.musicEnabled = val
                        var updated = progress
                        updated.musicEnabled = val
                        onProgressUpdated(updated)
                    },
                    onHapticToggle: { val in
                        soundManager.hapticEnabled = val
                        HapticManager.shared.isEnabled = val
                        var updated = progress
                        updated.hapticEnabled = val
                        onProgressUpdated(updated)
                    },
                    onDismiss: {
                        showSettings = false
                    }
                )
            }
        }
        .onReceive(timer) { _ in
            guard timerActive && !engine.isWon && !engine.isGameOver else { return }
            if remainingSeconds > 0 {
                remainingSeconds -= 1
            } else {
                // Time up = game over
                soundManager.playGameOver()
                HapticManager.shared.warning()
            }
        }
        .onChange(of: engine.isWon) { won in
            if won {
                soundManager.playWin()
                HapticManager.shared.success()
            }
        }
        .onChange(of: engine.isGameOver) { over in
            if over && !engine.isWon {
                soundManager.playGameOver()
                HapticManager.shared.warning()
            }
        }
    }
}

