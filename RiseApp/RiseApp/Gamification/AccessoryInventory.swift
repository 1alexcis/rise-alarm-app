import Foundation

/// Static catalog of all accessories and their unlock conditions.
struct AccessoryInventory {
    static let accessories: [Accessory] = [
        Accessory(id: "sunglasses",    name: "Cool Sunglasses", requiredStreak: 3,  imageName: "acc_sunglasses"),
        Accessory(id: "party_hat",     name: "Party Hat",       requiredStreak: 7,  imageName: "acc_party_hat"),
        Accessory(id: "golden_crown",  name: "Golden Crown",    requiredStreak: 14, imageName: "acc_golden_crown"),
        Accessory(id: "rainbow_cape",  name: "Rainbow Cape",    requiredStreak: 30, imageName: "acc_rainbow_cape"),
    ]
}
