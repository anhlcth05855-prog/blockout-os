import SwiftUI

public struct TopBar: View {
    public let levelName: String
    public let difficulty: String
    public let totalStars: Int
    public let totalCoins: Int
    public let movesMade: Int
    public let maxMoves: Int
    public let parMoves: Int
    public let remainingSeconds: Int
    public let onSettingsTapped: () -> Void

    public init(
        levelName: String,
        difficulty: String,
        totalStars: Int,
        totalCoins: Int,
        movesMade: Int,
        maxMoves: Int,
        parMoves: Int,
        remainingSeconds: Int,
        onSettingsTapped: @escaping () -> Void
    ) {
        self.levelName = levelName
        self.difficulty = difficulty
        self.totalStars = totalStars
        self.totalCoins = totalCoins
        self.movesMade = movesMade
        self.maxMoves = maxMoves
        self.parMoves = parMoves
        self.remainingSeconds = remainingSeconds
        self.onSettingsTapped = onSettingsTapped
    }

    private var formattedTime: String {
        let m = remainingSeconds / 60
        let s = remainingSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    public var body: some View {
        VStack(spacing: 8) {
            // Upper row: Stars, Coins, Settings
            HStack(spacing: 10) {
                // Stars pill
                HStack(spacing: 4) {
                    Text("★")
                        .foregroundColor(Color(hex: 0xFFB800))
                        .font(.system(size: 15, weight: .bold))
                    Text("\(totalStars)")
                        .foregroundColor(.white)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Capsule().fill(Color(hex: 0x1E2142)))

                // Coins pill
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color(hex: 0xFFB800))
                        .frame(width: 14, height: 14)
                        .overlay(Text("¢").font(.system(size: 9, weight: .black)).foregroundColor(.black))
                    Text("\(totalCoins)")
                        .foregroundColor(.white)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Capsule().fill(Color(hex: 0x1E2142)))

                Spacer()

                // Timer pill
                HStack(spacing: 4) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 12))
                        .foregroundColor(remainingSeconds < 30 ? .red : Color(hex: 0x00E5FF))
                    Text(formattedTime)
                        .foregroundColor(remainingSeconds < 30 ? .red : .white)
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Capsule().fill(Color(hex: 0x1E2142)))

                // Settings button
                Button(action: onSettingsTapped) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(Color(hex: 0x1E2142)))
                }
            }

            // Lower row: Level title + difficulty & Moves bar
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(levelName)
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundColor(.white)

                    Text(difficulty)
                        .font(.system(size: 10, weight: .heavy, design: .rounded))
                        .foregroundColor(diffColor)
                }

                Spacer()

                // Moves counter
                VStack(alignment: .trailing, spacing: 2) {
                    HStack(spacing: 4) {
                        Text("MOVES")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundColor(.white.opacity(0.6))
                        Text("\(movesMade)")
                            .font(.system(size: 16, weight: .black, design: .rounded))
                            .foregroundColor(movesMade <= parMoves ? .green : (movesMade >= maxMoves ? .red : .yellow))
                        Text("/ \(maxMoves)")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(0.4))
                    }

                    // 3-star thresholds indicator
                    HStack(spacing: 3) {
                        Text("★")
                            .font(.system(size: 10))
                            .foregroundColor(movesMade <= parMoves ? Color(hex: 0xFFB800) : .gray.opacity(0.4))
                        Text("★")
                            .font(.system(size: 10))
                            .foregroundColor(movesMade <= (parMoves + max(1, (maxMoves - parMoves) / 2)) ? Color(hex: 0xFFB800) : .gray.opacity(0.4))
                        Text("★")
                            .font(.system(size: 10))
                            .foregroundColor(movesMade < maxMoves ? Color(hex: 0xFFB800) : .gray.opacity(0.4))
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 6)
    }

    private var diffColor: Color {
        switch difficulty {
        case "EASY": return Color(hex: 0x00E676)
        case "NORMAL": return Color(hex: 0x00A2FF)
        case "ADEPT": return Color(hex: 0xFFB800)
        case "HARD": return Color(hex: 0xFF7A00)
        case "SUPER HARD": return Color(hex: 0xFF334B)
        default: return .white
        }
    }
}

