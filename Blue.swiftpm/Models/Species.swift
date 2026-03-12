import SwiftUI
struct Species: Identifiable, Hashable {
    let id: String
    let name: String
    let scientificName: String
    let category: SpeciesCategory
    let status: ConservationStatus
    let imageName: String
    let description: String
    let regionId: String
    let threats: [String]
    let size: String
    let habitat: String
    let diet: String
    let lifespan: String
    let population: String
    let funFact: String
    let populationTrend: PopulationTrend
    let depthRange: String
    let weight: String
}
enum PopulationTrend: String {
    case increasing = "Increasing"
    case stable = "Stable"
    case decreasing = "Declining"
    case unknown = "Unknown"

    var icon: String {
        switch self {
        case .increasing: return "arrow.up.right"
        case .stable: return "arrow.right"
        case .decreasing: return "arrow.down.right"
        case .unknown: return "questionmark"
        }
    }

    var color: Color {
        switch self {
        case .increasing: return .green
        case .stable: return .cyan
        case .decreasing: return .red
        case .unknown: return .gray
        }
    }
}
enum SpeciesCategory: String, CaseIterable {
    case emblematic = "Emblematic"
    case protected = "Protected"

    var icon: String {
        switch self {
        case .emblematic: return "star.fill"
        case .protected: return "shield.fill"
        }
    }

    var color: Color {
        switch self {
        case .emblematic: return .orange
        case .protected: return .red
        }
    }
}
enum ConservationStatus: String {
    case leastConcern = "Least Concern"
    case nearThreatened = "Near Threatened"
    case vulnerable = "Vulnerable"
    case endangered = "Endangered"
    case criticallyEndangered = "Critically Endangered"

    var shortLabel: String {
        switch self {
        case .leastConcern: return "LC"
        case .nearThreatened: return "NT"
        case .vulnerable: return "VU"
        case .endangered: return "EN"
        case .criticallyEndangered: return "CR"
        }
    }

    var color: Color {
        switch self {
        case .leastConcern: return .green
        case .nearThreatened: return .yellow
        case .vulnerable: return .orange
        case .endangered: return .red
        case .criticallyEndangered: return .purple
        }
    }
}
extension Species {

    static func species(for regionId: String) -> [Species] {
        allSpecies.filter { $0.regionId == regionId }
    }

    static func emblematic(for regionId: String) -> [Species] {
        species(for: regionId).filter { $0.category == .emblematic }
    }

    static func protected(for regionId: String) -> [Species] {
        species(for: regionId).filter { $0.category == .protected }
    }
    static let allSpecies: [Species] = californiaSpecies + bretagneSpecies + mediterraneanSpecies + norwaySpecies

    // MARK: California Species

