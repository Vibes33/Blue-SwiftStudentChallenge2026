import SwiftUI
import Charts

struct EcosystemView: View {
    let regionId: String
    @Environment(\.dismiss) private var dismiss
    @Environment(AccessibilityManager.self) private var accessibility
    @State private var ecosystem: EcosystemState
    @State private var showInfo: Bool = true
    @State private var selectedSpecies: String? = nil
    @State private var showChart: Bool = false

    init(regionId: String) {
        self.regionId = regionId
        let organisms = EcosystemOrganism.ecosystem(for: regionId)
        self._ecosystem = State(initialValue: EcosystemState(organisms: organisms))
    }

    var body: some View {
        ZStack {
            // Ocean background
            oceanBackground

            VStack(spacing: 0) {
                // Top bar
                topBar
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                // Health indicator
                healthBar
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                // Info banner (dismissable)
                if showInfo {
                    infoBanner
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                // Main ecosystem area
                oceanScene
                    .padding(.top, 8)

                // Bottom panel: Cascade Log / Population Chart toggle
                bottomPanel
                    .frame(height: 160)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
            }

            // Selection overlay
            if let selectedId = selectedSpecies,
               let organism = ecosystem.organisms.first(where: { $0.id == selectedId }) {
                removalConfirmation(for: organism)
            }
        }
        .navigationBarHidden(true)
        .blueAccessibility(accessibility)
    }
    private var oceanBackground: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.02, green: 0.06, blue: 0.15),
                    Color(red: 0.01, green: 0.10, blue: 0.28),
                    Color(red: 0.0, green: 0.06, blue: 0.22),
                    Color(red: 0.0, green: 0.03, blue: 0.12)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Subtle light rays
            GeometryReader { geo in
                ForEach(0..<3, id: \.self) { i in
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.cyan.opacity(0.03), .clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 60, height: geo.size.height)
                        .rotationEffect(.degrees(Double(i) * 8 - 8))
                        .offset(x: CGFloat(i) * 120 - 60)
                        .blendMode(.screen)
                }
            }
            .ignoresSafeArea()
        }
    }
    private var topBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.body.weight(.semibold))
                    Text("Back")
                        .font(.subheadline.weight(.medium))
                }
                .foregroundStyle(.white.opacity(0.6))
            }

            Spacer()

            Text("Ecosystem")
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)

            Spacer()

            Button {
                withAnimation(accessibility.reduceAnimations ? nil : .spring(response: 0.4, dampingFraction: 0.7)) {
                    ecosystem.reset()
                }
                let gen = UINotificationFeedbackGenerator()
                gen.notificationOccurred(.success)
            } label: {
                Image(systemName: "arrow.counterclockwise.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.cyan.opacity(ecosystem.removedSpecies.isEmpty ? 0.3 : 0.8))
            }
            .disabled(ecosystem.removedSpecies.isEmpty)
        }
    }
    private var healthBar: some View {
        VStack(spacing: 8) {
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(ecosystem.healthColor)
                        .frame(width: 8, height: 8)
                    Text(ecosystem.healthLabel)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.8))
                }

                Spacer()

                Text("\(Int(ecosystem.healthPercentage * 100))%")
                    .font(.caption.weight(.bold).monospacedDigit())
                    .foregroundStyle(ecosystem.healthColor)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(.white.opacity(0.08))
                        .frame(height: 6)

                    Capsule()
                        .fill(ecosystem.healthColor)
                        .frame(width: max(geo.size.width * ecosystem.healthPercentage, 4), height: 6)
                        .animation(accessibility.reduceAnimations ? nil : .easeInOut(duration: 0.8), value: ecosystem.healthPercentage)
                }
            }
            .frame(height: 6)
        }
    }
    private var infoBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "hand.tap.fill")
                .font(.title3)
                .foregroundStyle(.cyan)

            VStack(alignment: .leading, spacing: 2) {
                Text("Tap a species to remove it")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.8))
                Text("Observe the impact on the ecosystem")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(accessibility.tertiaryOpacity(0.4)))
            }

            Spacer()

            Button {
                withAnimation { showInfo = false }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.3))
            }
        }
        .padding(14)
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.cyan.opacity(0.08))
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(.cyan.opacity(0.15), lineWidth: 1)
                }
        }
    }
    private var oceanScene: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height

            ZStack {
                // Trophic level labels on left
                ForEach(TrophicLevel.allCases, id: \.rawValue) { level in
                    let yCenter = yPosition(for: level, in: height)
                    Text(level.label)
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(level.color.opacity(0.4))
                        .rotationEffect(.degrees(-90))
                        .position(x: 12, y: yCenter)
                }

                // Food chain connections (lines between predator-prey)
                ForEach(ecosystem.organisms, id: \.id) { organism in
                    ForEach(organism.preys, id: \.self) { preyId in
                        if let prey = ecosystem.organisms.first(where: { $0.id == preyId }) {
                            let fromPos = organismPosition(organism, in: CGSize(width: width, height: height))
                            let toPos = organismPosition(prey, in: CGSize(width: width, height: height))

                            let predatorRemoved = ecosystem.removedSpecies.contains(organism.id)
                            let preyRemoved = ecosystem.removedSpecies.contains(preyId)
                            let isDisconnected = predatorRemoved || preyRemoved

                            FoodChainLink(
                                from: fromPos,
                                to: toPos,
                                isDisconnected: isDisconnected,
                                predatorPop: ecosystem.populations[organism.id] ?? 1.0,
                                preyPop: ecosystem.populations[preyId] ?? 1.0,
                                trophicColor: organism.trophicLevel.color,
                                reduceAnimations: accessibility.reduceAnimations
                            )
                        }
                    }
                }

                // Organisms
                ForEach(ecosystem.organisms) { organism in
                    let isRemoved = ecosystem.removedSpecies.contains(organism.id)
                    let pop = ecosystem.populations[organism.id] ?? 1.0
                    let pos = organismPosition(organism, in: CGSize(width: width, height: height))

                    if !isRemoved {
                        OrganismBubble(
                            organism: organism,
                            population: pop,
                            isSimulating: ecosystem.isSimulating
                        )
                        .position(pos)
                        .transition(.scale.combined(with: .opacity))
                        .onTapGesture {
                            guard !ecosystem.isSimulating else { return }
                            let gen = UIImpactFeedbackGenerator(style: .medium)
                            gen.prepare()
                            gen.impactOccurred()
                            withAnimation(accessibility.reduceAnimations ? nil : .spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedSpecies = organism.id
                            }
                        }
                        .accessibilityLabel("\(organism.name), \(organism.trophicLevel.label)")
                        .accessibilityHint("Tap to see details and remove this species")
                    }
                }
            }
        }
    }
    private func removalConfirmation(for organism: EcosystemOrganism) -> some View {
        VStack {
            Spacer()

            VStack(spacing: 16) {
                // Header
                HStack(spacing: 12) {
                    Text(organism.emoji)
                        .font(.system(size: 36))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(organism.name)
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.white)
                        Text(organism.trophicLevel.label)
                            .font(.caption)
                            .foregroundStyle(organism.trophicLevel.color)
                    }
                    Spacer()
                }

                Text(organism.description)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
                    .lineSpacing(3)

                // Connections info
                HStack(spacing: 16) {
                    if !organism.preys.isEmpty {
                        let preyNames = organism.preys.compactMap { id in
                            ecosystem.organisms.first(where: { $0.id == id })?.emoji
                        }.joined(separator: " ")
                        Label("Eats: \(preyNames)", systemImage: "fork.knife")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    if !organism.predators.isEmpty {
                        let predNames = organism.predators.compactMap { id in
                            ecosystem.organisms.first(where: { $0.id == id })?.emoji
                        }.joined(separator: " ")
                        Label("Predators: \(predNames)", systemImage: "exclamationmark.triangle")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }

                HStack(spacing: 12) {
                    Button {
                        withAnimation(accessibility.reduceAnimations ? nil : .spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedSpecies = nil
                        }
                    } label: {
                        Text("Cancel")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.6))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(.white.opacity(0.08))
                            }
                    }

                    Button {
                        withAnimation(accessibility.reduceAnimations ? nil : .spring(response: 0.4, dampingFraction: 0.7)) {
                            selectedSpecies = nil
                            ecosystem.removeSpecies(organism.id)
                        }
                        let gen = UINotificationFeedbackGenerator()
                        gen.prepare()
                        gen.notificationOccurred(.warning)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "minus.circle.fill")
                            Text("Remove")
                        }
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(.red.opacity(0.6))
                        }
                    }
                }
            }
            .padding(20)
            .background {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(.white.opacity(0.1), lineWidth: 1)
                    }
                    .shadow(color: .black.opacity(0.4), radius: 20, y: 10)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
        .background {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedSpecies = nil
                    }
                }
        }
    }
    private var bottomPanel: some View {
        VStack(spacing: 0) {
            // Tab selector
            HStack(spacing: 0) {
                bottomTabButton(title: "Log", icon: "list.bullet.rectangle.fill", isActive: !showChart) {
                    withAnimation(.easeInOut(duration: 0.25)) { showChart = false }
                }
                bottomTabButton(title: "Chart", icon: "chart.xyaxis.line", isActive: showChart) {
                    withAnimation(.easeInOut(duration: 0.25)) { showChart = true }
                }
            }
            .padding(.horizontal, 10)
            .padding(.top, 8)

            // Content
            if showChart {
                populationChart
                    .transition(.opacity)
            } else {
                cascadeLogContent
                    .transition(.opacity)
            }
        }
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial.opacity(0.5))
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(.white.opacity(0.06), lineWidth: 1)
                }
        }
    }

    private func bottomTabButton(title: String, icon: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 10))
                Text(title)
                    .font(.caption2.weight(.bold))
            }
            .foregroundStyle(isActive ? .cyan : .white.opacity(0.4))
            .padding(.vertical, 5)
            .padding(.horizontal, 12)
            .background {
                if isActive {
                    Capsule()
                        .fill(.cyan.opacity(0.12))
                }
            }
        }
        .buttonStyle(.plain)
    }
    private var populationChart: some View {
        Group {
            if ecosystem.populationHistory.count < 2 {
                VStack(spacing: 6) {
                    Spacer()
                    Image(systemName: "chart.xyaxis.line")
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.2))
                    Text("Remove a species to see population trends")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.3))
                        .multilineTextAlignment(.center)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                Chart {
                    ForEach(ecosystem.organisms) { organism in
                        ForEach(ecosystem.populationHistory) { snapshot in
                            let pop = snapshot.populations[organism.id] ?? 0
                            LineMark(
                                x: .value("Step", snapshot.step),
                                y: .value("Population", pop * 100),
                                series: .value("Species", organism.id)
                            )
                            .foregroundStyle(organism.trophicLevel.color)
                            .interpolationMethod(.catmullRom)
                            .lineStyle(StrokeStyle(lineWidth: 2))
                        }
                    }
                }
                .chartXAxis(.hidden)
                .chartYAxis {
                    AxisMarks(position: .leading, values: [0, 50, 100, 150, 200]) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.3))
                            .foregroundStyle(.white.opacity(0.1))
                        AxisValueLabel {
                            if let v = value.as(Int.self) {
                                Text("\(v)%")
                                    .font(.system(size: 8).monospacedDigit())
                                    .foregroundStyle(.white.opacity(0.3))
                            }
                        }
                    }
                }
                .chartYScale(domain: 0...260)
                .chartLegend(.hidden)
                .padding(.horizontal, 10)
                .padding(.top, 4)

                // Compact emoji legend
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(ecosystem.organisms) { org in
                            HStack(spacing: 3) {
                                Circle()
                                    .fill(org.trophicLevel.color)
                                    .frame(width: 6, height: 6)
                                Text(org.emoji)
                                    .font(.system(size: 9))
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                }
                .padding(.bottom, 6)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: ecosystem.populationHistory.count)
    }
    private var cascadeLogContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if !ecosystem.cascadeMessages.isEmpty {
                    Text("\(ecosystem.cascadeMessages.count) events")
                        .font(.system(size: 10, weight: .medium).monospacedDigit())
                        .foregroundStyle(.white.opacity(0.3))
                }
                Spacer()
            }

            if ecosystem.cascadeMessages.isEmpty {
                VStack(spacing: 6) {
                    Spacer()
                    Text("Remove a species to observe the consequences")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(accessibility.tertiaryOpacity(0.3)))
                        .multilineTextAlignment(.center)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(ecosystem.cascadeMessages) { msg in
                                HStack(spacing: 8) {
                                    Image(systemName: msg.icon)
                                        .font(.system(size: 10))
                                        .foregroundStyle(msg.color)
                                        .frame(width: 16)

                                    Text(msg.text)
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundStyle(.white.opacity(0.7))
                                        .lineLimit(2)
                                }
                                .id(msg.id)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                            }
                        }
                    }
                    .onChange(of: ecosystem.cascadeMessages.count) {
                        if let last = ecosystem.cascadeMessages.last {
                            withAnimation {
                                proxy.scrollTo(last.id, anchor: .bottom)
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.bottom, 10)
    }
    private func yPosition(for level: TrophicLevel, in height: CGFloat) -> CGFloat {
        switch level {
        case .topPredator: return height * 0.15
        case .secondaryConsumer: return height * 0.38
        case .primaryConsumer: return height * 0.62
        case .producer: return height * 0.85
        }
    }

    private func organismPosition(_ organism: EcosystemOrganism, in size: CGSize) -> CGPoint {
        let y = yPosition(for: organism.trophicLevel, in: size.height)

        // Distribute horizontally within trophic level
        let sameLevel = ecosystem.organisms.filter { $0.trophicLevel == organism.trophicLevel }
        let index = sameLevel.firstIndex(of: organism) ?? 0
        let count = sameLevel.count
        let spacing = (size.width - 80) / CGFloat(max(count, 1))
        let startX: CGFloat = 40 + spacing / 2
        let x = startX + CGFloat(index) * spacing

        // Small vertical variation based on depth range
        let depthOffset = (organism.depthRange.lowerBound - 0.5) * 20

        return CGPoint(x: x, y: y + depthOffset)
    }
}
struct OrganismBubble: View {
    let organism: EcosystemOrganism
    let population: Double
    let isSimulating: Bool

