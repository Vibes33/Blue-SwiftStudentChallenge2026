import SwiftUI

struct QuizSessionView: View {
    let quiz: Quiz
    @Environment(\.dismiss) private var dismiss
    @Environment(ProgressManager.self) private var progressManager
    @Environment(AccessibilityManager.self) private var accessibility

    @State private var currentIndex: Int = 0
    @State private var selectedAnswer: Int? = nil
    @State private var isCorrect: Bool? = nil
    @State private var score: Int = 0
    @State private var showResult: Bool = false
    @State private var shakeWrong: Bool = false
    @State private var animateCorrect: Bool = false
    @State private var showConfetti: Bool = false
    @State private var pulseCorrect: Bool = false

    // Shuffled answer orders per question (generated once per session)
    @State private var shuffledOrders: [[Int]] = []

    private var currentQuestion: QuizQuestion {
        quiz.questions[currentIndex]
    }

    /// The shuffled answer order for the current question
    private var currentOrder: [Int] {
        guard currentIndex < shuffledOrders.count else { return [0, 1, 2, 3] }
        return shuffledOrders[currentIndex]
    }

    /// The position of the correct answer after shuffling
    private var shuffledCorrectIndex: Int {
        currentOrder.firstIndex(of: currentQuestion.correctIndex) ?? currentQuestion.correctIndex
    }

    private var progressFraction: Double {
        Double(currentIndex + 1) / Double(quiz.questions.count)
    }

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(red: 0.04, green: 0.08, blue: 0.18),
                    Color(red: 0.02, green: 0.10, blue: 0.25),
                    Color(red: 0.03, green: 0.14, blue: 0.32)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            if showResult {
                resultView
            } else {
                questionView
            }

