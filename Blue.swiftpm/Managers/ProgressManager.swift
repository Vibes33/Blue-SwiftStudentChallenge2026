import SwiftUI
import Observation

// Reading a species card = 3 points (once per card)
// Completing a quiz: Easy = 6, Intermediate = 9, Hard = 12, Expert = 18 points
// Level up every 18 points

@Observable
class ProgressManager {
    private var isLoading = false

    var userName: String = "" {
        didSet { if !isLoading { save() } }
    }

    // Store progress per region: regionId -> RegionProgress
    var regionProgressData: [String: RegionProgress] = [:] {
        didSet { if !isLoading { save() } }
    }

    // Global set of read card ids (species)
    var readCards: Set<String> = [] {
        didSet { if !isLoading { save() } }
    }

    // Achievements unlocked
    var achievements: [Achievement] = [] {
        didSet { if !isLoading { save() } }
    }

    // Completed quiz IDs
    var completedQuizzes: Set<String> = [] {
        didSet { if !isLoading { save() } }
    }

    // Achievement notification system
    private var achievementQueue: [AchievementType] = []
    private var isBannerShowing: Bool = false

    static let pointsPerCard: Int = 3
    static let pointsPerQuiz: Int = 9
    static let pointsPerLevel: Int = 18
    private enum Keys {
        static let userName = "blue_userName"
        static let regionProgress = "blue_regionProgress"
        static let readCards = "blue_readCards"
        static let achievements = "blue_achievements"
        static let completedQuizzes = "blue_completedQuizzes"
    }
    init() {
        load()
        // Always ensure California region achievement exists
        if !achievements.contains(where: { $0.type == .regionCalifornia }) {
            let a = Achievement(type: .regionCalifornia, dateUnlocked: Date())
            achievements.append(a)
        }
    }
    private func save() {
        let defaults = UserDefaults.standard
        defaults.set(userName, forKey: Keys.userName)

        if let data = try? JSONEncoder().encode(regionProgressData) {
            defaults.set(data, forKey: Keys.regionProgress)
        }
        if let data = try? JSONEncoder().encode(Array(readCards)) {
            defaults.set(data, forKey: Keys.readCards)
        }
        if let data = try? JSONEncoder().encode(achievements) {
            defaults.set(data, forKey: Keys.achievements)
        }
        if let data = try? JSONEncoder().encode(Array(completedQuizzes)) {
            defaults.set(data, forKey: Keys.completedQuizzes)
        }
    }

    private func load() {
        isLoading = true
        defer { isLoading = false }

        let defaults = UserDefaults.standard

        if let name = defaults.string(forKey: Keys.userName) {
            userName = name
        }
        if let data = defaults.data(forKey: Keys.regionProgress),
           let decoded = try? JSONDecoder().decode([String: RegionProgress].self, from: data) {
            regionProgressData = decoded
        }
        if let data = defaults.data(forKey: Keys.readCards),
           let decoded = try? JSONDecoder().decode([String].self, from: data) {
            readCards = Set(decoded)
        }
        if let data = defaults.data(forKey: Keys.achievements),
           let decoded = try? JSONDecoder().decode([Achievement].self, from: data) {
            achievements = decoded
        }
        if let data = defaults.data(forKey: Keys.completedQuizzes),
           let decoded = try? JSONDecoder().decode([String].self, from: data) {
            completedQuizzes = Set(decoded)
        }
    }
    func progress(for regionId: String) -> RegionProgress {
        regionProgressData[regionId] ?? RegionProgress()
    }
    var totalGlobalPoints: Int {
        regionProgressData.values.reduce(0) { $0 + $1.points }
    }

    var globalLevel: Int {
        totalGlobalPoints / ProgressManager.pointsPerLevel
    }

    var globalLevelProgress: Double {
        let remainder = totalGlobalPoints % ProgressManager.pointsPerLevel
        return Double(remainder) / Double(ProgressManager.pointsPerLevel)
    }

    var pointsInCurrentGlobalLevel: Int {
        totalGlobalPoints % ProgressManager.pointsPerLevel
    }
    func level(for regionId: String) -> Int {
        let pts = progress(for: regionId).points
        return pts / ProgressManager.pointsPerLevel
    }

