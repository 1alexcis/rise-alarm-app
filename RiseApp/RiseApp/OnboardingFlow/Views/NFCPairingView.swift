import SwiftUI

struct NFCPairingView: View {
    @Binding var step: Int
    @State private var pairingState: NFCPairingViewState = .idle
    private let alarmID = UUID()

    enum NFCPairingViewState {
        case idle, scanning, success, error(String)
    }

    var body: some View {
        VStack(spacing: Rise.Spacing.xl) {
            SunView(expression: .waving, size: 80)
                .padding(.top, Rise.Spacing.lg)

            VStack(spacing: Rise.Spacing.sm) {
                Text("Pair your sticker")
                    .font(Rise.Font.rounded(24, weight: .bold))
                    .foregroundStyle(Rise.Color.text)

                Text("Hold your iPhone to the back of your NFC sticker.")
                    .font(Rise.Font.rounded(16))
                    .foregroundStyle(Rise.Color.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, Rise.Spacing.xl)

            // Illustrated NFC tap graphic (code-drawn)
            ZStack {
                RoundedRectangle(cornerRadius: Rise.Radius.lg)
                    .fill(Rise.Color.surface)
                    .frame(width: 200, height: 160)
                    .shadow(color: .black.opacity(0.06), radius: 8)

                VStack(spacing: Rise.Spacing.sm) {
                    Image(systemName: "iphone.radiowaves.left.and.right")
                        .font(.system(size: 48))
                        .foregroundStyle(Rise.Color.primary)

                    switch pairingState {
                    case .idle:
                        Text("Tap to start")
                            .font(Rise.Font.rounded(14))
                            .foregroundStyle(Rise.Color.textSecondary)
                    case .scanning:
                        ProgressView()
                            .tint(Rise.Color.primary)
                        Text("Scanning…")
                            .font(Rise.Font.rounded(14))
                            .foregroundStyle(Rise.Color.textSecondary)
                    case .success:
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(Rise.Color.success)
                        Text("Paired!")
                            .font(Rise.Font.rounded(14, weight: .semibold))
                            .foregroundStyle(Rise.Color.success)
                    case .error(let msg):
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(Rise.Color.danger)
                        Text(msg)
                            .font(Rise.Font.rounded(12))
                            .foregroundStyle(Rise.Color.danger)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 160)
                    }
                }
            }

            Spacer()

            VStack(spacing: Rise.Spacing.md) {
                if case .success = pairingState {
                    RiseButton(title: "Continue") {
                        withAnimation { step = 5 }
                    }
                } else {
                    RiseButton(title: pairingState == .scanning ? "Scanning…" : "Start Pairing") {
                        guard pairingState != .scanning else { return }
                        pairingState = .scanning
                        // In production, call NFCHandler.beginPairingSession here
                        // via the ViewModel. For now simulating a 2-second scan.
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            pairingState = .success
                        }
                    }

                    Button("Skip for now →") {
                        withAnimation { step = 5 }
                    }
                    .font(Rise.Font.rounded(15))
                    .foregroundStyle(Rise.Color.textSecondary)
                }
            }
            .padding(.horizontal, Rise.Spacing.xl)
            .padding(.bottom, Rise.Spacing.xl)
        }
    }
}

// Make NFCPairingViewState Equatable for the guard check
extension NFCPairingView.NFCPairingViewState: Equatable {
    static func == (lhs: NFCPairingView.NFCPairingViewState, rhs: NFCPairingView.NFCPairingViewState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.scanning, .scanning), (.success, .success): return true
        case (.error(let a), .error(let b)): return a == b
        default: return false
        }
    }
}
