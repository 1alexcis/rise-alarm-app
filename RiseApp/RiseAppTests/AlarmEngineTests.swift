import XCTest
import Combine
@testable import RiseApp

final class AlarmEngineTests: XCTestCase {
    var engine: AlarmStateMachine!
    var mockDataLayer: MockDataLayer!
    var cancellables = Set<AnyCancellable>()

    override func setUpWithError() throws {
        mockDataLayer = MockDataLayer()
        engine = AlarmStateMachine(dataLayer: mockDataLayer)
    }

    // MARK: - Initial state

    func testInitialStateIsIdle() {
        XCTAssertEqual(engine.statePublisher.value, .idle)  // CurrentValueSubject
    }

    // MARK: - Schedule and state transitions

    func testScheduleAlarmSavesToDataLayer() throws {
        let alarm = AlarmModel.default
        try engine.scheduleAlarm(alarm)
        XCTAssertEqual(mockDataLayer.savedAlarms.count, 1)
    }

    func testNFCDismissTransitionsToPendingCheckIn() throws {
        let alarm = AlarmModel(
            id: UUID(),
            time: DateComponents(hour: 7, minute: 0),
            repeatDays: [],
            toneID: "sunrise_chime",
            volumeLevel: 0.7,
            linkedNFCTagID: "tag-abc",
            isActive: true
        )
        try engine.scheduleAlarm(alarm)

        // Manually inject firing state
        engine.stateSubject.send(.firing(alarmID: alarm.id))
        engine.receiveNFCDismiss(tagID: "tag-abc")

        if case .pendingCheckIn(let id, _) = engine.stateSubject.value {
            XCTAssertEqual(id, alarm.id)
        } else {
            XCTFail("Expected pendingCheckIn state, got \(engine.stateSubject.value)")
        }
    }

    func testCheckInSuccessTransitionsToDismissed() throws {
        let alarm = AlarmModel(
            id: UUID(),
            time: DateComponents(hour: 7, minute: 0),
            repeatDays: [],
            toneID: "sunrise_chime",
            volumeLevel: 0.7,
            linkedNFCTagID: "tag-xyz",
            isActive: true
        )
        try engine.scheduleAlarm(alarm)
        engine.stateSubject.send(.pendingCheckIn(alarmID: alarm.id, deadline: Date().addingTimeInterval(300)))
        engine.receiveCheckInResult(success: true)

        if case .dismissed(let id) = engine.stateSubject.value {
            XCTAssertEqual(id, alarm.id)
        } else {
            XCTFail("Expected dismissed, got \(engine.stateSubject.value)")
        }
    }

    func testCheckInFailureTransitionsToRefired() throws {
        let alarmID = UUID()
        engine.stateSubject.send(.pendingCheckIn(alarmID: alarmID, deadline: Date().addingTimeInterval(300)))
        engine.receiveCheckInResult(success: false)

        if case .firing(let id) = engine.stateSubject.value {
            XCTAssertEqual(id, alarmID)
        } else {
            XCTFail("Expected firing (re-fire), got \(engine.stateSubject.value)")
        }
    }

    func testCancelAlarmRemovesFromDataLayer() throws {
        let alarm = AlarmModel.default
        try engine.scheduleAlarm(alarm)
        try engine.cancelAlarm(id: alarm.id)
        XCTAssertEqual(mockDataLayer.savedAlarms.count, 0)
    }
}

// MARK: - Mock DataLayer
final class MockDataLayer: DataLayerProtocol {
    var savedAlarms: [AlarmModel] = []
    var petState: PetModel = .default
    var checkIns: [CheckInRecord] = []
    var onboardingComplete: Bool = false

    func saveAlarm(_ alarm: AlarmModel) throws {
        savedAlarms.removeAll { $0.id == alarm.id }
        savedAlarms.append(alarm)
    }
    func fetchAlarms() throws -> [AlarmModel] { savedAlarms }
    func deleteAlarm(id: UUID) throws { savedAlarms.removeAll { $0.id == id } }
    func recordCheckIn(success: Bool, date: Date, alarmID: UUID) throws {
        checkIns.append(CheckInRecord(id: UUID(), date: date, success: success, alarmID: alarmID))
    }
    func fetchStreakCount() throws -> Int { 0 }
    func fetchCheckInHistory() throws -> [CheckInRecord] { checkIns }
    func savePetState(_ state: PetModel) throws { petState = state }
    func fetchPetState() throws -> PetModel { petState }
    func markOnboardingComplete() throws { onboardingComplete = true }
    func isOnboardingComplete() throws -> Bool { onboardingComplete }
}

// Expose internal for testing
extension AlarmStateMachine {
    var stateSubject: CurrentValueSubject<AlarmState, Never> {
        // This requires making stateSubject internal in production code — acceptable for testing
        return self.value(forKey: "stateSubject") as! CurrentValueSubject<AlarmState, Never>
    }
}
