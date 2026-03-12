import SwiftUI
struct RegionIntroCard: View {
    let region: Region
    let speciesCount: Int
    let protectedCount: Int
    @Environment(AccessibilityManager.self) private var accessibility

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "mappin.circle.fill")
                    .foregroundStyle(.cyan)
                Text(region.name)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)

                Spacer()

                Text(region.subtitle)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(accessibility.tertiaryOpacity(0.4)))
            }

            Text(regionDescription(for: region.id))
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))
                .lineSpacing(4)

            HStack(spacing: 16) {
                StatPill(icon: "leaf.fill", label: "\(speciesCount) species", color: .teal)
                StatPill(icon: "shield.fill", label: "\(protectedCount) protected", color: .red)
            }
            .padding(.top, 4)
        }
        .glassCard()
    }

    private func regionDescription(for regionId: String) -> String {
        switch regionId {
        case "california":
            return "The California coast stretches over 1,350 km, from the kelp forests of Monterey to the warm waters of San Diego. This unique ecosystem is home to exceptional marine biodiversity."
        case "bretagne":
            return "With 2,730 km of coastline, Brittany is a land of marine contrasts. From the Iroise Sea to the Gulf of Morbihan, its cold waters sustain a rich and fragile ecosystem."
        case "mediterranean":
            return "The Mediterranean Sea holds 7% of all known marine species in less than 1% of the ocean's surface. From the Calanques to the Pelagos sanctuary, its warm waters shelter an extraordinary yet threatened biodiversity."
        case "norway":
            return "Norway's 100,000 km coastline, carved by over 1,000 fjords, hosts some of the planet's most spectacular marine life. From orca-filled Arctic waters to vast kelp forests, its cold seas teem with life."
        default:
            return "Discover the marine flora and fauna of this region."
        }
    }
}
struct StatPill: View {
    let icon: String
    let label: String
    let color: Color
    @Environment(AccessibilityManager.self) private var accessibility

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundStyle(color)
            Text(label)
                .font(.caption.weight(.medium))
                .foregroundStyle(.white.opacity(accessibility.secondaryOpacity(0.7)))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background {
            Capsule()
                .fill(color.opacity(0.12))
        }
    }
}
struct EmblematicSpeciesRow: View {
    let species: [Species]
    let readCards: Set<String>
    let onTap: (Species) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundStyle(.orange)
                    .font(.subheadline)
                Text("Emblematic Species")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
                Spacer()
                Text("\(species.count)")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(0.4))
            }
            .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(species) { sp in
                        EmblematicCard(species: sp, isRead: readCards.contains(sp.id))
                            .onTapGesture { onTap(sp) }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}
struct EmblematicCard: View {
    let species: Species
    var isRead: Bool = false
    @Environment(AccessibilityManager.self) private var accessibility

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image
            ZStack(alignment: .topTrailing) {
                Color.clear
                    .frame(width: 140, height: 100)
                    .overlay {
                        Image(species.imageName)
                            .resizable()
                            .scaledToFill()
                    }
                    .clipped()
                    .overlay {
                        LinearGradient(
                            colors: [.clear, .black.opacity(0.3)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }

                // Status badge
                VStack(spacing: 4) {
                    Text(species.status.shortLabel)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background {
                            Capsule()
                                .fill(species.status.color)
                        }

                    if isRead {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(.cyan)
                            .shadow(color: .black.opacity(0.5), radius: 2)
                    }
                }
                .padding(8)
            }

            // Info
            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(species.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    if isRead {
                        Spacer()
                        Text("+3")
                            .font(.system(size: 9, weight: .bold, design: .rounded))
                            .foregroundStyle(.cyan.opacity(0.7))
                    }
                }

                Text(species.scientificName)
                    .font(.system(size: 10, design: .serif))
                    .foregroundStyle(.white.opacity(accessibility.tertiaryOpacity(0.4)))
                    .italic()
                    .lineLimit(1)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
        }
        .frame(width: 140)
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.ultraThinMaterial)
        }
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(.white.opacity(0.08), lineWidth: 0.5)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(species.name), \(species.status.shortLabel)\(isRead ? ", already viewed" : "")")
        .accessibilityHint("Tap to see details")
    }
}
struct ProtectedSpeciesSection: View {
    let species: [Species]
    let readCards: Set<String>
    let onTap: (Species) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "shield.fill")
                    .foregroundStyle(.red)
                    .font(.subheadline)
                Text("Threatened & Protected Species")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(species) { sp in
                        ProtectedSpeciesCard(species: sp, isRead: readCards.contains(sp.id))
                            .onTapGesture { onTap(sp) }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}
