import SwiftUI

public struct Particle: Identifiable {
    public let id = UUID()
    public var x: CGFloat
    public var y: CGFloat
    public var vx: CGFloat
    public var vy: CGFloat
    public var size: CGFloat
    public var rotation: Double
    public var vRot: Double
    public let color: Color
    public var alpha: Double = 1.0
    public var life: Double = 1.0
}

public struct FloatingScore: Identifiable {
    public let id = UUID()
    public let text: String
    public var x: CGFloat
    public var y: CGFloat
    public let color: Color
    public var offsetY: CGFloat = 0
    public var alpha: Double = 1.0
    public var life: Double = 1.0
}

public struct GameBoardCanvas: View {
    @ObservedObject var engine: GameEngine
    public let activeTheme: ThemeItem
    public let isHammerActive: Bool
    public let onMoveMade: () -> Void
    public let onBlockEscaped: (Block, ExitSide) -> Void
    public let onHammerBlock: (String) -> Void
    public let onHammerObstacle: (String) -> Void

    @State private var activeBlockId: String? = nil
    @State private var dragOffset: CGSize = .zero
    @State private var particles: [Particle] = []
    @State private var floatingScores: [FloatingScore] = []
    @State private var chevronPulse: CGFloat = 0

    private let doorThickness: CGFloat = 26
    private let spacing: CGFloat = 4

    public init(
        engine: GameEngine,
        activeTheme: ThemeItem,
        isHammerActive: Bool = false,
        onMoveMade: @escaping () -> Void,
        onBlockEscaped: @escaping (Block, ExitSide) -> Void,
        onHammerBlock: @escaping (String) -> Void,
        onHammerObstacle: @escaping (String) -> Void
    ) {
        self.engine = engine
        self.activeTheme = activeTheme
        self.isHammerActive = isHammerActive
        self.onMoveMade = onMoveMade
        self.onBlockEscaped = onBlockEscaped
        self.onHammerBlock = onHammerBlock
        self.onHammerObstacle = onHammerObstacle
    }

    public var body: some View {
        GeometryReader { proxy in
            let availableW = proxy.size.width - 24
            let availableH = proxy.size.height - 24

            let cols = CGFloat(engine.gridWidth)
            let rows = CGFloat(engine.gridHeight)

            let maxCellW = (availableW - doorThickness * 2 - spacing * (cols - 1)) / cols
            let maxCellH = (availableH - doorThickness * 2 - spacing * (rows - 1)) / rows
            let cellSize = max(36, min(56, min(maxCellW, maxCellH)))

            let gridW = cols * cellSize + (cols - 1) * spacing
            let gridH = rows * cellSize + (rows - 1) * spacing
            let totalW = gridW + doorThickness * 2 + 16
            let totalH = gridH + doorThickness * 2 + 16

            ZStack {
                // Outer board border
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(activeTheme.boardBgColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .strokeBorder(activeTheme.boardBorderColor, lineWidth: 2)
                    )
                    .shadow(color: Color.black.opacity(0.5), radius: 14, x: 0, y: 8)
                    .frame(width: totalW, height: totalH)

                // Exit Doors on 4 sides
                doorsLayer(cellSize: cellSize, gridW: gridW, gridH: gridH)

                // Recessed grid slots
                gridSlotsLayer(cols: Int(cols), rows: Int(rows), cellSize: cellSize)
                    .frame(width: gridW, height: gridH)

                // Obstacles (Rocks)
                obstaclesLayer(cellSize: cellSize, gridW: gridW, gridH: gridH)

                // Blocks layer
                blocksLayer(cellSize: cellSize, gridW: gridW, gridH: gridH)

                // Particles layer
                particlesLayer()

                // Floating scores layer
                floatingScoresLayer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                chevronPulse = 4
            }
        }
    }

