import SwiftUI

struct RiseButton: View {
    let title: String
    var style: ButtonStyle = .primary
    let action: () -> Void

    enum ButtonStyle {
        case primary
        case secondary
        case danger
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Rise.Font.rounded(17, weight: .semibold))
                .foregroundStyle(foregroundColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(backgroundColor, in: RoundedRectangle(cornerRadius: Rise.Radius.pill))
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .primary:   return Rise.Color.primary
        case .secondary: return Rise.Color.surface
        case .danger:    return Rise.Color.danger
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary:   return Rise.Color.text
        case .secondary: return Rise.Color.primary
        case .danger:    return .white
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        RiseButton(title: "Wake Up!", style: .primary) {}
        RiseButton(title: "Skip", style: .secondary) {}
        RiseButton(title: "Delete Alarm", style: .danger) {}
    }
    .padding()
    .background(Rise.Color.background)
}
