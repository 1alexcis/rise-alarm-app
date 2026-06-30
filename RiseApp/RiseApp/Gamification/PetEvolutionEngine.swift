import Foundation

/// Maps XP to pet visual level and returns the appropriate SunExpression for display.
struct PetEvolutionEngine {

    static func expression(for pet: PetModel) -> SunExpression {
        if pet.isSad { return .sad }
        switch pet.level {
        case 1...3:  return .neutral
        case 4...6:  return .happy
        case 7...9:  return .happy
        case 10:     return .celebrating
        default:     return .neutral
        }
    }

    static func levelDescription(for level: Int) -> String {
        switch level {
        case 1:  return "Tiny Sun"
        case 2:  return "Glowing Sun"
        case 3:  return "Radiant Sun"
        case 4:  return "Bright Sun"
        case 5:  return "Shining Sun"
        case 6:  return "Blazing Sun"
        case 7:  return "Super Sun"
        case 8:  return "Mega Sun"
        case 9:  return "Ultra Sun"
        case 10: return "Legendary Sun ✨"
        default: return "Sun"
        }
    }

    /// Sun display size scales with level (200pt baseline at level 1).
    static func sunSize(for level: Int) -> CGFloat {
        let base: CGFloat = 200
        let scale = 1.0 + (CGFloat(level - 1) * 0.04)   // +4% per level
        return base * scale
    }
}
