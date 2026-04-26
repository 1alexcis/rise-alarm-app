import SwiftUI

struct AlarmDetailView: View {
    let alarm: AlarmModel
    @Environment(\.dismiss) private var dismiss
    @State private var editedTime = Date()
    @State private var isActive: Bool
    @State private var showDeleteConfirm = false

    init(alarm: AlarmModel) {
        self.alarm = alarm
        _isActive = State(initialValue: alarm.isActive)
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Time") {
                    DatePicker("Wake time", selection: $editedTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .tint(Rise.Color.primary)
                }

                Section("Repeat") {
                    let days = alarm.repeatDays.isEmpty ? "One-time" : alarm.repeatDays.shortSummary
                    LabeledContent("Days", value: days)
                }

                Section("Sound") {
                    LabeledContent("Tone", value: ToneLibrary.tone(id: alarm.toneID)?.name ?? alarm.toneID)
                    LabeledContent("Volume", value: "\(Int(alarm.volumeLevel * 100))%")
                }

                Section {
                    Button(role: .destructive) {
                        showDeleteConfirm = true
                    } label: {
                        Label("Delete Alarm", systemImage: "trash")
                    }
                }
            }
            .navigationTitle("Alarm")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { dismiss() }
                        .fontWeight(.semibold)
                        .tint(Rise.Color.primary)
                }
            }
            .confirmationDialog("Delete this alarm?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
                Button("Delete", role: .destructive) { dismiss() }
                Button("Cancel", role: .cancel) {}
            }
        }
    }
}

private extension Set<Weekday> {
    var shortSummary: String {
        if self == Set(Weekday.allCases.filter { $0 != .saturday && $0 != .sunday }) {
            return "Weekdays"
        }
        if self == Set([.saturday, .sunday]) { return "Weekends" }
        return self.sorted(by: { $0.rawValue < $1.rawValue }).map { $0.shortName }.joined(separator: " · ")
    }
}