    static let californiaSpecies: [Species] = [
        Species(
            id: "kelp_forest",
            name: "Giant Kelp",
            scientificName: "Macrocystis pyrifera",
            category: .emblematic,
            status: .leastConcern,
            imageName: "imagecalifornie1",
            description: "Giant kelp is the largest seaweed in the world, reaching up to 45 meters tall. These underwater forests shelter over 1,000 species and play a crucial role in the Californian coastal ecosystem.",
            regionId: "california",
            threats: ["Ocean warming", "Invasive sea urchins", "Coastal pollution"],
            size: "Up to 45 m",
            habitat: "Rocky coastal waters, 6-30 m depth",
            diet: "Photosynthesis",
            lifespan: "4 to 8 years",
            population: "Variable extent",
            funFact: "Kelp can grow 60 cm per day, making it one of the fastest-growing organisms on Earth.",
            populationTrend: .decreasing,
            depthRange: "6 – 30 m",
            weight: "—"
        ),
        Species(
            id: "sea_otter",
            name: "Sea Otter",
            scientificName: "Enhydra lutris nereis",
            category: .emblematic,
            status: .endangered,
            imageName: "imagecalifornie2",
            description: "The California sea otter is a keystone species. By feeding on sea urchins, it protects kelp forests. It is one of the few marine mammals to use tools.",
            regionId: "california",
            threats: ["Oil spills", "Sharks", "Parasitic diseases"],
            size: "1.2 m",
            habitat: "Coastal kelp forests",
            diet: "Sea urchins, mussels, crabs, abalone",
            lifespan: "15 to 20 years",
            population: "≈ 3,000 individuals",
            funFact: "Sea otters hold hands while sleeping to avoid drifting apart from each other.",
            populationTrend: .increasing,
            depthRange: "0 – 40 m",
            weight: "22 – 35 kg"
        ),
        Species(
            id: "california_sea_lion",
            name: "California Sea Lion",
            scientificName: "Zalophus californianus",
            category: .emblematic,
            status: .leastConcern,
            imageName: "imagecalifornie3",
            description: "The California sea lion is the most common pinniped on the West Coast. Highly social and intelligent, it forms large colonies on beaches and docks.",
            regionId: "california",
            threats: ["Entanglement in nets", "Pollution", "Prey decline"],
            size: "2.4 m",
            habitat: "Rocky coasts, docks, and beaches",
            diet: "Fish, squid, anchovies",
            lifespan: "20 to 30 years",
            population: "≈ 300,000 individuals",
            funFact: "Sea lions can dive to 274 m deep and hold their breath for 10 minutes.",
            populationTrend: .stable,
            depthRange: "0 – 274 m",
            weight: "100 – 390 kg"
        ),
        Species(
            id: "blue_whale",
            name: "Blue Whale",
            scientificName: "Balaenoptera musculus",
            category: .protected,
            status: .endangered,
            imageName: "imagecalifornie4",
            description: "The largest animal that has ever lived on Earth. The Northeast Pacific population visits Californian waters every summer to feed on krill.",
            regionId: "california",
            threats: ["Ship strikes", "Noise pollution", "Climate change"],
            size: "25 – 30 m",
            habitat: "Deep pelagic waters",
            diet: "Krill (up to 3.6 tonnes/day)",
            lifespan: "80 to 110 years",
            population: "≈ 2,500 (NE Pacific)",
            funFact: "A blue whale's heart weighs as much as a car and its heartbeat can be detected 3 km away.",
            populationTrend: .increasing,
            depthRange: "0 – 500 m",
            weight: "100 – 170 tonnes"
        ),
        Species(
            id: "great_white_shark",
            name: "Great White Shark",
            scientificName: "Carcharodon carcharias",
            category: .protected,
            status: .vulnerable,
            imageName: "imagecalifornie5",
            description: "The apex predator of Californian waters, the great white plays an essential role in maintaining marine ecosystem balance. The Red Triangle off San Francisco is one of its favorite hunting grounds.",
            regionId: "california",
            threats: ["Bycatch", "Prey decline", "Fear and persecution"],
            size: "4 – 6 m",
            habitat: "Coastal and pelagic waters",
            diet: "Seals, sea lions, fish",
            lifespan: "40 to 70 years",
            population: "≈ 3,500 worldwide",
            funFact: "The great white can detect a single drop of blood in 100 liters of water using its ampullae of Lorenzini.",
            populationTrend: .unknown,
            depthRange: "0 – 1 200 m",
            weight: "700 – 2 000 kg"
        ),
        Species(
            id: "leatherback_turtle",
            name: "Leatherback Turtle",
            scientificName: "Dermochelys coriacea",
            category: .protected,
            status: .criticallyEndangered,
            imageName: "imagecalifornie6",
            description: "The largest sea turtle in the world migrates to Californian waters every year to feed on jellyfish. Its Pacific population has declined by 97% in 20 years.",
            regionId: "california",
            threats: ["Plastic ingestion", "Bycatch", "Nesting site destruction"],
            size: "1.5 – 2 m",
            habitat: "Open ocean and coastal waters",
            diet: "Jellyfish (up to 200 kg/day)",
            lifespan: "45 to 50 years",
            population: "≈ 2,300 females (Pacific)",
            funFact: "The leatherback turtle can dive to over 1,200 m deep, a record for reptiles.",
            populationTrend: .decreasing,
            depthRange: "0 – 1 280 m",
            weight: "250 – 700 kg"
        )
    ]

    // MARK: Bretagne Species

