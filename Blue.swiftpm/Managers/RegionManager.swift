
import SwiftUI
import MapKit
import Observation

@Observable
class RegionManager {
    var selectedRegion: Region = .california {
        didSet {
            UserDefaults.standard.set(selectedRegion.id, forKey: "blue_selectedRegion")
        }
    }
    var allRegions: [Region] = Region.allRegions

    var selectedRegionName: String {
        selectedRegion.name
    }

    init() {
        if let savedId = UserDefaults.standard.string(forKey: "blue_selectedRegion"),
           let region = Region.allRegions.first(where: { $0.id == savedId && $0.isAvailable }) {
            selectedRegion = region
        }
    }

    func selectRegion(_ region: Region) {
        guard region.isAvailable else { return }
        withAnimation(.easeInOut(duration: 0.3)) {
            selectedRegion = region
        }
    }

    func selectRegion(_ region: Region, progressManager: ProgressManager) {
        guard region.isAvailable else { return }
        withAnimation(.easeInOut(duration: 0.3)) {
            selectedRegion = region
        }
        progressManager.markRegionVisited(region.id)
    }

    func isSelected(_ region: Region) -> Bool {
        selectedRegion.id == region.id
    }
}
