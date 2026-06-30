import XCTest
import SwiftData
@testable import RiseApp

final class DataLayerTests: XCTestCase {
    var store: LocalStore!

    override func setUpWithError() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: AlarmEntry.self, PetEntry.self, CheckInEntry.self, OnboardingEntry.self,
            configurations: config
        )
        store = LocalStore(container: container)
    }

    // MARK: - Alarm CRUD

    func testSaveAndFetchAlarm() throws {
        let alarm = AlarmModel.default
        try store.saveAlarm(alarm)
        let fetched = try store.fetchAlarms()
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched[0].id, alarm.id)
        XCTAssertEqual(fetched[0].toneID, alarm.toneID)
    }

    func testUpdateExistingAlarm() throws {
        var alarm = AlarmModel.default
        try store.saveAlarm(alarm)
        alarm.toneID = "electric_dawn"
        try store.saveAlarm(alarm)
        let fetched = try store.fetchAlarms()
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched[0].toneID, "electric_dawn")
    }

    func testDeleteAlarm() throws {
        let alarm = AlarmModel.default
        try store.saveAlarm(alarm)
        try store.deleteAlarm(id: alarm.id)
        XCTAssertEqual(try store.fetchAlarms().count, 0)
    }

    func testDeleteNonExistentAlarmThrows() throws {
        XCTAssertThrowsError(try store.deleteAlarm(id: UUID()))
    }

    // MARK: - Check-in / Streak

    func testRecordCheckInAndFetchHistory() throws {
        let alarmID = UUID()
        try store.recordCheckIn(success: true, date: .now, alarmID: alarmID)
        let history = try store.fetchCheckInHistory()
        XCTAssertEqual(history.count, 1)
        XCTAssertTrue(history[0].success)
    }

    func testStreakCountConsecutiveDays() throws {
        let calendar = Calendar.current
        for i in 0..<5 {
            let date = calendar.date(byAdding: .day, value: -i, to: .now)!
            try store.recordCheckIn(success: true, date: date, alarmID: UUID())
        }
        let streak = try store.fetchStreakCount()
        XCTAssertEqual(streak, 5)
    }

    func testStreakBreaksOnMissedDay() throws {
        let calendar = Calendar.current
        // Day 0 (today) and day 2 (skip day 1)
        try store.recordCheckIn(success: true, date: .now, alarmID: UUID())
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: .now)!
        try store.recordCheckIn(success: true, date: twoDaysAgo, alarmID: UUID())
        let streak = try store.fetchStreakCount()
        XCTAssertEqual(streak, 1)  // streak resets because day 1 was missed
    }

    // MARK: - Pet state

    func testSaveAndFetchPetState() throws {
        var pet = PetModel.default
        pet.xp = 500
        pet.level = PetModel.levelForXP(500)
        try store.savePetState(pet)
        let fetched = try store.fetchPetState()
        XCTAssertEqual(fetched.xp, 500)
        XCTAssertEqual(fetched.level, 2)
    }

    func testFetchPetStateReturnsDefaultWhenEmpty() throws {
        let pet = try store.fetchPetState()
        XCTAssertEqual(pet.xp, 0)
        XCTAssertEqual(pet.level, 1)
    }

    // MARK: - Onboarding

    func testMarkOnboardingComplete() throws {
        XCTAssertFalse(try store.isOnboardingComplete())
        try store.markOnboardingComplete()
        XCTAssertTrue(try store.isOnboardingComplete())
    }
}
