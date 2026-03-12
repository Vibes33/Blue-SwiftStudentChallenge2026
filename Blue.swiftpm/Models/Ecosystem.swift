import SwiftUI
import Charts
struct EcosystemOrganism: Identifiable, Equatable {
    let id: String
    let name: String
    let emoji: String
    let trophicLevel: TrophicLevel  // Position in food chain
    let basePopulation: Int         // Starting population count
    let preys: [String]             // IDs of species it eats
    let predators: [String]         // IDs of species that eat it
    let description: String         // What happens when removed
    let depthRange: ClosedRange<Double> // 0 = surface, 1 = deep

    static func == (lhs: EcosystemOrganism, rhs: EcosystemOrganism) -> Bool {
        lhs.id == rhs.id
    }
}

enum TrophicLevel: Int, CaseIterable, Comparable {
    case producer = 0       // Kelp, plankton, zostera
    case primaryConsumer = 1 // Urchins, small fish, shrimp
    case secondaryConsumer = 2 // Otters, lobsters, seals
    case topPredator = 3    // Sharks, orcas

    static func < (lhs: TrophicLevel, rhs: TrophicLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    var label: String {
        switch self {
        case .producer: return "Producers"
        case .primaryConsumer: return "Consumers I"
        case .secondaryConsumer: return "Consumers II"
        case .topPredator: return "Predators"
        }
    }

    var color: Color {
        switch self {
        case .producer: return .green
        case .primaryConsumer: return .yellow
        case .secondaryConsumer: return .orange
        case .topPredator: return .red
        }
    }
}
/// A snapshot of all populations at a given step in the simulation.
struct PopulationSnapshot: Identifiable {
    let id = UUID()
    let step: Int
    let populations: [String: Double]
}

@Observable
class EcosystemState {
    let organisms: [EcosystemOrganism]
    var removedSpecies: Set<String> = []
    var populations: [String: Double] = [:]  // ratio vs base (1.0 = normal)
    var cascadeMessages: [CascadeMessage] = []
    var isSimulating: Bool = false

    /// History of population snapshots for the chart
    var populationHistory: [PopulationSnapshot] = []
    private var currentStep: Int = 0

    struct CascadeMessage: Identifiable {
        let id = UUID()
        let text: String
        let icon: String
        let color: Color
        let timestamp: Date = Date()
    }

    init(organisms: [EcosystemOrganism]) {
        self.organisms = organisms
        // Initialize all populations to 1.0 (100%)
        for org in organisms {
            populations[org.id] = 1.0
        }
        // Record initial state
        recordSnapshot()
    }

    func reset() {
        removedSpecies.removeAll()
        cascadeMessages.removeAll()
        for org in organisms {
            populations[org.id] = 1.0
        }
        isSimulating = false
        populationHistory.removeAll()
        currentStep = 0
        recordSnapshot()
    }

    /// Capture current population state as a snapshot
    private func recordSnapshot() {
        currentStep += 1
        populationHistory.append(PopulationSnapshot(step: currentStep, populations: populations))
    }

    var activeOrganisms: [EcosystemOrganism] {
        organisms.filter { !removedSpecies.contains($0.id) }
    }

    var healthPercentage: Double {
        guard !organisms.isEmpty else { return 0 }
        let totalPop = organisms.reduce(0.0) { $0 + (populations[$1.id] ?? 0) }
        return totalPop / Double(organisms.count)
    }

    var healthColor: Color {
        let h = healthPercentage
        if h > 0.8 { return .green }
        if h > 0.5 { return .yellow }
        if h > 0.3 { return .orange }
        return .red
    }