struct ProtectedSpeciesCard: View {
    let species: Species
    var isRead: Bool = false
    @Environment(AccessibilityManager.self) private var accessibility

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Background image
            Color.clear
                .overlay {
                    Image(species.imageName)
                        .resizable()
                        .scaledToFill()
                }
                .clipped()

            // Gradient overlay
            LinearGradient(
                colors: [.clear, .clear, .black.opacity(0.7), .black.opacity(0.9)],
                startPoint: .top,
                endPoint: .bottom
            )

            // Content overlay
            VStack(alignment: .leading, spacing: 6) {
                Spacer()

                // Status badge
                HStack(spacing: 4) {
                    Circle()
                        .fill(species.status.color)
                        .frame(width: 6, height: 6)
                    Text(species.status.rawValue)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(species.status.color)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background {
                    Capsule()
                        .fill(species.status.color.opacity(0.15))
                }

                HStack {
                    Text(species.name)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.white)
                    if isRead {
                        Spacer()
                        Image(systemName: "checkmark.seal.fill")
                            .font(.body)
                            .foregroundStyle(.cyan)
                    }
                }

                Text(species.scientificName)
                    .font(.caption.italic())
                    .foregroundStyle(.white.opacity(accessibility.secondaryOpacity(0.5)))

                // Size info
                HStack(spacing: 4) {
                    Image(systemName: "ruler")
                        .font(.system(size: 9))
                    Text(species.size)
                        .font(.system(size: 10))
                }
                .foregroundStyle(.white.opacity(accessibility.tertiaryOpacity(0.4)))
            }
            .padding(14)
        }
        .frame(width: 180, height: 260)
        .contentShape(Rectangle())
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(.white.opacity(0.1), lineWidth: 0.5)
        }
        .shadow(color: .black.opacity(0.3), radius: 8, y: 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(species.name), \(species.status.rawValue), \(species.size)\(isRead ? ", already viewed" : "")")
        .accessibilityHint("Tap to see details")
    }
}
struct EcosystemHealthCard: View {
    let regionId: String

    private var data: [(String, Double, Color)] {
        switch regionId {
        case "california":
            return [
                ("Kelp forests", 0.72, .teal),
                ("Rocky reefs", 0.85, .cyan),
                ("Estuaries", 0.60, .blue),
                ("Open ocean", 0.68, .indigo)
            ]
        case "bretagne":
            return [
                ("Seagrass beds", 0.65, .teal),
                ("Rocky shores", 0.80, .cyan),
                ("Mudflats", 0.55, .blue),
                ("Sandy bottoms", 0.75, .indigo)
            ]
        case "mediterranean":
            return [
                ("Posidonia meadows", 0.48, .teal),
                ("Coral reefs", 0.55, .cyan),
                ("Rocky coves", 0.72, .blue),
                ("Open pelagic", 0.63, .indigo)
            ]
        case "norway":
            return [
                ("Kelp forests", 0.78, .teal),
                ("Fjord ecosystems", 0.82, .cyan),
                ("Arctic seabed", 0.70, .blue),
                ("Pelagic waters", 0.75, .indigo)
            ]
        default:
            return []
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Ecosystem Health")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
                Spacer()
                Image(systemName: "heart.fill")
                    .foregroundStyle(.red.opacity(0.7))
            }

            ForEach(data, id: \.0) { item in
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(item.0)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.7))
                        Spacer()
                        Text("\(Int(item.1 * 100))%")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(item.2)
                    }

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(.white.opacity(0.08))
                                .frame(height: 8)

                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [item.2, item.2.opacity(0.6)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geo.size.width * item.1, height: 8)
                                .shadow(color: item.2.opacity(0.4), radius: 3)
                        }
                    }
                    .frame(height: 8)
                }
            }
        }
        .glassCard()
    }
}
struct ThreatsOverviewCard: View {
    let regionId: String

