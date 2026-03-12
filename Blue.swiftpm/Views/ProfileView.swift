import SwiftUI

struct ProfileView: View {
    @Environment(RegionManager.self) private var regionManager
    @Environment(ProgressManager.self) private var progressManager
    @Environment(AccessibilityManager.self) private var accessibility
    @State private var isEditingName = false
    @State private var editedName = ""
    @State private var showSettings = false
    @State private var appeared = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Animated underwater background (Metal caustics shader)
                OceanBackgroundView()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        profileHeader
                            .padding(.top, 10)
                            .staggerIn(index: 0, appear: appeared, reduceAnimations: accessibility.reduceAnimations)

                        globalStatsCard
                            .staggerIn(index: 1, appear: appeared, reduceAnimations: accessibility.reduceAnimations)

                        achievementsSection
                            .staggerIn(index: 2, appear: appeared, reduceAnimations: accessibility.reduceAnimations)

                        allAchievementsGrid
                            .staggerIn(index: 3, appear: appeared, reduceAnimations: accessibility.reduceAnimations)

                        aboutTeaser
                            .staggerIn(index: 4, appear: appeared, reduceAnimations: accessibility.reduceAnimations)

                        Spacer().frame(height: 40)
                    }
                    .padding(.horizontal, 16)
                }
            }
            .onAppear { appeared = true }
            .navigationTitle("Profile")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.body)
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
    }
    private var profileHeader: some View {
        VStack(spacing: 16) {
            // Badge
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.cyan.opacity(0.3), .blue.opacity(0.1), .clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 70
                        )
                    )
                    .frame(width: 140, height: 140)

                Image(progressManager.globalBadgeImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .accessibilityLabel("Level \(progressManager.globalLevel) badge")
            }

            // Name (editable)
            if isEditingName {
                HStack(spacing: 10) {
                    TextField("User", text: $editedName)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(.white.opacity(0.08))
                        }
                        .frame(maxWidth: 220)

                    Button {
                        progressManager.userName = editedName.trimmingCharacters(in: .whitespaces)
                        isEditingName = false
                    } label: {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.cyan)
                    }
                }
            } else {
                Button {
                    editedName = progressManager.userName
                    isEditingName = true
                } label: {
                    HStack(spacing: 6) {
                        if progressManager.userName.isEmpty {
                            Text("User")
                                .font(.title2.weight(.bold))
                                .foregroundStyle(.white.opacity(0.3))
                        } else {
                            Text(progressManager.userName)
                                .font(.title2.weight(.bold))
                                .foregroundStyle(.white)
                        }
                        Image(systemName: "pencil.circle.fill")
                            .font(.body)
                            .foregroundStyle(.cyan.opacity(0.6))
                    }
                }
                .buttonStyle(.plain)
            }

            // Level label
            Text("Level \(progressManager.globalLevel)")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.cyan)

            // Level progress bar
            VStack(spacing: 6) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(.white.opacity(0.1))
                            .frame(height: 8)

                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [.cyan, .blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(geo.size.width * progressManager.globalLevelProgress, 8), height: 8)
                            .shadow(color: .cyan.opacity(0.5), radius: 4)
                    }
                }
                .frame(height: 8)
                .padding(.horizontal, 40)

                Text("\(progressManager.pointsInCurrentGlobalLevel)/\(ProgressManager.pointsPerLevel) pts to next level")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(accessibility.tertiaryOpacity(0.4)))
            }
        }
        .glassCard()
    }
    private var globalStatsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Statistics")
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white)

            HStack(spacing: 0) {
                ProfileStatItem(icon: "star.fill", value: "\(progressManager.totalGlobalPoints)", label: "Points", color: .cyan)
                Spacer()
                ProfileStatItem(icon: "book.fill", value: "\(progressManager.totalCardsRead)", label: "Cards read", color: .teal)
                Spacer()
                ProfileStatItem(icon: "map.fill", value: "\(progressManager.regionsVisited)", label: "Regions", color: .blue)
                Spacer()
                ProfileStatItem(icon: "trophy.fill", value: "\(progressManager.achievements.count)", label: "Achievements", color: .orange)
            }
        }
        .glassCard()
    }
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "trophy.fill")
                    .foregroundStyle(.orange)
                Text("Achievements unlocked")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
                Spacer()
                Text("\(progressManager.achievements.count)/\(AchievementType.allCases.count)")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(accessibility.tertiaryOpacity(0.4)))
            }

            if progressManager.achievements.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Text("🔒")
                            .font(.largeTitle)
                        Text("Explore species to\nunlock achievements!")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.5))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.vertical, 20)
                    Spacer()
                }
            } else {
                let reversed = progressManager.achievements.reversed()
                let items = Array(reversed)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 8) {
                        ForEach(items) { achievement in
                            AchievementRow(achievement: achievement, isUnlocked: true)
                        }
                    }
                }
                .frame(maxHeight: items.count > 3 ? 230 : .infinity)
            }
        }
        .glassCard()
    }
    private var allAchievementsGrid: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "square.grid.2x2.fill")
                    .foregroundStyle(.cyan)
                Text("All Achievements")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
            }

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 10),
                GridItem(.flexible(), spacing: 10),
                GridItem(.flexible(), spacing: 10)
            ], spacing: 10) {
                ForEach(AchievementType.allCases, id: \.rawValue) { type in
                    let unlocked = progressManager.hasAchievement(type)
                    AchievementBadge(type: type, isUnlocked: unlocked)
                }
            }
        }
        .glassCard()
    }
    private var aboutTeaser: some View {
        NavigationLink {
            AboutView()
                .navigationBarBackButtonHidden(true)
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.cyan.opacity(0.15), .purple.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 42, height: 42)

                    Image(systemName: "sparkles")
                        .font(.body.weight(.medium))
                        .foregroundStyle(.cyan.opacity(0.7))
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("The story behind Blue")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white.opacity(0.6))
                    Text("Discover →")
                        .font(.caption)
                        .foregroundStyle(.cyan.opacity(0.5))
                }

                Spacer()

                if progressManager.hasAchievement(.secretAbout) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.caption)
                        .foregroundStyle(.cyan.opacity(0.4))
                }
            }
            .padding(16)
            .background {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(.white.opacity(0.03))
                    .overlay {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(.white.opacity(0.05), lineWidth: 1)
                    }
            }
        }
        .buttonStyle(.plain)
    }
}
struct ProfileStatItem: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    @Environment(AccessibilityManager.self) private var accessibility

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(color)
            }
            Text(value)
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)
            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(.white.opacity(accessibility.secondaryOpacity(0.5)))
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }
}
struct AchievementRow: View {
    let achievement: Achievement
    let isUnlocked: Bool

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isUnlocked ? .white.opacity(0.08) : .white.opacity(0.03))
                    .frame(width: 50, height: 50)
                Text(achievement.type.emoji)
                    .font(.title2)
                    .opacity(isUnlocked ? 1 : 0.3)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(achievement.type.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(isUnlocked ? .white : .white.opacity(0.3))
                Text(achievement.type.description)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(isUnlocked ? 0.6 : 0.3))
                    .lineLimit(2)
            }

            Spacer()

            if isUnlocked {
                Image(systemName: "checkmark.seal.fill")
                    .font(.body)
                    .foregroundStyle(.cyan)
            }
        }
        .padding(10)
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(isUnlocked ? .cyan.opacity(0.05) : .white.opacity(0.02))
        }
    }
}
struct AchievementBadge: View {
    let type: AchievementType
    let isUnlocked: Bool
    @Environment(AccessibilityManager.self) private var accessibility

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isUnlocked ? .white.opacity(0.08) : .white.opacity(0.03))
                    .frame(width: 60, height: 60)
                    .overlay {
                        if isUnlocked {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(.cyan.opacity(0.2), lineWidth: 1)
                        }
                    }

                if isUnlocked {
                    Text(type.emoji)
                        .font(.title)
                } else {
                    Image(systemName: "lock.fill")
                        .font(.body)
                        .foregroundStyle(.white.opacity(accessibility.tertiaryOpacity(0.15)))
                }
            }

            Text(type.title)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(isUnlocked ? .white.opacity(accessibility.secondaryOpacity(0.8)) : .white.opacity(accessibility.tertiaryOpacity(0.25)))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(height: 24)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ProfileView()
        .environment(RegionManager())
        .environment(ProgressManager())
        .environment(AccessibilityManager())
        .preferredColorScheme(.dark)
}