    @Environment(AccessibilityManager.self) private var accessibility
    @State private var wobble: Bool = false

    private var bubbleSize: CGFloat {
        let base: CGFloat = 52
        return base * min(max(CGFloat(population), 0.4), 1.8)
    }

    private var populationColor: Color {
        if population > 1.5 { return .yellow }
        if population > 0.8 { return .green }
        if population > 0.4 { return .orange }
        return .red
    }

    var body: some View {
        VStack(spacing: 3) {
            ZStack {
                // Glow ring based on population
                Circle()
                    .fill(populationColor.opacity(0.12))
                    .frame(width: bubbleSize + 14, height: bubbleSize + 14)

                // Solid dark background so bubbles stand out over lines
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 0.03, green: 0.08, blue: 0.18),
                                Color(red: 0.02, green: 0.06, blue: 0.15)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: bubbleSize / 2
                        )
                    )
                    .frame(width: bubbleSize, height: bubbleSize)

                // Trophic color overlay
                Circle()
                    .fill(organism.trophicLevel.color.opacity(0.15))
                    .frame(width: bubbleSize, height: bubbleSize)

                // Border ring
                Circle()
                    .stroke(populationColor.opacity(0.5), lineWidth: 2)
                    .frame(width: bubbleSize, height: bubbleSize)

