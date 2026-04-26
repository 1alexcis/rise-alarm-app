import SwiftUI

struct TimePickerView: View {
    @Binding var step: Int
    @State private var selectedTime = Date()

    var body: some View {
        VStack(spacing: Rise.Spacing.xl) {
            SunView(expression: .waving, size: 100)
                .padding(.top, Rise.Spacing.lg)

            VStack(spacing: Rise.Spacing.sm) {
                Text("When do you need to wake up?")
                    .font(Rise.Font.rounded(24, weight: .bold))
                    .foregroundStyle(Rise.Color.text)
                    .multilineTextAlignment(.center)

                Text("We'll make sure you actually get up.")
                    .font(Rise.Font.rounded(16))
                    .foregroundStyle(Rise.Color.textSecondary)
            }
            .padding(.horizontal, Rise.Spacing.xl)

            DatePicker(
                "Wake time",
                selection: $selectedTime,
                displayedComponents: .hourAndMinute
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            .tint(Rise.Color.primary)

            Spacer()

            RiseButton(title: "Continue") {
                withAnimation { step = 1 }
            }
            .padding(.horizontal, Rise.Spacing.xl)
            .padding(.bottom, Rise.Spacing.xl)
        }
    }
}
