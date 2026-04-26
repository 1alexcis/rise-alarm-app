import SwiftUI

struct RiseCard<Content: View>: View {
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        content()
            .padding(Rise.Spacing.md)
            .background(Rise.Color.surface, in: RoundedRectangle(cornerRadius: Rise.Radius.md))
            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    RiseCard {
        VStack(alignment: .leading) {
            Text("7:30 AM").font(Rise.Font.rounded(28, weight: .bold))
            Text("Mon · Tue · Wed · Thu · Fri").font(Rise.Font.rounded(14)).foregroundStyle(Rise.Color.textSecondary)
        }
    }
    .padding()
    .background(Rise.Color.background)
}