    private var threats: [(String, String, Color)] {
        switch regionId {
        case "california":
            return [
                ("Ocean warming", "thermometer.sun.fill", .orange),
                ("Plastic pollution", "trash.fill", .red),
                ("Overfishing", "fish.fill", .yellow),
                ("Acidification", "drop.fill", .purple)
            ]
        case "bretagne":
            return [
                ("Green algae", "leaf.fill", .green),
                ("Overfishing", "fish.fill", .orange),
                ("Chemical pollution", "flask.fill", .red),
                ("Coastal erosion", "mountain.2.fill", .yellow)
            ]
        case "mediterranean":
            return [
                ("Plastic pollution", "trash.fill", .red),
                ("Overfishing", "fish.fill", .orange),
                ("Invasive species", "ant.fill", .purple),
                ("Ocean warming", "thermometer.sun.fill", .yellow)
            ]
        case "norway":
            return [
                ("Ocean warming", "thermometer.sun.fill", .orange),
                ("Oil industry", "fuelpump.fill", .red),
                ("Invasive king crab", "ant.fill", .purple),
                ("Microplastics", "drop.triangle.fill", .yellow)
            ]
        default:
            return []
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Main Threats")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
                Spacer()
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
            }

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 10),
                GridItem(.flexible(), spacing: 10)
            ], spacing: 10) {
                ForEach(threats, id: \.0) { threat in
                    HStack(spacing: 10) {
                        Image(systemName: threat.1)
                            .font(.system(size: 16))
                            .foregroundStyle(threat.2)
                            .frame(width: 32, height: 32)
                            .background {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(threat.2.opacity(0.12))
                            }

                        Text(threat.0)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.white.opacity(0.7))
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(8)
                    .background {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(.white.opacity(0.04))
                    }
                }
            }
        }
        .glassCard()
    }
}
struct SpeciesDetailSheet: View {
    let species: Species
    @Environment(\.dismiss) private var dismiss
    @Environment(AccessibilityManager.self) private var accessibility

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                // Hero image
                ZStack(alignment: .topTrailing) {
                    Color.clear
                        .frame(height: 300)
                        .overlay {
                            Image(species.imageName)
                                .resizable()
                                .scaledToFill()
                        }
                        .clipped()
                        .overlay {
                            LinearGradient(
                                colors: [.clear, .clear, Color(red: 0.04, green: 0.08, blue: 0.18)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        }

                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.white.opacity(0.7))
                            .padding(16)
                    }
                }

                VStack(alignment: .leading, spacing: 20) {
                    // Name & status badge
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(alignment: .top) {
                            Text(species.name)
                                .font(.title.weight(.bold))
                                .foregroundStyle(.white)
                            Spacer()
                            VStack(spacing: 4) {
                                Text(species.status.shortLabel)
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background { Capsule().fill(species.status.color) }

                                HStack(spacing: 3) {
                                    Image(systemName: species.populationTrend.icon)
                                        .font(.caption2.weight(.bold))
                                    Text(species.populationTrend.rawValue)
                                        .font(.caption2.weight(.medium))
                                }
                                .foregroundStyle(species.populationTrend.color)
                            }
                        }

                        Text(species.scientificName)
                            .font(.subheadline.italic())
                            .foregroundStyle(.white.opacity(0.5))
                    }

