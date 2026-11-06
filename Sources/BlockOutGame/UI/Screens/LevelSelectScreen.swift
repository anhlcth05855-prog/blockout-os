import SwiftUI

public struct LevelSelectScreen: View {
    public let progress: GameProgress
    public let onLevelSelected: (Int) -> Void
    public let onBack: () -> Void

    private let columns = [
        GridItem(.adaptive(minimum: 80, maximum: 100), spacing: 14)
    ]

    public init(
        progress: GameProgress,
        onLevelSelected: @escaping (Int) -> Void,
        onBack: @escaping () -> Void
    ) {
        self.progress = progress
        self.onLevelSelected = onLevelSelected
        self.onBack = onBack
    }

    public var body: some View {
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

                    Text("LEVEL SELECT")
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundColor(.white)

                    Spacer()

                    // Balance placeholder for centering
                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                ScrollView {
                    VStack(spacing: 18) {
                        // Daily Challenge Card
                        Button(action: { onLevelSelected(9999) }) {
                            HStack(spacing: 12) {
                                Image(systemName: "calendar.badge.clock")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(Color(hex: 0xFFB800))

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("DAILY CHALLENGE")
                                        .font(.system(size: 15, weight: .black, design: .rounded))
                                        .foregroundColor(.white)
                                    Text("Special reward: +100 Coins & Stars")
                                        .font(.system(size: 11, weight: .medium, design: .rounded))
                                        .foregroundColor(Color(hex: 0xFFB800))
                                }

                                Spacer()

                                Image(systemName: "play.circle.fill")
                                    .font(.system(size: 26))
                                    .foregroundColor(Color(hex: 0x00E676))
                            }
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(Color(hex: 0x1F2242))
                                    .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).strokeBorder(Color(hex: 0xFFB800).opacity(0.4), lineWidth: 1.5))
                            )
                        }

                        // Grid of 36 Levels
                        LazyVGrid(columns: columns, spacing: 14) {
                            ForEach(1...36, id: \.self) { lvlId in
                                levelCell(lvlId: lvlId)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
        }
    }

    private func levelCell(lvlId: Int) -> some View {
        let isUnlocked = lvlId <= progress.unlockedLevelMax
        let stars = progress.starsPerLevel[lvlId] ?? 0
        let isCurrent = lvlId == progress.currentLevelId

        return Button(action: {
            if isUnlocked {
                onLevelSelected(lvlId)
            }
        }) {
            VStack(spacing: 4) {
                if isUnlocked {
                    Text("\(lvlId)")
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundColor(isCurrent ? .black : .white)

                    HStack(spacing: 2) {
                        ForEach(0..<3) { s in
                            Text("★")
                                .font(.system(size: 10))
                                .foregroundColor(s < stars ? Color(hex: 0xFFB800) : (isCurrent ? .black.opacity(0.3) : .white.opacity(0.2)))
                        }
                    }
                } else {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.gray.opacity(0.5))
                    Text("\(lvlId)")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(.gray.opacity(0.4))
                }
            }
            .frame(height: 74)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        isCurrent
                        ? Color(hex: 0xFFB800)
                        : (isUnlocked ? Color(hex: 0x1D203C) : Color.white.opacity(0.04))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(
                                isCurrent
                                ? Color.white
                                : (isUnlocked ? Color.white.opacity(0.12) : Color.clear),
                                lineWidth: isCurrent ? 2 : 1
                            )
                    )
            )
        }
        .disabled(!isUnlocked)
    }
}

