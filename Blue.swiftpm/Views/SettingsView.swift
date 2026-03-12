import SwiftUI

struct SettingsView: View {
    @Environment(AccessibilityManager.self) private var accessibility
    @Environment(\.dismiss) private var dismiss
    @State private var showVoiceOverAlert = false

    var body: some View {
        @Bindable var accessibility = accessibility

        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.04, green: 0.08, blue: 0.18),
                        Color(red: 0.02, green: 0.12, blue: 0.28),
                        Color(red: 0.01, green: 0.16, blue: 0.36)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {

                        VStack(alignment: .leading, spacing: 16) {
                            Label("Accessibility", systemImage: "accessibility")
                                .font(.headline.weight(.bold))
                                .foregroundStyle(.white)

                            // VoiceOver
                            voiceOverToggle()

                            // Larger Text
                            settingsToggle(
                                icon: "textformat.size.larger",
                                color: .mint,
                                title: "Larger Text",
                                subtitle: "Increases text size throughout the app",
                                isOn: $accessibility.useLargerText
                            )

                            // Reduce Animations
                            settingsToggle(
                                icon: "figure.walk.motion",
                                color: .orange,
                                title: "Reduce Animations",
                                subtitle: "Disables confetti and complex animations",
                                isOn: $accessibility.reduceAnimations
                            )

                            // High Contrast
                            settingsToggle(
                                icon: "circle.lefthalf.filled",
                                color: .purple,
                                title: "High Contrast",
                                subtitle: "Enhances contrasts for better readability",
                                isOn: $accessibility.highContrast
                            )
                        }
                        .padding(18)
                        .glassCard()

                        VStack(alignment: .leading, spacing: 14) {
                            Label("About", systemImage: "info.circle.fill")
                                .font(.headline.weight(.bold))
                                .foregroundStyle(.white)

                            infoRow(label: "Version", value: "1.0.0")
                            infoRow(label: "Developer", value: "Ryan")
                            infoRow(label: "Framework", value: "SwiftUI")
                            infoRow(label: "Compatibility", value: "iOS 17+")
                        }
                        .padding(18)
                        .glassCard()

                        Button {
                            UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
                            dismiss()
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.body.weight(.medium))
                                Text("Replay tutorial")
                                    .font(.subheadline.weight(.semibold))
                            }
                            .foregroundStyle(.cyan)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(.cyan.opacity(0.08))
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .stroke(.cyan.opacity(0.15), lineWidth: 1)
                                    }
                            }
                        }

                        Spacer().frame(height: 40)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Settings")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.white.opacity(0.4))
                    }
                }
            }
        }
    }
    private func voiceOverToggle() -> some View {
        @Bindable var accessibility = accessibility

        return settingsToggle(
            icon: "speaker.wave.3.fill",
            color: .cyan,
            title: "Voice Descriptions",
            subtitle: "Adds detailed labels for screen readers",
            isOn: $accessibility.isVoiceOverEnabled
        )
        .onChange(of: accessibility.isVoiceOverEnabled) { _, newValue in
            if newValue {
                showVoiceOverAlert = true
            }
        }
        .alert("Enable VoiceOver", isPresented: $showVoiceOverAlert) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Got it", role: .cancel) { }
        } message: {
            Text("Voice Descriptions adds accessibility labels throughout Blue. For the full screen-reader experience, also enable VoiceOver in Settings → Accessibility → VoiceOver.")
        }
    }
    private func settingsToggle(
        icon: String,
        color: Color,
        title: String,
        subtitle: String,
        isOn: Binding<Bool>
    ) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(color.opacity(0.12))
                    .frame(width: 38, height: 38)
                Image(systemName: icon)
                    .font(.body.weight(.medium))
                    .foregroundStyle(color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.4))
                    .lineLimit(2)
            }

            Spacer()

            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(.cyan)
        }
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.white.opacity(isOn.wrappedValue ? 0.06 : 0.03))
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(.white.opacity(isOn.wrappedValue ? 0.1 : 0.04), lineWidth: 1)
                }
        }
    }
    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.5))
            Spacer()
            Text(value)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white.opacity(0.8))
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    SettingsView()
        .environment(AccessibilityManager())
        .preferredColorScheme(.dark)
}