                    // Quick info grid (2×2)
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)], spacing: 8) {
                        DetailInfoItem(icon: "ruler", label: "Size", value: species.size)
                        DetailInfoItem(icon: "scalemass", label: "Weight", value: species.weight)
                        DetailInfoItem(icon: "clock", label: "Lifespan", value: species.lifespan)
                        DetailInfoItem(icon: "arrow.down.to.line", label: "Depth", value: species.depthRange)
                    }

                    // Habitat & Diet row
                    HStack(spacing: 8) {
                        DetailInfoItem(icon: "water.waves", label: "Habitat", value: species.habitat)
                        DetailInfoItem(icon: "fork.knife", label: "Diet", value: species.diet)
                    }

                    // Population badge
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(species.populationTrend.color.opacity(0.15))
                                .frame(width: 44, height: 44)
                            Image(systemName: "person.3.fill")
                                .font(.body)
                                .foregroundStyle(species.populationTrend.color)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Population")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.4))
                            Text(species.population)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.white)
                        }

                        Spacer()

                        HStack(spacing: 4) {
                            Image(systemName: species.populationTrend.icon)
                                .font(.caption.weight(.bold))
                            Text(species.populationTrend.rawValue)
                                .font(.caption.weight(.semibold))
                        }
                        .foregroundStyle(species.populationTrend.color)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background {
                            Capsule()
                                .fill(species.populationTrend.color.opacity(0.12))
                        }
                    }
                    .padding(14)
                    .background {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(.white.opacity(0.05))
                    }

                    // Description
                    Text(species.description)
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.7))
                        .lineSpacing(5)

                    // Fun Fact callout
                    HStack(alignment: .top, spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(.yellow.opacity(0.15))
                                .frame(width: 36, height: 36)
                            Text("💡")
                                .font(.body)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Did you know?")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.yellow)
                            Text(species.funFact)
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.7))
                                .lineSpacing(4)
                        }
                    }
                    .padding(14)
                    .background {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(.yellow.opacity(0.06))
                            .overlay {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .strokeBorder(.yellow.opacity(0.12), lineWidth: 1)
                            }
                    }

                    // Threats
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.orange)
                            Text("Main Threats")
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(.white)
                        }

                        ForEach(Array(species.threats.enumerated()), id: \.offset) { index, threat in
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(.orange.opacity(0.12))
                                        .frame(width: 28, height: 28)
                                    Text("\(index + 1)")
                                        .font(.caption2.weight(.bold))
                                        .foregroundStyle(.orange)
                                }
                                Text(threat)
                                    .font(.subheadline)
                                    .foregroundStyle(.white.opacity(0.7))
                                Spacer()
                            }
                        }
                    }
                    .padding(16)
                    .background {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(.orange.opacity(0.06))
                            .overlay {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .strokeBorder(.orange.opacity(0.1), lineWidth: 1)
                            }
                    }

                    // Depth range visualization
                    DepthRangeBar(depthRange: species.depthRange)

                    Spacer().frame(height: 40)
                }
                .padding(20)
            }
        }
        .background(Color(red: 0.04, green: 0.08, blue: 0.18))
        .ignoresSafeArea(edges: .top)
    }
}
struct DepthRangeBar: View {
    let depthRange: String

    private var parsedRange: (min: Double, max: Double) {
        let cleaned = depthRange
            .replacingOccurrences(of: " m", with: "")
            .replacingOccurrences(of: " ", with: "")
        let parts = cleaned.components(separatedBy: "–")
        guard parts.count == 2,
              let minVal = Double(parts[0]),
              let maxVal = Double(parts[1]) else {
            return (0, 100)
        }
        return (minVal, maxVal)
    }

    var body: some View {
        let range = parsedRange
        let maxScale = max(range.max, 100)
        let startFraction = range.min / maxScale
        let endFraction = range.max / maxScale

        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "arrow.down.to.line")
                    .foregroundStyle(.cyan)
                Text("Activity Depth")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
            }

            GeometryReader { geo in
                let w = geo.size.width
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [.cyan.opacity(0.08), .blue.opacity(0.2)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )

                    // Active range
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [.cyan.opacity(0.5), .blue.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(8, w * (endFraction - startFraction)))
                        .offset(x: w * startFraction)
                }
            }
            .frame(height: 20)
            .clipShape(RoundedRectangle(cornerRadius: 6))

            HStack {
                Text("0 m")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.3))
                Spacer()
                Text(depthRange)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.cyan)
                Spacer()
                Text("\(Int(maxScale)) m")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.3))
            }
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.white.opacity(0.05))
        }
    }
}
struct DetailInfoItem: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.cyan)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.4))
            Text(value)
                .font(.caption.weight(.medium))
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 6)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.white.opacity(0.05))
        }
    }
}
struct MarineONG: Identifiable {
    let id = UUID()
    let name: String
    let icon: String        // SF Symbol
    let color: Color
    let description: String
    let websiteURL: String
    let scope: String       // "Locale" / "Nationale" / "Internationale"
}

