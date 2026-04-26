import SwiftUI
import Observation

/// Root coordinator: decides whether to show onboarding or the home screen.
@Observable
final class AppCoordinator {
    var showOnboarding: Bool = true

    private var dataLayer: (any DataLayerProtocol)?

    func configure(dataLayer: any DataLayerProtocol) {
        self.dataLayer = dataLayer
        showOnboarding = (try? dataLayer.isOnboardingComplete()) != true
    }

    @ViewBuilder
    func rootView() -> some View {
        if showOnboarding {
            OnboardingCoordinator(onComplete: { [weak self] in
                self?.showOnboarding = false
            }).rootView()
        } else {
            HomeView()
        }
    }
}
