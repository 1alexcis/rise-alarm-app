import Foundation
import Combine

// MARK: - Alarm state
enum AlarmState: Equatable {
    case idle
    case firing(alarmID: UUID)
    case pendingCheckIn(alarmID: UUID, deadline: Date)
    case dismissed(alarmID: UUID)
    case refired(alarmID: UUID, attempt: Int)
}

// MARK: - Public protocol
protocol AlarmEngineProtocol: AnyObject {
    var statePublisher: AnyPublisher<AlarmState, Never> { get }

    func scheduleAlarm(_ alarm: AlarmModel) throws
    func cancelAlarm(id: UUID) throws
    func receiveNFCDismiss(tagID: String)
    func receiveCheckInResult(success: Bool)
    func fetchUpcomingAlarms() -> [AlarmModel]
}
