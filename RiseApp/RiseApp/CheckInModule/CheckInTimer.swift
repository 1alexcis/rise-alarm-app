import Foundation
import Combine

final class CheckInTimer: CheckInModuleProtocol {

    // OPEN QUESTION: Product decision — how many seconds before re-fire?
    static let responseWindowSeconds: TimeInterval = 300

    // OPEN QUESTION: Does re-fired alarm use same tone, louder tone, or different tone?
    static let reFireBehavior: ReFireBehavior = .same

    private let stateSubject = CurrentValueSubject<CheckInState, Never>(.idle)
    var checkInStatePublisher: AnyPublisher<CheckInState, Never> { stateSubject.eraseToAnyPublisher() }

    private weak var alarmEngine: (any AlarmEngineProtocol)?
    private weak var gamification: (any GamificationEngineProtocol)?
    private var deadlineTimer: Timer?
    private var cancellables = Set<AnyCancellable>()

    init(alarmEngine: any AlarmEngineProtocol, gamification: any GamificationEngineProtocol) {
        self.alarmEngine = alarmEngine
        self.gamification = gamification
        observeAlarmEngine()
    }

    // MARK: - Observe AlarmEngine state changes
    private func observeAlarmEngine() {
        alarmEngine?.statePublisher
            .sink { [weak self] state in
                if case .pendingCheckIn(let alarmID, let deadline) = state {
                    self?.startCheckInTimer(for: alarmID, deadline: deadline)
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Protocol conformance

    func startCheckInTimer(for alarmID: UUID) {
        let deadline = Date().addingTimeInterval(Self.responseWindowSeconds)
        startCheckInTimer(for: alarmID, deadline: deadline)
    }

    func userConfirmedAwake() {
        guard case .waiting(_, let alarmID) = stateSubject.value else { return }
        deadlineTimer?.invalidate()
        stateSubject.send(.confirmedAwake(alarmID: alarmID))
        alarmEngine?.receiveCheckInResult(success: true)
        gamification?.recordWakeSuccess(date: .now)
    }

    // MARK: - Internal

    private func startCheckInTimer(for alarmID: UUID, deadline: Date) {
        deadlineTimer?.invalidate()
        stateSubject.send(.waiting(deadline: deadline, alarmID: alarmID))
        scheduleBackgroundNotification(alarmID: alarmID, deadline: deadline)

        let interval = max(deadline.timeIntervalSinceNow, 1)
        deadlineTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            self?.handleTimeout(alarmID: alarmID)
        }
    }

    private func handleTimeout(alarmID: UUID) {
        stateSubject.send(.timedOut(alarmID: alarmID))
        alarmEngine?.receiveCheckInResult(success: false)
        gamification?.recordWakeFailure(date: .now)
    }

    private func scheduleBackgroundNotification(alarmID: UUID, deadline: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Still awake? ☀️"
        content.body = "Tap to confirm you're up — \(Int(Self.responseWindowSeconds / 60)) minutes left!"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: max(deadline.timeIntervalSinceNow * 0.5, 30),
            repeats: false
        )
        let request = UNNotificationRequest(
            identifier: "checkin-\(alarmID.uuidString)",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }
}

// Import UNUserNotificationCenter without full UserNotifications import
import UserNotifications