    var healthLabel: String {
        let h = healthPercentage
        if h > 0.8 { return "Healthy ecosystem" }
        if h > 0.5 { return "Weakened ecosystem" }
        if h > 0.3 { return "Ecosystem at risk" }
        return "Ecological collapse"
    }
    func removeSpecies(_ id: String) {
        guard !removedSpecies.contains(id) else { return }
        guard let organism = organisms.first(where: { $0.id == id }) else { return }

        isSimulating = true
        removedSpecies.insert(id)

        withAnimation(.easeOut(duration: 0.5)) {
            populations[id] = 0
        }

        // Add removal message
        cascadeMessages.append(CascadeMessage(
            text: "\(organism.emoji) \(organism.name) removed from the ecosystem",
            icon: "minus.circle.fill",
            color: .red
        ))

        // Record snapshot after removal
        recordSnapshot()

        // Trigger cascade with delays for dramatic effect
        var delay: Double = 0.6

        // 1. Species that ATE the removed species lose a food source
        for org in organisms where !removedSpecies.contains(org.id) {
            if org.preys.contains(id) {
                let currentPop = populations[org.id] ?? 1.0
                // Lose population proportional to how much they depended on this prey
                let dependencyRatio = 1.0 / Double(max(org.preys.filter { !removedSpecies.contains($0) }.count + 1, 1))
                let newPop = max(currentPop - dependencyRatio * 0.5, 0.1)

                let capturedOrg = org
                let capturedPop = newPop
                let capturedDelay = delay

                DispatchQueue.main.asyncAfter(deadline: .now() + capturedDelay) {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        self.populations[capturedOrg.id] = capturedPop
                    }
                    self.cascadeMessages.append(CascadeMessage(
                        text: "\(capturedOrg.emoji) \(capturedOrg.name) loses a food source",
                        icon: "arrow.down.circle.fill",
                        color: .orange
                    ))
                    self.recordSnapshot()
                }
                delay += 0.5
            }
        }

        // 2. Species that WERE EATEN by the removed species boom (no predator)
        for org in organisms where !removedSpecies.contains(org.id) {
            if org.predators.contains(id) {
                let currentPop = populations[org.id] ?? 1.0
                // Check if any other predators remain
                let remainingPredators = org.predators.filter { !removedSpecies.contains($0) }
                let boom = remainingPredators.isEmpty ? 0.8 : 0.3
                let newPop = min(currentPop + boom, 2.5)

                let capturedOrg = org
                let capturedPop = newPop
                let capturedDelay = delay

                DispatchQueue.main.asyncAfter(deadline: .now() + capturedDelay) {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        self.populations[capturedOrg.id] = capturedPop
                    }
                    self.cascadeMessages.append(CascadeMessage(
                        text: "\(capturedOrg.emoji) \(capturedOrg.name) proliferates without predator!",
                        icon: "arrow.up.circle.fill",
                        color: .yellow
                    ))
                    self.recordSnapshot()
                }
                delay += 0.5
            }
        }

