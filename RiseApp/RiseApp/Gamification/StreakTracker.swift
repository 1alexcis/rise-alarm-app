import Foundation
import Combine

final class GamificationEngineImpl: GamificationEngineProtocol {

    // MARK: - XP constants
    static let xpPerWake: Int = 100
    static let xpStreakBonusPerDay: Int = 10
    static let xpStreakBonusCap: Int = 100

    private let petSubject: CurrentValueSubject<PetModel, Never>
    private let streakSubject: CurrentValueSubject<Int, Never>

    var petStatePublisher: AnyPublisher<PetModel, Never> { petSubject.eraseToAnyPublisher() }
    var streakPublisher: AnyPublisher<Int, Never> { streakSubject.eraseToAnyPublisher() }

    private let dataLayer: any DataLayerProtocol

    init(dataLayer: any DataLayerProtocol) {
        self.dataLayer = dataLayer
        let pet = (try? dataLayer.fetchPetState()) ?? .default
        let streak = (try? dataLayer.fetchStreakCount()) ?? 0
        petSubject = CurrentValueSubject(pet)
        streakSubject = CurrentValueSubject(streak)
    }

    // MARK: - Record wake

    func recordWakeSuccess(date: Date) {
        var pet = petSubject.value
        let streak = streakSubject.value

        let streakBonus = min(streak * Self.xpStreakBonusPerDay, Self.xpStreakBonusCap)
        pet.xp += Self.xpPerWake + streakBonus
        pet.level = PetModel.levelForXP(pet.xp)
        pet.isSad = false
        pet.lastUpdated = date

        // Unlock streak-milestone accessories
        let newStreak = streak + 1
        for accessory in AccessoryInventory.accessories where accessory.requiredStreak == newStreak {
            pet.unlockedAccessories.insert(accessory.id)
        }

        pet.unlockedAccessories = pet.unlockedAccessories.union(
            AccessoryInventory.accessories
                .filter { $0.requiredStreak <= newStreak }
                .map { $0.id }
        )

        try? dataLayer.savePetState(pet)
        try? dataLayer.recordCheckIn(success: true, date: date, alarmID: UUID())

        petSubject.send(pet)
        streakSubject.send(newStreak)
    }

    func recordWakeFailure(date: Date) {
        var pet = petSubject.value
        pet.isSad = true
        pet.lastUpdated = date
        try? dataLayer.savePetState(pet)
        try? dataLayer.recordCheckIn(success: false, date: date, alarmID: UUID())

        petSubject.send(pet)
        streakSubject.send(0)   // streak resets on miss
    }

    // MARK: - Accessories

    func equipAccessory(_ accessoryID: String) throws {
        guard AccessoryInventory.accessories.contains(where: { $0.id == accessoryID }) else {
            throw GamificationError.accessoryNotFound
        }
        var pet = petSubject.value
        guard pet.unlockedAccessories.contains(accessoryID) else {
            let required = AccessoryInventory.accessories.first(where: { $0.id == accessoryID })?.requiredStreak ?? 0
            throw GamificationError.accessoryLocked(requiredStreak: required)
        }
        pet.equippedAccessory = accessoryID
        pet.lastUpdated = .now
        try dataLayer.savePetState(pet)
        petSubject.send(pet)
    }

    func availableAccessories() -> [Accessory] {
        AccessoryInventory.accessories
    }
}
