import SwiftUI

// MARK: - Win Dialog
public struct WinDialog: View {
    public let stars: Int
    public let score: Int
    public let coins: Int
    public let movesMade: Int
    public let parMoves: Int
    public let onNextLevel: () -> Void
    public let onReplay: () -> Void
    public let onHome: () -> Void

    @State private var starScales: [CGFloat] = [0, 0, 0]

    public init(
        stars: Int,
        score: Int,
        coins: Int,
        movesMade: Int,
        parMoves: Int,
        onNextLevel: @escaping () -> Void,
        onReplay: @escaping () -> Void,
        onHome: @escaping () -> Void
    ) {
        self.stars = stars
        self.score = score
        self.coins = coins
        self.movesMade = movesMade
        self.parMoves = parMoves
        self.onNextLevel = onNextLevel
        self.onReplay = onReplay
        self.onHome = onHome
    }

    public var body: some View {
        ZStack {
            Color.black.opacity(0.65).ignoresSafeArea()

            VStack(spacing: 18) {
                // Title
                VStack(spacing: 4) {
                    Text("BLOCK OUT!")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom)
                        )
                    Text("LEVEL CLEARED!")
                        .font(.system(size: 13, weight: .heavy, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                        .tracking(2)
                }

                // 3 Stars
                HStack(spacing: 12) {
                    ForEach(0..<3) { idx in
                        Image(systemName: idx < stars ? "star.fill" : "star")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(idx < stars ? Color(hex: 0xFFB800) : .gray.opacity(0.4))
                            .shadow(color: idx < stars ? Color(hex: 0xFFB800).opacity(0.8) : .clear, radius: 8)
                            .scaleEffect(starScales[idx])
                    }
                }

                // Rewards
                HStack(spacing: 20) {
                    statBox(title: "SCORE", value: "\(score)")
                    statBox(title: "COINS", value: "+\(coins)")
                    statBox(title: "MOVES", value: "\(movesMade)/\(parMoves)")
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(RoundedRectangle(cornerRadius: 14).fill(Color.white.opacity(0.06)))

                // Buttons
                VStack(spacing: 10) {
                    Button(action: onNextLevel) {
                        HStack {
                            Text("NEXT LEVEL")
                                .font(.system(size: 15, weight: .black, design: .rounded))
                            Image(systemName: "chevron.right")
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(colors: [Color(hex: 0x00E676), Color(hex: 0x00A855)], startPoint: .top, endPoint: .bottom)
                        )
                        .clipShape(Capsule())
                        .shadow(color: Color.green.opacity(0.4), radius: 8, y: 3)
                    }

                    HStack(spacing: 12) {
                        Button(action: onReplay) {
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.counterclockwise")
                                Text("Replay")
                            }
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Capsule().fill(Color.white.opacity(0.1)))
                        }

                        Button(action: onHome) {
                            HStack(spacing: 4) {
                                Image(systemName: "house.fill")
                                Text("Home")
                            }
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Capsule().fill(Color.white.opacity(0.1)))
                        }
                    }
                }
            }
            .padding(24)
            .frame(maxWidth: 310)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color(hex: 0x16182E))
                    .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).strokeBorder(Color.white.opacity(0.15), lineWidth: 1.5))
                    .shadow(color: .black.opacity(0.6), radius: 20)
            )
        }
        .onAppear {
            for i in 0..<3 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2 + Double(i) * 0.16) {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                        starScales[i] = 1.0
                    }
                }
            }
        }
    }

    private func statBox(title: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
            Text(value)
                .font(.system(size: 16, weight: .black, design: .rounded))
                .foregroundColor(.white)
        }
    }
}

// MARK: - Game Over Dialog
public struct GameOverDialog: View {
    public let movesMade: Int
    public let onAddMoves: () -> Void
    public let onRetry: () -> Void
    public let onHome: () -> Void

