import SwiftUI
import MapKit
struct Region: Identifiable, Hashable {
    let id: String
    let name: String
    let subtitle: String
    let coordinate: CLLocationCoordinate2D
    let span: MKCoordinateSpan
    let isAvailable: Bool
    let boundaryCoordinates: [CLLocationCoordinate2D]

    var region: MKCoordinateRegion {
        MKCoordinateRegion(center: coordinate, span: span)
    }

    // Hashable conformance (CLLocationCoordinate2D is not Hashable)
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Region, rhs: Region) -> Bool {
        lhs.id == rhs.id
    }
}
extension Region {
    static let allRegions: [Region] = [
        // Available regions
        .california,
        .bretagne,
        // Unavailable regions (coming soon)
        .greatBarrierReef,
        .mediterranean,
        .caribbean,
        .norway,
        .galapagos,
        .japan
    ]

    static var availableRegions: [Region] {
        allRegions.filter { $0.isAvailable }
    }
    static let california = Region(
        id: "california",
        name: "California",
        subtitle: "Pacific Coast, USA",
        coordinate: CLLocationCoordinate2D(latitude: 35.5, longitude: -121.0),
        span: MKCoordinateSpan(latitudeDelta: 8.0, longitudeDelta: 8.0),
        isAvailable: true,
        boundaryCoordinates: [
            CLLocationCoordinate2D(latitude: 42.0, longitude: -124.4),
            CLLocationCoordinate2D(latitude: 42.0, longitude: -120.0),
            CLLocationCoordinate2D(latitude: 39.0, longitude: -120.0),
            CLLocationCoordinate2D(latitude: 35.0, longitude: -117.5),
            CLLocationCoordinate2D(latitude: 32.5, longitude: -117.1),
            CLLocationCoordinate2D(latitude: 32.5, longitude: -118.5),
            CLLocationCoordinate2D(latitude: 34.5, longitude: -120.5),
            CLLocationCoordinate2D(latitude: 37.8, longitude: -122.5),
            CLLocationCoordinate2D(latitude: 40.0, longitude: -124.3),
            CLLocationCoordinate2D(latitude: 42.0, longitude: -124.4)
        ]
    )

    static let bretagne = Region(
        id: "bretagne",
        name: "Brittany",
        subtitle: "Atlantic Coast, France",
        coordinate: CLLocationCoordinate2D(latitude: 48.2, longitude: -3.5),
        span: MKCoordinateSpan(latitudeDelta: 3.0, longitudeDelta: 4.0),
        isAvailable: true,
        boundaryCoordinates: [
            CLLocationCoordinate2D(latitude: 48.65, longitude: -1.15),
            CLLocationCoordinate2D(latitude: 48.85, longitude: -1.85),
            CLLocationCoordinate2D(latitude: 48.70, longitude: -3.0),
            CLLocationCoordinate2D(latitude: 48.80, longitude: -3.8),
            CLLocationCoordinate2D(latitude: 48.45, longitude: -4.8),
            CLLocationCoordinate2D(latitude: 48.0, longitude: -4.8),
            CLLocationCoordinate2D(latitude: 47.75, longitude: -4.35),
            CLLocationCoordinate2D(latitude: 47.50, longitude: -3.1),
            CLLocationCoordinate2D(latitude: 47.30, longitude: -2.5),
            CLLocationCoordinate2D(latitude: 47.45, longitude: -1.8),
            CLLocationCoordinate2D(latitude: 47.75, longitude: -1.3),
            CLLocationCoordinate2D(latitude: 48.2, longitude: -1.1),
            CLLocationCoordinate2D(latitude: 48.65, longitude: -1.15)
        ]
    )
    static let greatBarrierReef = Region(
        id: "great_barrier_reef",
        name: "Great Barrier",
        subtitle: "Queensland, Australia",
        coordinate: CLLocationCoordinate2D(latitude: -18.3, longitude: 147.7),
        span: MKCoordinateSpan(latitudeDelta: 8.0, longitudeDelta: 6.0),
        isAvailable: false,
        boundaryCoordinates: [
            CLLocationCoordinate2D(latitude: -14.0, longitude: 144.0),
            CLLocationCoordinate2D(latitude: -14.0, longitude: 148.0),
            CLLocationCoordinate2D(latitude: -22.0, longitude: 152.0),
            CLLocationCoordinate2D(latitude: -24.5, longitude: 152.5),
            CLLocationCoordinate2D(latitude: -24.5, longitude: 149.0),
            CLLocationCoordinate2D(latitude: -18.0, longitude: 145.0),
            CLLocationCoordinate2D(latitude: -14.0, longitude: 144.0)
        ]
    )

