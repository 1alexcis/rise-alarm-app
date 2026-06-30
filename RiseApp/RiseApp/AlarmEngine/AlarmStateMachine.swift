import Foundation
import Combine
import UserNotifications
import BackgroundTasks

// MARK: - Concrete AlarmEngine implementation
final class AlarmStateMachine: AlarmEngineProtocol {

    // OPEN QUESTION: Product decision — how many seconds before re-fire?
    static let checkInWindowSeconds: TimeInterval = 300

    let stateSubject = CurrentValueSubject<AlarmState, Never>(.idle)
    var statePublisher: AnyPublisher<AlarmState, Never> { stateSubject.eraseToAnyPublisher() }

    private let dataLayer: any DataLayerProtocol
    private var activeAlarms: [UUID: AlarmModel] = [:]
    private var checkInDeadlineTimer: Timer?
    private var currentRefireAttempt: Int = 0

    init(dataLayer: any DataLayerProtocol) {
        self.dataLayer = dataLayer
        loadAlarmsFromStore()
        requestNotificationPermission()
    }

    // MARK: - Protocol conformance

    func scheduleAlarm(_ alarm: AlarmModel) throws {
        try dataLayer.saveAlarm(alarm)
        activeAlarms[alarm.id] = alarm
        try scheduleNotification(for: alarm)
    }

    func cancelAlarm(id: UUID) throws {
        activeAlarms.removeValue(forKey: id)
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id.uuidString])
        try dataLayer.deleteAlarm(id: id)
        if case .firing(let fid) = stateSubject.value, fid == id {
            transition(to: .idle)
        }
    }

    func receiveNFCDismiss(tagID: String) {
        guard case .firing(let alarmID) = stateSubject.value,
              let alarm = activeAlarms[alarmID],
              alarm.linkedNFCTagID == tagID else { return }

        let deadline = Date().addingTimeInterval(Self.checkInWindowSeconds)
        transition(to: .pendingCheckIn(alarmID: alarmID, deadline: deadline))
        startCheckInDeadlineTimer(alarmID: alarmID, deadline: deadline)
    }

    func receiveCheckInResult(success: Bool) {
        guard case .pendingCheckIn(let alarmID, _) = stateSubject.value else { return }
        checkInDeadlineTimer?.invalidate()

        if success {
            transition(to: .dismissed(alarmID: alarmID))
            currentRefireAttempt = 0
            if let alarm = activeAlarms[alarmID] {
                rescheduleRepeating(alarm: alarm)
            }
        } else {
            currentRefireAttempt += 1
            transition(to: .refired(alarmID: alarmID, attempt: currentRefireAttempt))
            transition(to: .firing(alarmID: alarmID))
            fireAlarmNotification(alarmID: alarmID)
        }
    }

    func fetchUpcomingAlarms() -> [AlarmModel] {
        (try? dataLayer.fetchAlarms())?.filter { $0.isActive } ?? []
    }

    // MARK: - Internal helpers

    private func transition(to newState: AlarmState) {
        stateSubject.send(newState)
        // Persist transition (best-effort, not a hard failure)
    }

    private func loadAlarmsFromStore() {
        guard let alarms = try? dataLayer.fetchAlarms() else { return }
        alarms.forEach { activeAlarms[$0.id] = $0 }
    }

    private func startCheckInDeadlineTimer(alarmID: UUID, deadline: Date) {
        checkInDeadlineTimer?.invalidate()
        let interval = deadline.timeIntervalSinceNow
        checkInDeadlineTimer = Timer.scheduledTimer(withTimeInterval: max(interval, 1), repeats: false) { [weak self] _ in
            // Timer fired before user confirmed — treat as failure → re-fire
            self?.receiveCheckInResult(success: false)
        }
    }

    private func rescheduleRepeating(alarm: AlarmModel) {
        guard !alarm.repeatDays.isEmpty else {
            // One-time alarm: mark inactive
            var updated = alarm
            updated.isActive = false
            try? dataLayer.saveAlarm(updated)
            activeAlarms[alarm.id] = updated
            return
        }
        // Repeating — next firing is automatically handled by the scheduled notification
    }

    // MARK: - UNUserNotificationCenter

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    private func scheduleNotification(for alarm: AlarmModel) throws {
        let content = UNMutableNotificationContent()
        content.title = "Time to Rise! ☀️"
        content.body = "Tap your sticker to dismiss."
        content.sound = .defaultCritical
        content.categoryIdentifier = "ALARM"

        guard let hour = alarm.time.hour, let minute = alarm.time.minute else { return }
        var components = DateComponents()
        components.hour = hour
        components.minute = minute

        let trigger: UNNotificationTrigger
        if alarm.repeatDays.isEmpty {
            trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        } else {
            // Schedule one notification per repeat day
            for day in alarm.repeatDays {
                components.weekday = day.rawValue
                let weeklyTrigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
                let request = UNNotificationRequest(
                    identifier: "\(alarm.id.uuidString)-\(day.rawValue)",
                    content: content,
                    trigger: weeklyTrigger
                )
                UNUserNotificationCenter.current().add(request)
            }
            return
        }

        let request = UNNotificationRequest(identifier: alarm.id.uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    private func fireAlarmNotification(alarmID: UUID) {
        let content = UNMutableNotificationContent()
        content.title = "Rise Again! ☀️"
        content.body = "You didn't confirm — time to really wake up!"
        content.sound = .defaultCritical
        let request = UNNotificationRequest(
            identifier: "\(alarmID.uuidString)-refire-\(currentRefireAttempt)",
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        )
        UNUserNotificationCenter.current().add(request)
    }
}
