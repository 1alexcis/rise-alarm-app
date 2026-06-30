import SwiftUI

struct AlarmDetailView: View {
    let alarm: AlarmModel
    let onSave: (AlarmModel) -> Void
    let onDelete: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var editedTime: Date
    @State private var isActive: Bool
    @State private var repeatDays: Set<Weekday>
    @State private var selectedToneID: String
    @State private var volumeLevel: Float
    @State private var showDeleteConfirm = false

    private let orderedDays: [Weekday] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]

    init(alarm: AlarmModel, onSave: @escaping (AlarmModel) -> Void, onDelete: @escaping () -> Void) {
        self.alarm = alarm
        self.onSave = onSave
        self.onDelete = onDelete
        let date = Calendar.current.date(from: alarm.time) ?? Date()
        _editedTime = State(initialValue: date)
        _isActive = State(initialValue: alarm.isActive)
        _repeatDays = State(initialValue: alarm.repeatDays)
        _selectedToneID = State(initialValue: alarm.toneID)
        _volumeLevel = State(initialValue: alarm.volumeLevel)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Time") {
                    DatePicker("Wake time", selection: $editedTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .tint(Rise.Color.primary)
                }

                Section("Repeat") {
                    HStack(spacing: Rise.Spacing.sm) {
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
                    .padding(.vertical, Rise.Spacing.xs)
                }

                Section("Sound") {
                    Picker("Tone", selection: $selectedToneID) {
                        ForEach(ToneLibrary.tones) { tone in
                            Text(tone.name).tag(tone.id)
                        }
                    }
                    HStack {
                        Image(systemName: "speaker.fill").foregroundStyle(Rise.Color.textSecondary)
                        Slider(value: $volumeLevel, in: 0.1...1.0, step: 0.05).tint(Rise.Color.primary)
                        Image(systemName: "speaker.wave.3.fill").foregroundStyle(Rise.Color.primary)
                    }
                    Text("Max volume: \(Int(volumeLevel * 100))%")
                        .font(Rise.Font.rounded(13))
                        .foregroundStyle(Rise.Color.textSecondary)
                }

                Section {
                    Toggle("Active", isOn: $isActive).tint(Rise.Color.primary)
                }

                Section {
                    Button(role: .destructive) {
                        showDeleteConfirm = true
                    } label: {
                        Label("Delete Alarm", systemImage: "trash")
                    }
                }
            }
            .navigationTitle("Edit Alarm")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let time = Calendar.current.dateComponents([.hour, .minute], from: editedTime)
                        let updated = AlarmModel(
                            id: alarm.id,
                            time: time,
                            repeatDays: repeatDays,
                            toneID: selectedToneID,
                            volumeLevel: volumeLevel,
                            linkedNFCTagID: alarm.linkedNFCTagID,
                            isActive: isActive
                        )
                        onSave(updated)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .tint(Rise.Color.primary)
                }
            }
            .confirmationDialog("Delete this alarm?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
                Button("Delete", role: .destructive) {
                    onDelete()
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
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
