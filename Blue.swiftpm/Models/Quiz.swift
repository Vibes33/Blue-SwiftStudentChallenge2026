import SwiftUI
enum QuizDifficulty: String, CaseIterable, Identifiable {
    case easy = "Easy"
    case intermediate = "Intermediate"
    case hard = "Hard"
    case expert = "Expert"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .easy: return "1.circle.fill"
        case .intermediate: return "2.circle.fill"
        case .hard: return "3.circle.fill"
        case .expert: return "4.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .easy: return .green
        case .intermediate: return .orange
        case .hard: return .red
        case .expert: return .purple
        }
    }

    var subtitle: String {
        switch self {
        case .easy: return "Great for beginners"
        case .intermediate: return "For the curious"
        case .hard: return "For the passionate"
        case .expert: return "Only experts survive"
        }
    }

    var pointsReward: Int {
        switch self {
        case .easy: return 6
        case .intermediate: return 9
        case .hard: return 12
        case .expert: return 18
        }
    }
}
struct QuizQuestion: Identifiable {
    let id = UUID()
    let question: String
    let answers: [String]      // 4 answers
    let correctIndex: Int      // 0-3
}
struct Quiz: Identifiable {
    let id: String
    let regionId: String
    let difficulty: QuizDifficulty
    let questions: [QuizQuestion]  // Always 5 questions
}
extension Quiz {

    static func quizzes(for regionId: String) -> [Quiz] {
        switch regionId {
        case "california": return californiaQuizzes
        case "bretagne": return bretagneQuizzes
        case "mediterranean": return mediterraneanQuizzes
        case "norway": return norwayQuizzes
        default: return []
        }
    }

