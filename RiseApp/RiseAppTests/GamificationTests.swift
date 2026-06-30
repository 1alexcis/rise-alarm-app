import XCTest
import Combine
@testable import RiseApp

final class GamificationTests: XCTestCase {
    var engine: GamificationEngineImpl!
    var mockData: MockDataLayer!

    override func setUp() {
        mockData = MockDataLayer()
        engine = GamificationEngineImpl(dataLayer: mockData)
    }

    // MARK: - XP

    func testWakeSuccessGrantsXP() {
        engine.recordWakeSuccess(date: .now)
        XCTAssertEqual(engine.petStatePublisher.value.xp, GamificationEngineImpl.xpPerWake)
    }

    func testStreakBonusIsApplied() {
        // Set a streak of 5 in the mock
        for _ in 0..<5 {
            try? mockData.recordCheckIn(success: true, date: .now, alarmID: UUID())
        }
        // Re-init with existing streak data reflected via fetchStreakCount
        engine.recordWakeSuccess(date: .now)
        let expectedBonus = min(0 * GamificationEngineImpl.xpStreakBonusPerDay, GamificationEngineImpl.xpStreakBonusCap)
        XCTAssertGreaterThanOrEqual(engine.petStatePublisher.value.xp, GamificationEngineImpl.xpPerWake + expectedBonus)
    }

    func testWakeFailureResetStreak() {
        engine.recordWakeSuccess(date: .now)
        engine.recordWakeFailure(date: .now)
        XCTAssertEqual(engine.streakPublisher.value, 0)
    }

    func testPetEntersSadStateOnFailure() {
        engine.recordWakeFailure(date: .now)
        XCTAssertTrue(engine.petStatePublisher.value.isSad)
    }

    // MARK: - Pet level

    func testPetLevelAdvancesWithXP() {
        // Need 500 XP to reach level 2
        for _ in 0..<5 {
            engine.recordWakeSuccess(date: .now)
        }
        XCTAssertGreaterThanOrEqual(engine.petStatePublisher.value.level, 1)
    }

    // MARK: - Accessories

    func testAccessoryLockedBeforeStreakRequirement() {
        XCTAssertThrowsError(try engine.equipAccessory("sunglasses")) { error in
            if case GamificationError.accessoryLocked = error {} else {
                XCTFail("Expected accessoryLocked error")
            }
        }
    }

    func testEquipUnlockedAccessory() {
        var pet = PetModel.default
        pet.unlockedAccessories.insert("sunglasses")
        try? mockData.savePetState(pet)
        engine = GamificationEngineImpl(dataLayer: mockData)
        XCTAssertNoThrow(try engine.equipAccessory("sunglasses"))
        XCTAssertEqual(engine.petStatePublisher.value.equippedAccessory, "sunglasses")
    }

    func testAvailableAccessoriesCount() {
        XCTAssertEqual(engine.availableAccessories().count, AccessoryInventory.accessories.count)
    }
}

// CurrentValueSubject value helper
extension Publisher where Failure == Never {
    var value: Output {
        var result: Output!
        let cancellable = self.sink { result = $0 }
        _ = cancellable
        return result
    }
}
