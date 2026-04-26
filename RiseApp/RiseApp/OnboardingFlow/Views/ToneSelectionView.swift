import SwiftUI

struct ToneSelectionView: View {
    @Binding var step: Int
    @State private var selectedToneID: String = ToneLibrary.defaultTone.id

    var body: some View {
        VStack(spacing: Rise.Spacing.xl) {
            SunView(expression: .waving, size: 80)
                .padding(.top, Rise.Spacing.lg)

            VStack(spacing: Rise.Spacing.sm) {
                Text("Pick your wake-up sound")
                    .font(Rise.Font.rounded(24, weight: .bold))
                    .foregroundStyle(Rise.Color.text)

                Text("A good tone makes all the difference.")
                    .font(Rise.Font.rounded(16))
                    .foregroundStyle(Rise.Color.textSecondary)
            }
            .padding(.horizontal, Rise.Spacing.xl)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Rise.Spacing.md) {
                    ForEach(ToneLibrary.tones) { tone in
                        ToneCard(
                            tone: tone,
                            isSelected: tone.id == selectedToneID,
                            onSelect: { selectedToneID = tone.id }
                        )
                    }
                }
                .padding(.horizontal, Rise.Spacing.xl)
            }

            Spacer()

            RiseButton(title: "Continue") {
                withAnimation { step = 2 }
            }
            .padding(.horizontal, Rise.Spacing.xl)
            .padding(.bottom, Rise.Spacing.xl)
        }
    }
}

private struct ToneCard: View {
    let tone: Tone
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        VStack(spacing: Rise.Spacing.sm) {
            ZStack {
                Circle()
                    .fill(isSelected ? Rise.Color.primary : Rise.Color.surface)
                    .frame(width: 56, height: 56)
                    .shadow(color: .black.opacity(0.08), radius: 4)
                Image(systemName: isSelected ? "pause.fill" : "play.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(isSelected ? Rise.Color.text : Rise.Color.primary)
            }
            .onTapGesture { onSelect() }

            Text(tone.name)
                .font(Rise.Font.rounded(13, weight: isSelected ? .semibold : .regular))
                .foregroundStyle(Rise.Color.text)
                .multilineTextAlignment(.center)
                .frame(width: 80)

            Text(tone.mood.rawValue.capitalized)
                .font(Rise.Font.rounded(11))
                .foregroundStyle(Rise.Color.textSecondary)
        }
        .padding(.vertical, Rise.Spacing.md)
    }
}