            // Confetti overlay
            if showConfetti && !accessibility.reduceAnimations {
                ConfettiView()
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
        }
        .blueAccessibility(accessibility)
    }
    private var questionView: some View {
        VStack(spacing: 0) {
            // Top bar
            topBar
                .padding(.horizontal, 20)
                .padding(.top, 16)

            // Progress bar
            progressBar
                .padding(.horizontal, 20)
                .padding(.top, 12)

            Spacer()

            // Question
            VStack(spacing: 8) {
                Text("Question \(currentIndex + 1)/\(quiz.questions.count)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(quiz.difficulty.color)

                Text(currentQuestion.question)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 24)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, 20)

            Spacer()

            // Answer buttons
            VStack(spacing: 12) {
                ForEach(0..<4, id: \.self) { index in
                    AnswerButton(
                        text: currentQuestion.answers[currentOrder[index]],
                        index: index,
                        selectedAnswer: selectedAnswer,
                        correctIndex: shuffledCorrectIndex,
                        isRevealed: isCorrect != nil,
                        shakeWrong: shakeWrong && selectedAnswer == index && isCorrect == false
                    ) {
                        handleAnswer(index)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .onAppear {
            if shuffledOrders.isEmpty {
                shuffledOrders = quiz.questions.map { _ in
                    [0, 1, 2, 3].shuffled()
                }
            }
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
                    Text("Quit")
                        .font(.subheadline.weight(.medium))
                }
                .foregroundStyle(.white.opacity(0.6))
            }

            Spacer()

            // Difficulty badge
            HStack(spacing: 4) {
                Circle()
                    .fill(quiz.difficulty.color)
                    .frame(width: 8, height: 8)
                Text(quiz.difficulty.rawValue)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(quiz.difficulty.color)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background {
                Capsule()
                    .fill(quiz.difficulty.color.opacity(0.12))
            }

            Spacer()

            // Score
            HStack(spacing: 4) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.green)
                Text("\(score)/\(quiz.questions.count)")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.white)
            }
        }
    }
    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.white.opacity(0.08))
                    .frame(height: 6)

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [quiz.difficulty.color, quiz.difficulty.color.opacity(0.6)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(geo.size.width * progressFraction, 8), height: 6)
                    .animation(.easeInOut(duration: 0.4), value: currentIndex)
            }
        }
        .frame(height: 6)
    }
    private func handleAnswer(_ index: Int) {
        guard selectedAnswer == nil else { return }

        // Tap on selection
        let selectionFeedback = UIImpactFeedbackGenerator(style: .medium)
        selectionFeedback.prepare()
        selectionFeedback.impactOccurred()

        selectedAnswer = index
        let correct = index == shuffledCorrectIndex
        isCorrect = correct

        if correct {
            score += 1

            // Success haptic — notification style
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                let notification = UINotificationFeedbackGenerator()
                notification.prepare()
                notification.notificationOccurred(.success)
            }

            withAnimation(accessibility.reduceAnimations ? nil : .spring(response: 0.3, dampingFraction: 0.7)) {
                animateCorrect = true
                pulseCorrect = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                moveToNext()
            }
        } else {
            // Error haptic — notification error
            let notification = UINotificationFeedbackGenerator()
            notification.prepare()
            notification.notificationOccurred(.error)

            withAnimation(accessibility.reduceAnimations ? nil : .default) {
                shakeWrong = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                moveToNext()
            }
        }
    }

    private func moveToNext() {
        if currentIndex < quiz.questions.count - 1 {
            // Transition tap
            let transition = UIImpactFeedbackGenerator(style: .light)
            transition.prepare()
            transition.impactOccurred()

            withAnimation(accessibility.reduceAnimations ? nil : .easeInOut(duration: 0.3)) {
                currentIndex += 1
                selectedAnswer = nil
                isCorrect = nil
                shakeWrong = false
                animateCorrect = false
                pulseCorrect = false
            }
        } else {
            let passed = score >= 3
            withAnimation(accessibility.reduceAnimations ? nil : .spring(response: 0.5, dampingFraction: 0.8)) {
                showResult = true
            }

            if passed {
                progressManager.completeQuiz(quizId: quiz.id, regionId: quiz.regionId, difficulty: quiz.difficulty)

                // Trigger confetti with celebration haptics
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        showConfetti = true
                    }
                    // Celebration haptic — strong success notification
                    let notification = UINotificationFeedbackGenerator()
                    notification.prepare()
                    notification.notificationOccurred(.success)

                    // Follow-up medium impact
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.prepare()
                        impact.impactOccurred()
                    }
                }

                // Stop confetti after a few seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    withAnimation(.easeOut(duration: 1)) {
                        showConfetti = false
                    }
                }
            } else {
                // Failed quiz — warning notification
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    let notification = UINotificationFeedbackGenerator()
                    notification.prepare()
                    notification.notificationOccurred(.warning)
                }
            }
        }
    }
    private var resultView: some View {
        VStack(spacing: 24) {
            Spacer()

            // Result emoji
            let passed = score >= 3
            Text(passed ? "🎉" : "😢")
                .font(.system(size: 72))
                .scaleEffect(showResult ? 1 : 0.3)
                .animation(accessibility.reduceAnimations ? nil : .spring(response: 0.5, dampingFraction: 0.6), value: showResult)
                .accessibilityLabel(passed ? "Congratulations, quiz passed" : "Quiz failed")

            Text(passed ? "Well done!" : "Too bad…")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(.white)

            Text(resultMessage)
                .font(.body)
                .foregroundStyle(.white.opacity(accessibility.secondaryOpacity(0.6)))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            // Score display
            HStack(spacing: 30) {
                VStack(spacing: 4) {
                    Text("\(score)/\(quiz.questions.count)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(passed ? .green : .orange)
                    Text("Correct answers")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(accessibility.secondaryOpacity(0.5)))
                }

                if passed {
                    VStack(spacing: 4) {
                        Text("+\(quiz.difficulty.pointsReward)")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(.cyan)
                        Text("Points earned")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(accessibility.secondaryOpacity(0.5)))
                    }
                }
            }
            .padding(24)
            .background {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.white.opacity(0.05))
            }

            Spacer()

            // Buttons
            VStack(spacing: 12) {
                if !passed {
                    Button {
                        // Restart with re-shuffled answers
                        withAnimation {
                            currentIndex = 0
                            selectedAnswer = nil
                            isCorrect = nil
                            score = 0
                            showResult = false
                            shakeWrong = false
                            animateCorrect = false
                            showConfetti = false
                            pulseCorrect = false
                            shuffledOrders = quiz.questions.map { _ in
                                [0, 1, 2, 3].shuffled()
                            }
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Retry")
                        }
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(quiz.difficulty.color)
                        }
                    }
                }

                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "xmark")
                        Text(passed ? "Finish" : "Quit")
                    }
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(passed ? .white : .white.opacity(0.6))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(passed ? .cyan : .white.opacity(0.08))
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
    }

    private var resultMessage: String {
        switch score {
        case 5: return "Perfect score! You are a true marine life expert 🌊"
        case 4: return "Excellent! You know the species of this region very well"
        case 3: return "Well played! The quiz is validated, keep exploring"
        case 2: return "You need at least 3 correct answers to pass. Try again!"
        case 1: return "Read the species cards to improve your score!"
        default: return "Don't give up! The species cards are here to help you"
        }
    }
}
struct AnswerButton: View {
    let text: String
    let index: Int
    let selectedAnswer: Int?
    let correctIndex: Int
    let isRevealed: Bool
    let shakeWrong: Bool
    let onTap: () -> Void
    @Environment(AccessibilityManager.self) private var accessibility

