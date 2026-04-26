import SwiftUI

struct ToneSelectionView: View {
    @Binding var step: Int
    @Binding var selectedToneID: String

    var body: some View {
        ZStack {
            Color(hex: "FAFAF7").ignoresSafeArea(.all)
        VStack(spacing: 0) {
            Text("Pick your wake-up sound")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .padding(.top, 24)
                .padding(.bottom, 4)

            Text("A good tone makes all the difference.")
                .font(.system(size: 15, design: .rounded))
                .foregroundStyle(.secondary)
                .padding(.bottom, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(ToneLibrary.tones) { tone in
                        ToneCard(
                            tone: tone,
                            isSelected: tone.id == selectedToneID,
                            onSelect: { selectedToneID = tone.id }
                        )
                    }
                }
                .padding(.horizontal, 24)
            }

            Spacer()

            Button {
                withAnimation { step = 2 }
            } label: {
                Text("Continue")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Rise.Color.primary, in: RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal, 24)
            }
            .padding(.bottom, 40)
        }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
}

private struct ToneCard: View {
    let tone: Tone
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(isSelected ? Rise.Color.primary : Color(UIColor.secondarySystemBackground))
                    .frame(width: 56, height: 56)
                Image(systemName: isSelected ? "pause.fill" : "play.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(isSelected ? .black : Rise.Color.primary)
            }
            .onTapGesture { onSelect() }

            Text(tone.name)
                .font(.system(size: 13, weight: isSelected ? .semibold : .regular, design: .rounded))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .frame(width: 80)

            Text(tone.mood.rawValue.capitalized)
                .font(.system(size: 11, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 12)
    }
}
