import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .portrait
    }
}

@main
struct BlueApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var regionManager = RegionManager()
    @State private var progressManager = ProgressManager()
    @State private var accessibilityManager = AccessibilityManager()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some Scene {
        WindowGroup {
            Group {
                if hasCompletedOnboarding {
                    ContentView()
                        .environment(regionManager)
                        .environment(progressManager)
                        .environment(accessibilityManager)
                        .preferredColorScheme(.dark)
                        .transition(.opacity)
                } else {
                    OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                        .preferredColorScheme(.dark)
                        .transition(.opacity)
                }
            }
        }
    }
}

// MARK: - Window-level Achievement Banner System
// Shows a notification above everything (sheets, fullScreenCovers, tabs)

class AchievementBannerManager {
    static let shared = AchievementBannerManager()
    private var overlayWindow: AchievementOverlayWindow?

    func show(achievementType: AchievementType) {
        guard let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first else { return }

        // Dismiss existing banner if any
        dismiss()

        let bannerView = AchievementBannerContent(achievementType: achievementType)
        let hostingController = UIHostingController(rootView: bannerView)
        hostingController.view.backgroundColor = .clear

        let window = AchievementOverlayWindow(windowScene: windowScene)
        window.rootViewController = hostingController
        window.windowLevel = .alert + 1
        window.isHidden = false
        self.overlayWindow = window

        // Animate in
        hostingController.view.alpha = 0
        hostingController.view.transform = CGAffineTransform(translationX: 0, y: -80)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0) {
            hostingController.view.alpha = 1
            hostingController.view.transform = .identity
        }

        // Auto-dismiss after 3.5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) { [weak self] in
            self?.dismissAnimated()
        }
    }

    private func dismissAnimated() {
        guard let window = overlayWindow else { return }
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut) {
            window.rootViewController?.view.alpha = 0
            window.rootViewController?.view.transform = CGAffineTransform(translationX: 0, y: -80)
        } completion: { _ in
            window.isHidden = true
            self.overlayWindow = nil
        }
    }

    private func dismiss() {
        overlayWindow?.isHidden = true
        overlayWindow = nil
    }
}

// Passthrough window — lets touches fall through to the app
class AchievementOverlayWindow: UIWindow {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        // If hit lands on the root hosting controller's base view, pass through
        if view === self.rootViewController?.view {
            return nil
        }
        return view
    }
}

// The banner SwiftUI content
struct AchievementBannerContent: View {
    let achievementType: AchievementType

    var body: some View {
        VStack {
            HStack(spacing: 14) {
                Text(achievementType.emoji)
                    .font(.system(size: 32))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Achievement unlocked!")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.cyan)
                    Text(achievementType.title)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.white)
                }

                Spacer()

                Image(systemName: "checkmark.seal.fill")
                    .font(.title3)
                    .foregroundStyle(.cyan)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [.cyan.opacity(0.5), .purple.opacity(0.3)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                lineWidth: 1.5
                            )
                    }
                    .shadow(color: .cyan.opacity(0.2), radius: 15, y: 5)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)

            Spacer()
        }
        .preferredColorScheme(.dark)
    }
}
