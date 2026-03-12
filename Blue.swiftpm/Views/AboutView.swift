import SwiftUI
import Charts

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ProgressManager.self) private var progressManager
    @Environment(AccessibilityManager.self) private var accessibility
    @State private var hasTriggeredAchievement = false

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

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    // Header
                    aboutHeader

                    // Personal Story
                    storyCard

                    // Dev Stats
                    devStatsCard

                    // Timeline Chart
                    timelineCard

                    // Tech Stack
                    techStackCard

                    // Motivation
                    motivationCard

                    // Ocean message
                    oceanMessageCard

                    Spacer(minLength: 60)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }

            // Navigation bar
            VStack {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                                .font(.body.weight(.semibold))
                            Text("Profile")
                                .font(.subheadline.weight(.medium))
                        }
                        .foregroundStyle(.white.opacity(0.6))
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                Spacer()
            }

        }
        .navigationBarHidden(true)
        .onAppear {
            triggerSecretAchievement()
        }
    }
    private func triggerSecretAchievement() {
        guard !hasTriggeredAchievement else { return }
        hasTriggeredAchievement = true
        progressManager.discoverAboutPage()
    }
    private var aboutHeader: some View {
        VStack(spacing: 12) {
            Spacer(minLength: 50)

            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.cyan.opacity(0.3), .blue.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 90, height: 90)

                Text("🌊")
                    .font(.system(size: 44))
            }

            Text("About Blue")
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)

            Text("The story behind the app")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.5))
        }
        .padding(.bottom, 8)
    }
    private var storyCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("My Story", systemImage: "heart.text.square.fill")
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)

            Text("Blue was born from my desire to do something concrete, with my skills, to show, teach, and raise awareness through a project that reflects who I am.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
                .lineSpacing(4)

            Text("As a student passionate about iOS development and marine conservation, I wanted to create an experience that makes learning about ocean biodiversity accessible, engaging, and beautiful.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
                .lineSpacing(4)

            Text("Every species card and every quiz is designed to share important and fascinating information about a world that remains largely unknown 🐋")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
                .lineSpacing(4)
        }
        .padding(20)
        .glassCard()
    }
    private var devStatsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Development", systemImage: "hammer.fill")
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 14) {
                DevStatItem(icon: "clock.fill", value: "80+", label: "Dev hours", color: .cyan)
                DevStatItem(icon: "cup.and.saucer.fill", value: "12", label: "Coffees", color: .orange)
                DevStatItem(icon: "doc.text.fill", value: "9000+", label: "Lines of code", color: .mint)
                DevStatItem(icon: "ant.fill", value: "42", label: "Bugs fixed", color: .red)
                DevStatItem(icon: "fish.fill", value: "24", label: "Species documented", color: .teal)
                DevStatItem(icon: "questionmark.circle.fill", value: "80", label: "Quiz questions", color: .purple)
            }
        }
        .padding(20)
        .glassCard()
    }
    private var timelineCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Project Timeline", systemImage: "chart.line.uptrend.xyaxis")
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)

            Chart {
                ForEach(projectTimeline, id: \.week) { entry in
                    BarMark(
                        x: .value("Week", entry.week),
                        y: .value("Hours", entry.hours)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.cyan, .blue],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(6)
                }
            }
            .chartXAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisValueLabel()
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
            .chartYAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisGridLine()
                        .foregroundStyle(.white.opacity(0.08))
                    AxisValueLabel()
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
            .frame(height: 180)

            Text("Hours breakdown per development week")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.4))
        }
        .padding(20)
        .glassCard()
    }
    private var techStackCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Technologies", systemImage: "wrench.and.screwdriver.fill")
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)

            VStack(spacing: 10) {
                TechRow(name: "SwiftUI", detail: "100% declarative UI", icon: "swift", color: .orange)
                TechRow(name: "MapKit", detail: "Interactive cartography", icon: "map.fill", color: .green)
                TechRow(name: "Swift Charts", detail: "Data visualization", icon: "chart.bar.fill", color: .cyan)
                TechRow(name: "@Observable", detail: "Modern state management", icon: "eye.fill", color: .purple)
                TechRow(name: "UserDefaults", detail: "Local persistence", icon: "externaldrive.fill", color: .mint)
                TechRow(name: "Core Haptics", detail: "Immersive haptic feedback", icon: "hand.tap.fill", color: .pink)
                TechRow(name: "Metal", detail: "GPU caustics shader", icon: "cpu", color: .gray)
                TechRow(name: "Accessibility", detail: "VoiceOver & Dynamic Type", icon: "accessibility", color: .blue)
                TechRow(name: "Swift 6", detail: "Strict concurrency", icon: "swift", color: .red)
            }
        }
        .padding(20)
        .glassCard()
    }
    private var motivationCard: some View {
        VStack(spacing: 16) {
            Image(systemName: "quote.opening")
                .font(.title2)
                .foregroundStyle(.cyan.opacity(0.5))

            Text("\"The ocean is all around us , let's try to better understand and protect its wonderful ecosystems.\"")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .lineSpacing(5)
                .italic()

            Text("— Ryan Delépine, Computer Science Student")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.cyan.opacity(0.7))
        }
        .padding(24)
        .glassCard()
    }
    private var oceanMessageCard: some View {
        VStack(spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "leaf.fill")
                    .foregroundStyle(.green)
                Text("A gesture for the ocean")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
            }

            Text("Every day, marine species see their habitat threatened. By learning about them, we take the first step toward their protection. Spread the word. 🌍")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Divider()
                .overlay(Color.white.opacity(0.08))

            Text("Thank you for exploring Blue 💙")
                .font(.caption.weight(.medium))
                .foregroundStyle(.cyan.opacity(0.7))
        }
        .padding(20)
        .glassCard()
    }
    private var projectTimeline: [(week: String, hours: Double)] {
        [
            ("W1", 22),
            ("W2", 28),
            ("W3", 24),
            ("W4", 26)
        ]
    }
}
private struct DevStatItem: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)

            Text(value)
                .font(.title3.weight(.bold).monospacedDigit())
                .foregroundStyle(.white)

            Text(label)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.5))
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(color.opacity(0.08))
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(color.opacity(0.15), lineWidth: 1)
                }
        }
    }
}

private struct TechRow: View {
    let name: String
    let detail: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(color)
                .frame(width: 32, height: 32)
                .background {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(color.opacity(0.12))
                }

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    AboutView()
        .environment(ProgressManager())
        .environment(AccessibilityManager())
        .preferredColorScheme(.dark)
}
