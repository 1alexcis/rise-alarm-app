import SwiftUI
import SwiftData
import Observation

@Observable
final class AppCoordinator {
    var showOnboarding: Bool

    let homeViewModel: HomeViewModel
    let onboardingViewModel: OnboardingViewModel

    init(container: ModelContainer) {
        let store = LocalStore(container: container)
        let engine = AlarmStateMachine(dataLayer: store)
        let gam = GamificationEngineImpl(dataLayer: store)
        let nfc = NFCSessionManager()

        self.showOnboarding = (try? store.isOnboardingComplete()) != true
        self.homeViewModel = HomeViewModel(alarmEngine: engine, gamification: gam, dataLayer: store)
        self.onboardingViewModel = OnboardingViewModel(dataLayer: store, alarmEngine: engine, nfcHandler: nfc)
    }

    func finishOnboarding() {
        showOnboarding = false
        homeViewModel.load()
    }
}