    static let bretagneSpecies: [Species] = [
        Species(
            id: "grey_seal",
            name: "Grey Seal",
            scientificName: "Halichoerus grypus",
            category: .emblematic,
            status: .leastConcern,
            imageName: "imagebretagne1",
            description: "The grey seal is the largest carnivore in France. The Molène archipelago in the Iroise Sea hosts the largest French colony with over 300 individuals.",
            regionId: "bretagne",
            threats: ["Human disturbance", "Pollution", "Bycatch"],
            size: "1.8 – 2.3 m",
            habitat: "Rocky islets and foreshore",
            diet: "Bottom fish, rays, cephalopods",
            lifespan: "25 to 35 years",
            population: "≈ 300 (Molène-Iroise)",
            funFact: "Grey seals can hold their breath for up to 20 minutes and dive to 70 m to hunt.",
            populationTrend: .increasing,
            depthRange: "0 – 70 m",
            weight: "150 – 300 kg"
        ),
        Species(
            id: "bottlenose_dolphin",
            name: "Bottlenose Dolphin",
            scientificName: "Tursiops truncatus",
            category: .emblematic,
            status: .leastConcern,
            imageName: "imagebretagne2",
            description: "A resident population of bottlenose dolphins lives year-round in the Iroise Sea, a rare case in Europe. This group of 30 to 40 individuals has been monitored by scientists since the 1990s.",
            regionId: "bretagne",
            threats: ["Chemical pollution", "Underwater noise", "Bycatch"],
            size: "2.5 – 3.5 m",
            habitat: "Coastal waters, bays, and estuaries",
            diet: "Fish, cephalopods, shrimp",
            lifespan: "40 to 50 years",
            population: "≈ 30-40 (Iroise)",
            funFact: "Dolphins sleep with only one brain hemisphere at a time, keeping one eye open to watch for predators.",
            populationTrend: .stable,
            depthRange: "0 – 300 m",
            weight: "200 – 350 kg"
        ),
        Species(
            id: "zostera",
            name: "Eelgrass",
            scientificName: "Zostera marina",
            category: .emblematic,
            status: .nearThreatened,
            imageName: "imagebretagne3",
            description: "The eelgrass meadows of the Gulf of Morbihan are the largest in France. These underwater prairies are essential nurseries for many fish and crustacean species.",
            regionId: "bretagne",
            threats: ["Boat anchoring", "Eutrophication", "Coastal development"],
            size: "30 – 120 cm",
            habitat: "Shallow sandy bottoms",
            diet: "Photosynthesis",
            lifespan: "Perennial",
            population: "800 ha (Morbihan)",
            funFact: "1 m² of eelgrass produces 10 liters of oxygen per day and captures as much CO₂ as a tree.",
            populationTrend: .decreasing,
            depthRange: "0 – 10 m",
            weight: "—"
        ),
        Species(
            id: "european_lobster",
            name: "European Lobster",
            scientificName: "Homarus gammarus",
            category: .protected,
            status: .vulnerable,
            imageName: "imagebretagne4",
            description: "The European blue lobster is declining across much of its range. Breton waters are one of its last strongholds thanks to rigorous fishery management.",
            regionId: "bretagne",
            threats: ["Overfishing", "Ocean warming", "Diseases"],
            size: "30 – 50 cm",
            habitat: "Rocky bottoms, 5-40 m",
            diet: "Mussels, sea urchins, small crustaceans",
            lifespan: "50 to 100 years",
            population: "Declining (limited data)",
            funFact: "Lobsters have blue blood! Their blood contains copper-based hemocyanin instead of iron-based hemoglobin.",
            populationTrend: .decreasing,
            depthRange: "5 – 40 m",
            weight: "1 – 4 kg"
        ),
        Species(
            id: "puffin",
            name: "Atlantic Puffin",
            scientificName: "Fratercula arctica",
            category: .protected,
            status: .vulnerable,
            imageName: "imagebretagne5",
            description: "The \"sea parrot\" nests on the Sept-Îles, the largest French colony. Its population has dramatically declined due to the collapse of sand eels, its main food source.",
            regionId: "bretagne",
            threats: ["Prey decline", "Light pollution", "Rat predation"],
            size: "26 – 30 cm",
            habitat: "Sea cliffs and open ocean",
            diet: "Sand eels, sprats, herring",
            lifespan: "25 to 30 years",
            population: "≈ 250 pairs (Sept-Îles)",
            funFact: "Puffins can carry up to 62 small fish in their beak at once thanks to their specialized tongue.",
            populationTrend: .decreasing,
            depthRange: "0 – 60 m",
            weight: "310 – 500 g"
        ),
        Species(
            id: "basking_shark",
            name: "Basking Shark",
            scientificName: "Cetorhinus maximus",
            category: .protected,
            status: .endangered,
            imageName: "imagebretagne6",
            description: "The second largest fish in the world visits Breton waters every summer to feed on plankton. Despite its impressive 12-meter size, it is completely harmless.",
            regionId: "bretagne",
            threats: ["Ship strikes", "Bycatch", "Pollution"],
            size: "8 – 12 m",
            habitat: "Plankton-rich coastal waters",
            diet: "Plankton (filters 1,500 m³/h)",
            lifespan: "Estimated 50 years",
            population: "Unknown (elusive species)",
            funFact: "The basking shark swims with its mouth wide open and filters the equivalent of an Olympic swimming pool per hour.",
            populationTrend: .unknown,
            depthRange: "0 – 900 m",
            weight: "3 – 5 tonnes"
        )
    ]
    static let mediterraneanSpecies: [Species] = [
        Species(
            id: "posidonia",
            name: "Posidonia",
            scientificName: "Posidonia oceanica",
            category: .emblematic,
            status: .vulnerable,
            imageName: "imagemed1",
            description: "This underwater flowering plant forms vast meadows that serve as nurseries for hundreds of marine species. It produces more oxygen per square meter than the Amazon rainforest.",
            regionId: "mediterranean",
            threats: ["Anchoring damage", "Coastal development", "Invasive algae"],
            size: "30 – 120 cm leaves",
            habitat: "Sandy seabeds, 0–40 m depth",
            diet: "Photosynthesis",
            lifespan: "Over 100,000 years (clonal)",
            population: "Declining (–34% in 50 years)",
            funFact: "A Posidonia clone in Ibiza was dated at over 100,000 years old, making it one of the oldest living organisms on Earth.",
            populationTrend: .decreasing,
            depthRange: "0 – 40 m",
            weight: "N/A (plant)"
        ),
        Species(
            id: "loggerhead_turtle",
            name: "Loggerhead Turtle",
            scientificName: "Caretta caretta",
            category: .protected,
            status: .vulnerable,
            imageName: "imagemed4",
            description: "The most common sea turtle in the Mediterranean, the loggerhead returns to the same beaches to nest. Its powerful jaws can crush hard-shelled prey like conchs and crabs.",
            regionId: "mediterranean",
            threats: ["Plastic ingestion", "Bycatch", "Nest disturbance"],
            size: "70 – 100 cm",
            habitat: "Open sea and coastal waters",
            diet: "Jellyfish, crustaceans, mollusks",
            lifespan: "50 to 70 years",
            population: "≈ 7,200 nesting females",
            funFact: "Loggerhead hatchlings use the Earth's magnetic field to navigate across entire ocean basins.",
            populationTrend: .decreasing,
            depthRange: "0 – 230 m",
            weight: "80 – 200 kg"
        ),
        Species(
            id: "Moray",
            name: "Mediterranean Moray",
            scientificName: "Muraena helena",
            category: .emblematic,
            status: .leastConcern,
            imageName: "imagemed2",
            description: "This snake-like predator hides in rocky crevices during the day and hunts at night. Its double jaw system (pharyngeal jaws) works like the creature from Alien.",
            regionId: "mediterranean",
            threats: ["Overfishing", "Habitat degradation", "Pollution"],
            size: "80 – 150 cm",
            habitat: "Rocky reefs and caves",
            diet: "Fish, octopus, crustaceans",
            lifespan: "Up to 30 years",
            population: "Stable",
            funFact: "Moray eels have a second set of jaws in their throat that shoot forward to grab prey and drag it down — just like the Xenomorph.",
            populationTrend: .stable,
            depthRange: "0 – 80 m",
            weight: "3 – 6 kg"
        ),
        Species(
            id: "dusky_grouper",
            name: "Dusky Grouper",
            scientificName: "Epinephelus marginatus",
            category: .protected,
            status: .endangered,
            imageName: "imagemed5",
            description: "Once nearly wiped out by spearfishing, the dusky grouper is making a comeback in marine protected areas. This gentle giant is a sequential hermaphrodite — all individuals start female.",
            regionId: "mediterranean",
            threats: ["Overfishing", "Slow reproduction", "Habitat loss"],
            size: "60 – 150 cm",
            habitat: "Rocky reefs and Posidonia meadows",
            diet: "Fish, octopus, crabs",
            lifespan: "Over 50 years",
            population: "Recovering in MPAs",
            funFact: "All dusky groupers are born female and transform into males after about 10 years — a process called protogynous hermaphroditism.",
            populationTrend: .increasing,
            depthRange: "5 – 200 m",
            weight: "Up to 60 kg"
        ),
        Species(
            id: "bluefin_tuna",
            name: "Atlantic Bluefin Tuna",
            scientificName: "Thunnus thynnus",
            category: .emblematic,
            status: .endangered,
            imageName: "imagemed3",
            description: "The Mediterranean is the primary spawning ground for the Atlantic bluefin tuna, one of the ocean's fastest and most valuable fish. A single specimen can sell for millions at auction.",
            regionId: "mediterranean",
            threats: ["Overfishing", "Illegal fishing", "Climate change"],
            size: "2 – 3.3 m",
            habitat: "Open ocean, coastal spawning",
            diet: "Fish, squid, crustaceans",
            lifespan: "35 to 40 years",
            population: "Recovering since quotas",
            funFact: "Bluefin tuna can maintain their body temperature above the surrounding water, allowing them to dive into freezing depths while keeping muscles warm.",
            populationTrend: .increasing,
            depthRange: "0 – 1,000 m",
            weight: "250 – 680 kg"
        ),
        Species(
            id: "monk_seal",
            name: "Monk Seal",
            scientificName: "Monachus monachus",
            category: .protected,
            status: .endangered,
            imageName: "imagemed6",
            description: "One of the rarest mammals on Earth, the monk seal was once common across the entire Mediterranean. Fewer than 700 survive today, hiding in remote sea caves.",
            regionId: "mediterranean",
            threats: ["Habitat loss", "Human disturbance", "Pollution"],
            size: "2.4 – 2.8 m",
            habitat: "Sea caves and rocky coastlines",
            diet: "Fish, octopus, eels",
            lifespan: "20 to 30 years",
            population: "≈ 700 worldwide",
            funFact: "Ancient Greeks considered monk seals sacred to Poseidon and Apollo — killing one was punishable by death.",
            populationTrend: .decreasing,
            depthRange: "0 – 70 m",
            weight: "250 – 400 kg"
        )
    ]
    static let norwaySpecies: [Species] = [
        Species(
            id: "atlantic_cod",
            name: "Atlantic Cod",
            scientificName: "Gadus morhua",
            category: .emblematic,
            status: .vulnerable,
            imageName: "imagenor1",
            description: "The Atlantic cod shaped Norwegian history — its dried form (stockfish) fueled Viking voyages and medieval trade. The Lofoten fishery remains one of the world's most iconic.",
            regionId: "norway",
            threats: ["Overfishing", "Ocean warming", "Habitat change"],
            size: "60 – 130 cm",
            habitat: "Cold continental shelves",
            diet: "Fish, crustaceans, worms",
            lifespan: "20 to 25 years",
            population: "Recovering (Barents Sea stock)",
            funFact: "A single female cod can release up to 9 million eggs in one spawning season — but only one in a million survives to adulthood.",
            populationTrend: .increasing,
            depthRange: "0 – 600 m",
            weight: "5 – 35 kg"
        ),
        Species(
            id: "orca",
            name: "Orca",
            scientificName: "Orcinus orca",
            category: .emblematic,
            status: .leastConcern,
            imageName: "imagenor2",
            description: "Norwegian orcas follow massive herring shoals into fjords each winter, creating one of nature's greatest spectacles. They use a unique \"carousel feeding\" technique to corral fish.",
            regionId: "norway",
            threats: ["Pollution (PCBs)", "Prey decline", "Ship noise"],
            size: "5.5 – 9 m",
            habitat: "Fjords and open ocean",
            diet: "Herring, seals, fish",
            lifespan: "50 to 80 years",
            population: "≈ 3,000 (NE Atlantic)",
            funFact: "Norwegian orcas invented 'carousel feeding' — they swim in circles blowing bubbles to pack herring into a tight ball, then stun them with tail slaps.",
            populationTrend: .stable,
            depthRange: "0 – 300 m",
            weight: "3 – 6 tonnes"
        ),
        Species(
            id: "king_crab",
            name: "Red King Crab",
            scientificName: "Paralithodes camtschaticus",
            category: .emblematic,
            status: .leastConcern,
            imageName: "imagenor3",
            description: "Introduced from the Kamchatka Peninsula by Soviet scientists in the 1960s, the king crab has invaded Norwegian waters. It devastates local ecosystems but supports a lucrative fishery.",
            regionId: "norway",
            threats: ["Rapid expansion", "Ecosystem disruption", "Climate shift"],
            size: "Leg span up to 1.8 m",
            habitat: "Sandy and muddy seabeds",
            diet: "Starfish, mussels, urchins, worms",
            lifespan: "20 to 30 years",
            population: "Expanding rapidly",
            funFact: "The red king crab is not a true crab — it's more closely related to hermit crabs and evolved its crab-like shape independently.",
            populationTrend: .increasing,
            depthRange: "5 – 400 m",
            weight: "Up to 12 kg"
        ),
        Species(
            id: "atlantic_wolffish",
            name: "Atlantic Wolffish",
            scientificName: "Anarhichas lupus",
            category: .protected,
            status: .vulnerable,
            imageName: "imagenor4",
            description: "The Atlantic wolffish has a terrifying face but a gentle nature. Its powerful jaws crush sea urchins, crabs, and starfish — making it a keystone species that prevents urchin barrens from destroying kelp forests.",
            regionId: "norway",
            threats: ["Bycatch", "Bottom trawling", "Habitat destruction"],
            size: "90 – 150 cm",
            habitat: "Rocky seabeds and cold reefs",
            diet: "Sea urchins, crabs, starfish, mussels",
            lifespan: "Up to 20 years",
            population: "Declining (–90% in some areas)",
            funFact: "Wolffish produce natural antifreeze proteins in their blood to survive in near-freezing Arctic waters — a trait studied for cryopreservation research.",
            populationTrend: .decreasing,
            depthRange: "2 – 500 m",
            weight: "Up to 24 kg"
        ),
        Species(
            id: "humpback_whale",
            name: "Humpback Whale",
            scientificName: "Megaptera novaeangliae",
            category: .protected,
            status: .leastConcern,
            imageName: "imagenor5",
            description: "Humpback whales have dramatically returned to Norwegian waters after centuries of whaling. Each winter they join orcas to feast on herring in the Arctic fjords near Tromsø.",
            regionId: "norway",
            threats: ["Ship strikes", "Entanglement", "Noise pollution"],
            size: "12 – 16 m",
            habitat: "Arctic fjords and open ocean",
            diet: "Krill, herring, capelin",
            lifespan: "45 to 80 years",
            population: "Growing (≈ 80,000 globally)",
            funFact: "Each humpback whale has a unique tail pattern — like a fingerprint — used by scientists to identify and track individuals across oceans.",
            populationTrend: .increasing,
            depthRange: "0 – 200 m",
            weight: "25 – 40 tonnes"
        ),
        Species(
            id: "white_tailed_eagle",
            name: "White-tailed Eagle",
            scientificName: "Haliaeetus albicilla",
            category: .protected,
            status: .leastConcern,
            imageName: "imagenor6",
            description: "Europe's largest bird of prey soars above Norwegian coastlines with a wingspan exceeding 2.4 meters. Once nearly extinct, it has made a remarkable comeback thanks to conservation efforts.",
            regionId: "norway",
            threats: ["Wind turbines", "Lead poisoning", "Habitat fragmentation"],
            size: "70 – 92 cm (wingspan 2 – 2.45 m)",
            habitat: "Coastal cliffs and islands",
            diet: "Fish, seabirds, carrion",
            lifespan: "20 to 25 years",
            population: "≈ 4,000 pairs (Norway)",
            funFact: "White-tailed eagles can snatch fish from the water surface at 70 km/h — they were called 'flying barn doors' by fishermen due to their massive wingspan.",
            populationTrend: .increasing,
            depthRange: "Surface (plunge dives)",
            weight: "4 – 7 kg"
        )
    ]
}
