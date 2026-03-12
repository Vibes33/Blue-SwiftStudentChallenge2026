import SwiftUI

struct OnboardingPage: Identifiable {
    let id: Int
    let emoji: String
    let title: String
    let subtitle: String
    let description: String
    let accentColor: Color
}

private let onboardingPages: [OnboardingPage] = [
    OnboardingPage(
        id: 0,
        emoji: "🌊",
        title: "Welcome to\nBlue",
        subtitle: "Explore marine life",
        description: "Discover the protected species of our oceans, learn about them, and understand why each one is essential.",
        accentColor: .cyan
    ),
    OnboardingPage(
        id: 1,
        emoji: "🦦",
        title: "Species to\ndiscover",
        subtitle: "Detailed profiles",
        description: "Each species has a full profile: conservation status, threats, population, habitat, and fascinating facts.",
        accentColor: .teal
    ),
    OnboardingPage(
        id: 2,
        emoji: "🧠",
        title: "Test your\nknowledge",
        subtitle: "Quizzes by difficulty",
        description: "4 quiz levels for each region. Earn points, level up, and unlock achievements.",
        accentColor: .blue
    ),
    OnboardingPage(
        id: 3,
        emoji: "🌿",
        title: "Simulate an\necosystem",
        subtitle: "Interactive food chain",
        description: "Remove a species and watch the cascade collapse. Understand why every link matters.",
        accentColor: .green
    ),
    OnboardingPage(
        id: 4,
        emoji: "🗺️",
        title: "Navigate the\nmap",
        subtitle: "Change regions",
        description: "Use the interactive map to select a marine zone. Each region has its own species, quizzes, and ecosystem to explore.",
        accentColor: .mint
    ),
    OnboardingPage(
        id: 5,
        emoji: "💚",
        title: "Take action\nfor the ocean",
        subtitle: "Partner organizations",
        description: "Find local and international marine conservation NGOs. Learn more, support their actions, and make a difference.",
        accentColor: .green
    ),
    OnboardingPage(
        id: 6,
        emoji: "♿",
        title: "Accessible\nto all",
        subtitle: "Designed for everyone",
        description: "Larger text, reduced animations, high contrast, and voice descriptions. Customize Blue from your profile settings.",
        accentColor: .purple
    ),
]
struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage: Int = 0
    @State private var progressTimer: Timer? = nil
    @State private var autoProgress: CGFloat = 0  // 0...1 ring fill

    private let totalPages = onboardingPages.count
    private let autoAdvanceDuration: Double = 12.0 // seconds per slide

    var body: some View {
        ZStack {
            // Background — animated gradient per page
            backgroundGradient
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.6), value: currentPage)

            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    if currentPage < totalPages - 1 {
                        Button {
                            completeOnboarding()
                        } label: {
                            Text("Skip")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.white.opacity(0.5))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                        }
                        .transition(.opacity)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .frame(height: 44)

                Spacer()

                // Page content
                pageContent
                    .padding(.horizontal, 28)

                Spacer()

                // Page indicators + next button
                bottomControls
                    .padding(.horizontal, 28)
                    .padding(.bottom, 50)
            }
        }
        .onAppear {
            startAutoProgress()
        }
        .onDisappear {
            stopAutoProgress()
        }
    }
    private var backgroundGradient: some View {
        let page = onboardingPages[currentPage]
        return LinearGradient(
            colors: [
                Color(red: 0.04, green: 0.08, blue: 0.18),
                page.accentColor.opacity(0.15),
                Color(red: 0.02, green: 0.10, blue: 0.25),
                Color(red: 0.03, green: 0.14, blue: 0.32)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    private var pageContent: some View {
        let page = onboardingPages[currentPage]

        return VStack(spacing: 24) {
            // Big emoji with glow
            ZStack {
                Circle()
                    .fill(page.accentColor.opacity(0.08))
                    .frame(width: 160, height: 160)

                Circle()
                    .fill(page.accentColor.opacity(0.05))
                    .frame(width: 120, height: 120)

                Text(page.emoji)
                    .font(.system(size: 64))
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 8)

            // Subtitle pill
            Text(page.subtitle)
                .font(.caption.weight(.bold))
                .foregroundStyle(page.accentColor)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background {
                    Capsule()
                        .fill(page.accentColor.opacity(0.12))
                }

            // Title
            Text(page.title)
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            // Description
            Text(page.description)
                .font(.body)
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .lineSpacing(5)
        }
        .id(currentPage) // Force view replacement for transition
        .transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        ))
    }
    private var bottomControls: some View {
        HStack {
            // Page dots
            HStack(spacing: 8) {
                ForEach(0..<totalPages, id: \.self) { i in
                    Capsule()
                        .fill(i == currentPage ? onboardingPages[currentPage].accentColor : .white.opacity(0.2))
                        .frame(width: i == currentPage ? 24 : 8, height: 8)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
                }
            }

            Spacer()

            // Next / Start button with progress ring
            Button {
                advancePage()
            } label: {
                ZStack {
                    // Background ring track
                    Circle()
                        .stroke(.white.opacity(0.1), lineWidth: 3)
                        .frame(width: 62, height: 62)

                    // Progress ring
                    Circle()
                        .trim(from: 0, to: autoProgress)
                        .stroke(
                            onboardingPages[currentPage].accentColor,
                            style: StrokeStyle(lineWidth: 3, lineCap: .round)
                        )
                        .frame(width: 62, height: 62)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 0.05), value: autoProgress)

                    // Button circle
                    Circle()
                        .fill(onboardingPages[currentPage].accentColor)
                        .frame(width: 52, height: 52)
                        .shadow(color: onboardingPages[currentPage].accentColor.opacity(0.4), radius: 8, y: 4)

                    // Icon
                    if currentPage == totalPages - 1 {
                        Image(systemName: "checkmark")
                            .font(.body.weight(.bold))
                            .foregroundStyle(.white)
                    } else {
                        Image(systemName: "arrow.right")
                            .font(.body.weight(.bold))
                            .foregroundStyle(.white)
                    }
                }
            }
            .buttonStyle(.plain)
        }
    }
    private func advancePage() {
        let gen = UIImpactFeedbackGenerator(style: .light)
        gen.prepare()
        gen.impactOccurred()

        if currentPage < totalPages - 1 {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                currentPage += 1
            }
            resetAutoProgress()
        } else {
            completeOnboarding()
        }
    }

    private func completeOnboarding() {
        let gen = UINotificationFeedbackGenerator()
        gen.prepare()
        gen.notificationOccurred(.success)

        stopAutoProgress()

        withAnimation(.easeOut(duration: 0.3)) {
            hasCompletedOnboarding = true
        }
    }
    private func startAutoProgress() {
        autoProgress = 0
        let interval: Double = 0.05
        let increment = CGFloat(interval / autoAdvanceDuration)

        progressTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            DispatchQueue.main.async {
                if autoProgress >= 1.0 {
                    advancePage()
                } else {
                    autoProgress += increment
                }
            }
        }
    }

    private func stopAutoProgress() {
        progressTimer?.invalidate()
        progressTimer = nil
    }

    private func resetAutoProgress() {
        stopAutoProgress()
        autoProgress = 0
        startAutoProgress()
    }
}

#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
        .preferredColorScheme(.dark)
}
