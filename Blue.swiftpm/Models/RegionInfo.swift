import SwiftUI
struct RegionInfo: Identifiable {
    let id: String
    let regionId: String
    let funFacts: [FunFact]
    let stats: [RegionStat]
    let highlights: [Highlight]
}

struct FunFact: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
}

struct Highlight: Identifiable {
    let id = UUID()
    let name: String
    let latitude: Double
    let longitude: Double
}

struct RegionStat: Identifiable {
    let id = UUID()
    let label: String
    let value: String
    let icon: String
    let color: Color
}
extension RegionInfo {
    static func info(for regionId: String) -> RegionInfo {
        switch regionId {
        case "california":
            return californiaInfo
        case "bretagne":
            return bretagneInfo
        case "mediterranean":
            return mediterraneanInfo
        case "norway":
            return norwayInfo
        default:
            return defaultInfo
        }
    }

    static let californiaInfo = RegionInfo(
        id: "california_info",
        regionId: "california",
        funFacts: [
            FunFact(
                icon: "🦦",
                title: "Sea otters: tool users",
                description: "Sea otters use rocks to crack open shellfish — among the few marine tool users."
            ),
            FunFact(
                icon: "🐋",
                title: "Whale highway",
                description: "Over 20,000 gray whales migrate along the California coast each year."
            ),
            FunFact(
                icon: "🦈",
                title: "Red Triangle",
                description: "The zone between Monterey and Bodega Bay accounts for 38% of great white shark encounters."
            ),
            FunFact(
                icon: "🌊",
                title: "Underwater forests",
                description: "Kelp forests can grow 60 cm per day and shelter over 1,000 species."
            )
        ],
        stats: [
            RegionStat(label: "Protected species", value: "34", icon: "fish.fill", color: .cyan),
            RegionStat(label: "Marine areas", value: "124", icon: "water.waves", color: .blue),
            RegionStat(label: "Km of coastline", value: "1,350", icon: "map.fill", color: .teal),
            RegionStat(label: "Marine sanctuaries", value: "4", icon: "shield.fill", color: .mint)
        ],
        highlights: [
            Highlight(name: "Monterey Bay Marine Sanctuary", latitude: 36.60, longitude: -122.00),
            Highlight(name: "Channel Islands National Park", latitude: 34.00, longitude: -119.77),
            Highlight(name: "Point Lobos Marine Reserve", latitude: 36.52, longitude: -121.94),
            Highlight(name: "Farallon Wildlife Refuge", latitude: 37.70, longitude: -123.00)
        ]
    )

    static let bretagneInfo = RegionInfo(
        id: "bretagne_info",
        regionId: "bretagne",
        funFacts: [
            FunFact(
                icon: "🦭",
                title: "Grey seal colony",
                description: "The Molène archipelago hosts France's largest grey seal colony — over 300 individuals."
            ),
            FunFact(
                icon: "🐬",
                title: "Resident dolphins",
                description: "Bottlenose dolphins live year-round in the Iroise Sea — a rare resident group in Europe."
            ),
            FunFact(
                icon: "🦞",
                title: "Blue European lobster",
                description: "Breton waters are among the last refuges of the European blue lobster, declining elsewhere."
            ),
            FunFact(
                icon: "🌿",
                title: "Eelgrass meadows",
                description: "The Gulf of Morbihan has France's largest eelgrass beds — nurseries for dozens of species."
            )
        ],
        stats: [
            RegionStat(label: "Protected species", value: "28", icon: "fish.fill", color: .cyan),
            RegionStat(label: "Nature reserves", value: "15", icon: "water.waves", color: .blue),
            RegionStat(label: "Km of coastline", value: "2,730", icon: "map.fill", color: .teal),
            RegionStat(label: "Marine parks", value: "3", icon: "shield.fill", color: .mint)
        ],
        highlights: [
            Highlight(name: "Iroise Marine Nature Park", latitude: 48.38, longitude: -4.96),
            Highlight(name: "Sept-Îles Reserve", latitude: 48.88, longitude: -3.43),
            Highlight(name: "Gulf of Morbihan", latitude: 47.58, longitude: -2.77),
            Highlight(name: "Molène Archipelago", latitude: 48.40, longitude: -4.95)
        ]
    )

