import SwiftUI
import MapKit

struct MapView: View {
    @Environment(RegionManager.self) private var regionManager
    @Environment(ProgressManager.self) private var progressManager
    @Environment(AccessibilityManager.self) private var accessibility
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var selectedRegionID: String?
    @State private var showRegionSheet: Bool = false

    var body: some View {
        ZStack(alignment: .top) {
            Map(position: $cameraPosition) {
                // Draw all region polygons
                ForEach(regionManager.allRegions) { region in
                    // Region polygon fill
                    MapPolygon(coordinates: region.boundaryCoordinates)
                        .foregroundStyle(fillColor(for: region))
                        .stroke(strokeColor(for: region), lineWidth: regionManager.isSelected(region) ? 3 : 1.5)

                    // Region label annotation
                    Annotation(region.name, coordinate: region.coordinate) {
                        RegionAnnotationView(
                            region: region,
                            isSelected: regionManager.isSelected(region)
                        ) {
                            if region.isAvailable {
                                regionManager.selectRegion(region, progressManager: progressManager)
                                withAnimation(.easeInOut(duration: 0.8)) {
                                    cameraPosition = .region(region.region)
                                }
                            }
                        }
                    }
                }
            }
            .mapStyle(.standard(elevation: .realistic, emphasis: .muted))
            .ignoresSafeArea()
            .onAppear {
                cameraPosition = .region(
                    MKCoordinateRegion(
                        center: CLLocationCoordinate2D(latitude: 20, longitude: -30),
                        span: MKCoordinateSpan(latitudeDelta: 120, longitudeDelta: 160)
                    )
                )
            }

            // Top bar with current region info
            currentRegionBar
        }
    }
    private var currentRegionBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "globe.europe.africa.fill")
                .font(.title3)
                .foregroundStyle(.cyan)

            VStack(alignment: .leading, spacing: 2) {
                Text("Active Region")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(accessibility.secondaryOpacity(0.5)))
                Text(regionManager.selectedRegion.name)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
            }

            Spacer()

            Text(regionManager.selectedRegion.subtitle)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.5))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.3), radius: 10, y: 4)
        }
        .padding(.horizontal, 16)
        .padding(.top, 60)
    }
    private func fillColor(for region: Region) -> some ShapeStyle {
        if !region.isAvailable {
            return AnyShapeStyle(.gray.opacity(0.15))
        }
        if regionManager.isSelected(region) {
            return AnyShapeStyle(.cyan.opacity(0.2))
        }
        return AnyShapeStyle(.blue.opacity(0.12))
    }

    private func strokeColor(for region: Region) -> Color {
        if !region.isAvailable {
            return .gray.opacity(0.3)
        }
        if regionManager.isSelected(region) {
            return .cyan
        }
        return .blue.opacity(0.5)
    }
}
struct RegionAnnotationView: View {
    let region: Region
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(isSelected ? .cyan : (region.isAvailable ? .blue : .gray.opacity(0.5)))
                        .frame(width: 36, height: 36)
                        .shadow(color: isSelected ? .cyan.opacity(0.5) : .clear, radius: 8)

                    Image(systemName: region.isAvailable ? "mappin.circle.fill" : "lock.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(.white)
                }

                Text(region.name)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(isSelected ? .cyan : (region.isAvailable ? .white : .gray))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background {
                        Capsule()
                            .fill(.ultraThinMaterial)
                    }

                if !region.isAvailable {
                    Text("Soon")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(.gray)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(region.name)\(isSelected ? ", selected" : "")\(region.isAvailable ? "" : ", locked")")
        .accessibilityHint(region.isAvailable ? "Tap to select this region" : "This region will be available soon")
    }
}

#Preview {
    MapView()
        .environment(RegionManager())
        .environment(ProgressManager())
        .environment(AccessibilityManager())
        .preferredColorScheme(.dark)
}
