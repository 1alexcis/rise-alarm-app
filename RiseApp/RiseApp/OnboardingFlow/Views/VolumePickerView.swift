import SwiftUI

struct VolumePickerView: View {
    @Binding var step: Int
    @State private var volume: Float = 0.7

    var body: some View {
        VStack(spacing: Rise.Spacing.xl) {
            SunView(expression: .waving, size: 80)
                .padding(.top, Rise.Spacing.lg)

            VStack(spacing: Rise.Spacing.sm) {
                Text("How loud?")
                    .font(Rise.Font.rounded(24, weight: .bold))
                    .foregroundStyle(Rise.Color.text)

                Text("Rise starts quiet and ramps up over 30 seconds.")
                    .font(Rise.Font.rounded(16))
                    .foregroundStyle(Rise.Color.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, Rise.Spacing.xl)

            VStack(spacing: Rise.Spacing.md) {
                HStack {
                    Image(systemName: "speaker.fill")
                        .foregroundStyle(Rise.Color.textSecondary)
                    Slider(value: $volume, in: 0.1...1.0, step: 0.05)
                        .tint(Rise.Color.primary)
                    Image(systemName: "speaker.wave.3.fill")
                        .foregroundStyle(Rise.Color.primary)
                }
                .padding(.horizontal, Rise.Spacing.xl)

                Text("Max volume: \(Int(volume * 100))%")
                    .font(Rise.Font.rounded(15, weight: .medium))
                    .foregroundStyle(Rise.Color.textSecondary)
            }

            Spacer()

            RiseButton(title: "Continue") {
                withAnimation { step = 3 }
            }
            .padding(.horizontal, Rise.Spacing.xl)
            .padding(.bottom, Rise.Spacing.xl)
        }
    }
}