extension MarineONG {
    static func organizations(for regionId: String) -> [MarineONG] {
        switch regionId {
        case "california":
            return [
                MarineONG(
                    name: "Monterey Bay Aquarium",
                    icon: "fish.fill",
                    color: .cyan,
                    description: "Ocean education",
                    websiteURL: "https://www.montereybayaquarium.org",
                    scope: "Local"
                ),
                MarineONG(
                    name: "Surfrider Foundation",
                    icon: "water.waves",
                    color: .blue,
                    description: "Ocean protection",
                    websiteURL: "https://www.surfrider.org",
                    scope: "National"
                ),
                MarineONG(
                    name: "Ocean Conservancy",
                    icon: "globe.americas.fill",
                    color: .teal,
                    description: "Coast cleanups",
                    websiteURL: "https://oceanconservancy.org",
                    scope: "National"
                ),
                MarineONG(
                    name: "Oceana",
                    icon: "leaf.fill",
                    color: .green,
                    description: "Ocean conservation",
                    websiteURL: "https://oceana.org",
                    scope: "International"
                ),
                MarineONG(
                    name: "Sea Shepherd",
                    icon: "shield.fill",
                    color: .orange,
                    description: "Direct action",
                    websiteURL: "https://seashepherd.org",
                    scope: "International"
                ),
            ]
        case "bretagne":
            return [
                MarineONG(
                    name: "Océanopolis",
                    icon: "fish.fill",
                    color: .cyan,
                    description: "Ocean science",
                    websiteURL: "https://www.oceanopolis.com",
                    scope: "Local"
                ),
                MarineONG(
                    name: "Surfrider Foundation Europe",
                    icon: "water.waves",
                    color: .blue,
                    description: "Shoreline protection",
                    websiteURL: "https://surfrider.eu",
                    scope: "Local"
                ),
                MarineONG(
                    name: "LPO — Bird Protection League",
                    icon: "bird.fill",
                    color: .mint,
                    description: "Seabird protection",
                    websiteURL: "https://www.lpo.fr",
                    scope: "National"
                ),
                MarineONG(
                    name: "Sea Shepherd France",
                    icon: "shield.fill",
                    color: .orange,
                    description: "Wildlife defense",
                    websiteURL: "https://seashepherd.fr",
                    scope: "National"
                ),
                MarineONG(
                    name: "WWF France",
                    icon: "globe.europe.africa.fill",
                    color: .green,
                    description: "Marine biodiversity",
                    websiteURL: "https://www.wwf.fr",
                    scope: "International"
                ),
            ]
        case "mediterranean":
            return [
                MarineONG(
                    name: "Parc national des Calanques",
                    icon: "mountain.2.fill",
                    color: .teal,
                    description: "Marine & coastal park",
                    websiteURL: "https://www.calanques-parcnational.fr",
                    scope: "Local"
                ),
                MarineONG(
                    name: "Institut Océanographique Paul Ricard",
                    icon: "fish.fill",
                    color: .cyan,
                    description: "Marine research",
                    websiteURL: "https://www.institut-paul-ricard.org",
                    scope: "Local"
                ),
                MarineONG(
                    name: "MedPAN",
                    icon: "globe.europe.africa.fill",
                    color: .blue,
                    description: "Mediterranean MPAs network",
                    websiteURL: "https://medpan.org",
                    scope: "International"
                ),
                MarineONG(
                    name: "WWF Mediterranean",
                    icon: "leaf.fill",
                    color: .green,
                    description: "Marine conservation",
                    websiteURL: "https://www.wwf.fr",
                    scope: "International"
                ),
                MarineONG(
                    name: "Sea Shepherd France",
                    icon: "shield.fill",
                    color: .orange,
                    description: "Direct action",
                    websiteURL: "https://seashepherd.fr",
                    scope: "National"
                ),
            ]
        case "norway":
            return [
                MarineONG(
                    name: "Norwegian Institute of Marine Research",
                    icon: "fish.fill",
                    color: .cyan,
                    description: "Ocean science",
                    websiteURL: "https://www.hi.no/en",
                    scope: "Local"
                ),
                MarineONG(
                    name: "WWF Norway",
                    icon: "globe.europe.africa.fill",
                    color: .green,
                    description: "Arctic conservation",
                    websiteURL: "https://www.wwf.no",
                    scope: "National"
                ),
                MarineONG(
                    name: "Bellona Foundation",
                    icon: "leaf.fill",
                    color: .mint,
                    description: "Ocean & climate",
                    websiteURL: "https://bellona.org",
                    scope: "National"
                ),
                MarineONG(
                    name: "Ocean Conservancy",
                    icon: "water.waves",
                    color: .blue,
                    description: "Global ocean protection",
                    websiteURL: "https://oceanconservancy.org",
                    scope: "International"
                ),
                MarineONG(
                    name: "Greenpeace Nordic",
                    icon: "shield.fill",
                    color: .orange,
                    description: "Arctic defense",
                    websiteURL: "https://www.greenpeace.org/norway",
                    scope: "International"
                ),
            ]
        default:
            return []
        }
    }
}
struct ONGSectionCard: View {
    let regionId: String
    @Environment(AccessibilityManager.self) private var accessibility