    static let mediterraneanInfo = RegionInfo(
        id: "mediterranean_info",
        regionId: "mediterranean",
        funFacts: [
            FunFact(
                icon: "🌿",
                title: "Posidonia: ocean lungs",
                description: "Posidonia meadows produce more oxygen per m² than the Amazon rainforest and store carbon for millennia."
            ),
            FunFact(
                icon: "🐢",
                title: "Ancient travelers",
                description: "Loggerhead turtles nesting in the Mediterranean can travel over 12,000 km in a single migration cycle."
            ),
            FunFact(
                icon: "🦭",
                title: "Rarest seal on Earth",
                description: "The Mediterranean monk seal is the world's most endangered pinniped — fewer than 700 remain."
            ),
            FunFact(
                icon: "🐟",
                title: "Biodiversity hotspot",
                description: "The Mediterranean holds 7% of all known marine species despite covering less than 1% of the ocean surface."
            )
        ],
        stats: [
            RegionStat(label: "Marine species", value: "17,000", icon: "fish.fill", color: .cyan),
            RegionStat(label: "Protected areas", value: "1,231", icon: "water.waves", color: .blue),
            RegionStat(label: "Km of coastline", value: "46,000", icon: "map.fill", color: .teal),
            RegionStat(label: "UNESCO sites", value: "12", icon: "shield.fill", color: .mint)
        ],
        highlights: [
            Highlight(name: "Calanques National Park", latitude: 43.21, longitude: 5.45),
            Highlight(name: "Port-Cros National Park", latitude: 43.00, longitude: 6.40),
            Highlight(name: "Pelagos Sanctuary", latitude: 43.25, longitude: 8.00),
            Highlight(name: "Côte Bleue Marine Park", latitude: 43.33, longitude: 5.15)
        ]
    )

    static let norwayInfo = RegionInfo(
        id: "norway_info",
        regionId: "norway",
        funFacts: [
            FunFact(
                icon: "🐋",
                title: "Whale watching capital",
                description: "Northern Norway is one of the best places on Earth to see orcas and humpback whales hunting herring."
            ),
            FunFact(
                icon: "🦅",
                title: "Sea eagle kingdom",
                description: "Norway has Europe's largest population of white-tailed eagles, with over 4,000 breeding pairs."
            ),
            FunFact(
                icon: "🦀",
                title: "Giant invader",
                description: "The red king crab, introduced from Russia, has spread across Norway — some weigh over 10 kg."
            ),
            FunFact(
                icon: "🌊",
                title: "Maelstrom power",
                description: "The Saltstraumen strait has the world's strongest tidal current — reaching 40 km/h."
            )
        ],
        stats: [
            RegionStat(label: "Marine species", value: "9,000", icon: "fish.fill", color: .cyan),
            RegionStat(label: "Fjords", value: "1,190", icon: "water.waves", color: .blue),
            RegionStat(label: "Km of coastline", value: "100,915", icon: "map.fill", color: .teal),
            RegionStat(label: "Marine reserves", value: "19", icon: "shield.fill", color: .mint)
        ],
        highlights: [
            Highlight(name: "Lofoten Islands", latitude: 68.20, longitude: 14.40),
            Highlight(name: "Tromsø Arctic Waters", latitude: 69.65, longitude: 18.95),
            Highlight(name: "Saltstraumen Tidal Current", latitude: 67.23, longitude: 14.62),
            Highlight(name: "Vesterålen Marine Zone", latitude: 68.80, longitude: 15.40)
        ]
    )

    static let defaultInfo = RegionInfo(
        id: "default_info",
        regionId: "unknown",
        funFacts: [],
        stats: [],
        highlights: []
    )
}