    func pointsInCurrentLevel(for regionId: String) -> Int {
        let pts = progress(for: regionId).points
        return pts % ProgressManager.pointsPerLevel
    }

    func levelProgress(for regionId: String) -> Double {
        Double(pointsInCurrentLevel(for: regionId)) / Double(ProgressManager.pointsPerLevel)
    }

    func totalPoints(for regionId: String) -> Int {
        progress(for: regionId).points
    }
    var globalBadgeImage: String {
        switch globalLevel {
        case 0: return "Badge1"
        case 1: return "Badge2"
        default: return "Badge3"
        }
    }
    func hasReadCard(_ speciesId: String) -> Bool {
        readCards.contains(speciesId)
    }

    func markCardRead(speciesId: String, regionId: String) {
        guard !readCards.contains(speciesId) else { return }

        readCards.insert(speciesId)

        var prog = progress(for: regionId)
        prog.points += ProgressManager.pointsPerCard
        prog.cardsRead += 1
        prog.speciesDiscovered.insert(speciesId)
        regionProgressData[regionId] = prog

        // Check for species-specific achievement
        if let achievement = AchievementType.forSpecies(speciesId) {
            unlockAchievement(achievement)
        }

        // Check for regional "all cards read" achievements
        checkAllCardsReadAchievement(for: regionId)
    }
    func hasCompletedQuiz(quizId: String) -> Bool {
        completedQuizzes.contains(quizId)
    }

    func completeQuiz(quizId: String, regionId: String, difficulty: QuizDifficulty) {
        let isFirstTime = !completedQuizzes.contains(quizId)
        completedQuizzes.insert(quizId)

        if isFirstTime {
            var prog = progress(for: regionId)
            prog.points += difficulty.pointsReward
            prog.quizzesCompleted += 1
            regionProgressData[regionId] = prog
        }

        // Unlock quiz-specific achievements
        switch difficulty {
        case .easy:
            unlockAchievement(.quizEasy)
        case .intermediate:
            unlockAchievement(.quizIntermediate)
        case .hard:
            unlockAchievement(.quizHard)
        case .expert:
            unlockAchievement(.quizExpert)
        }

        // Check if all quizzes for this region are completed
        let allDone = QuizDifficulty.allCases.allSatisfy { diff in
            if let q = Quiz.quiz(for: regionId, difficulty: diff) {
                return completedQuizzes.contains(q.id)
            }
            return true
        }
        if allDone {
            switch regionId {
            case "california": unlockAchievement(.allQuizCalifornia)
            case "bretagne": unlockAchievement(.allQuizBretagne)
            case "mediterranean": unlockAchievement(.allQuizMediterranean)
            case "norway": unlockAchievement(.allQuizNorway)
            default: break
            }
        }
    }

    func totalQuizPoints(for regionId: String) -> Int {
        // Sum points from completed quizzes in this region
        var total = 0
        for diff in QuizDifficulty.allCases {
            if let q = Quiz.quiz(for: regionId, difficulty: diff),
               completedQuizzes.contains(q.id) {
                total += diff.pointsReward
            }
        }
        return total
    }
    func markRegionVisited(_ regionId: String) {
        if let achievement = AchievementType.forRegion(regionId) {
            unlockAchievement(achievement)
        }
    }

