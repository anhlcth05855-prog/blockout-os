import SwiftUI

public struct HomeScreen: View {
    public let progress: GameProgress
    public let onContinueLevel: (Int) -> Void
    public let onDailyPuzzle: () -> Void
    public let onLevelSelect: () -> Void
    public let onThemes: () -> Void
    public let onMissions: () -> Void
    public let onSettings: () -> Void

    public init(
        progress: GameProgress,
        onContinueLevel: @escaping (Int) -> Void,
        onDailyPuzzle: @escaping () -> Void,
        onLevelSelect: @escaping () -> Void,
        onThemes: @escaping () -> Void,
        onMissions: @escaping () -> Void,
        onSettings: @escaping () -> Void
    ) {
        self.progress = progress
        self.onContinueLevel = onContinueLevel
        self.onDailyPuzzle = onDailyPuzzle
        self.onLevelSelect = onLevelSelect
        self.onThemes = onThemes
        self.onMissions = onMissions
        self.onSettings = onSettings
    }

    public var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color(hex: 0x101226), Color(hex: 0x191B3A), Color(hex: 0x13152C)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Header: Stars, Coins, Settings
                    headerRow()

                    // Title
                    VStack(spacing: 2) {
                        Text("BLOCK OUT!")
                            .font(.system(size: 36, weight: .black, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(colors: [Color(hex: 0xFFB800), Color(hex: 0xFFFF7A00)], startPoint: .top, endPoint: .bottom)
                            )
                            .shadow(color: Color.orange.opacity(0.4), radius: 8, y: 3)

                        Text("COLOR SORT PUZZLE")
                            .font(.system(size: 13, weight: .heavy, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                            .tracking(3)
                    }
                    .padding(.top, 4)

                    // Hero Card
                    heroCard()

                    // Main Action Buttons
                    VStack(spacing: 12) {
                        Button(action: { onContinueLevel(progress.currentLevelId) }) {
                            HStack {
                                Image(systemName: "play.fill")
                                    .font(.system(size: 18, weight: .black))
                                Text("CONTINUE LEVEL \(progress.currentLevelId)")
                                    .font(.system(size: 17, weight: .black, design: .rounded))
                            }
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: 0x00E676), Color(hex: 0x00A855)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .clipShape(Capsule())
                            .shadow(color: Color.green.opacity(0.4), radius: 10, y: 4)
                        }

                        Button(action: onLevelSelect) {
                            HStack {
                                Image(systemName: "square.grid.3x3.fill")
                                Text("SELECT LEVEL")
                                    .font(.system(size: 15, weight: .black, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Capsule().fill(Color.white.opacity(0.12)))
                        }
                    }

                    // Daily Challenge Banner Card
                    dailyChallengeCard()

                    // Quick Nav Bar: Themes & Missions
                    HStack(spacing: 14) {
                        navCard(title: "THEMES", icon: "paintbrush.fill", color: Color(hex: 0xA855F7), action: onThemes)
                        navCard(title: "MISSIONS", icon: "target", color: Color(hex: 0x00A2FF), action: onMissions)
                    }

                    Spacer(minLength: 30)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }
        }
    }

    private func headerRow() -> some View {
        HStack {
            // Stars
            HStack(spacing: 5) {
                Text("★").foregroundColor(Color(hex: 0xFFB800)).font(.system(size: 16))
                Text("\(progress.totalStars)").foregroundColor(.white).font(.system(size: 14, weight: .bold, design: .rounded))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Capsule().fill(Color(hex: 0x1E2142)))

            // Coins
            HStack(spacing: 5) {
                Circle().fill(Color(hex: 0xFFB800)).frame(width: 16, height: 16)
                    .overlay(Text("¢").font(.system(size: 10, weight: .black)).foregroundColor(.black))
                Text("\(progress.totalCoins)").foregroundColor(.white).font(.system(size: 14, weight: .bold, design: .rounded))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Capsule().fill(Color(hex: 0x1E2142)))

            Spacer()

            Button(action: onSettings) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(Color(hex: 0x1E2142)))
            }
        }
    }

    private func heroCard() -> some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("WORLD 1")
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .foregroundColor(Color(hex: 0x00E5FF))
                    Text("Neon Outskirts")
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                }
                Spacer()
                ZStack {
                    Circle().fill(Color(hex: 0xFFB800)).frame(width: 44, height: 44)
                    Text("\(progress.currentLevelId)")
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundColor(.black)
                }
            }

            // Toy block visual preview
            HStack(spacing: 8) {
                ForEach([BlockColor.blue, BlockColor.red, BlockColor.yellow, BlockColor.green], id: \.self) { c in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(c.mainColor)
                        .frame(height: 38)
                        .overlay(
                            Circle().fill(c.lightColor).frame(width: 14, height: 14)
                        )
                }
            }

            // Progress bar
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Progress")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                    Spacer()
                    Text("\(progress.unlockedLevelMax) / 36 Levels")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }

                GeometryReader { g in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.white.opacity(0.1)).frame(height: 8)
                        Capsule()
                            .fill(LinearGradient(colors: [Color(hex: 0x00E5FF), Color(hex: 0x00A2FF)], startPoint: .leading, endPoint: .trailing))
                            .frame(width: g.size.width * CGFloat(progress.unlockedLevelMax) / 36.0, height: 8)
                    }
                }
                .frame(height: 8)
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(hex: 0x1A1C36))
                .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).strokeBorder(Color.white.opacity(0.1), lineWidth: 1.5))
        )
    }

    private func dailyChallengeCard() -> some View {
        Button(action: onDailyPuzzle) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color(hex: 0xFFB800))
                        .frame(width: 48, height: 48)
                    Image(systemName: "calendar")
                        .font(.system(size: 22, weight: .black))
                        .foregroundColor(.black)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("DAILY PUZZLE")
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    Text("Earn +100 Coins & Stars!")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(Color(hex: 0xFFB800))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color(hex: 0x1E203C))
                    .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).strokeBorder(Color(hex: 0xFFB800).opacity(0.4), lineWidth: 1.5))
            )
        }
    }

    private func navCard(title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(color)
                Text(title)
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color(hex: 0x1A1C36))
                    .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).strokeBorder(Color.white.opacity(0.08), lineWidth: 1))
            )
        }
    }
}