    static let mediterranean = Region(
        id: "mediterranean",
        name: "Mediterranean",
        subtitle: "French Riviera, France",
        coordinate: CLLocationCoordinate2D(latitude: 43.3, longitude: 5.4),
        span: MKCoordinateSpan(latitudeDelta: 3.0, longitudeDelta: 5.0),
        isAvailable: true,
        boundaryCoordinates: [
            CLLocationCoordinate2D(latitude: 43.8, longitude: 3.0),
            CLLocationCoordinate2D(latitude: 43.5, longitude: 3.5),
            CLLocationCoordinate2D(latitude: 43.2, longitude: 5.0),
            CLLocationCoordinate2D(latitude: 43.7, longitude: 7.5),
            CLLocationCoordinate2D(latitude: 42.5, longitude: 7.0),
            CLLocationCoordinate2D(latitude: 42.0, longitude: 4.5),
            CLLocationCoordinate2D(latitude: 42.5, longitude: 3.0),
            CLLocationCoordinate2D(latitude: 43.8, longitude: 3.0)
        ]
    )

    static let caribbean = Region(
        id: "caribbean",
        name: "Caribbean",
        subtitle: "French West Indies",
        coordinate: CLLocationCoordinate2D(latitude: 15.5, longitude: -61.5),
        span: MKCoordinateSpan(latitudeDelta: 5.0, longitudeDelta: 5.0),
        isAvailable: false,
        boundaryCoordinates: [
            CLLocationCoordinate2D(latitude: 18.0, longitude: -64.0),
            CLLocationCoordinate2D(latitude: 18.0, longitude: -59.0),
            CLLocationCoordinate2D(latitude: 13.5, longitude: -59.0),
            CLLocationCoordinate2D(latitude: 13.5, longitude: -64.0),
            CLLocationCoordinate2D(latitude: 18.0, longitude: -64.0)
        ]
    )

    static let norway = Region(
        id: "norway",
        name: "Norway",
        subtitle: "Fjords & Nordic Coasts",
        coordinate: CLLocationCoordinate2D(latitude: 65.0, longitude: 12.0),
        span: MKCoordinateSpan(latitudeDelta: 10.0, longitudeDelta: 12.0),
        isAvailable: true,
        boundaryCoordinates: [
            CLLocationCoordinate2D(latitude: 70.0, longitude: 5.0),
            CLLocationCoordinate2D(latitude: 71.0, longitude: 15.0),
            CLLocationCoordinate2D(latitude: 70.0, longitude: 20.0),
            CLLocationCoordinate2D(latitude: 62.0, longitude: 12.0),
            CLLocationCoordinate2D(latitude: 58.0, longitude: 6.0),
            CLLocationCoordinate2D(latitude: 60.0, longitude: 4.0),
            CLLocationCoordinate2D(latitude: 70.0, longitude: 5.0)
        ]
    )

    static let galapagos = Region(
        id: "galapagos",
        name: "Galápagos",
        subtitle: "Galápagos Islands, Ecuador",
        coordinate: CLLocationCoordinate2D(latitude: -0.5, longitude: -90.5),
        span: MKCoordinateSpan(latitudeDelta: 3.0, longitudeDelta: 3.0),
        isAvailable: false,
        boundaryCoordinates: [
            CLLocationCoordinate2D(latitude: 1.0, longitude: -92.0),
            CLLocationCoordinate2D(latitude: 1.0, longitude: -89.0),
            CLLocationCoordinate2D(latitude: -2.0, longitude: -89.0),
            CLLocationCoordinate2D(latitude: -2.0, longitude: -92.0),
            CLLocationCoordinate2D(latitude: 1.0, longitude: -92.0)
        ]
    )

    static let japan = Region(
        id: "japan",
        name: "Okinawa",
        subtitle: "East China Sea, Japan",
        coordinate: CLLocationCoordinate2D(latitude: 26.5, longitude: 128.0),
        span: MKCoordinateSpan(latitudeDelta: 4.0, longitudeDelta: 4.0),
        isAvailable: false,
        boundaryCoordinates: [
            CLLocationCoordinate2D(latitude: 28.5, longitude: 126.0),
            CLLocationCoordinate2D(latitude: 28.5, longitude: 130.0),
            CLLocationCoordinate2D(latitude: 24.0, longitude: 130.0),
            CLLocationCoordinate2D(latitude: 24.0, longitude: 126.0),
            CLLocationCoordinate2D(latitude: 28.5, longitude: 126.0)
        ]
    )
}
