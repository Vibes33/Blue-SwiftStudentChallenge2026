import SwiftUI

struct DiscoverView: View {
    @Environment(RegionManager.self) private var regionManager
    @Environment(ProgressManager.self) private var progressManager
    @Environment(AccessibilityManager.self) private var accessibility
    @State private var selectedSpecies: Species?
    @State private var appeared = false

    private var regionId: String { regionManager.selectedRegion.id }
    private var emblematicSpecies: [Species] { Species.emblematic(for: regionId) }
    private var protectedSpecies: [Species] { Species.protected(for: regionId) }
    private var allRegionSpecies: [Species] { Species.species(for: regionId) }
    private var regionInfo: RegionInfo { RegionInfo.info(for: regionId) }

    var body: some View {
        NavigationStack {
            ZStack {
                // Animated underwater background (Metal caustics shader)
                OceanBackgroundView()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {

                        RegionIntroCard(
                            region: regionManager.selectedRegion,
                            speciesCount: allRegionSpecies.count,
                            protectedCount: protectedSpecies.count
                        )
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .staggerIn(index: 0, appear: appeared, reduceAnimations: accessibility.reduceAnimations)

                        if !emblematicSpecies.isEmpty {
                            EmblematicSpeciesRow(species: emblematicSpecies, readCards: progressManager.readCards) { species in
                                selectedSpecies = species
                            }
                            .staggerIn(index: 1, appear: appeared, reduceAnimations: accessibility.reduceAnimations)
                        }

                        if !protectedSpecies.isEmpty {
                            ProtectedSpeciesSection(species: protectedSpecies, readCards: progressManager.readCards) { species in
                                selectedSpecies = species
                            }
                            .staggerIn(index: 2, appear: appeared, reduceAnimations: accessibility.reduceAnimations)
                        }

                        EcosystemHealthCard(regionId: regionId)
                            .padding(.horizontal, 16)
                            .staggerIn(index: 3, appear: appeared, reduceAnimations: accessibility.reduceAnimations)

                        if !regionInfo.stats.isEmpty {
                            RegionStatsCard(stats: regionInfo.stats)
                                .padding(.horizontal, 16)
                                .staggerIn(index: 4, appear: appeared, reduceAnimations: accessibility.reduceAnimations)
                        }

                        ThreatsOverviewCard(regionId: regionId)
                            .padding(.horizontal, 16)
                            .staggerIn(index: 5, appear: appeared, reduceAnimations: accessibility.reduceAnimations)

                        ONGSectionCard(regionId: regionId)
                            .padding(.horizontal, 16)
                            .staggerIn(index: 6, appear: appeared, reduceAnimations: accessibility.reduceAnimations)

                        Spacer().frame(height: 40)
                    }
                }
            }
            .onAppear { appeared = true }
            .navigationTitle("Discover")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(item: $selectedSpecies) { species in
                SpeciesDetailSheet(species: species)
                    .presentationDragIndicator(.visible)
                    .onAppear {
                        progressManager.markCardRead(speciesId: species.id, regionId: regionId)
                        // Milestone achievements
                        if progressManager.totalCardsRead >= 1 {
                            progressManager.unlockAchievement(.firstCard)
                        }
                        if progressManager.totalCardsRead >= 5 {
                            progressManager.unlockAchievement(.fiveCards)
                        }
                        if progressManager.totalCardsRead >= 10 {
                            progressManager.unlockAchievement(.tenCards)
                        }
                        if progressManager.totalCardsRead >= 20 {
                            progressManager.unlockAchievement(.twentyCards)
                        }
                    }
            }
        }
    }
}

#Preview {
    DiscoverView()
        .environment(RegionManager())
        .environment(ProgressManager())
        .environment(AccessibilityManager())
        .preferredColorScheme(.dark)
}