    // MARK: - Doors Layer
    @ViewBuilder
    private func doorsLayer(cellSize: CGFloat, gridW: CGFloat, gridH: CGFloat) -> some View {
        ForEach(engine.doors) { door in
            let span = CGFloat(door.widthCells)
            let length = span * cellSize + (span - 1) * spacing
            let offsetStart = CGFloat(door.index) * (cellSize + spacing) + length / 2

            switch door.side {
            case .top:
                doorView(door: door, length: length, thickness: doorThickness, isHorizontal: true, arrow: "chevron.up")
                    .position(x: offsetStart + doorThickness + 8, y: doorThickness / 2 + 4)
            case .bottom:
                doorView(door: door, length: length, thickness: doorThickness, isHorizontal: true, arrow: "chevron.down")
                    .position(x: offsetStart + doorThickness + 8, y: gridH + doorThickness + doorThickness / 2 + 12)
            case .left:
                doorView(door: door, length: length, thickness: doorThickness, isHorizontal: false, arrow: "chevron.left")
                    .position(x: doorThickness / 2 + 4, y: offsetStart + doorThickness + 8)
            case .right:
                doorView(door: door, length: length, thickness: doorThickness, isHorizontal: false, arrow: "chevron.right")
                    .position(x: gridW + doorThickness + doorThickness / 2 + 12, y: offsetStart + doorThickness + 8)
            }
        }
    }

