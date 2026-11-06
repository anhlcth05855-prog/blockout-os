import SwiftUI

public struct MissionsScreen: View {
    public let progress: GameProgress
    public let prefManager: PreferencesManager
    public let onProgressUpdated: (GameProgress) -> Void
    public let onBack: () -> Void

    @State private var missions: [Mission] = []

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

                    Text("MISSIONS")
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundColor(.white)

                    Spacer()

                    // Coins
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
                        ForEach(missions) { mission in
                            missionCard(mission: mission)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
        }
        .onAppear {
            loadAndSyncMissions()
        }
    }

    private func missionCard(mission: Mission) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(mission.title)
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    Text(mission.description)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                }

                Spacer()

                // Reward badge
                HStack(spacing: 3) {
                    Circle().fill(Color(hex: 0xFFB800)).frame(width: 12, height: 12)
                    Text("+\(mission.rewardCoins)")
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .foregroundColor(Color(hex: 0xFFB800))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Capsule().fill(Color(hex: 0xFFB800).opacity(0.15)))
            }

            // Progress bar & claim button
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Spacer()
                        Text("\(min(mission.current, mission.target)) / \(mission.target)")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(.white.opacity(0.5))
                    }

                    GeometryReader { g in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color.white.opacity(0.1)).frame(height: 6)
                            Capsule()
                                .fill(LinearGradient(colors: [Color(hex: 0x00E5FF), Color(hex: 0x00E676)], startPoint: .leading, endPoint: .trailing))
                                .frame(width: g.size.width * CGFloat(mission.progressRatio), height: 6)
                        }
                    }
                    .frame(height: 6)
                }

                if mission.isClaimed {
                    Text("CLAIMED")
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .foregroundColor(.gray.opacity(0.6))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(Color.white.opacity(0.06)))
                } else if mission.isComplete {
                    Button(action: {
                        claimReward(missionId: mission.id, coins: mission.rewardCoins)
                    }) {
                        Text("CLAIM")
                            .font(.system(size: 12, weight: .black, design: .rounded))
                            .foregroundColor(.black)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(Color(hex: 0x00E676)))
                            .shadow(color: Color.green.opacity(0.4), radius: 6)
                    }
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(hex: 0x1A1C38))
                .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).strokeBorder(Color.white.opacity(0.08), lineWidth: 1))
        )
    }

    private func loadAndSyncMissions() {
        var list = prefManager.loadMissions()
        // Sync mission progress with current game progress
        for i in list.indices {
            switch list[i].id {
            case "m1": // Solve 3 levels
                list[i].current = progress.starsPerLevel.count
            case "m2": // Solve 10 levels
                list[i].current = progress.starsPerLevel.count
            case "m5": // Amass 15 stars
                list[i].current = progress.totalStars
            default:
                break
            }
        }
        missions = list
        prefManager.saveMissions(list)
    }

    private func claimReward(missionId: String, coins: Int) {
        guard let idx = missions.firstIndex(where: { $0.id == missionId }) else { return }
        missions[idx].isClaimed = true
        prefManager.saveMissions(missions)

        var updated = progress
        updated.totalCoins += coins
        onProgressUpdated(updated)
    }
}

