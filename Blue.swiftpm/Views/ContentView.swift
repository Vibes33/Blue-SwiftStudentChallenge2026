import SwiftUI
enum BlueTab: Hashable {
    case home
    case discover
    case quiz
    case map
    case profile
}
struct ContentView: View {
    @State private var selectedTab: BlueTab = .home
    @Environment(AccessibilityManager.self) private var accessibility

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Home", systemImage: "water.waves", value: .home) {
                HomeView()
            }

            Tab("Discover", systemImage: "fish.fill", value: .discover) {
                DiscoverView()
            }

            Tab("Quiz", systemImage: "questionmark.bubble.fill", value: .quiz) {
                QuizView()
            }

            Tab("Map", systemImage: "map.fill", value: .map) {
                MapView()
            }

            Tab("Profile", systemImage: "person.crop.circle.fill", value: .profile) {
                ProfileView()
            }
        }
        .tint(.cyan)
        .blueAccessibility(accessibility)
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