    func discoverAboutPage() {
        unlockAchievement(.secretAbout)
    }
    func unlockAchievement(_ type: AchievementType) {
        guard !achievements.contains(where: { $0.type == type }) else { return }
        let achievement = Achievement(type: type, dateUnlocked: Date())
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            achievements.append(achievement)
        }
        // Trigger global banner notification
        showAchievementNotification(for: type)
    }

    private func showAchievementNotification(for type: AchievementType) {
        achievementQueue.append(type)
        processAchievementQueue()
    }

    private func processAchievementQueue() {
        guard !isBannerShowing, !achievementQueue.isEmpty else { return }
        isBannerShowing = true

        let type = achievementQueue.removeFirst()
        AchievementBannerManager.shared.show(achievementType: type)

        let gen = UIImpactFeedbackGenerator(style: .soft)
        gen.impactOccurred(intensity: 0.7)

        // Wait for banner to dismiss, then show next if queued
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) { [weak self] in
            guard let self = self else { return }
            self.isBannerShowing = false
            self.processAchievementQueue()
        }
    }

    func hasAchievement(_ type: AchievementType) -> Bool {
        achievements.contains(where: { $0.type == type })
    }

    private func checkAllCardsReadAchievement(for regionId: String) {
        let allSpecies = Species.species(for: regionId)
        let allRead = allSpecies.allSatisfy { readCards.contains($0.id) }
        if allRead {
            switch regionId {
            case "california": unlockAchievement(.allCardsCalifornia)
            case "bretagne": unlockAchievement(.allCardsBretagne)
            case "mediterranean": unlockAchievement(.allCardsMediterranean)
            case "norway": unlockAchievement(.allCardsNorway)
            default: break
            }
        }
    }
    var totalCardsRead: Int { readCards.count }

    var totalQuizzes: Int {
        regionProgressData.values.reduce(0) { $0 + $1.quizzesCompleted }
    }

    var regionsVisited: Int {
        achievements.filter {
            switch $0.type {
            case .regionCalifornia, .regionBretagne, .regionMediterranean, .regionNorway: return true
            default: return false
            }
        }.count
    }
}
struct RegionProgress: Codable {
    var points: Int = 0
    var cardsRead: Int = 0
    var quizzesCompleted: Int = 0
    var speciesDiscovered: Set<String> = []
}
struct Achievement: Identifiable, Codable {
    let id: UUID
    let type: AchievementType
    let dateUnlocked: Date

    init(type: AchievementType, dateUnlocked: Date) {
        self.id = UUID()
        self.type = type
        self.dateUnlocked = dateUnlocked
    }
}
enum AchievementType: String, CaseIterable, Codable {
    // Region visits
    case regionCalifornia
    case regionBretagne
    case regionMediterranean
    case regionNorway

    // Species discoveries — California
    case cardSeaOtter
    case cardBlueWhale
    case cardGreatWhiteShark
    case cardLeatherbackTurtle
    case cardCaliforniaSeaLion
    case cardKelpForest

    // Species discoveries — Bretagne
    case cardGreySeal
    case cardBottlenoseDolphin
    case cardZostera
    case cardEuropeanLobster
    case cardPuffin
    case cardBaskingShark

    // Species discoveries — Mediterranean
    case cardPosidonia
    case cardLoggerheadTurtle
    case cardMediterraneanMoray
    case cardDuskyGrouper
    case cardBluefinTuna
    case cardMonkSeal

    // Species discoveries — Norway
    case cardAtlanticCod
    case cardOrca
    case cardKingCrab
    case cardAtlanticWolffish
    case cardHumpbackWhale
    case cardWhiteTailedEagle

    // Completion
    case allCardsCalifornia
    case allCardsBretagne
    case allCardsMediterranean
    case allCardsNorway

    // Quiz achievements
    case quizEasy
    case quizIntermediate
    case quizHard
    case quizExpert
    case allQuizCalifornia
    case allQuizBretagne
    case allQuizMediterranean
    case allQuizNorway

    // Milestones
    case firstCard
    case fiveCards
    case tenCards
    case twentyCards

    // Secret
    case secretAbout

    var emoji: String {
        switch self {
        case .regionCalifornia: return "🌊"
        case .regionBretagne: return "⚓️"
        case .regionMediterranean: return "☀️"
        case .regionNorway: return "❄️"
        case .cardSeaOtter: return "🦦"
        case .cardBlueWhale: return "🐋"
        case .cardGreatWhiteShark: return "🦈"
        case .cardLeatherbackTurtle: return "🐢"
        case .cardCaliforniaSeaLion: return "🦭"
        case .cardKelpForest: return "🌿"
        case .cardGreySeal: return "🦭"
        case .cardBottlenoseDolphin: return "🐬"
        case .cardZostera: return "🌱"
        case .cardEuropeanLobster: return "🦞"
        case .cardPuffin: return "🐧"
        case .cardBaskingShark: return "🦈"
        case .cardPosidonia: return "🌿"
        case .cardLoggerheadTurtle: return "🐢"
        case .cardMediterraneanMoray: return "🐍"
        case .cardDuskyGrouper: return "🐟"
        case .cardBluefinTuna: return "🐟"
        case .cardMonkSeal: return "🦭"
        case .cardAtlanticCod: return "🐟"
        case .cardOrca: return "🐋"
        case .cardKingCrab: return "🦀"
        case .cardAtlanticWolffish: return "🐺"
        case .cardHumpbackWhale: return "🐳"
        case .cardWhiteTailedEagle: return "🦅"
        case .allCardsCalifornia: return "🏆"
        case .allCardsBretagne: return "🏅"
        case .allCardsMediterranean: return "🏆"
        case .allCardsNorway: return "🏅"
        case .quizEasy: return "📝"
        case .quizIntermediate: return "🧠"
        case .quizHard: return "🔥"
        case .quizExpert: return "👑"
        case .allQuizCalifornia: return "🎓"
        case .allQuizBretagne: return "🎓"
        case .allQuizMediterranean: return "🎓"
        case .allQuizNorway: return "🎓"
        case .firstCard: return "🎉"
        case .fiveCards: return "⭐️"
        case .tenCards: return "💎"
        case .twentyCards: return "🌟"
        case .secretAbout: return "🔮"
        }
    }