    public init(
        movesMade: Int,
        onAddMoves: @escaping () -> Void,
        onRetry: @escaping () -> Void,
        onHome: @escaping () -> Void
    ) {
        self.movesMade = movesMade
        self.onAddMoves = onAddMoves
        self.onRetry = onRetry
        self.onHome = onHome
    }

    public var body: some View {
        ZStack {
            Color.black.opacity(0.65).ignoresSafeArea()

            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundColor(Color(hex: 0xFF334B))

                Text("OUT OF MOVES!")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundColor(.white)

                Text("You've used all \(movesMade) moves. Don't give up!")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)

                // Add +5 Moves button
                Button(action: onAddMoves) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("CONTINUE WITH +5 MOVES")
                            .font(.system(size: 14, weight: .black, design: .rounded))
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(colors: [Color(hex: 0x00E676), Color(hex: 0x00A855)], startPoint: .top, endPoint: .bottom)
                    )
                    .clipShape(Capsule())
                }

                HStack(spacing: 12) {
                    Button(action: onRetry) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Retry")
                        }
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Capsule().fill(Color.white.opacity(0.1)))
                    }

                    Button(action: onHome) {
                        HStack(spacing: 4) {
                            Image(systemName: "house.fill")
                            Text("Home")
                        }
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Capsule().fill(Color.white.opacity(0.1)))
                    }
                }
            }
            .padding(24)
            .frame(maxWidth: 310)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color(hex: 0x16182E))
                    .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).strokeBorder(Color.white.opacity(0.15), lineWidth: 1.5))
            )
        }
    }
}

// MARK: - Settings Dialog
public struct SettingsDialog: View {
    public let soundEnabled: Bool
    public let musicEnabled: Bool
    public let hapticEnabled: Bool
    public let onSoundToggle: (Bool) -> Void
    public let onMusicToggle: (Bool) -> Void
    public let onHapticToggle: (Bool) -> Void
    public let onDismiss: () -> Void

    public init(
        soundEnabled: Bool,
        musicEnabled: Bool,
        hapticEnabled: Bool,
        onSoundToggle: @escaping (Bool) -> Void,
        onMusicToggle: @escaping (Bool) -> Void,
        onHapticToggle: @escaping (Bool) -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.soundEnabled = soundEnabled
        self.musicEnabled = musicEnabled
        self.hapticEnabled = hapticEnabled
        self.onSoundToggle = onSoundToggle
        self.onMusicToggle = onMusicToggle
        self.onHapticToggle = onHapticToggle
        self.onDismiss = onDismiss
    }

    public var body: some View {
        ZStack {
            Color.black.opacity(0.65).ignoresSafeArea()

            VStack(spacing: 18) {
                Text("SETTINGS")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundColor(.white)

                VStack(spacing: 14) {
                    settingToggle(title: "Sound Effects", icon: "speaker.wave.2.fill", isOn: soundEnabled, toggle: onSoundToggle)
                    settingToggle(title: "Music", icon: "music.note", isOn: musicEnabled, toggle: onMusicToggle)
                    settingToggle(title: "Haptic Feedback", icon: "iphone.radiowaves.left.and.right", isOn: hapticEnabled, toggle: onHapticToggle)
                }
                .padding(.vertical, 8)

                Button(action: onDismiss) {
                    Text("DONE")
                        .font(.system(size: 15, weight: .black, design: .rounded))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Capsule().fill(Color(hex: 0xFFB800)))
                }
            }
            .padding(24)
            .frame(maxWidth: 300)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color(hex: 0x16182E))
                    .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).strokeBorder(Color.white.opacity(0.15), lineWidth: 1.5))
            )
        }
    }

    private func settingToggle(title: String, icon: String, isOn: Bool, toggle: @escaping (Bool) -> Void) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(isOn ? Color(hex: 0x00E5FF) : .gray)
                .frame(width: 28)

            Text(title)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Spacer()

            Toggle("", isOn: Binding(get: { isOn }, set: toggle))
                .labelsHidden()
        }
    }
}