        // 3. Secondary cascade — overpopulated species eat more of THEIR prey
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.secondaryCascade()
            self.recordSnapshot()
            self.isSimulating = false
        }
    }

    private func secondaryCascade() {
        for org in organisms where !removedSpecies.contains(org.id) {
            let pop = populations[org.id] ?? 1.0
            if pop > 1.5 {
                // This species is overpopulated — it over-consumes its prey
                for preyId in org.preys {
                    guard !removedSpecies.contains(preyId),
                          let prey = organisms.first(where: { $0.id == preyId }) else { continue }

                    let preyPop = populations[preyId] ?? 1.0
                    let consumption = (pop - 1.0) * 0.4
                    let newPreyPop = max(preyPop - consumption, 0.05)

                    withAnimation(.easeInOut(duration: 1.0)) {
                        populations[preyId] = newPreyPop
                    }

                    if newPreyPop < 0.3 {
                        cascadeMessages.append(CascadeMessage(
                            text: "\(prey.emoji) \(prey.name) in critical decline!",
                            icon: "exclamationmark.triangle.fill",
                            color: .red
                        ))
                    }
                }
            }
        }
    }
}
extension EcosystemOrganism {
    static let californiaEcosystem: [EcosystemOrganism] = [
        EcosystemOrganism(
            id: "eco_kelp",
            name: "Kelp Forest",
            emoji: "🌿",
            trophicLevel: .producer,
            basePopulation: 100,
            preys: [],
            predators: ["eco_urchin"],
            description: "The kelp forest is the foundation of the ecosystem. Without it, everything collapses.",
            depthRange: 0.3...0.7
        ),
        EcosystemOrganism(
            id: "eco_plankton",
            name: "Plankton",
            emoji: "🫧",
            trophicLevel: .producer,
            basePopulation: 200,
            preys: [],
            predators: ["eco_smallfish", "eco_whale"],
            description: "Plankton feeds the entire ocean food chain.",
            depthRange: 0.1...0.4
        ),
        EcosystemOrganism(
            id: "eco_urchin",
            name: "Sea Urchins",
            emoji: "🟣",
            trophicLevel: .primaryConsumer,
            basePopulation: 60,
            preys: ["eco_kelp"],
            predators: ["eco_otter"],
            description: "Sea urchins graze on kelp. Without predators, they decimate underwater forests.",
            depthRange: 0.5...0.8
        ),
        EcosystemOrganism(
            id: "eco_smallfish",
            name: "Fish",
            emoji: "🐟",
            trophicLevel: .primaryConsumer,
            basePopulation: 80,
            preys: ["eco_plankton"],
            predators: ["eco_sealion", "eco_shark"],
            description: "Small fish are the central link of the food chain.",
            depthRange: 0.2...0.6
        ),
        EcosystemOrganism(
            id: "eco_otter",
            name: "Sea Otter",
            emoji: "🦦",
            trophicLevel: .secondaryConsumer,
            basePopulation: 25,
            preys: ["eco_urchin"],
            predators: ["eco_shark"],
            description: "The sea otter controls urchins and indirectly protects the kelp forest.",
            depthRange: 0.1...0.4
        ),
        EcosystemOrganism(
            id: "eco_sealion",
            name: "Sea Lion",
            emoji: "🦭",
            trophicLevel: .secondaryConsumer,
            basePopulation: 30,
            preys: ["eco_smallfish"],
            predators: ["eco_shark"],
            description: "The sea lion regulates fish populations.",
            depthRange: 0.2...0.5
        ),
        EcosystemOrganism(
            id: "eco_whale",
            name: "Blue Whale",
            emoji: "🐋",
            trophicLevel: .secondaryConsumer,
            basePopulation: 5,
            preys: ["eco_plankton"],
            predators: [],
            description: "The blue whale fertilizes the ocean with its nutrients, stimulating plankton.",
            depthRange: 0.3...0.8
        ),
        EcosystemOrganism(
            id: "eco_shark",
            name: "Great White Shark",
            emoji: "🦈",
            trophicLevel: .topPredator,
            basePopulation: 8,
            preys: ["eco_sealion", "eco_otter", "eco_smallfish"],
            predators: [],
            description: "The shark regulates all populations below. Removing it throws everything off balance.",
            depthRange: 0.2...0.9
        ),
    ]

