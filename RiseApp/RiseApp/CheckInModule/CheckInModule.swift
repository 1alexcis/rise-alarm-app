import Foundation
import Combine

// MARK: - Check-in state
enum CheckInState: Equatable {
    case idle
    case waiting(deadline: Date, alarmID: UUID)
    case confirmedAwake(alarmID: UUID)
    case timedOut(alarmID: UUID)    // triggers re-fire via AlarmEngine
}

// OPEN QUESTION: Does re-fired alarm use same tone, louder tone, or different tone?
// Product decision pending — defaulting to .same until decided.
enum ReFireBehavior {
    case same
    case louder(multiplier: Float)
    case different(toneID: String)
}

// MARK: - Public protocol
protocol CheckInModuleProtocol: AnyObject {
    func startCheckInTimer(for alarmID: UUID)
    func userConfirmedAwake()
    var checkInStatePublisher: AnyPublisher<CheckInState, Never> { get }
}
