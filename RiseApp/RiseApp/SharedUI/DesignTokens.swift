import SwiftUI

// MARK: - Hex color initializer
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

// MARK: - Design tokens
enum Rise {
    enum Color {
        static let primary        = SwiftUI.Color(hex: "F5B800")  // warm yellow
        static let background     = SwiftUI.Color(hex: "FAFAF7")  // off-white
        static let surface        = SwiftUI.Color(hex: "FFFFFF")
        static let text           = SwiftUI.Color(hex: "1A1A1A")
        static let textSecondary  = SwiftUI.Color(hex: "888888")
        static let success        = SwiftUI.Color(hex: "34C759")
        static let danger         = SwiftUI.Color(hex: "FF3B30")
        static let streakAmber    = SwiftUI.Color(hex: "FF9500")
    }

    enum Radius {
        static let sm:   CGFloat = 8
        static let md:   CGFloat = 16
        static let lg:   CGFloat = 24
        static let pill: CGFloat = 999
    }

    enum Font {
        static func rounded(_ size: CGFloat, weight: SwiftUI.Font.Weight = .regular) -> SwiftUI.Font {
            .system(size: size, weight: weight, design: .rounded)
        }
    }

    enum Spacing {
        static let xs:  CGFloat = 4
        static let sm:  CGFloat = 8
        static let md:  CGFloat = 16
        static let lg:  CGFloat = 24
        static let xl:  CGFloat = 32
        static let xxl: CGFloat = 48
    }
}
