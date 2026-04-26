import SwiftUI

struct RepeatPickerView: View {
    @Binding var step: Int
    @State private var selectedDays: Set<Weekday> = [.monday, .tuesday, .wednesday, .thursday, .friday]
    @State private var isOneTime: Bool = false

    private let orderedDays: [Weekday] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]

    var body: some View {
        VStack(spacing: Rise.Spacing.xl) {
            SunView(expression: .waving, size: 80)
                .padding(.top, Rise.Spacing.lg)

            VStack(spacing: Rise.Spacing.sm) {
                Text("Which days?")
                    .font(Rise.Font.rounded(24, weight: .bold))
                    .foregroundStyle(Rise.Color.text)

                Text("Tap the days you need Rise to fire.")
                    .font(Rise.Font.rounded(16))
                    .foregroundStyle(Rise.Color.textSecondary)
            }
            .padding(.horizontal, Rise.Spacing.xl)

            Toggle("One-time alarm only", isOn: $isOneTime)
                .tint(Rise.Color.primary)
                .font(Rise.Font.rounded(16, weight: .medium))
                .padding(.horizontal, Rise.Spacing.xl)

            if !isOneTime {
                HStack(spacing: Rise.Spacing.sm) {
                    ForEach(orderedDays) { day in
                        DayPill(
                            day: day,
                            isSelected: selectedDays.contains(day),
                            onTap: {
                                if selectedDays.contains(day) && selectedDays.count > 1 {
                                    selectedDays.remove(day)
                                } else {
                                    selectedDays.insert(day)
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, Rise.Spacing.xl)
            }

            Spacer()

            RiseButton(title: "Continue") {
                withAnimation { step = 4 }
            }
            .padding(.horizontal, Rise.Spacing.xl)
            .padding(.bottom, Rise.Spacing.xl)
        }
    }
}

private struct DayPill: View {
    let day: Weekday
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Text(day.shortName)
            .font(Rise.Font.rounded(14, weight: isSelected ? .bold : .regular))
            .foregroundStyle(isSelected ? Rise.Color.text : Rise.Color.textSecondary)
            .frame(width: 36, height: 36)
            .background(isSelected ? Rise.Color.primary : Rise.Color.surface, in: Circle())
            .shadow(color: .black.opacity(0.05), radius: 2)
            .onTapGesture { onTap() }
            .animation(.spring(response: 0.25), value: isSelected)
    }
}
