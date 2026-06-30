import SwiftUI

struct VolumePickerView: View {
    @Binding var step: Int
    @Binding var volumeLevel: Float

    var body: some View {
        ZStack {
            Color(hex: "FAFAF7").ignoresSafeArea(.all)
        VStack(spacing: 0) {
            Text("How loud?")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .padding(.top, 24)
                .padding(.bottom, 4)

            Text("Rise starts quiet and ramps up over 30 seconds.")
                .font(.system(size: 15, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.bottom, 32)

            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "speaker.fill")
                        .foregroundStyle(.secondary)
                    Slider(value: $volumeLevel, in: 0.1...1.0, step: 0.05)
                        .tint(Rise.Color.primary)
                    Image(systemName: "speaker.wave.3.fill")
                        .foregroundStyle(Rise.Color.primary)
                }
                .padding(.horizontal, 24)

                Text("Max volume: \(Int(volumeLevel * 100))%")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                withAnimation { step = 3 }
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