    static let bretagneEcosystem: [EcosystemOrganism] = [
        EcosystemOrganism(
            id: "eco_zostera",
            name: "Eelgrass Meadow",
            emoji: "🌱",
            trophicLevel: .producer,
            basePopulation: 100,
            preys: [],
            predators: ["eco_shrimp"],
            description: "The eelgrass meadow is the nursery of the Breton ecosystem.",
            depthRange: 0.3...0.6
        ),
        EcosystemOrganism(
            id: "eco_phyto",
            name: "Phytoplankton",
            emoji: "🫧",
            trophicLevel: .producer,
            basePopulation: 200,
            preys: [],
            predators: ["eco_shrimp", "eco_sardine"],
            description: "Phytoplankton is the foundation of all Breton marine life.",
            depthRange: 0.1...0.3
        ),
        EcosystemOrganism(
            id: "eco_shrimp",
            name: "Shrimp",
            emoji: "🦐",
            trophicLevel: .primaryConsumer,
            basePopulation: 90,
            preys: ["eco_phyto", "eco_zostera"],
            predators: ["eco_lobster", "eco_dolphin"],
            description: "Shrimp are essential in the coastal food web.",
            depthRange: 0.4...0.7
        ),
        EcosystemOrganism(
            id: "eco_sardine",
            name: "Sardines",
            emoji: "🐟",
            trophicLevel: .primaryConsumer,
            basePopulation: 120,
            preys: ["eco_phyto"],
            predators: ["eco_seal", "eco_puffin", "eco_basking"],
            description: "Sardines are the main prey of many species.",
            depthRange: 0.2...0.5
        ),
        EcosystemOrganism(
            id: "eco_lobster",
            name: "European Lobster",
            emoji: "🦞",
            trophicLevel: .secondaryConsumer,
            basePopulation: 20,
            preys: ["eco_shrimp"],
            predators: ["eco_seal"],
            description: "The lobster is an important benthic predator.",
            depthRange: 0.6...0.9
        ),
        EcosystemOrganism(
            id: "eco_puffin",
            name: "Atlantic Puffin",
            emoji: "🐧",
            trophicLevel: .secondaryConsumer,
            basePopulation: 35,
            preys: ["eco_sardine"],
            predators: [],
            description: "The puffin dives to fish. Without sardines, its colonies disappear.",
            depthRange: 0.0...0.3
        ),
        EcosystemOrganism(
            id: "eco_seal",
            name: "Grey Seal",
            emoji: "🦭",
            trophicLevel: .secondaryConsumer,
            basePopulation: 15,
            preys: ["eco_sardine", "eco_lobster"],
            predators: ["eco_basking"],
            description: "The grey seal regulates coastal fish populations.",
            depthRange: 0.1...0.5
        ),
        EcosystemOrganism(
            id: "eco_dolphin",
            name: "Bottlenose Dolphin",
            emoji: "🐬",
            trophicLevel: .topPredator,
            basePopulation: 10,
            preys: ["eco_shrimp", "eco_sardine"],
            predators: [],
            description: "The dolphin is a social super-predator that structures the ecosystem.",
            depthRange: 0.1...0.6
        ),
    ]
    static let mediterraneanEcosystem: [EcosystemOrganism] = [
        EcosystemOrganism(
            id: "eco_posidonia",
            name: "Posidonia",
            emoji: "🌿",
            trophicLevel: .producer,
            basePopulation: 200,
            preys: [],
            predators: [],
            description: "Posidonia meadows are the foundation of Mediterranean ecosystems, producing oxygen and sheltering species.",
            depthRange: 0.7...1.0
        ),
        EcosystemOrganism(
            id: "eco_med_phyto",
            name: "Phytoplankton",
            emoji: "🦠",
            trophicLevel: .producer,
            basePopulation: 300,
            preys: [],
            predators: ["eco_anchovy", "eco_med_shrimp"],
            description: "Microscopic algae fuel the Mediterranean food web through photosynthesis.",
            depthRange: 0.3...0.7
        ),
        EcosystemOrganism(
            id: "eco_med_shrimp",
            name: "Mediterranean Shrimp",
            emoji: "🦐",
            trophicLevel: .primaryConsumer,
            basePopulation: 100,
            preys: ["eco_med_phyto"],
            predators: ["eco_moray", "eco_grouper"],
            description: "Shrimp are a vital link between plankton and larger predators.",
            depthRange: 0.5...0.8
        ),
        EcosystemOrganism(
            id: "eco_anchovy",
            name: "Anchovy",
            emoji: "🐟",
            trophicLevel: .primaryConsumer,
            basePopulation: 150,
            preys: ["eco_med_phyto"],
            predators: ["eco_tuna", "eco_moray", "eco_grouper"],
            description: "Schooling anchovies are prey for almost every Mediterranean predator.",
            depthRange: 0.2...0.5
        ),
        EcosystemOrganism(
            id: "eco_moray",
            name: "Moray Eel",
            emoji: "🐍",
            trophicLevel: .secondaryConsumer,
            basePopulation: 25,
            preys: ["eco_anchovy", "eco_med_shrimp"],
            predators: ["eco_grouper"],
            description: "The moray eel ambushes prey from rocky crevices with its pharyngeal jaws.",
            depthRange: 0.5...0.8
        ),
        EcosystemOrganism(
            id: "eco_grouper",
            name: "Dusky Grouper",
            emoji: "🐡",
            trophicLevel: .secondaryConsumer,
            basePopulation: 15,
            preys: ["eco_anchovy", "eco_med_shrimp", "eco_moray"],
            predators: ["eco_monk_seal"],
            description: "The grouper is an apex reef predator that controls smaller fish populations.",
            depthRange: 0.3...0.7
        ),
        EcosystemOrganism(
            id: "eco_turtle",
            name: "Loggerhead Turtle",
            emoji: "🐢",
            trophicLevel: .secondaryConsumer,
            basePopulation: 12,
            preys: ["eco_med_shrimp"],
            predators: [],
            description: "Sea turtles regulate jellyfish populations and transport nutrients across ecosystems.",
            depthRange: 0.1...0.5
        ),
        EcosystemOrganism(
            id: "eco_monk_seal",
            name: "Monk Seal",
            emoji: "🦭",
            trophicLevel: .topPredator,
            basePopulation: 5,
            preys: ["eco_anchovy", "eco_grouper"],
            predators: [],
            description: "The rarest marine mammal, the monk seal is the Mediterranean's top predator.",
            depthRange: 0.1...0.4
        ),
    ]
    static let norwayEcosystem: [EcosystemOrganism] = [
        EcosystemOrganism(
            id: "eco_nor_phyto",
            name: "Arctic Phytoplankton",
            emoji: "🦠",
            trophicLevel: .producer,
            basePopulation: 250,
            preys: [],
            predators: ["eco_krill", "eco_herring"],
            description: "Cold Arctic waters support explosive phytoplankton blooms in spring and summer.",
            depthRange: 0.5...1.0
        ),
        EcosystemOrganism(
            id: "eco_kelp_nor",
            name: "Kelp Forest",
            emoji: "🌿",
            trophicLevel: .producer,
            basePopulation: 180,
            preys: [],
            predators: [],
            description: "Norwegian kelp forests shelter fish nurseries and stabilize coastal ecosystems.",
            depthRange: 0.6...0.9
        ),
        EcosystemOrganism(
            id: "eco_krill",
            name: "Arctic Krill",
            emoji: "🦐",
            trophicLevel: .primaryConsumer,
            basePopulation: 200,
            preys: ["eco_nor_phyto"],
            predators: ["eco_cod", "eco_wolffish", "eco_humpback"],
            description: "Krill swarms are the keystone prey species fueling Norway's entire marine food web.",
            depthRange: 0.3...0.7
        ),
        EcosystemOrganism(
            id: "eco_herring",
            name: "Norwegian Herring",
            emoji: "🐟",
            trophicLevel: .primaryConsumer,
            basePopulation: 150,
            preys: ["eco_nor_phyto"],
            predators: ["eco_cod", "eco_orca", "eco_humpback", "eco_eagle"],
            description: "Massive herring shoals drive the winter feeding frenzy of orcas and whales in the fjords.",
            depthRange: 0.2...0.6
        ),
        EcosystemOrganism(
            id: "eco_cod",
            name: "Atlantic Cod",
            emoji: "🐟",
            trophicLevel: .secondaryConsumer,
            basePopulation: 40,
            preys: ["eco_krill", "eco_herring"],
            predators: ["eco_orca", "eco_eagle"],
            description: "The cod is Norway's most iconic fish — its dried form (stockfish) powered Viking exploration.",
            depthRange: 0.3...0.8
        ),
        EcosystemOrganism(
            id: "eco_wolffish",
            name: "Atlantic Wolffish",
            emoji: "🐺",
            trophicLevel: .secondaryConsumer,
            basePopulation: 20,
            preys: ["eco_krill", "eco_herring"],
            predators: ["eco_eagle"],
            description: "The wolffish crushes sea urchins and crabs, preventing urchin barrens that destroy kelp forests.",
            depthRange: 0.5...0.9
        ),
        EcosystemOrganism(
            id: "eco_eagle",
            name: "White-tailed Eagle",
            emoji: "🦅",
            trophicLevel: .secondaryConsumer,
            basePopulation: 20,
            preys: ["eco_herring", "eco_cod", "eco_wolffish"],
            predators: [],
            description: "Europe's largest raptor snatches fish from the surface at 70 km/h.",
            depthRange: 0.0...0.1
        ),
        EcosystemOrganism(
            id: "eco_orca",
            name: "Orca",
            emoji: "🐋",
            trophicLevel: .topPredator,
            basePopulation: 8,
            preys: ["eco_herring", "eco_cod"],
            predators: [],
            description: "Orcas use carousel feeding to corral herring in the fjords — the apex predator of Norwegian waters.",
            depthRange: 0.0...0.5
        ),
        EcosystemOrganism(
            id: "eco_humpback",
            name: "Humpback Whale",
            emoji: "🐳",
            trophicLevel: .topPredator,
            basePopulation: 6,
            preys: ["eco_krill", "eco_herring"],
            predators: [],
            description: "Humpback whales lunge-feed on vast swarms of krill and herring in Arctic fjords.",
            depthRange: 0.0...0.4
        ),
    ]

    static func ecosystem(for regionId: String) -> [EcosystemOrganism] {
        switch regionId {
        case "california": return californiaEcosystem
        case "bretagne": return bretagneEcosystem
        case "mediterranean": return mediterraneanEcosystem
        case "norway": return norwayEcosystem
        default: return californiaEcosystem
        }
    }
}