    private var organizations: [MarineONG] {
        MarineONG.organizations(for: regionId)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(.green.opacity(0.15))
                        .frame(width: 36, height: 36)
                    Image(systemName: "heart.circle.fill")
                        .font(.body)
                        .foregroundStyle(.green)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Take Action for the Ocean")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                    Text("Marine conservation organizations")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(accessibility.tertiaryOpacity(0.4)))
                }
            }

            // ONG list
            VStack(spacing: 10) {
                ForEach(organizations) { ong in
                    ONGRow(ong: ong)
                }
            }

            // Footer message
            HStack(spacing: 8) {
                Image(systemName: "info.circle")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.3))
                Text("Every action counts. Learn, share, act. 🌍")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.4))
                    .lineSpacing(2)
            }
            .padding(.top, 4)
        }
        .padding(18)
        .glassCard()
    }
}
struct ONGRow: View {
    let ong: MarineONG
    @Environment(AccessibilityManager.self) private var accessibility
    @State private var showInternetAlert = false

    var body: some View {
        Button {
            showInternetAlert = true
        } label: {
            HStack(spacing: 14) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(ong.color.opacity(0.12))
                        .frame(width: 44, height: 44)
                    Image(systemName: ong.icon)
                        .font(.body.weight(.medium))
                        .foregroundStyle(ong.color)
                }

                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(ong.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)

                    HStack(spacing: 6) {
                        Text(ong.scope)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(ong.color)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background {
                                Capsule()
                                    .fill(ong.color.opacity(0.12))
                            }

                        Text(ong.description)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(accessibility.secondaryOpacity(0.5)))
                            .lineLimit(1)
                    }
                }

                Spacer(minLength: 4)

                // External link indicator
                Image(systemName: "arrow.up.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white.opacity(accessibility.tertiaryOpacity(0.25)))
            }
            .padding(12)
            .background {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(.white.opacity(0.04))
                    .overlay {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(.white.opacity(accessibility.borderOpacity(0.06)), lineWidth: 1)
                    }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(ong.name), \(ong.scope), \(ong.description)")
        .accessibilityHint("Opens the organization's website")
        .alert("Open External Link", isPresented: $showInternetAlert) {
            Button("Open in Safari") {
                if let url = URL(string: ong.websiteURL) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("You are about to leave Blue to visit \(ong.name). Make sure you are connected to the internet.")
        }
    }
}