                Text(organism.emoji)
                    .font(.system(size: bubbleSize * 0.45))
            }
            .scaleEffect(wobble && !accessibility.reduceAnimations ? 1.05 : 0.95)
            .animation(
                accessibility.reduceAnimations ? nil :
                .easeInOut(duration: Double.random(in: 1.8...2.8))
                .repeatForever(autoreverses: true),
                value: wobble
            )
            .onAppear { wobble = true }

            // Name label
            Text(organism.name)
                .font(.system(size: 8, weight: .bold))
                .foregroundStyle(.white.opacity(accessibility.secondaryOpacity(0.6)))
                .lineLimit(1)

            // Population indicator
            if population != 1.0 {
                Text(populationLabel)
                    .font(.system(size: 8, weight: .bold).monospacedDigit())
                    .foregroundStyle(populationColor)
            }
        }
        .animation(.easeInOut(duration: 0.6), value: population)
    }

    private var populationLabel: String {
        let pct = Int(population * 100)
        if population > 1.0 {
            return "↑ \(pct)%"
        } else {
            return "↓ \(pct)%"
        }
    }
}
struct FoodChainLink: View {
    let from: CGPoint
    let to: CGPoint
    let isDisconnected: Bool
    let predatorPop: Double
    let preyPop: Double
    let trophicColor: Color
    let reduceAnimations: Bool

