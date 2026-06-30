import SwiftUI

struct TimePickerView: View {
    @Binding var step: Int
    @Binding var wakeDate: Date

    var body: some View {
        ZStack {
            Color(hex: "FAFAF7").ignoresSafeArea(.all)
        VStack(spacing: 0) {
            Text("When do you need to wake up?")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 4)

            Text("We'll make sure you actually get up.")
                .font(.system(size: 15, design: .rounded))
                .foregroundStyle(.secondary)
                .padding(.bottom, 16)

            // Explicit light background so picker digits are always visible
            ZStack {
                Color(UIColor.secondarySystemBackground)
                DatePicker(
                    "",
                    selection: $wakeDate,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .frame(maxWidth: .infinity)
                // Force light rendering — prevents white-text-on-white-bg
                .colorScheme(.light)
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 24)

            Spacer()

            Button {
                withAnimation { step = 1 }
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
