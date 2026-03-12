import SwiftUI

@Observable
class AccessibilityManager {
    var isVoiceOverEnabled: Bool {
        didSet { if !isLoading { save() } }
    }
    var useLargerText: Bool {
        didSet { if !isLoading { save() } }
    }
    var reduceAnimations: Bool {
        didSet { if !isLoading { save() } }
    }
    var highContrast: Bool {
        didSet { if !isLoading { save() } }
    }

    private var isLoading = false

    init() {
        isLoading = true
        isVoiceOverEnabled = UserDefaults.standard.bool(forKey: "blue_voiceover")
        useLargerText = UserDefaults.standard.bool(forKey: "blue_largertext")
        reduceAnimations = UserDefaults.standard.bool(forKey: "blue_reduceanimations")
        highContrast = UserDefaults.standard.bool(forKey: "blue_highcontrast")
        isLoading = false
    }

    private func save() {
        UserDefaults.standard.set(isVoiceOverEnabled, forKey: "blue_voiceover")
        UserDefaults.standard.set(useLargerText, forKey: "blue_largertext")
        UserDefaults.standard.set(reduceAnimations, forKey: "blue_reduceanimations")
        UserDefaults.standard.set(highContrast, forKey: "blue_highcontrast")
    }
    /// Returns boosted opacity for secondary text (0.5 → 0.85 in high contrast)
    func secondaryOpacity(_ base: Double = 0.5) -> Double {
        highContrast ? min(base + 0.35, 1.0) : base
    }

    /// Returns boosted opacity for tertiary/dim text (0.3 → 0.65 in high contrast)
    func tertiaryOpacity(_ base: Double = 0.3) -> Double {
        highContrast ? min(base + 0.35, 1.0) : base
    }

    /// Returns boosted opacity for borders/strokes
    func borderOpacity(_ base: Double = 0.15) -> Double {
        highContrast ? min(base + 0.25, 0.8) : base
    }
    var dynamicTypeSize: DynamicTypeSize {
        useLargerText ? .xxxLarge : .large
    }
    /// Returns nil animation when reduce animations is on, otherwise the provided animation
    func animation<V: Equatable>(_ animation: Animation?, value: V) -> some ViewModifier {
        AnimationModifier(animation: reduceAnimations ? nil : animation, value: value)
    }
}
private struct AnimationModifier<V: Equatable>: ViewModifier {
    let animation: Animation?
    let value: V

    func body(content: Content) -> some View {
        content.animation(animation, value: value)
    }
}
extension View {
    /// Applies larger dynamic type when the setting is enabled
    func blueAccessibility(_ manager: AccessibilityManager) -> some View {
        self.dynamicTypeSize(manager.dynamicTypeSize)
    }

    /// Wraps animation call — returns .identity when reduceAnimations is on
    func blueAnimation(_ animation: Animation?, value: some Equatable, reduce: Bool) -> some View {
        self.animation(reduce ? nil : animation, value: value)
    }
}
