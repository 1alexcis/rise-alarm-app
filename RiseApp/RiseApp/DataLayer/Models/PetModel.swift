import Foundation

struct PetModel: Codable, Equatable {
    var xp: Int
    var level: Int                       // 1–10, derived from XP thresholds
    var unlockedAccessories: Set<String>
    var equippedAccessory: String?
    var lastUpdated: Date
    var isSad: Bool                      // true for 24h after a miss

    static let xpThresholds: [Int] = [0, 500, 1500, 2999, 5000, 7500, 10500, 14000, 18000, 23000]

    static func levelForXP(_ xp: Int) -> Int {
        let idx = xpThresholds.lastIndex(where: { xp >= $0 }) ?? 0
        return min(idx + 1, 10)
    }

    static var `default`: PetModel {
        PetModel(
            xp: 0,
            level: 1,
            unlockedAccessories: [],
            equippedAccessory: nil,
            lastUpdated: .now,
            isSad: false
        )
    }
}
