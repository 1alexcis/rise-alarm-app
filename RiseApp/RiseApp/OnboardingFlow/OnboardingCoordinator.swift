import SwiftUI

final class OnboardingCoordinator {
    var onComplete: (() -> Void)?

    init(onComplete: (() -> Void)? = nil) {
        self.onComplete = onComplete
    }

    @ViewBuilder
    func rootView() -> some View {
        OnboardingContainerView(onComplete: onComplete ?? {})
    }
}

struct OnboardingContainerView: View {
    let onComplete: () -> Void
    @State private var step: Int = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            Rise.Color.background.ignoresSafeArea()

            VStack {
                progressDots
                    .padding(.top, Rise.Spacing.md)

                Group {
                    switch step {
                    case 0: TimePickerView(step: $step)
                    case 1: ToneSelectionView(step: $step)
                    case 2: VolumePickerView(step: $step)
                    case 3: RepeatPickerView(step: $step)
                    case 4: NFCPairingView(step: $step)
                    case 5: PlacementConfirmView(onComplete: onComplete)
                    default: EmptyView()
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing),
                    removal: .move(edge: .leading)
                ))
                .animation(.easeInOut(duration: 0.3), value: step)
            }
        }
    }

    private var progressDots: some View {
        HStack(spacing: 8) {
            ForEach(0..<6, id: \.self) { i in
                Circle()
                    .fill(i == step ? Rise.Color.primary : Rise.Color.primary.opacity(0.25))
                    .frame(width: i == step ? 10 : 7, height: i == step ? 10 : 7)
                    .animation(.spring(response: 0.3), value: step)
            }
        }
    }
}
