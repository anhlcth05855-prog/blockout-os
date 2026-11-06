import SwiftUI

public struct ThemesScreen: View {
    public let progress: GameProgress
    public let prefManager: PreferencesManager
    public let onProgressUpdated: (GameProgress) -> Void
    public let onBack: () -> Void

    @State private var unlockedThemeIds: Set<String> = ["midnight_glow"]

    public init(
        progress: GameProgress,
        prefManager: PreferencesManager,
        onProgressUpdated: @escaping (GameProgress) -> Void,
        onBack: @escaping () -> Void
    ) {
        self.progress = progress
        self.prefManager = prefManager
        self.onProgressUpdated = onProgressUpdated
        self.onBack = onBack
    }

    public var body: some View {
        let themes = prefManager.getAvailableThemes()

        ZStack {
            LinearGradient(
                colors: [Color(hex: 0x101226), Color(hex: 0x161836), Color(hex: 0x0F1020)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 16) {
                // Top Bar
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(Color.white.opacity(0.1)))
                    }

                    Spacer()

                    Text("THEMES SHOP")
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundColor(.white)

                    Spacer()

                    // Coins badge
                    HStack(spacing: 4) {
                        Circle().fill(Color(hex: 0xFFB800)).frame(width: 14, height: 14)
                            .overlay(Text("¢").font(.system(size: 9, weight: .black)).foregroundColor(.black))
                        Text("\(progress.totalCoins)")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color(hex: 0x1E2142)))
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                ScrollView {
                    VStack(spacing: 14) {
                        ForEach(themes) { theme in
                            themeCard(theme: theme)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
        }
        .onAppear {
            loadUnlocked()
        }
    }

    private func themeCard(theme: ThemeItem) -> some View {
        let isUnlocked = unlockedThemeIds.contains(theme.id) || theme.price == 0
        let isApplied = progress.activeThemeId == theme.id

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(theme.name)
                        .font(.system(size: 17, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    Text(theme.description)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                }

                Spacer()

                // Color palette circles
                HStack(spacing: 5) {
                    Circle().fill(theme.backgroundStartColor).frame(width: 22, height: 22)
                    Circle().fill(theme.backgroundEndColor).frame(width: 22, height: 22)
                    Circle().fill(theme.boardBorderColor).frame(width: 22, height: 22)
                }
            }

            // Action row
            HStack {
                Spacer()

                if isApplied {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                        Text("APPLIED")
                    }
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundColor(Color(hex: 0x00E676))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(Capsule().fill(Color(hex: 0x00E676).opacity(0.18)))
                } else if isUnlocked {
                    Button(action: {
                        var updated = progress
                        updated.activeThemeId = theme.id
                        onProgressUpdated(updated)
                    }) {
                        Text("APPLY")
                            .font(.system(size: 12, weight: .black, design: .rounded))
                            .foregroundColor(.black)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(Color(hex: 0x00E5FF)))
                    }
                } else {
                    Button(action: {
                        if progress.totalCoins >= theme.price {
                            var updated = progress
                            updated.totalCoins -= theme.price
                            updated.activeThemeId = theme.id
                            unlockedThemeIds.insert(theme.id)
                            saveUnlocked()
                            onProgressUpdated(updated)
                        }
                    }) {
                        HStack(spacing: 4) {
                            Text("UNLOCK FOR")
                            Circle().fill(Color(hex: 0xFFB800)).frame(width: 12, height: 12)
                            Text("\(theme.price)")
                        }
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .foregroundColor(progress.totalCoins >= theme.price ? .black : .gray)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule().fill(progress.totalCoins >= theme.price ? Color(hex: 0xFFB800) : Color.white.opacity(0.1))
                        )
                    }
                    .disabled(progress.totalCoins < theme.price)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(hex: 0x1A1C38))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(isApplied ? Color(hex: 0x00E676) : Color.white.opacity(0.1), lineWidth: isApplied ? 2 : 1)
                )
        )
    }

    private func loadUnlocked() {
        if let saved = UserDefaults.standard.stringArray(forKey: "unlocked_themes") {
            unlockedThemeIds = Set(saved)
        }
        unlockedThemeIds.insert("midnight_glow")
    }

    private func saveUnlocked() {
        UserDefaults.standard.set(Array(unlockedThemeIds), forKey: "unlocked_themes")
    }
}

