
import SwiftUI
import Charts
struct GlassCard: ViewModifier {
    @Environment(AccessibilityManager.self) private var accessibility

    func body(content: Content) -> some View {
        content
            .padding(20)
            .background {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(accessibility.borderOpacity(0.15)),
                                        .white.opacity(accessibility.borderOpacity(0.05))
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: accessibility.highContrast ? 1.0 : 0.5
                            )
                    }
                    .shadow(color: .black.opacity(0.2), radius: 12, y: 4)
            }
    }
}

extension View {
    func glassCard() -> some View {
        modifier(GlassCard())
    }

    func staggerIn(index: Int, appear: Bool, reduceAnimations: Bool) -> some View {
        self
            .opacity(appear ? 1 : 0)
            .offset(y: appear ? 0 : 25)
            .animation(
                reduceAnimations ? nil : .spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.08),
                value: appear
            )
    }
}
struct LevelProgressCard: View {
    let level: Int
    let currentPoints: Int
    let pointsNeeded: Int
    let progress: Double
    let totalPoints: Int
    let cardsRead: Int
    let quizzesCompleted: Int
    @Environment(AccessibilityManager.self) private var accessibility

    // Badge image name based on level
    private var badgeImageName: String {
        switch level {
        case 0: return "Badge1"
        case 1: return "Badge1"
        case 2: return "Badge2"
        default: return "Badge3"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("Progress")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
                Spacer()
                Text("\(totalPoints) pts")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.cyan)
            }

            // Level display with icons
            HStack(spacing: 12) {
                // Big level badge
                Image(badgeImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 64, height: 64)
                    .accessibilityLabel("Level \(level) badge")

                VStack(alignment: .leading, spacing: 6) {
                    Text("Level \(level)")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.white)

                    // Progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(.white.opacity(0.1))
                                .frame(height: 10)

                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [.cyan, .blue],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: max(geo.size.width * progress, 10), height: 10)
                                .shadow(color: .cyan.opacity(0.5), radius: 4)
                        }
                    }
                    .frame(height: 10)

                    Text("\(currentPoints)/\(pointsNeeded) pts to next level")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(accessibility.secondaryOpacity(0.5)))
                }
            }

            // Activity summary row
            Divider()
                .overlay(.white.opacity(0.1))

            HStack(spacing: 0) {
                ActivityBubble(icon: "book.fill", label: "Cards read", value: "\(cardsRead)", color: .teal)
                Spacer()
                ActivityBubble(icon: "checkmark.circle.fill", label: "Quizzes completed", value: "\(quizzesCompleted)", color: .blue)
                Spacer()
                ActivityBubble(icon: "star.fill", label: "Points", value: "\(totalPoints)", color: .cyan)
            }
        }
        .glassCard()
    }
}
struct ActivityBubble: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    @Environment(AccessibilityManager.self) private var accessibility

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 42, height: 42)

                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(color)
            }

            Text(value)
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)

            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(.white.opacity(accessibility.secondaryOpacity(0.5)))
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }
}
struct FunFactsCard: View {
    let facts: [FunFact]
    @State private var currentIndex: Int = 0
    @Environment(AccessibilityManager.self) private var accessibility

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            HStack {
                Text("Did you know?")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
                Spacer()
                Text("\(currentIndex + 1)/\(facts.count)")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(accessibility.tertiaryOpacity(0.4)))
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)

            if !facts.isEmpty {
                // Horizontal paging scroll
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 0) {
                        ForEach(Array(facts.enumerated()), id: \.element.id) { index, fact in
                            FunFactItem(fact: fact)
                                .containerRelativeFrame(.horizontal)
                                .id(index)
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.viewAligned)
                .scrollPosition(id: Binding(
                    get: { currentIndex },
                    set: { if let newValue = $0 { currentIndex = newValue } }
                ))
                .scrollClipDisabled(false)

                // Page dots
                HStack(spacing: 6) {
                    Spacer()
                    ForEach(0..<facts.count, id: \.self) { i in
                        Circle()
                            .fill(i == currentIndex ? .cyan : .white.opacity(0.2))
                            .frame(width: 6, height: 6)
                            .animation(.easeInOut(duration: 0.2), value: currentIndex)
                    }
                    Spacer()
                }
                .padding(.bottom, 20)
            }
        }
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.15), .white.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.5
                        )
                }
                .shadow(color: .black.opacity(0.2), radius: 12, y: 4)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}
