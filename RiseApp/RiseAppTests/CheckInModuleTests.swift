import XCTest
import Combine
@testable import RiseApp

final class CheckInModuleTests: XCTestCase {
    var checkInTimer: CheckInTimer!
    var mockAlarmEngine: MockAlarmEngine!
    var mockGamification: MockGamificationEngine!
    var cancellables = Set<AnyCancellable>()

    override func setUp() {
        mockAlarmEngine = MockAlarmEngine()
        mockGamification = MockGamificationEngine()
        checkInTimer = CheckInTimer(alarmEngine: mockAlarmEngine, gamification: mockGamification)
    }

    // MARK: - Timer state

    func testStartCheckInTimerTransitionsToWaiting() {
        let alarmID = UUID()
        checkInTimer.startCheckInTimer(for: alarmID)
        if case .waiting(_, let id) = checkInTimer.checkInStatePublisher.value {
            XCTAssertEqual(id, alarmID)
        } else {
            XCTFail("Expected waiting state")
        }
    }

    func testUserConfirmedAwakeTransitionsToConfirmed() {
        let alarmID = UUID()
        checkInTimer.startCheckInTimer(for: alarmID)
        checkInTimer.userConfirmedAwake()
        if case .confirmedAwake(let id) = checkInTimer.checkInStatePublisher.value {
            XCTAssertEqual(id, alarmID)
        } else {
            XCTFail("Expected confirmedAwake state")
        }
    }

    func testUserConfirmedAwakeCallsAlarmEngine() {
        let alarmID = UUID()
        checkInTimer.startCheckInTimer(for: alarmID)
        checkInTimer.userConfirmedAwake()
        XCTAssertTrue(mockAlarmEngine.receivedCheckInSuccess)
    }

    func testUserConfirmedAwakeCallsGamification() {
        let alarmID = UUID()
        checkInTimer.startCheckInTimer(for: alarmID)
        checkInTimer.userConfirmedAwake()
        XCTAssertTrue(mockGamification.wakeSuccessRecorded)
    }

    func testResponseWindowSecondsConstantExists() {
        XCTAssertGreaterThan(CheckInTimer.responseWindowSeconds, 0)
    }

    func testReFireBehaviorDefaultIsSame() {
        if case .same = CheckInTimer.reFireBehavior {} else {
            XCTFail("Default re-fire behavior should be .same")
        }
    }
}

// MARK: - Mocks

final class MockAlarmEngine: AlarmEngineProtocol {
    var receivedCheckInSuccess: Bool?
    var receivedNFCTagID: String?
    private let stateSubject = CurrentValueSubject<AlarmState, Never>(.idle)
    var statePublisher: AnyPublisher<AlarmState, Never> { stateSubject.eraseToAnyPublisher() }

    func scheduleAlarm(_ alarm: AlarmModel) throws {}
    func cancelAlarm(id: UUID) throws {}
    func receiveNFCDismiss(tagID: String) { receivedNFCTagID = tagID }
    func receiveCheckInResult(success: Bool) { receivedCheckInSuccess = success }
    func fetchUpcomingAlarms() -> [AlarmModel] { [] }
}

final class MockGamificationEngine: GamificationEngineProtocol {
    var wakeSuccessRecorded = false
    var wakeFailureRecorded = false
    private let petSubject = CurrentValueSubject<PetModel, Never>(.default)
    private let streakSubject = CurrentValueSubject<Int, Never>(0)
    var petStatePublisher: AnyPublisher<PetModel, Never> { petSubject.eraseToAnyPublisher() }
    var streakPublisher: AnyPublisher<Int, Never> { streakSubject.eraseToAnyPublisher() }

    func recordWakeSuccess(date: Date) { wakeSuccessRecorded = true }
    func recordWakeFailure(date: Date) { wakeFailureRecorded = true }
    func equipAccessory(_ accessoryID: String) throws {}
    func availableAccessories() -> [Accessory] { [] }
}
