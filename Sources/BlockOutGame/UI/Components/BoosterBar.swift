import SwiftUI

public struct BoosterBar: View {
    public let undoCount: Int
    public let hintCount: Int
    public let extraMovesCount: Int
    public let hammerCount: Int
    public let isHammerActive: Bool
    public let onUndo: () -> Void
    public let onHint: () -> Void
    public let onAddMoves: () -> Void
    public let onHammerToggle: () -> Void

    public init(
        undoCount: Int,
        hintCount: Int,
        extraMovesCount: Int,
        hammerCount: Int,
        isHammerActive: Bool,
        onUndo: @escaping () -> Void,
        onHint: @escaping () -> Void,
        onAddMoves: @escaping () -> Void,
        onHammerToggle: @escaping () -> Void
    ) {
        self.undoCount = undoCount
        self.hintCount = hintCount
        self.extraMovesCount = extraMovesCount
        self.hammerCount = hammerCount
        self.isHammerActive = isHammerActive
        self.onUndo = onUndo
        self.onHint = onHint
        self.onAddMoves = onAddMoves
        self.onHammerToggle = onHammerToggle
    }

    public var body: some View {
        VStack(spacing: 6) {
            if isHammerActive {
                Text("Tap any block or rock to smash it!")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.yellow)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.yellow.opacity(0.18)))
                    .transition(.scale.combined(with: .opacity))
            }

            HStack(spacing: 20) {
                boosterButton(
                    icon: "arrow.uturn.backward",
                    label: "Undo",
                    count: undoCount,
                    isActive: false,
                    color: Color(hex: 0x00E5FF),
                    action: onUndo
                )

                boosterButton(
                    icon: "lightbulb.fill",
                    label: "Hint",
                    count: hintCount,
                    isActive: false,
                    color: Color(hex: 0xFFB800),
                    action: onHint
                )

                boosterButton(
                    icon: "plus.circle.fill",
                    label: "+5 Moves",
                    count: extraMovesCount,
                    isActive: false,
                    color: Color(hex: 0x00E676),
                    action: onAddMoves
                )

                boosterButton(
                    icon: "hammer.fill",
                    label: "Hammer",
                    count: hammerCount,
                    isActive: isHammerActive,
                    color: Color(hex: 0xFFFF7A00),
                    action: onHammerToggle
                )
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color(hex: 0x14162B).opacity(0.95))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.4), radius: 10, y: 5)
            )
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
    }

    private func boosterButton(
        icon: String,
        label: String,
        count: Int,
        isActive: Bool,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 3) {
                ZStack(alignment: .topTrailing) {
                    Circle()
                        .fill(isActive ? color : Color.white.opacity(0.08))
                        .frame(width: 48, height: 48)
                        .overlay(
                            Circle()
                                .strokeBorder(isActive ? Color.white : color.opacity(0.4), lineWidth: 2)
                        )

                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(isActive ? .black : color)
                        .frame(width: 48, height: 48)

                    Text("\(count)")
                        .font(.system(size: 10, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(color))
                        .offset(x: 4, y: -4)
                }

                Text(label)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .disabled(count <= 0 && !isActive)
    }
}

