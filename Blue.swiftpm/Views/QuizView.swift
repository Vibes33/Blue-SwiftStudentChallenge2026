import SwiftUI

struct QuizView: View {
    @Environment(RegionManager.self) private var regionManager
    @Environment(ProgressManager.self) private var progressManager
    @Environment(AccessibilityManager.self) private var accessibility
    @State private var activeQuiz: Quiz?
    @State private var appeared = false

    private var regionId: String { regionManager.selectedRegion.id }

    var body: some View {
        NavigationStack {
            ZStack {
                // Animated underwater background (Metal caustics shader)
                OceanBackgroundView()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        // Header
                        quizHeader
                            .padding(.top, 10)
                            .staggerIn(index: 0, appear: appeared, reduceAnimations: accessibility.reduceAnimations)

                        // Difficulty cards
                        ForEach(Array(QuizDifficulty.allCases.enumerated()), id: \.element) { idx, difficulty in
                            if let quiz = Quiz.quiz(for: regionId, difficulty: difficulty) {
                                QuizDifficultyCard(
                                    difficulty: difficulty,
                                    isCompleted: progressManager.hasCompletedQuiz(quizId: quiz.id),
                                    pointsReward: difficulty.pointsReward
                                ) {
                                    activeQuiz = quiz
                                }
                                .staggerIn(index: idx + 1, appear: appeared, reduceAnimations: accessibility.reduceAnimations)
                            }
                        }

                        // Stats
                        quizStatsCard
                            .staggerIn(index: 5, appear: appeared, reduceAnimations: accessibility.reduceAnimations)

                        Spacer().frame(height: 40)
                    }
                    .padding(.horizontal, 16)
                }
            }
            .onAppear { appeared = true }
            .navigationTitle("Quiz")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .fullScreenCover(item: $activeQuiz) { quiz in
                QuizSessionView(quiz: quiz)
            }
        }
    }
    private var quizHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "questionmark.bubble.fill")
                    .foregroundStyle(.cyan)
                    .font(.title2)
                Text("Test your knowledge")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)
            }

            HStack(spacing: 6) {
                Image(systemName: "mappin.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.cyan)
                Text(regionManager.selectedRegion.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.cyan)
                Text("·")
                    .foregroundStyle(.white.opacity(0.3))
                Text("\(Quiz.quizzes(for: regionId).count) quizzes available")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.5))
            }

            Text("Each quiz contains 5 questions about the marine species of your region. Complete them all to unlock achievements!")
                .font(.caption)
                .foregroundStyle(.white.opacity(accessibility.tertiaryOpacity(0.4)))
                .lineSpacing(3)
        }
        .glassCard()
    }
    private var quizStatsCard: some View {
        let completedCount = QuizDifficulty.allCases.filter { diff in
            if let quiz = Quiz.quiz(for: regionId, difficulty: diff) {
                return progressManager.hasCompletedQuiz(quizId: quiz.id)
            }
            return false
        }.count

        return VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Quiz Progress")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
                Spacer()
                Text("\(completedCount)/4")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.cyan)
            }

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(.white.opacity(0.1))
                        .frame(height: 10)

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [.cyan, .green],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(geo.size.width * Double(completedCount) / 4.0, 8), height: 10)
                        .shadow(color: .cyan.opacity(0.5), radius: 4)
                }
            }
            .frame(height: 10)

            HStack(spacing: 16) {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.green)
                    Text("\(completedCount) completed")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }
                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundStyle(.cyan)
                    Text("\(progressManager.totalQuizPoints(for: regionId)) pts earned")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
        }
        .glassCard()
    }
}
struct QuizDifficultyCard: View {
    let difficulty: QuizDifficulty
    let isCompleted: Bool
    let pointsReward: Int
    let onTap: () -> Void
    @Environment(AccessibilityManager.self) private var accessibility

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Difficulty icon
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(difficulty.color.opacity(0.15))
                        .frame(width: 56, height: 56)

                    Image(systemName: difficulty.icon)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(difficulty.color)
                }

                // Info
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(difficulty.rawValue)
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.white)

                        if isCompleted {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.subheadline)
                                .foregroundStyle(.green)
                        }
                    }

                    Text(difficulty.subtitle)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))

                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 9))
                            .foregroundStyle(.cyan)
                        Text("+\(pointsReward) pts")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.cyan)
                    }
                }

                Spacer()

                // Arrow / Status
                if isCompleted {
                    VStack(spacing: 2) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white.opacity(accessibility.tertiaryOpacity(0.4)))
                        Text("Retry")
                            .font(.system(size: 9))
                            .foregroundStyle(.white.opacity(accessibility.tertiaryOpacity(0.3)))
                    }
                } else {
                    Image(systemName: "chevron.right")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.white.opacity(accessibility.tertiaryOpacity(0.3)))
                }
            }
            .padding(16)
            .background {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(
                                isCompleted
                                    ? LinearGradient(colors: [.green.opacity(0.5), .green.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                    : LinearGradient(colors: [.white.opacity(0.15), .white.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing),
                                lineWidth: isCompleted ? 1.5 : 0.5
                            )
                    }
                    .shadow(color: isCompleted ? .green.opacity(0.15) : .black.opacity(0.2), radius: 12, y: 4)
            }
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Quiz \(difficulty.rawValue), \(isCompleted ? "completed" : "not completed"), \(pointsReward) points")
        .accessibilityHint(isCompleted ? "Tap to redo this quiz" : "Tap to start this quiz")
    }
}

#Preview {
    QuizView()
        .environment(RegionManager())
        .environment(ProgressManager())
        .environment(AccessibilityManager())
        .preferredColorScheme(.dark)
}