    var title: String {
        switch self {
        case .regionCalifornia: return "Pacific Explorer"
        case .regionBretagne: return "Breton Sailor"
        case .regionMediterranean: return "Mediterranean Diver"
        case .regionNorway: return "Norse Navigator"
        case .cardSeaOtter: return "Otter Friend"
        case .cardBlueWhale: return "Giant Hunter"
        case .cardGreatWhiteShark: return "Fearless"
        case .cardLeatherbackTurtle: return "Turtle Guardian"
        case .cardCaliforniaSeaLion: return "Show Time!"
        case .cardKelpForest: return "Sea Forester"
        case .cardGreySeal: return "Seal's Eye"
        case .cardBottlenoseDolphin: return "Flipper's Friend"
        case .cardZostera: return "Underwater Prairie"
        case .cardEuropeanLobster: return "Pinch Me!"
        case .cardPuffin: return "Sea Parrot"
        case .cardBaskingShark: return "Jaw Dropper"
        case .cardPosidonia: return "Ocean Lungs"
        case .cardLoggerheadTurtle: return "Ancient Traveler"
        case .cardMediterraneanMoray: return "Cave Lurker"
        case .cardDuskyGrouper: return "Reef Guardian"
        case .cardBluefinTuna: return "Speed Demon"
        case .cardMonkSeal: return "Ghost of the Sea"
        case .cardAtlanticCod: return "Viking's Gold"
        case .cardOrca: return "Apex Predator"
        case .cardKingCrab: return "Giant Invader"
        case .cardAtlanticWolffish: return "Arctic Crusher"
        case .cardHumpbackWhale: return "Song of the Deep"
        case .cardWhiteTailedEagle: return "Flying Barn Door"
        case .allCardsCalifornia: return "California Expert"
        case .allCardsBretagne: return "Brittany Expert"
        case .allCardsMediterranean: return "Mediterranean Expert"
        case .allCardsNorway: return "Norway Expert"
        case .quizEasy: return "First Wave"
        case .quizIntermediate: return "Deep Waters"
        case .quizHard: return "Abyss Master"
        case .quizExpert: return "Ocean Legend"
        case .allQuizCalifornia: return "California Graduate"
        case .allQuizBretagne: return "Brittany Graduate"
        case .allQuizMediterranean: return "Mediterranean Graduate"
        case .allQuizNorway: return "Norway Graduate"
        case .firstCard: return "First Step"
        case .fiveCards: return "Explorer"
        case .tenCards: return "Oceanographer"
        case .twentyCards: return "Marine Biologist"
        case .secretAbout: return "Behind the Scenes"
        }
    }

