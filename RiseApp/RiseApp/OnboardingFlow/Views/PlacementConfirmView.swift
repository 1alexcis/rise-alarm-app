import SwiftUI

struct PlacementConfirmView: View {
    let onComplete: () -> Void
    @Environment(OnboardingViewModel.self) private var viewModel
    @State private var isSaving: Bool = false

    var body: some View {
        ZStack {
            Color(hex: "FAFAF7").ignoresSafeArea(.all)
        VStack(spacing: Rise.Spacing.xl) {
            SunView(expression: .celebrating, size: 100)
                .padding(.top, Rise.Spacing.lg)

            VStack(spacing: Rise.Spacing.md) {
                Text("Now put your sticker there! 📌")
                    .font(Rise.Font.rounded(24, weight: .bold))
                    .foregroundStyle(Rise.Color.text)
                    .multilineTextAlignment(.center)

                Text("Stick it on your whiteboard, door, bathroom mirror — wherever forces you to get up.")
                    .font(Rise.Font.rounded(16))
                    .foregroundStyle(Rise.Color.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, Rise.Spacing.xl)

            // Illustration: whiteboard on dorm door (code-drawn placeholder)
            ZStack {
                RoundedRectangle(cornerRadius: Rise.Radius.lg)
                    .fill(Rise.Color.surface)
                    .frame(width: 220, height: 160)
                    .shadow(color: .black.opacity(0.07), radius: 8)

                VStack(spacing: Rise.Spacing.sm) {
                    Image(systemName: "door.left.hand.closed")
                        .font(.system(size: 40))
                        .foregroundStyle(Rise.Color.text.opacity(0.5))

                    ZStack {
                        RoundedRectangle(cornerRadius: Rise.Radius.sm)
                            .fill(Color.white)
                            .frame(width: 80, height: 50)
                            .shadow(color: .black.opacity(0.1), radius: 2)

                        Circle()
                            .fill(Rise.Color.primary)
                            .frame(width: 18, height: 18)
                            .overlay(
                                Image(systemName: "sun.max.fill")
                                    .font(.system(size: 10))
                                    .foregroundStyle(.white)
                            )
                    }
                }
            }

            Spacer()

            RiseButton(title: isSaving ? "Saving…" : "I'm ready to Rise! ☀️") {
                guard !isSaving else { return }
                isSaving = true
                Task {
                    try? await viewModel.completeOnboarding()
                    await MainActor.run { onComplete() }
                }
            }
            .padding(.horizontal, Rise.Spacing.xl)
            .padding(.bottom, Rise.Spacing.xl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
}
