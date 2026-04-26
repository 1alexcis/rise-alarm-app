import SwiftUI

struct AddAlarmSheet: View {
    let onSave: (AlarmModel) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var wakeDate: Date = Calendar.current.date(from: DateComponents(hour: 7, minute: 30)) ?? Date()
    @State private var selectedDays: Set<Weekday> = [.monday, .tuesday, .wednesday, .thursday, .friday]
    @State private var isOneTime: Bool = false
    @State private var selectedToneID: String = ToneLibrary.defaultTone.id
    @State private var volumeLevel: Float = 0.7

    private let orderedDays: [Weekday] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]

    var body: some View {
        NavigationStack {
            Form {
                Section("Time") {
                    DatePicker("Wake time", selection: $wakeDate, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .tint(Rise.Color.primary)
                }

                Section("Repeat") {
                    Toggle("One-time alarm", isOn: $isOneTime)
                        .tint(Rise.Color.primary)
                        .onChange(of: isOneTime) { _, oneTime in
                            selectedDays = oneTime ? [] : [.monday, .tuesday, .wednesday, .thursday, .friday]
                        }

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
                        .padding(.vertical, Rise.Spacing.xs)
                    }
                }

                Section("Sound") {
                    Picker("Tone", selection: $selectedToneID) {
                        ForEach(ToneLibrary.tones) { tone in
                            Text(tone.name).tag(tone.id)
                        }
                    }

                    HStack {
                        Image(systemName: "speaker.fill")
                            .foregroundStyle(Rise.Color.textSecondary)
                        Slider(value: $volumeLevel, in: 0.1...1.0, step: 0.05)
                            .tint(Rise.Color.primary)
                        Image(systemName: "speaker.wave.3.fill")
                            .foregroundStyle(Rise.Color.primary)
                    }
                    Text("Max volume: \(Int(volumeLevel * 100))%")
                        .font(Rise.Font.rounded(13))
                        .foregroundStyle(Rise.Color.textSecondary)
                }
            }
            .navigationTitle("New Alarm")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let time = Calendar.current.dateComponents([.hour, .minute], from: wakeDate)
                        let alarm = AlarmModel(
                            id: UUID(),
                            time: time,
                            repeatDays: selectedDays,
                            toneID: selectedToneID,
                            volumeLevel: volumeLevel,
                            linkedNFCTagID: nil,
                            isActive: true
                        )
                        onSave(alarm)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .tint(Rise.Color.primary)
                }
            }
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
            .onTapGesture { onTap() }
            .animation(.spring(response: 0.25), value: isSelected)
    }
}
