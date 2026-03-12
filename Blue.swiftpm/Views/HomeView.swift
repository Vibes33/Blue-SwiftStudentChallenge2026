
import SwiftUI

struct HomeView: View {
    @Environment(RegionManager.self) private var regionManager
    @Environment(ProgressManager.self) private var progressManager
    @Environment(AccessibilityManager.self) private var accessibility

    private var regionId: String { regionManager.selectedRegion.id }
    private var regionInfo: RegionInfo { RegionInfo.info(for: regionId) }

    var body: some View {
        NavigationStack {
            ZStack {
                // Animated underwater background (Metal caustics shader)
                OceanBackgroundView()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {

                        headerSection
                            .padding(.top, 10)

                        LevelProgressCard(
                            level: progressManager.level(for: regionId),
                            currentPoints: progressManager.pointsInCurrentLevel(for: regionId),
                            pointsNeeded: ProgressManager.pointsPerLevel,
                            progress: progressManager.levelProgress(for: regionId),
                            totalPoints: progressManager.totalPoints(for: regionId),
                            cardsRead: progressManager.progress(for: regionId).cardsRead,
                            quizzesCompleted: progressManager.progress(for: regionId).quizzesCompleted
                        )

                        ecosystemCard

                        if !regionInfo.funFacts.isEmpty {
                            FunFactsCard(facts: regionInfo.funFacts)
                                .id(regionId)
                        }

                        if !regionInfo.stats.isEmpty {
                            RegionStatsCard(stats: regionInfo.stats)
                        }

                        PointsBreakdownCard(
                            cardsRead: progressManager.progress(for: regionId).cardsRead,
                            quizzesCompleted: progressManager.progress(for: regionId).quizzesCompleted,
                            totalQuizPoints: progressManager.totalQuizPoints(for: regionId)
                        )

                        if !regionInfo.highlights.isEmpty {
                            HighlightsCard(
                                highlights: regionInfo.highlights,
                                regionName: regionManager.selectedRegion.name
                            )
                        }

                        // Bottom spacing for tab bar
                        Spacer()
                            .frame(height: 40)
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
    }
    @State private var showEcosystem = false

    private var ecosystemCard: some View {
        Button {
            showEcosystem = true
        } label: {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [.green.opacity(0.2), .cyan.opacity(0.15)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)

                    Text("🌊")
                        .font(.system(size: 28))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Ecosystem Simulator")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.white)
                    Text("Remove a species, observe the consequences")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(accessibility.secondaryOpacity(0.5)))
                        .lineLimit(2)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.cyan.opacity(0.5))
            }
            .padding(16)
            .glassCard()
        }
        .buttonStyle(.plain)
        .fullScreenCover(isPresented: $showEcosystem) {
            EcosystemView(regionId: regionId)
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(progressManager.userName.isEmpty ? "Hello 👋🏻" : "Hello, \(progressManager.userName) 👋🏻")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    HStack(spacing: 6) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.cyan)
                        Text("Current zone ·")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(accessibility.secondaryOpacity(0.5)))
                        Text(regionManager.selectedRegion.name)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.cyan)
                    }
                }

                Spacer()

                // Global level badge
                VStack(spacing: 2) {
                    Image(progressManager.globalBadgeImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 44, height: 44)
                        .accessibilityLabel("Level \(progressManager.globalLevel) badge")

                    Text("Lv.\(progressManager.globalLevel)")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(.cyan)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    HomeView()
        .environment(RegionManager())
        .environment(ProgressManager())
        .environment(AccessibilityManager())
}