    static func quiz(for regionId: String, difficulty: QuizDifficulty) -> Quiz? {
        quizzes(for: regionId).first { $0.difficulty == difficulty }
    }
    static let californiaQuizzes: [Quiz] = [
        // EASY
        Quiz(
            id: "california_easy",
            regionId: "california",
            difficulty: .easy,
            questions: [
                QuizQuestion(
                    question: "Which animal is nicknamed the 'gardener of kelp forests'?",
                    answers: ["The dolphin", "The sea otter", "The seal", "The whale"],
                    correctIndex: 1
                ),
                QuizQuestion(
                    question: "What is the largest animal species that has ever existed?",
                    answers: ["The great white shark", "The elephant seal", "The blue whale", "The sperm whale"],
                    correctIndex: 2
                ),
                QuizQuestion(
                    question: "Approximately how many teeth does a great white shark have?",
                    answers: ["50", "150", "300", "500"],
                    correctIndex: 2
                ),
                QuizQuestion(
                    question: "Which type of sea turtle nests on Californian beaches?",
                    answers: ["Green turtle", "Leatherback turtle", "Hawksbill turtle", "Loggerhead turtle"],
                    correctIndex: 1
                ),
                QuizQuestion(
                    question: "How much can kelp forests grow per day?",
                    answers: ["5 cm", "30 cm", "60 cm", "1 meter"],
                    correctIndex: 2
                )
            ]
        ),
        // INTERMEDIATE
        Quiz(
            id: "california_intermediate",
            regionId: "california",
            difficulty: .intermediate,
            questions: [
                QuizQuestion(
                    question: "How does the sea otter protect itself from the cold?",
                    answers: ["Thick layer of fat", "Densest fur in the animal kingdom", "It migrates in winter", "It stays on the surface"],
                    correctIndex: 1
                ),
                QuizQuestion(
                    question: "What is the maximum diving depth of a blue whale?",
                    answers: ["100 m", "200 m", "500 m", "1,000 m"],
                    correctIndex: 2
                ),
                QuizQuestion(
                    question: "What is special about the leatherback turtle's blood?",
                    answers: ["It is blue", "It resists extreme cold", "It is toxic", "It clots very quickly"],
                    correctIndex: 1
                ),
                QuizQuestion(
                    question: "How fast can the California sea lion swim?",
                    answers: ["10 km/h", "20 km/h", "35 km/h", "50 km/h"],
                    correctIndex: 2
                ),
                QuizQuestion(
                    question: "What special organ does the great white shark have?",
                    answers: ["Ampullae of Lorenzini", "Biological sonar", "Third eye", "Double heart"],
                    correctIndex: 0
                )
            ]
        ),
        // HARD
        Quiz(
            id: "california_hard",
            regionId: "california",
            difficulty: .hard,
            questions: [
                QuizQuestion(
                    question: "How many hairs per cm² does the sea otter's fur have?",
                    answers: ["10,000", "50,000", "100,000", "150,000"],
                    correctIndex: 3
                ),
                QuizQuestion(
                    question: "How much krill does a blue whale eat per day?",
                    answers: ["500 kg", "1 tonne", "3.6 tonnes", "6 tonnes"],
                    correctIndex: 2
                ),
                QuizQuestion(
                    question: "What is the estimated lifespan of a great white shark?",
                    answers: ["30 years", "50 years", "70 years", "100 years"],
                    correctIndex: 2
                ),
                QuizQuestion(
                    question: "How many species do kelp forests shelter in California?",
                    answers: ["100", "400", "800", "Over 1,000"],
                    correctIndex: 2
                ),
                QuizQuestion(
                    question: "How far does the leatherback turtle travel during its annual migration?",
                    answers: ["1,000 km", "5,000 km", "10,000 km", "16,000 km"],
                    correctIndex: 3
                )
            ]
        ),
        // EXPERT
        Quiz(
            id: "california_expert",
            regionId: "california",
            difficulty: .expert,
            questions: [
                QuizQuestion(
                    question: "What percentage of Californian kelp forests has disappeared since the 2010s?",
                    answers: ["20%", "50%", "80%", "95%"],
                    correctIndex: 2
                ),
                QuizQuestion(
                    question: "What frequency (Hz) does the blue whale use to communicate?",
                    answers: ["10-40 Hz", "100-200 Hz", "500-1000 Hz", "2000-5000 Hz"],
                    correctIndex: 0
                ),
                QuizQuestion(
                    question: "How many liters of milk does the female sea lion produce per day?",
                    answers: ["0.2 L", "0.5 L", "1 L", "2 L"],
                    correctIndex: 1
                ),
                QuizQuestion(
                    question: "What body temperature does the leatherback turtle maintain in cold water?",
                    answers: ["18°C above water temp", "10°C above water temp", "5°C above water temp", "Same as water"],
                    correctIndex: 0
                ),
                QuizQuestion(
                    question: "What is the scientific name of the giant kelp of California?",
                    answers: ["Macrocystis pyrifera", "Laminaria digitata", "Fucus vesiculosus", "Sargassum muticum"],
                    correctIndex: 0
                )
            ]
        )
    ]
    static let bretagneQuizzes: [Quiz] = [
        // EASY
        Quiz(
            id: "bretagne_easy",
            regionId: "bretagne",
            difficulty: .easy,
            questions: [
                QuizQuestion(
                    question: "What is the largest carnivore in France?",
                    answers: ["The wolf", "The brown bear", "The grey seal", "The fox"],
                    correctIndex: 2
                ),
                QuizQuestion(
                    question: "What is the Atlantic puffin's nickname?",
                    answers: ["Sea duck", "Sea parrot", "Colorful gull", "Breton penguin"],
                    correctIndex: 1
                ),
                QuizQuestion(
                    question: "Which Breton archipelago hosts the largest grey seal colony?",
                    answers: ["Glénan", "Bréhat", "Molène", "Ouessant"],
                    correctIndex: 2
                ),
                QuizQuestion(
                    question: "Is the basking shark dangerous to humans?",
                    answers: ["Yes, very", "Only in winter", "No, it eats plankton", "Yes, but rare"],
                    correctIndex: 2
                ),
                QuizQuestion(
                    question: "What is eelgrass (Zostera marina)?",
                    answers: ["A fish", "A seaweed", "An underwater flowering plant", "A coral"],
                    correctIndex: 2
                )
            ]
        ),
        // INTERMEDIATE
        Quiz(
            id: "bretagne_intermediate",
            regionId: "bretagne",
            difficulty: .intermediate,
            questions: [
                QuizQuestion(
                    question: "How long can the grey seal hold its breath?",
                    answers: ["5 minutes", "10 minutes", "20 minutes", "45 minutes"],
                    correctIndex: 2
                ),
                QuizQuestion(
                    question: "How many fish can the puffin carry in its beak?",
                    answers: ["5", "15", "40", "62"],
                    correctIndex: 3
                ),
                QuizQuestion(
                    question: "What color is the European lobster's blood?",
                    answers: ["Red", "Blue", "Green", "Colorless"],
                    correctIndex: 1
                ),
                QuizQuestion(
                    question: "How many individuals are in the resident dolphin group in the Iroise Sea?",
                    answers: ["10-15", "30-40", "80-100", "200+"],
                    correctIndex: 1
                ),
                QuizQuestion(
                    question: "What is the maximum size of the basking shark?",
                    answers: ["5 m", "8 m", "12 m", "18 m"],
                    correctIndex: 2
                )
            ]
        ),
        // HARD
        Quiz(
            id: "bretagne_hard",
            regionId: "bretagne",
            difficulty: .hard,
            questions: [
                QuizQuestion(
                    question: "How much oxygen does 1 m² of eelgrass produce per day?",
                    answers: ["1 liter", "5 liters", "10 liters", "20 liters"],
                    correctIndex: 2
                ),
                QuizQuestion(
                    question: "What is the estimated lifespan of the European lobster?",
                    answers: ["10-20 years", "30-40 years", "50-100 years", "150 years"],
                    correctIndex: 2
                ),
                QuizQuestion(
                    question: "How do dolphins sleep?",
                    answers: ["They don't sleep", "One hemisphere at a time", "In a tight group", "On the sea floor"],
                    correctIndex: 1
                ),
                QuizQuestion(
                    question: "How many m³ of water does the basking shark filter per hour?",
                    answers: ["100 m³", "500 m³", "1,500 m³", "5,000 m³"],
                    correctIndex: 2
                ),
                QuizQuestion(
                    question: "Where is the largest French puffin colony located?",
                    answers: ["Îles Glénan", "Sept-Îles", "Île de Sein", "Belle-Île"],
                    correctIndex: 1
                )
            ]
        ),
        // EXPERT
        Quiz(
            id: "bretagne_expert",
            regionId: "bretagne",
            difficulty: .expert,
            questions: [
                QuizQuestion(
                    question: "Which metal gives the lobster's blood its blue color?",
                    answers: ["Iron", "Cobalt", "Copper", "Zinc"],
                    correctIndex: 2
                ),
                QuizQuestion(
                    question: "What is the area of eelgrass meadows in the Gulf of Morbihan?",
                    answers: ["200 ha", "500 ha", "800 ha", "1 200 ha"],
                    correctIndex: 2
                ),
                QuizQuestion(
                    question: "What is the maximum depth the basking shark can reach?",
                    answers: ["100 m", "300 m", "600 m", "900 m"],
                    correctIndex: 3
                ),
                QuizQuestion(
                    question: "How many puffin pairs nest on the Sept-Îles?",
                    answers: ["50", "150", "250", "500"],
                    correctIndex: 2
                ),
                QuizQuestion(
                    question: "Since when have scientists been tracking the Iroise dolphins?",
                    answers: ["1970s", "1980s", "1990s", "2000s"],
                    correctIndex: 2
                )
            ]
        )
    ]
    static let mediterraneanQuizzes: [Quiz] = [
        // BEGINNER
        Quiz(
            id: "mediterranean_beginner",
            regionId: "mediterranean",
            difficulty: .easy,
            questions: [
                QuizQuestion(
                    question: "What type of organism is Posidonia oceanica?",
                    answers: ["An alga", "A coral", "A flowering plant", "A sponge"],
                    correctIndex: 2
                ),
                QuizQuestion(
                    question: "What is the most common sea turtle in the Mediterranean?",
                    answers: ["Leatherback", "Green turtle", "Loggerhead", "Hawksbill"],
                    correctIndex: 2
                ),
                QuizQuestion(
                    question: "The Mediterranean monk seal is among the most endangered…?",
                    answers: ["Fish", "Mammals", "Birds", "Reptiles"],
                    correctIndex: 1
                ),
                QuizQuestion(
                    question: "What is the dusky grouper's hunting strategy?",
                    answers: ["Chase prey", "Ambush predator", "Filter feeding", "Scavenging"],
                    correctIndex: 1
                ),
                QuizQuestion(
                    question: "Bluefin tuna can maintain their body temperature above…?",
                    answers: ["Air temperature", "Surrounding water", "Other fish", "The sun's heat"],
                    correctIndex: 1
                )
            ]
        ),
        // INTERMEDIATE
        Quiz(
            id: "mediterranean_intermediate",
            regionId: "mediterranean",
            difficulty: .intermediate,
            questions: [
                QuizQuestion(
                    question: "What percentage of known marine species lives in the Mediterranean?",
                    answers: ["1%", "4%", "7%", "15%"],
                    correctIndex: 2
                ),
                QuizQuestion(
                    question: "What do loggerhead hatchlings use to navigate across oceans?",
                    answers: ["Stars", "Ocean currents", "Earth's magnetic field", "Smell"],
                    correctIndex: 2
                ),
                QuizQuestion(
                    question: "What unique jaw feature do moray eels possess?",
                    answers: ["Retractable teeth", "Pharyngeal jaws", "Bioluminescent lure", "Venomous fangs"],
                    correctIndex: 1
                ),
                QuizQuestion(
                    question: "All dusky groupers are born as which sex?",
                    answers: ["Male", "Female", "Both", "Neither"],
                    correctIndex: 1
                ),
                QuizQuestion(
                    question: "How many Mediterranean monk seals remain in the wild?",
                    answers: ["About 200", "About 700", "About 2,000", "About 5,000"],
                    correctIndex: 1
                )
            ]
        ),
        // ADVANCED
        Quiz(
            id: "mediterranean_advanced",
            regionId: "mediterranean",
            difficulty: .hard,
            questions: [
                QuizQuestion(
                    question: "How old is the oldest known Posidonia clone (in Ibiza)?",
                    answers: ["1,000 years", "10,000 years", "100,000 years", "1 million years"],
                    correctIndex: 2
                ),
                QuizQuestion(
                    question: "What is the Pelagos Sanctuary primarily designed to protect?",
                    answers: ["Coral reefs", "Marine mammals", "Seabird colonies", "Fish stocks"],
                    correctIndex: 1
                ),
                QuizQuestion(
                    question: "How many eggs can a female loggerhead lay per nest?",
                    answers: ["20–30", "50–70", "80–120", "200–300"],
                    correctIndex: 2
                ),
                QuizQuestion(
                    question: "What maximum depth can a bluefin tuna reach?",
                    answers: ["200 m", "500 m", "1,000 m", "2,000 m"],
                    correctIndex: 2
                ),
                QuizQuestion(
                    question: "Posidonia meadows have declined by what percentage over 50 years?",
                    answers: ["10%", "20%", "34%", "50%"],
                    correctIndex: 2
                )
            ]
        ),
        // EXPERT
        Quiz(
            id: "mediterranean_expert",
            regionId: "mediterranean",
            difficulty: .expert,
            questions: [
                QuizQuestion(
                    question: "What process allows dusky groupers to change sex?",
                    answers: ["Androgenesis", "Protogynous hermaphroditism", "Parthenogenesis", "Metagenesis"],
                    correctIndex: 1
                ),
                QuizQuestion(
                    question: "What was the ancient Greek punishment for killing a monk seal?",
                    answers: ["Exile", "Fine of 100 drachmas", "Death", "Slavery"],
                    correctIndex: 2
                ),
                QuizQuestion(
                    question: "What invasive alga threatens Posidonia meadows?",
                    answers: ["Sargassum", "Caulerpa taxifolia", "Ulva lactuca", "Codium fragile"],
                    correctIndex: 1
                ),
                QuizQuestion(
                    question: "How much water volume per hour does the Mediterranean receive from the Atlantic?",
                    answers: ["0.5 million m³", "1.5 million m³", "3 million m³", "10 million m³"],
                    correctIndex: 1
                ),
                QuizQuestion(
                    question: "At what age does a dusky grouper typically transition from female to male?",
                    answers: ["3 years", "5 years", "10 years", "20 years"],
                    correctIndex: 2
                )
            ]
        )
    ]
    static let norwayQuizzes: [Quiz] = [
        // BEGINNER
        Quiz(
            id: "norway_beginner",
            regionId: "norway",
            difficulty: .easy,
            questions: [
                QuizQuestion(
                    question: "What fish shaped Norway's Viking history through trade?",
                    answers: ["Salmon", "Herring", "Cod", "Mackerel"],
                    correctIndex: 2
                ),
                QuizQuestion(
                    question: "What is another name for the orca?",
                    answers: ["Blue whale", "Killer whale", "Pilot whale", "Fin whale"],
                    correctIndex: 1
                ),
                QuizQuestion(
                    question: "Where did the red king crab originally come from?",
                    answers: ["Alaska", "Japan", "Russia/Kamchatka", "Antarctica"],
                    correctIndex: 2
                ),
                QuizQuestion(
                    question: "The white-tailed eagle is Europe's largest…?",
                    answers: ["Seabird", "Bird of prey", "Wading bird", "Songbird"],
                    correctIndex: 1
                ),
                QuizQuestion(
                    question: "Where is one of the best places to see humpback whales in Norway?",
                    answers: ["Oslo", "Bergen", "Tromsø", "Stavanger"],
                    correctIndex: 2
                )
            ]
        ),
        // INTERMEDIATE
        Quiz(
            id: "norway_intermediate",
            regionId: "norway",
            difficulty: .intermediate,
            questions: [
                QuizQuestion(
                    question: "What unique feeding technique do Norwegian orcas use?",
                    answers: ["Bubble netting", "Carousel feeding", "Bottom trawling", "Spy hopping"],
                    correctIndex: 1
                ),
                QuizQuestion(
                    question: "How many eggs can a female cod release in one spawning season?",
                    answers: ["100,000", "1 million", "9 million", "50 million"],
                    correctIndex: 2
                ),
                QuizQuestion(
                    question: "What does the Atlantic wolffish mainly eat?",
                    answers: ["Plankton", "Sea urchins and crabs", "Seaweed", "Salmon"],
                    correctIndex: 1
                ),
                QuizQuestion(
                    question: "What makes each humpback whale's tail unique?",
                    answers: ["Its color", "Its pattern", "Its size", "Its shape"],
                    correctIndex: 1
                ),
                QuizQuestion(
                    question: "The red king crab is more closely related to which animal?",
                    answers: ["Lobsters", "Shrimp", "Hermit crabs", "Spiders"],
                    correctIndex: 2
                )
            ]
        ),
        // ADVANCED
        Quiz(
            id: "norway_advanced",
            regionId: "norway",
            difficulty: .hard,
            questions: [
                QuizQuestion(
                    question: "How fast is the tidal current at Saltstraumen?",
                    answers: ["10 km/h", "20 km/h", "40 km/h", "60 km/h"],
                    correctIndex: 2
                ),
                QuizQuestion(
                    question: "How many fjords does Norway have?",
                    answers: ["About 300", "About 700", "About 1,190", "About 2,500"],
                    correctIndex: 2
                ),
                QuizQuestion(
                    question: "What is the wingspan of a white-tailed eagle?",
                    answers: ["1.5 m", "2 m", "2.45 m", "3 m"],
                    correctIndex: 2
                ),
                QuizQuestion(
                    question: "How many breeding pairs of white-tailed eagles live in Norway?",
                    answers: ["500", "1,500", "4,000", "8,000"],
                    correctIndex: 2
                ),
                QuizQuestion(
                    question: "What is the maximum weight of a red king crab?",
                    answers: ["5 kg", "8 kg", "12 kg", "20 kg"],
                    correctIndex: 2
                )
            ]
        ),
        // EXPERT
        Quiz(
            id: "norway_expert",
            regionId: "norway",
            difficulty: .expert,
            questions: [
                QuizQuestion(
                    question: "In what decade was the red king crab introduced to the Barents Sea?",
                    answers: ["1940s", "1960s", "1980s", "2000s"],
                    correctIndex: 1
                ),
                QuizQuestion(
                    question: "What is the estimated orca population in the NE Atlantic?",
                    answers: ["500", "1,500", "3,000", "10,000"],
                    correctIndex: 2
                ),
                QuizQuestion(
                    question: "At what speed can a white-tailed eagle snatch fish from the surface?",
                    answers: ["30 km/h", "50 km/h", "70 km/h", "100 km/h"],
                    correctIndex: 2
                ),
                QuizQuestion(
                    question: "What special protein do wolffish produce to survive Arctic waters?",
                    answers: ["Hemoglobin", "Antifreeze proteins", "Keratin", "Collagen"],
                    correctIndex: 1
                ),
                QuizQuestion(
                    question: "By how much has the wolffish population declined in some areas?",
                    answers: ["30%", "50%", "70%", "90%"],
                    correctIndex: 3
                )
            ]
        )
    ]
}
