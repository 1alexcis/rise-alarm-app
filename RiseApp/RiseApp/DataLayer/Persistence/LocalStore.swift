import Foundation
import SwiftData

// MARK: - SwiftData backing models (internal, never exposed outside DataLayer)

@Model
final class AlarmEntry {
    var id: UUID
    var timeHour: Int
    var timeMinute: Int
    var repeatDaysRaw: [Int]
    var toneID: String
    var volumeLevel: Float
    var linkedNFCTagID: String?
    var isActive: Bool

    init(from model: AlarmModel) {
        self.id = model.id
        self.timeHour = model.time.hour ?? 7
        self.timeMinute = model.time.minute ?? 0
        self.repeatDaysRaw = model.repeatDays.map { $0.rawValue }
        self.toneID = model.toneID
        self.volumeLevel = model.volumeLevel
        self.linkedNFCTagID = model.linkedNFCTagID
        self.isActive = model.isActive
    }

    func toModel() -> AlarmModel {
        AlarmModel(
            id: id,
            time: DateComponents(hour: timeHour, minute: timeMinute),
            repeatDays: Set(repeatDaysRaw.compactMap { Weekday(rawValue: $0) }),
            toneID: toneID,
            volumeLevel: volumeLevel,
            linkedNFCTagID: linkedNFCTagID,
            isActive: isActive
        )
    }
}

@Model
final class PetEntry {
    var xp: Int
    var level: Int
    var unlockedAccessoriesRaw: [String]
    var equippedAccessory: String?
    var lastUpdated: Date
    var isSad: Bool

    init(from model: PetModel) {
        self.xp = model.xp
        self.level = model.level
        self.unlockedAccessoriesRaw = Array(model.unlockedAccessories)
        self.equippedAccessory = model.equippedAccessory
        self.lastUpdated = model.lastUpdated
        self.isSad = model.isSad
    }

    func toModel() -> PetModel {
        PetModel(
            xp: xp,
            level: level,
            unlockedAccessories: Set(unlockedAccessoriesRaw),
            equippedAccessory: equippedAccessory,
            lastUpdated: lastUpdated,
            isSad: isSad
        )
    }
}

@Model
final class CheckInEntry {
    var id: UUID
    var date: Date
    var success: Bool
    var alarmID: UUID

    init(id: UUID, date: Date, success: Bool, alarmID: UUID) {
        self.id = id
        self.date = date
        self.success = success
        self.alarmID = alarmID
    }

    func toRecord() -> CheckInRecord {
        CheckInRecord(id: id, date: date, success: success, alarmID: alarmID)
    }
}

@Model
final class OnboardingEntry {
    var isComplete: Bool

    init(isComplete: Bool) {
        self.isComplete = isComplete
    }
}

// MARK: - Concrete DataLayer implementation backed by SwiftData
final class LocalStore: DataLayerProtocol {
    private let container: ModelContainer

    init(container: ModelContainer) {
        self.container = container
    }

    private var context: ModelContext {
        ModelContext(container)
    }

    // MARK: - Alarms

    func saveAlarm(_ alarm: AlarmModel) throws {
        let ctx = context
        let fetchDescriptor = FetchDescriptor<AlarmEntry>(
            predicate: #Predicate { $0.id == alarm.id }
        )
        if let existing = try ctx.fetch(fetchDescriptor).first {
            existing.timeHour = alarm.time.hour ?? 7
            existing.timeMinute = alarm.time.minute ?? 0
            existing.repeatDaysRaw = alarm.repeatDays.map { $0.rawValue }
            existing.toneID = alarm.toneID
            existing.volumeLevel = alarm.volumeLevel
            existing.linkedNFCTagID = alarm.linkedNFCTagID
            existing.isActive = alarm.isActive
        } else {
            ctx.insert(AlarmEntry(from: alarm))
        }
        try ctx.save()
    }

    func fetchAlarms() throws -> [AlarmModel] {
        let ctx = context
        let entries = try ctx.fetch(FetchDescriptor<AlarmEntry>())
        return entries.map { $0.toModel() }
    }

    func deleteAlarm(id: UUID) throws {
        let ctx = context
        let descriptor = FetchDescriptor<AlarmEntry>(predicate: #Predicate { $0.id == id })
        guard let entry = try ctx.fetch(descriptor).first else {
            throw DataLayerError.notFound("AlarmEntry id=\(id)")
        }
        ctx.delete(entry)
        try ctx.save()
    }

    // MARK: - Check-ins

    func recordCheckIn(success: Bool, date: Date, alarmID: UUID) throws {
        let ctx = context
        ctx.insert(CheckInEntry(id: UUID(), date: date, success: success, alarmID: alarmID))
        try ctx.save()
    }

    func fetchStreakCount() throws -> Int {
        let records = try fetchCheckInHistory()
        let calendar = Calendar.current
        var streak = 0
        var checkDate = calendar.startOfDay(for: .now)

        let successDays = Set(
            records.filter { $0.success }
                   .map { calendar.startOfDay(for: $0.date) }
        )

        while successDays.contains(checkDate) {
            streak += 1
            guard let prev = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = prev
        }
        return streak
    }

    func fetchCheckInHistory() throws -> [CheckInRecord] {
        let ctx = context
        let entries = try ctx.fetch(FetchDescriptor<CheckInEntry>())
        return entries.map { $0.toRecord() }
    }

    // MARK: - Pet state

    func savePetState(_ state: PetModel) throws {
        let ctx = context
        let existing = try ctx.fetch(FetchDescriptor<PetEntry>()).first
        if let existing {
            existing.xp = state.xp
            existing.level = state.level
            existing.unlockedAccessoriesRaw = Array(state.unlockedAccessories)
            existing.equippedAccessory = state.equippedAccessory
            existing.lastUpdated = state.lastUpdated
            existing.isSad = state.isSad
        } else {
            ctx.insert(PetEntry(from: state))
        }
        try ctx.save()
    }

    func fetchPetState() throws -> PetModel {
        let ctx = context
        if let entry = try ctx.fetch(FetchDescriptor<PetEntry>()).first {
            return entry.toModel()
        }
        return .default
    }

    // MARK: - Onboarding

    func markOnboardingComplete() throws {
        let ctx = context
        if let entry = try ctx.fetch(FetchDescriptor<OnboardingEntry>()).first {
            entry.isComplete = true
        } else {
            ctx.insert(OnboardingEntry(isComplete: true))
        }
        try ctx.save()
    }

    func isOnboardingComplete() throws -> Bool {
        let ctx = context
        return try ctx.fetch(FetchDescriptor<OnboardingEntry>()).first?.isComplete ?? false
    }
}