struct FunFactItem: View {
    let fact: FunFact

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Text(fact.icon)
                .font(.system(size: 36))
                .frame(width: 52, height: 52)
                .background {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(.white.opacity(0.08))
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(fact.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)

                Text(fact.description)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal, 20)
    }
}
struct RegionStatsCard: View {
    let stats: [RegionStat]
    @Environment(AccessibilityManager.self) private var accessibility

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Region in numbers")
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white)

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                ForEach(stats) { stat in
                    HStack(spacing: 10) {
                        Image(systemName: stat.icon)
                            .font(.system(size: 16))
                            .foregroundStyle(stat.color)
                            .frame(width: 34, height: 34)
                            .background {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(stat.color.opacity(0.12))
                            }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(stat.value)
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(.white)
                            Text(stat.label)
                                .font(.system(size: 10))
                                .foregroundStyle(.white.opacity(accessibility.secondaryOpacity(0.5)))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(stat.label): \(stat.value)")
                    .padding(10)
                    .background {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(.white.opacity(0.05))
                    }
                }
            }
        }
        .glassCard()
    }
}
struct HighlightsCard: View {
    let highlights: [Highlight]
    let regionName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Notable Places")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
                Spacer()
                Image(systemName: "sparkles")
                    .foregroundStyle(.cyan)
            }

            ForEach(Array(highlights.enumerated()), id: \.element.id) { index, highlight in
                Button {
                    openInAppleMaps(highlight: highlight)
                } label: {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.cyan.opacity(0.2), .blue.opacity(0.15)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: 32, height: 32)

                            Text("\(index + 1)")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.cyan)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(highlight.name)
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.8))
                            Text("Open in Maps")
                                .font(.system(size: 10))
                                .foregroundStyle(.cyan.opacity(0.6))
                        }

                        Spacer()

                        Image(systemName: "arrow.up.right.square")
                            .font(.caption)
                            .foregroundStyle(.cyan.opacity(0.5))
                    }
                    .padding(.vertical, 4)
                }
                .buttonStyle(.plain)

                if index < highlights.count - 1 {
                    Divider()
                        .overlay(.white.opacity(0.06))
                }
            }
        }
        .glassCard()
    }

    private func openInAppleMaps(highlight: Highlight) {
        let latitude = highlight.latitude
        let longitude = highlight.longitude
        let name = highlight.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? highlight.name
        if let url = URL(string: "maps://?ll=\(latitude),\(longitude)&q=\(name)&z=12") {
            UIApplication.shared.open(url)
        }
    }
}
struct PointsBreakdownCard: View {
    let cardsRead: Int
    let quizzesCompleted: Int
    let totalQuizPoints: Int

    private var cardPoints: Int { cardsRead * ProgressManager.pointsPerCard }
    private var quizPoints: Int { totalQuizPoints }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Points Breakdown")
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white)

            HStack(spacing: 20) {
                // Mini donut chart
                ZStack {
                    Circle()
                        .stroke(.white.opacity(0.08), lineWidth: 14)
                        .frame(width: 80, height: 80)

                    let total = max(Double(cardPoints + quizPoints), 1)

                    Circle()
                        .trim(from: 0, to: Double(cardPoints) / total)
                        .stroke(
                            LinearGradient(colors: [.teal, .cyan], startPoint: .top, endPoint: .bottom),
                            style: StrokeStyle(lineWidth: 14, lineCap: .round)
                        )
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))

                    Circle()
                        .trim(from: Double(cardPoints) / total, to: 1.0)
                        .stroke(
                            LinearGradient(colors: [.blue, .indigo], startPoint: .top, endPoint: .bottom),
                            style: StrokeStyle(lineWidth: 14, lineCap: .round)
                        )
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))

                    Text("\(cardPoints + quizPoints)")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(.cyan)
                            .frame(width: 8, height: 8)
                        Text("Cards")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.6))
                        Spacer()
                        Text("\(cardPoints) pts")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.white)
                    }

                    HStack(spacing: 8) {
                        Circle()
                            .fill(.blue)
                            .frame(width: 8, height: 8)
                        Text("Quiz")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.6))
                        Spacer()
                        Text("\(quizPoints) pts")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.white)
                    }

                    Divider()
                        .overlay(.white.opacity(0.1))

                    HStack(spacing: 8) {
                        Text("📊")
                            .font(.caption)
                        Text("Average")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.6))
                        Spacer()
                        let sessions = max(cardsRead + quizzesCompleted, 1)
                        Text("\(String(format: "%.1f", Double(cardPoints + quizPoints) / Double(sessions))) pts/session")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.cyan)
                    }
                }
            }
        }
        .glassCard()
    }
}