    // Stable random speed per link instance
    @State private var flowSpeed: Double = Double.random(in: 2.0...3.5)

    /// Line color based on ecosystem health of this connection
    private var linkColor: Color {
        if isDisconnected { return .red }
        let health = min(predatorPop, preyPop)
        if health > 0.8 { return trophicColor }
        if health > 0.4 { return .orange }
        return .red
    }

    /// Line opacity based on connection state
    private var linkOpacity: Double {
        if isDisconnected { return 0 }
        let health = min(predatorPop, preyPop)
        return max(0.1, health * 0.35)
    }

    /// Line width based on flow strength
    private var linkWidth: CGFloat {
        if isDisconnected { return 0.5 }
        let health = min(predatorPop, preyPop)
        return max(1, health * 2.5)
    }

    var body: some View {
        ZStack {
            // Base connection line (glow)
            curvePath
                .stroke(
                    linkColor.opacity(linkOpacity * 0.5),
                    style: StrokeStyle(lineWidth: linkWidth + 3, lineCap: .round)
                )
                .blur(radius: 3)

            // Main connection line
            curvePath
                .stroke(
                    linkColor.opacity(linkOpacity),
                    style: StrokeStyle(lineWidth: linkWidth, lineCap: .round)
                )

            // Animated energy flow — uses TimelineView so it always works after reset
            if !isDisconnected && !reduceAnimations {
                TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
                    let seconds = timeline.date.timeIntervalSinceReferenceDate
                    let phase = (seconds / flowSpeed).truncatingRemainder(dividingBy: 1.0)

                    curvePath
                        .trim(from: max(0, phase - 0.12), to: phase)
                        .stroke(
                            linkColor.opacity(linkOpacity * 2.5),
                            style: StrokeStyle(lineWidth: linkWidth + 1.5, lineCap: .round)
                        )
                        .blur(radius: 1.5)
                }
            }
        }
        .animation(.easeInOut(duration: 0.8), value: isDisconnected)
        .animation(.easeInOut(duration: 0.8), value: predatorPop)
        .animation(.easeInOut(duration: 0.8), value: preyPop)
    }

    private var curvePath: Path {
        Path { path in
            path.move(to: from)
            let midY = (from.y + to.y) / 2
            path.addCurve(
                to: to,
                control1: CGPoint(x: from.x, y: midY),
                control2: CGPoint(x: to.x, y: midY)
            )
        }
    }
}
#Preview {
    EcosystemView(regionId: "california")
        .environment(AccessibilityManager())
        .preferredColorScheme(.dark)
}