    var description: String {
        switch self {
        case .regionCalifornia: return "You explored the Californian coast"
        case .regionBretagne: return "You navigated Breton waters"
        case .regionMediterranean: return "You dove into the Mediterranean"
        case .regionNorway: return "You braved the Norwegian fjords"
        case .cardSeaOtter: return "Discovered the sea otter"
        case .cardBlueWhale: return "Discovered the blue whale"
        case .cardGreatWhiteShark: return "Discovered the great white shark"
        case .cardLeatherbackTurtle: return "Discovered the leatherback turtle"
        case .cardCaliforniaSeaLion: return "Discovered the sea lion"
        case .cardKelpForest: return "Discovered the kelp forest"
        case .cardGreySeal: return "Discovered the grey seal"
        case .cardBottlenoseDolphin: return "Discovered the bottlenose dolphin"
        case .cardZostera: return "Discovered the eelgrass"
        case .cardEuropeanLobster: return "Discovered the European lobster"
        case .cardPuffin: return "Discovered the Atlantic puffin"
        case .cardBaskingShark: return "Discovered the basking shark"
        case .cardPosidonia: return "Discovered the Posidonia meadows"
        case .cardLoggerheadTurtle: return "Discovered the loggerhead turtle"
        case .cardMediterraneanMoray: return "Discovered the Mediterranean moray"
        case .cardDuskyGrouper: return "Discovered the dusky grouper"
        case .cardBluefinTuna: return "Discovered the Atlantic bluefin tuna"
        case .cardMonkSeal: return "Discovered the Mediterranean monk seal"
        case .cardAtlanticCod: return "Discovered the Atlantic cod"
        case .cardOrca: return "Discovered the orca"
        case .cardKingCrab: return "Discovered the red king crab"
        case .cardAtlanticWolffish: return "Discovered the Atlantic wolffish"
        case .cardHumpbackWhale: return "Discovered the humpback whale"
        case .cardWhiteTailedEagle: return "Discovered the white-tailed eagle"
        case .allCardsCalifornia: return "All Californian species discovered"
        case .allCardsBretagne: return "All Breton species discovered"
        case .allCardsMediterranean: return "All Mediterranean species discovered"
        case .allCardsNorway: return "All Norwegian species discovered"
        case .quizEasy: return "First easy quiz completed"
        case .quizIntermediate: return "Intermediate quiz completed"
        case .quizHard: return "Hard quiz conquered"
        case .quizExpert: return "Expert quiz dominated"
        case .allQuizCalifornia: return "All California quizzes completed"
        case .allQuizBretagne: return "All Brittany quizzes completed"
        case .allQuizMediterranean: return "All Mediterranean quizzes completed"
        case .allQuizNorway: return "All Norway quizzes completed"
        case .firstCard: return "You read your first species card"
        case .fiveCards: return "5 species cards discovered"
        case .tenCards: return "10 species cards discovered"
        case .twentyCards: return "20 species cards discovered"
        case .secretAbout: return "You discovered the story behind Blue"
        }
    }

    // Map species ID to achievement type
    static func forSpecies(_ speciesId: String) -> AchievementType? {
        switch speciesId {
        case "sea_otter": return .cardSeaOtter
        case "blue_whale": return .cardBlueWhale
        case "great_white_shark": return .cardGreatWhiteShark
        case "leatherback_turtle": return .cardLeatherbackTurtle
        case "california_sea_lion": return .cardCaliforniaSeaLion
        case "kelp_forest": return .cardKelpForest
        case "grey_seal": return .cardGreySeal
        case "bottlenose_dolphin": return .cardBottlenoseDolphin
        case "zostera": return .cardZostera
        case "european_lobster": return .cardEuropeanLobster
        case "puffin": return .cardPuffin
        case "basking_shark": return .cardBaskingShark
        case "posidonia": return .cardPosidonia
        case "loggerhead_turtle": return .cardLoggerheadTurtle
        case "mediterranean_moray": return .cardMediterraneanMoray
        case "dusky_grouper": return .cardDuskyGrouper
        case "bluefin_tuna": return .cardBluefinTuna
        case "monk_seal": return .cardMonkSeal
        case "atlantic_cod": return .cardAtlanticCod
        case "orca": return .cardOrca
        case "king_crab": return .cardKingCrab
        case "atlantic_wolffish": return .cardAtlanticWolffish
        case "humpback_whale": return .cardHumpbackWhale
        case "white_tailed_eagle": return .cardWhiteTailedEagle
        default: return nil
        }
    }

    // Map region ID to achievement type
    static func forRegion(_ regionId: String) -> AchievementType? {
        switch regionId {
        case "california": return .regionCalifornia
        case "bretagne": return .regionBretagne
        case "mediterranean": return .regionMediterranean
        case "norway": return .regionNorway
        default: return nil
        }
    }
}
