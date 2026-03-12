import SwiftUI

/// Animated underwater background using a Metal caustics shader.
/// Falls back to a static gradient when `reduceAnimations` is enabled.
struct OceanBackgroundView: View {
    @Environment(AccessibilityManager.self) private var accessibility

    private let gradientColors: [Color] = [
        Color(red: 0.02, green: 0.18, blue: 0.38),
        Color(red: 0.02, green: 0.12, blue: 0.28),
        Color(red: 0.03, green: 0.06, blue: 0.14)
    ]

    var body: some View {
        if accessibility.reduceAnimations {
            LinearGradient(
                colors: gradientColors,
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        } else {
            CausticsLayer(gradientColors: gradientColors)
                .ignoresSafeArea()
        }
    }
}

/// Separate view so TimelineView generic inference works.
private struct CausticsLayer: View {
    let gradientColors: [Color]

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
            CausticsContent(
                gradientColors: gradientColors,
                elapsed: timeline.date.timeIntervalSinceReferenceDate
            )
        }
    }
}

private struct CausticsContent: View {
    let gradientColors: [Color]
    let elapsed: Double

    var body: some View {
        LinearGradient(
            colors: gradientColors,
            startPoint: .top,
            endPoint: .bottom
        )
        .visualEffect { view, proxy in
            view.colorEffect(
                ShaderLibrary.oceanCaustics(
                    .float2(proxy.size),
                    .float(Float(elapsed))
                )
            )
        }
    }
}

#Preview {
    OceanBackgroundView()
        .environment(AccessibilityManager())
}
