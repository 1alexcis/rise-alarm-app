import SwiftUI

struct OnboardingContainerView: View {
    @Bindable var viewModel: OnboardingViewModel
    let onComplete: () -> Void
    @State private var step: Int = 0

    var body: some View {
        Color(hex: "FAFAF7")
            .ignoresSafeArea(.all)
            .overlay {
                VStack(spacing: 0) {
                    progressDots
                        .padding(.vertical, 12)

                    Group {
                        switch step {
                        case 0:
                            TimePickerView(step: $step, wakeDate: $viewModel.wakeDate)
                        case 1:
                            ToneSelectionView(step: $step, selectedToneID: $viewModel.selectedToneID)
                        case 2:
                            VolumePickerView(step: $step, volumeLevel: $viewModel.volumeLevel)
                        case 3:
                            RepeatPickerView(step: $step, repeatDays: $viewModel.repeatDays)
                        case 4:
                            NFCPairingView(step: $step)
                        case 5:
                            PlacementConfirmView(onComplete: onComplete)
                        default:
                            EmptyView()
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
                    .animation(.easeInOut(duration: 0.3), value: step)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .environment(viewModel)
    }

    private var progressDots: some View {
        HStack(spacing: 8) {
            ForEach(0..<6, id: \.self) { i in
                Circle()
                    .fill(i == step ? Rise.Color.primary : Rise.Color.primary.opacity(0.3))
                    .frame(width: i == step ? 10 : 7, height: i == step ? 10 : 7)
                    .animation(.spring(response: 0.3), value: step)
            }
        }
    }
}