    private var backgroundColor: Color {
        guard isRevealed else {
            return selectedAnswer == index ? .white.opacity(0.12) : .white.opacity(0.06)
        }
        if index == correctIndex {
            return .green.opacity(0.2)
        }
        if selectedAnswer == index {
            return .red.opacity(0.2)
        }
        return .white.opacity(0.04)
    }

    private var borderColor: Color {
        guard isRevealed else {
            return selectedAnswer == index ? .cyan.opacity(0.4) : .white.opacity(0.1)
        }
        if index == correctIndex {
            return .green.opacity(0.6)
        }
        if selectedAnswer == index {
            return .red.opacity(0.6)
        }
        return .white.opacity(0.05)
    }

    private var textColor: Color {
        guard isRevealed else { return .white }
        if index == correctIndex { return .green }
        if selectedAnswer == index { return .red }
        return .white.opacity(accessibility.tertiaryOpacity(0.3))
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                // Letter circle
                ZStack {
                    Circle()
                        .fill(isRevealed && index == correctIndex ? .green.opacity(0.2) : .white.opacity(0.08))
                        .frame(width: 36, height: 36)

                    if isRevealed && index == correctIndex {
                        Image(systemName: "checkmark")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.green)
                    } else if isRevealed && selectedAnswer == index && index != correctIndex {
                        Image(systemName: "xmark")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.red)
                    } else {
                        Text(letterForIndex(index))
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }

                    Text(text)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(textColor)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)

                Spacer()

                if isRevealed && index == correctIndex {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .transition(.scale.combined(with: .opacity))
                        .accessibilityLabel("Correct answer")
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Answer \(letterForIndex(index)): \(text)")
            .accessibilityHint(isRevealed ? (index == correctIndex ? "Correct answer" : "Wrong answer") : "Tap to select")
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(backgroundColor)
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(borderColor, lineWidth: 1.5)
                    }
            }
            .offset(x: shakeWrong && !accessibility.reduceAnimations ? -8 : 0)
            .animation(
                shakeWrong && !accessibility.reduceAnimations
                    ? .default.repeatCount(4, autoreverses: true).speed(6)
                    : .default,
                value: shakeWrong
            )
        }
        .buttonStyle(.plain)
        .disabled(selectedAnswer != nil)
        .animation(.easeInOut(duration: 0.3), value: isRevealed)
    }

    private func letterForIndex(_ i: Int) -> String {
        ["A", "B", "C", "D"][i]
    }
}
struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    @State private var isAnimating = false

    struct ConfettiParticle: Identifiable {
        let id = UUID()
        let color: Color
        let x: CGFloat
        let size: CGFloat
        let rotation: Double
        let shape: Int // 0 = circle, 1 = rectangle, 2 = star
        let delay: Double
        let speed: Double
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles) { p in
                    confettiShape(for: p)
                        .foregroundStyle(p.color)
                        .frame(width: p.size, height: p.shape == 1 ? p.size * 1.6 : p.size)
                        .rotationEffect(.degrees(isAnimating ? p.rotation + 360 : p.rotation))
                        .position(
                            x: p.x * geo.size.width,
                            y: isAnimating ? geo.size.height + 40 : -40
                        )
                        .opacity(isAnimating ? 0 : 1)
                        .animation(
                            .easeIn(duration: p.speed)
                            .delay(p.delay),
                            value: isAnimating
                        )
                }
            }
            .onAppear {
                generateParticles()
                // Small delay then start falling
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    isAnimating = true
                }
            }
        }
    }

    @ViewBuilder
    private func confettiShape(for p: ConfettiParticle) -> some View {
        switch p.shape {
        case 0:
            Circle()
        case 1:
            RoundedRectangle(cornerRadius: 2, style: .continuous)
        default:
            Image(systemName: "star.fill")
                .resizable()
        }
    }

    private func generateParticles() {
        let colors: [Color] = [
            .cyan, .mint, .blue, .teal, .white,
            Color(red: 0.3, green: 0.85, blue: 1),
            Color(red: 0.6, green: 0.95, blue: 0.9),
            .yellow.opacity(0.8),
            .orange.opacity(0.6)
        ]

        var result: [ConfettiParticle] = []
        for _ in 0..<50 {
            result.append(
                ConfettiParticle(
                    color: colors.randomElement()!,
                    x: CGFloat.random(in: 0.05...0.95),
                    size: CGFloat.random(in: 5...12),
                    rotation: Double.random(in: 0...360),
                    shape: Int.random(in: 0...2),
                    delay: Double.random(in: 0...0.8),
                    speed: Double.random(in: 2.0...3.5)
                )
            )
        }
        particles = result
    }
}

#Preview {
    QuizSessionView(quiz: Quiz.californiaQuizzes[0])
        .environment(ProgressManager())
        .environment(AccessibilityManager())
        .preferredColorScheme(.dark)
}
