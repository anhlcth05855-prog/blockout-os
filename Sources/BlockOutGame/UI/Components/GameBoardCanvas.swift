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
    @State private var currentLimits: DragLimits? = nil
    @State private var dragPixelX: CGFloat = 0
    @State private var dragPixelY: CGFloat = 0

    @State private var particles: [Particle] = []
    @State private var floatingScores: [FloatingScore] = []
    @State private var chevronPulse: CGFloat = 0

    private let doorDepth: CGFloat = 24

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
            // Bound strictly to square so it never overflows vertical or horizontal bounds
            let pad: CGFloat = 16
            let availW = max(100, proxy.size.width - pad * 2)
            let availH = max(100, proxy.size.height - pad * 2)
            let boardSize = min(availW, availH)

            let doorMargin: CGFloat = doorDepth + 8
            let gridInnerSize = boardSize - doorMargin * 2
            let cols = CGFloat(max(1, engine.gridWidth))
            let rows = CGFloat(max(1, engine.gridHeight))
            let cellSize = min(gridInnerSize / cols, gridInnerSize / rows)

            let gridActualW = cols * cellSize
            let gridActualH = rows * cellSize
            let gridStartX = (boardSize - gridActualW) / 2
            let gridStartY = (boardSize - gridActualH) / 2

            ZStack(alignment: .center) {
                // Outer board container
                ZStack(alignment: .topLeading) {
                    // 1. Board Frame and Background Plate
                    boardFrameLayer(
                        gridStartX: gridStartX,
                        gridStartY: gridStartY,
                        gridW: gridActualW,
                        gridH: gridActualH
                    )

                    // 2. Recessed Grid Slots
                    gridSlotsLayer(
                        cols: engine.gridWidth,
                        rows: engine.gridHeight,
                        cellSize: cellSize,
                        gridStartX: gridStartX,
                        gridStartY: gridStartY
                    )

                    // 3. Exit Doors on 4 Sides
                    doorsLayer(
                        cellSize: cellSize,
                        gridStartX: gridStartX,
                        gridStartY: gridStartY,
                        gridW: gridActualW,
                        gridH: gridActualH
                    )

                    // 4. Obstacles Layer
                    obstaclesLayer(
                        cellSize: cellSize,
                        gridStartX: gridStartX,
                        gridStartY: gridStartY
                    )

                    // 5. Blocks Layer
                    blocksLayer(
                        cellSize: cellSize,
                        gridStartX: gridStartX,
                        gridStartY: gridStartY
                    )

                    // 6. Particles Layer
                    particlesLayer()

                    // 7. Floating Scores Layer
                    floatingScoresLayer()
                }
                .frame(width: boardSize, height: boardSize)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                chevronPulse = 3.5
            }
        }
    }

    // MARK: - Board Frame Layer
    @ViewBuilder
    private func boardFrameLayer(gridStartX: CGFloat, gridStartY: CGFloat, gridW: CGFloat, gridH: CGFloat) -> some View {
        let framePadding = doorDepth + 6
        let frameX = gridStartX - framePadding
        let frameY = gridStartY - framePadding
        let frameW = gridW + framePadding * 2
        let frameH = gridH + framePadding * 2

        // Outer tubular frame
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [Color(hex: 0x1E233D), Color(hex: 0x141829)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(Color(hex: 0x3A4468), lineWidth: 2)
            )
            .shadow(color: Color.black.opacity(0.55), radius: 12, x: 0, y: 6)
            .frame(width: frameW, height: frameH)
            .offset(x: frameX, y: frameY)

        // Inner board base plate
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Color(hex: 0x333E65))
            .frame(width: gridW + 4, height: gridH + 4)
            .offset(x: gridStartX - 2, y: gridStartY - 2)
    }

    // MARK: - Recessed Grid Slots
    @ViewBuilder
    private func gridSlotsLayer(cols: Int, rows: Int, cellSize: CGFloat, gridStartX: CGFloat, gridStartY: CGFloat) -> some View {
        let tileInset: CGFloat = 2.0
        let tileSize = cellSize - tileInset * 2

        ForEach(0..<rows, id: \.self) { r in
            ForEach(0..<cols, id: \.self) { c in
                let tx = gridStartX + CGFloat(c) * cellSize + tileInset
                let ty = gridStartY + CGFloat(r) * cellSize + tileInset

                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color(hex: 0x4C5882))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .strokeBorder(Color(hex: 0x576594), lineWidth: 1)
                    )
                    .frame(width: tileSize, height: tileSize)
                    .offset(x: tx, y: ty)
            }
        }
    }

    // MARK: - Doors Layer
    @ViewBuilder
    private func doorsLayer(cellSize: CGFloat, gridStartX: CGFloat, gridStartY: CGFloat, gridW: CGFloat, gridH: CGFloat) -> some View {
        ForEach(engine.doors) { door in
            let doorSpan = CGFloat(door.widthCells) * cellSize - 4
            let startCoord = CGFloat(door.index) * cellSize + 2

            switch door.side {
            case .top:
                doorView(door: door, width: doorSpan, height: doorDepth, arrow: "chevron.up")
                    .offset(x: gridStartX + startCoord, y: gridStartY - doorDepth)
            case .bottom:
                doorView(door: door, width: doorSpan, height: doorDepth, arrow: "chevron.down")
                    .offset(x: gridStartX + startCoord, y: gridStartY + gridH)
            case .left:
                doorView(door: door, width: doorDepth, height: doorSpan, arrow: "chevron.left")
                    .offset(x: gridStartX - doorDepth, y: gridStartY + startCoord)
            case .right:
                doorView(door: door, width: doorDepth, height: doorSpan, arrow: "chevron.right")
                    .offset(x: gridStartX + gridW, y: gridStartY + startCoord)
            }
        }
    }

    private func doorView(door: ExitDoor, width: CGFloat, height: CGFloat, arrow: String) -> some View {
        let isHorizontal = door.side == .top || door.side == .bottom

        return ZStack {
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [door.color.lightColor, door.color.mainColor],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .strokeBorder(door.color.darkColor, lineWidth: 1.5)
                )
                .shadow(color: door.color.mainColor.opacity(0.6), radius: 4)

            // Animated directional arrow(s)
            if isHorizontal {
                HStack(spacing: 4) {
                    ForEach(0..<max(1, door.widthCells), id: \.self) { _ in
                        Image(systemName: arrow)
                            .font(.system(size: 10, weight: .black))
                            .foregroundColor(.white)
                            .offset(y: door.side == .top ? -chevronPulse : chevronPulse)
                    }
                }
            } else {
                VStack(spacing: 4) {
                    ForEach(0..<max(1, door.widthCells), id: \.self) { _ in
                        Image(systemName: arrow)
                            .font(.system(size: 10, weight: .black))
                            .foregroundColor(.white)
                            .offset(x: door.side == .left ? -chevronPulse : chevronPulse)
                    }
                }
            }
        }
        .frame(width: width, height: height)
    }

    // MARK: - Obstacles Layer
    @ViewBuilder
    private func obstaclesLayer(cellSize: CGFloat, gridStartX: CGFloat, gridStartY: CGFloat) -> some View {
        ForEach(engine.obstacles.filter { !$0.isDestroyed }) { obs in
            let ox = gridStartX + CGFloat(obs.x) * cellSize + 2.5
            let oy = gridStartY + CGFloat(obs.y) * cellSize + 2.5
            let ow = CGFloat(obs.width) * cellSize - 5
            let oh = CGFloat(obs.height) * cellSize - 5

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
                            .strokeBorder(Color(hex: 0x334155), lineWidth: 2)
                    )
                    .shadow(color: .black.opacity(0.4), radius: 4, x: 0, y: 3)

                Image(systemName: "mountain.2.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(hex: 0x94A3B8))

                if isHammerActive {
                    Image(systemName: "hammer.fill")
                        .font(.system(size: 22, weight: .black))
                        .foregroundColor(.yellow)
                        .shadow(color: .black, radius: 4)
                }
            }
            .frame(width: ow, height: oh)
            .offset(x: ox, y: oy)
            .onTapGesture {
                if isHammerActive {
                    onHammerObstacle(obs.id)
                }
            }
        }
    }

    // MARK: - Blocks Layer
    @ViewBuilder
    private func blocksLayer(cellSize: CGFloat, gridStartX: CGFloat, gridStartY: CGFloat) -> some View {
        ForEach(engine.blocks) { block in
            let isCurrent = activeBlockId == block.id
            let offX = isCurrent ? dragPixelX : 0
            let offY = isCurrent ? dragPixelY : 0

            let bx = gridStartX + CGFloat(block.x) * cellSize + 2.5 + offX
            let by = gridStartY + CGFloat(block.y) * cellSize + 2.5 + offY
            let bw = CGFloat(block.width) * cellSize - 5
            let bh = CGFloat(block.height) * cellSize - 5

            legoBlockView(block: block, width: bw, height: bh, cellSize: cellSize)
                .frame(width: bw, height: bh)
                .offset(x: bx, y: by)
                .scaleEffect(block.isEscaped ? 0.05 : (isCurrent ? 1.03 : 1.0))
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
                            if res.escaped, let side = res.escapeSide {
                                triggerEscapeEffects(block: block, side: side, cellSize: cellSize, gridStartX: gridStartX, gridStartY: gridStartY)
                                onBlockEscaped(block, side)
                            }
                            onMoveMade()
                        }
                    }
                }
                .gesture(
                    DragGesture(minimumDistance: 4)
                        .onChanged { value in
                            guard !isHammerActive && !block.isEscaped else { return }

                            if activeBlockId != block.id {
                                activeBlockId = block.id
                                currentLimits = engine.calculateLimits(block: block)
                            }

                            guard let limits = currentLimits else { return }

                            if block.direction == .horizontal {
                                let minPixel = CGFloat(limits.minXOnBoard - block.x) * cellSize - (limits.canEscapeLeft ? cellSize * 0.95 : 0)
                                let maxPixel = CGFloat(limits.maxXOnBoard - block.x) * cellSize + (limits.canEscapeRight ? cellSize * 0.95 : 0)
                                dragPixelX = min(maxPixel, max(minPixel, value.translation.width))
                                dragPixelY = 0
                            } else if block.direction == .vertical {
                                let minPixel = CGFloat(limits.minYOnBoard - block.y) * cellSize - (limits.canEscapeTop ? cellSize * 0.95 : 0)
                                let maxPixel = CGFloat(limits.maxYOnBoard - block.y) * cellSize + (limits.canEscapeBottom ? cellSize * 0.95 : 0)
                                dragPixelX = 0
                                dragPixelY = min(maxPixel, max(minPixel, value.translation.height))
                            }
                        }
                        .onEnded { value in
                            guard !isHammerActive && !block.isEscaped else {
                                activeBlockId = nil
                                currentLimits = nil
                                dragPixelX = 0
                                dragPixelY = 0
                                return
                            }

                            let finalX = dragPixelX
                            let finalY = dragPixelY
                            let dist = hypot(finalX, finalY)

                            activeBlockId = nil
                            currentLimits = nil
                            dragPixelX = 0
                            dragPixelY = 0

                            if dist < 8 {
                                if let res = engine.tryQuickEscape(blockId: block.id) {
                                    if res.escaped, let side = res.escapeSide {
                                        triggerEscapeEffects(block: block, side: side, cellSize: cellSize, gridStartX: gridStartX, gridStartY: gridStartY)
                                        onBlockEscaped(block, side)
                                    }
                                    onMoveMade()
                                }
                                return
                            }

                            let deltaX = Float(finalX / cellSize)
                            let deltaY = Float(finalY / cellSize)
                            let isFling = abs(value.velocity.width) > 400 || abs(value.velocity.height) > 400

                            if let res = engine.applyMove(blockId: block.id, deltaCellsX: deltaX, deltaCellsY: deltaY, isFling: isFling) {
                                if res.escaped, let side = res.escapeSide {
                                    triggerEscapeEffects(block: block, side: side, cellSize: cellSize, gridStartX: gridStartX, gridStartY: gridStartY)
                                    onBlockEscaped(block, side)
                                }
                                onMoveMade()
                            }
                        }
                )
        }
    }

    // MARK: - Lego 3D Block View
    private func legoBlockView(block: Block, width: CGFloat, height: CGFloat, cellSize: CGFloat) -> some View {
        ZStack {
            // Drop shadow base
            RoundedRectangle(cornerRadius: 11, style: .continuous)
                .fill(block.color.darkColor)
                .offset(y: 3.5)

            // Main face gradient
            RoundedRectangle(cornerRadius: 11, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [block.color.lightColor, block.color.mainColor],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            // Bevel gloss rim
            RoundedRectangle(cornerRadius: 11, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [Color.white.opacity(0.55), Color.clear, block.color.darkColor],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )

            // Studs for each cell in block (2x2 per cell like authentic Lego)
            let studsX = block.width * 2
            let studsY = block.height * 2
            let studRadius = (width / CGFloat(studsX)) * 0.34

            VStack(spacing: 0) {
                ForEach(0..<studsY, id: \.self) { _ in
                    HStack(spacing: 0) {
                        ForEach(0..<studsX, id: \.self) { _ in
                            studView(color: block.color, symbol: block.symbol, size: studRadius * 2)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                }
            }

            if isHammerActive {
                Image(systemName: "hammer.fill")
                    .font(.system(size: 24, weight: .black))
                    .foregroundColor(.yellow)
                    .shadow(color: .black, radius: 4)
            }
        }
    }

    private func studView(color: BlockColor, symbol: String?, size: CGFloat) -> some View {
        ZStack {
            // Stud base shadow
            Circle()
                .fill(color.darkColor.opacity(0.6))
                .offset(y: 1.2)
                .frame(width: size, height: size)

            // Stud body
            Circle()
                .fill(
                    LinearGradient(
                        colors: [color.lightColor, color.studColor],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(Circle().strokeBorder(Color.white.opacity(0.4), lineWidth: 0.8))
                .frame(width: size, height: size)

            // Center highlight
            Circle()
                .fill(Color.white.opacity(0.35))
                .frame(width: size * 0.45, height: size * 0.45)
                .offset(x: -size * 0.15, y: -size * 0.15)
        }
    }

    // MARK: - Particles & Effects
    private func triggerEscapeEffects(block: Block, side: ExitSide, cellSize: CGFloat, gridStartX: CGFloat, gridStartY: CGFloat) {
        let spawnX = gridStartX + CGFloat(block.x) * cellSize + CGFloat(block.width) * cellSize / 2
        let spawnY = gridStartY + CGFloat(block.y) * cellSize + CGFloat(block.height) * cellSize / 2

        // Add 24 colorful particles
        for _ in 0..<24 {
            let p = Particle(
                x: spawnX,
                y: spawnY,
                vx: CGFloat.random(in: -5...5),
                vy: CGFloat.random(in: -6...2),
                size: CGFloat.random(in: 6...12),
                rotation: Double.random(in: 0...Double.pi * 2),
                vRot: Double.random(in: -0.2...0.2),
                color: Bool.random() ? block.color.mainColor : .white
            )
            particles.append(p)
        }

        // Add floating score text
        let pts = block.width * block.height * 100 * engine.comboMultiplier
        let comboText = engine.comboMultiplier > 1 ? "+\(pts) (x\(engine.comboMultiplier) COMBO!)" : "+\(pts)"
        floatingScores.append(FloatingScore(text: comboText, x: spawnX, y: spawnY, color: block.color.lightColor))

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