    private func doorView(door: ExitDoor, length: CGFloat, thickness: CGFloat, isHorizontal: Bool, arrow: String) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [door.color.mainColor.opacity(0.9), door.color.darkColor],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: door.color.mainColor.opacity(0.8), radius: 8)

            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .strokeBorder(Color.white.opacity(0.4), lineWidth: 1.5)

            // Chevrons
            if isHorizontal {
                HStack(spacing: 6) {
                    ForEach(0..<max(1, door.widthCells), id: \.self) { _ in
                        Image(systemName: arrow)
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(.white)
                            .offset(y: door.side == .top ? -chevronPulse : chevronPulse)
                    }
                }
            } else {
                VStack(spacing: 6) {
                    ForEach(0..<max(1, door.widthCells), id: \.self) { _ in
                        Image(systemName: arrow)
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(.white)
                            .offset(x: door.side == .left ? -chevronPulse : chevronPulse)
                    }
                }
            }
        }
        .frame(width: isHorizontal ? length : thickness, height: isHorizontal ? thickness : length)
    }

    // MARK: - Grid Slots
    private func gridSlotsLayer(cols: Int, rows: Int, cellSize: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(hex: 0x0A0B14).opacity(0.85))

            VStack(spacing: spacing) {
                ForEach(0..<rows, id: \.self) { _ in
                    HStack(spacing: spacing) {
                        ForEach(0..<cols, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(Color.white.opacity(0.04))
                                .overlay(
                                    Circle()
                                        .fill(Color.white.opacity(0.03))
                                        .frame(width: cellSize * 0.35, height: cellSize * 0.35)
                                )
                                .frame(width: cellSize, height: cellSize)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Obstacles Layer
    private func obstaclesLayer(cellSize: CGFloat, gridW: CGFloat, gridH: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            ForEach(engine.obstacles.filter { !$0.isDestroyed }) { obs in
                let w = CGFloat(obs.width) * cellSize + CGFloat(obs.width - 1) * spacing
                let h = CGFloat(obs.height) * cellSize + CGFloat(obs.height - 1) * spacing
                let x = CGFloat(obs.x) * (cellSize + spacing)
                let y = CGFloat(obs.y) * (cellSize + spacing)

                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: 0x475569), Color(hex: 0x1E293B)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .strokeBorder(Color.white.opacity(0.2), lineWidth: 1.5)
                        )
                        .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 3)

                    Image(systemName: "mountain.2.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(hex: 0x94A3B8))

                    if isHammerActive {
                        Image(systemName: "hammer.fill")
                            .font(.system(size: 24, weight: .black))
                            .foregroundColor(.yellow)
                            .shadow(color: .black, radius: 4)
                    }
                }
                .frame(width: w, height: h)
                .offset(x: x, y: y)
                .onTapGesture {
                    if isHammerActive {
                        onHammerObstacle(obs.id)
                    }
                }
            }
        }
        .frame(width: gridW, height: gridH, alignment: .topLeading)
    }

    // MARK: - Blocks Layer
    private func blocksLayer(cellSize: CGFloat, gridW: CGFloat, gridH: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            ForEach(engine.blocks) { block in
                let isDragging = activeBlockId == block.id
                let blockW = CGFloat(block.width) * cellSize + CGFloat(block.width - 1) * spacing
                let blockH = CGFloat(block.height) * cellSize + CGFloat(block.height - 1) * spacing

                let posX = CGFloat(block.x) * (cellSize + spacing) + (isDragging ? dragOffset.width : 0)
                let posY = CGFloat(block.y) * (cellSize + spacing) + (isDragging ? dragOffset.height : 0)

                legoBlockView(block: block, width: blockW, height: blockH, cellSize: cellSize)
                    .frame(width: blockW, height: blockH)
                    .offset(x: posX, y: posY)
                    .scaleEffect(block.isEscaped ? 0.05 : (isDragging ? 1.04 : 1.0))
                    .opacity(block.isEscaped ? 0 : 1)
                    .animation(.spring(response: 0.28, dampingFraction: 0.72), value: block.x)
                    .animation(.spring(response: 0.28, dampingFraction: 0.72), value: block.y)
                    .animation(.easeOut(duration: 0.35), value: block.isEscaped)
                    .onTapGesture {
                        if isHammerActive {
                            onHammerBlock(block.id)
                        } else {
                            // Quick escape tap
                            if let res = engine.tryQuickEscape(blockId: block.id) {
                                triggerEscapeEffects(block: block, side: res.escapeSide ?? .top, cellSize: cellSize)
                                onMoveMade()
                            }
                        }
                    }
                    .gesture(
                        DragGesture(minimumDistance: 10)
                            .onChanged { value in
                                guard !isHammerActive && !block.isEscaped else { return }
                                activeBlockId = block.id

                                // Constrain translation to valid direction
                                var t = value.translation
                                if block.direction == .horizontal {
                                    t.height = 0
                                } else if block.direction == .vertical {
                                    t.width = 0
                                }
                                dragOffset = t
                            }
                            .onEnded { value in
                                guard !isHammerActive && !block.isEscaped else {
                                    activeBlockId = nil
                                    dragOffset = .zero
                                    return
                                }

                                let deltaCellsX = Float(dragOffset.width / (cellSize + spacing))
                                let deltaCellsY = Float(dragOffset.height / (cellSize + spacing))

                                activeBlockId = nil
                                dragOffset = .zero

                                let isFling = abs(value.velocity.width) > 500 || abs(value.velocity.height) > 500
                                if let res = engine.applyMove(
                                    blockId: block.id,
                                    deltaCellsX: deltaCellsX,
                                    deltaCellsY: deltaCellsY,
                                    isFling: isFling
                                ) {
                                    if res.escaped, let side = res.escapeSide {
                                        triggerEscapeEffects(block: block, side: side, cellSize: cellSize)
                                    }
                                    onMoveMade()
                                }
                            }
                    )
            }
        }
        .frame(width: gridW, height: gridH, alignment: .topLeading)
    }

    // MARK: - Lego 3D Block View
    private func legoBlockView(block: Block, width: CGFloat, height: CGFloat, cellSize: CGFloat) -> some View {
        ZStack {
            // Drop shadow base
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(block.color.darkColor)
                .offset(y: 4)

            // Main face gradient
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [block.color.lightColor.opacity(0.85), block.color.mainColor, block.color.darkColor],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            // Bevel gloss rim
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [Color.white.opacity(0.6), Color.clear, Color.black.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )

            // Studs for each cell in block
            VStack(spacing: spacing) {
                ForEach(0..<block.height, id: \.self) { _ in
                    HStack(spacing: spacing) {
                        ForEach(0..<block.width, id: \.self) { _ in
                            studView(color: block.color, symbol: block.symbol, size: cellSize * 0.44)
                                .frame(width: cellSize, height: cellSize)
                        }
                    }
                }
            }

            if isHammerActive {
                Image(systemName: "hammer.fill")
                    .font(.system(size: 26, weight: .black))
                    .foregroundColor(.yellow)
                    .shadow(color: .black, radius: 4)
            }
        }
    }

    private func studView(color: BlockColor, symbol: String?, size: CGFloat) -> some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [color.lightColor, color.studColor],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(Circle().strokeBorder(Color.white.opacity(0.4), lineWidth: 1))
                .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1.5)
                .frame(width: size, height: size)

            if let sym = symbol {
                symbolIcon(sym)
                    .font(.system(size: size * 0.5, weight: .black))
                    .foregroundColor(Color.white.opacity(0.9))
            }
        }
    }

    @ViewBuilder
    private func symbolIcon(_ sym: String) -> some View {
        switch sym {
        case "star": Image(systemName: "star.fill")
        case "diamond": Image(systemName: "suit.diamond.fill")
        case "square": Image(systemName: "square.fill")
        case "circle": Image(systemName: "circle.fill")
        case "cross": Image(systemName: "plus")
        default: Image(systemName: "sparkle")
        }
    }

    // MARK: - Particles & Effects
    private func triggerEscapeEffects(block: Block, side: ExitSide, cellSize: CGFloat) {
        let spawnX = CGFloat(block.x) * (cellSize + spacing) + CGFloat(block.width) * cellSize / 2
        let spawnY = CGFloat(block.y) * (cellSize + spacing) + CGFloat(block.height) * cellSize / 2

        // Add 16 colorful spark particles
        for _ in 0..<16 {
            let p = Particle(
                x: spawnX,
                y: spawnY,
                vx: CGFloat.random(in: -4...4),
                vy: CGFloat.random(in: -5...2),
                size: CGFloat.random(in: 6...12),
                rotation: Double.random(in: 0...Double.pi * 2),
                vRot: Double.random(in: -0.2...0.2),
                color: block.color.mainColor
            )
            particles.append(p)
        }

        // Add floating score text
        let pts = block.width * block.height * 100 * engine.comboMultiplier
        let comboText = engine.comboMultiplier > 1 ? "+\(pts) (x\(engine.comboMultiplier) COMBO!)" : "+\(pts)"
        floatingScores.append(FloatingScore(text: comboText, x: spawnX, y: spawnY, color: block.color.lightColor))

        // Trigger loop updates
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.016) {
            animateEffects()
        }
    }

    private func animateEffects() {
        guard !particles.isEmpty || !floatingScores.isEmpty else { return }

        for i in particles.indices.reversed() {
            particles[i].x += particles[i].vx
            particles[i].y += particles[i].vy
            particles[i].vy += 0.35 // Gravity
            particles[i].rotation += particles[i].vRot
            particles[i].life -= 0.04
            particles[i].alpha = max(0, particles[i].life)
            if particles[i].life <= 0 {
                particles.remove(at: i)
            }
        }

        for i in floatingScores.indices.reversed() {
            floatingScores[i].offsetY -= 2
            floatingScores[i].life -= 0.03
            floatingScores[i].alpha = max(0, floatingScores[i].life)
            if floatingScores[i].life <= 0 {
                floatingScores.remove(at: i)
            }
        }

        if !particles.isEmpty || !floatingScores.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.016) {
                animateEffects()
            }
        }
    }

    private func particlesLayer() -> some View {
        Canvas { context, _ in
            for p in particles {
                let rect = CGRect(x: p.x, y: p.y, width: p.size, height: p.size)
                var t = CGAffineTransform.identity
                t = t.translatedBy(x: rect.midX, y: rect.midY)
                t = t.rotated(by: p.rotation)
                t = t.translatedBy(x: -rect.midX, y: -rect.midY)

                context.concatenate(t)
                context.fill(Path(rect), with: .color(p.color.opacity(p.alpha)))
                context.concatenate(t.inverted())
            }
        }
        .allowsHitTesting(false)
    }

    private func floatingScoresLayer() -> some View {
        ZStack {
            ForEach(floatingScores) { score in
                Text(score.text)
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundColor(score.color)
                    .shadow(color: .black, radius: 4)
                    .position(x: score.x, y: score.y + score.offsetY)
                    .opacity(score.alpha)
            }
        }
        .allowsHitTesting(false)
    }
}

