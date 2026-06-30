import Foundation
import Combine

struct Accessory: Identifiable, Equatable {
    let id: String
    let name: String
    let requiredStreak: Int
    let imageName: String
}

// MARK: - Public protocol
protocol GamificationEngineProtocol: AnyObject {
    var petStatePublisher: AnyPublisher<PetModel, Never> { get }
    var streakPublisher: AnyPublisher<Int, Never> { get }

    func recordWakeSuccess(date: Date)
    func recordWakeFailure(date: Date)
    func equipAccessory(_ accessoryID: String) throws
    func availableAccessories() -> [Accessory]
}

// MARK: - Gamification errors
enum GamificationError: Error {
    case accessoryLocked(requiredStreak: Int)
    case accessoryNotFound
}
