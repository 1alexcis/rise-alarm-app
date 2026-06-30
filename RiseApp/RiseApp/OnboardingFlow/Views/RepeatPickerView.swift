import SwiftUI

struct RepeatPickerView: View {
    @Binding var step: Int
    @Binding var repeatDays: Set<Weekday>
    @State private var isOneTime: Bool = false

    private let orderedDays: [Weekday] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]

    var body: some View {
        ZStack {
            Color(hex: "FAFAF7").ignoresSafeArea(.all)
        VStack(spacing: 0) {
            Text("Which days?")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .padding(.top, 24)
                .padding(.bottom, 4)

            Text("Tap the days you need Rise to fire.")
                .font(.system(size: 15, design: .rounded))
                .foregroundStyle(.secondary)
                .padding(.bottom, 24)

            Toggle("One-time alarm only", isOn: $isOneTime)
                .tint(Rise.Color.primary)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .padding(.horizontal, 24)
                .onChange(of: isOneTime) { _, oneTime in
                    repeatDays = oneTime ? [] : [.monday, .tuesday, .wednesday, .thursday, .friday]
                }

            if !isOneTime {
                HStack(spacing: 8) {
                    ForEach(orderedDays) { day in
                        DayPill(
                            day: day,
                            isSelected: repeatDays.contains(day),
                            onTap: {
                                if repeatDays.contains(day) && repeatDays.count > 1 {
                                    repeatDays.remove(day)
                                } else {
                                    repeatDays.insert(day)
                                }
                            }
                        )
                    }
                }
                .padding(.top, 20)
            }

            Spacer()

            Button {
                withAnimation { step = 4 }
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

private struct DayPill: View {
    let day: Weekday
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Text(day.shortName)
            .font(.system(size: 14, weight: isSelected ? .bold : .regular, design: .rounded))
            .foregroundStyle(isSelected ? .black : .secondary)
            .frame(width: 36, height: 36)
            .background(isSelected ? Rise.Color.primary : Color(UIColor.secondarySystemBackground), in: Circle())
            .onTapGesture { onTap() }
            .animation(.spring(response: 0.25), value: isSelected)
    }
}
