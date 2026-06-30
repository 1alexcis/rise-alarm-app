import SwiftUI
import SwiftData

private let appBackground = Color(hex: "FAFAF7")

@main
struct RiseApp: App {
    private let container: ModelContainer
    @State private var coordinator: AppCoordinator

    init() {
        let schema = Schema([AlarmEntry.self, PetEntry.self, CheckInEntry.self, OnboardingEntry.self])
        let container = try! ModelContainer(for: schema)
        self.container = container
        self._coordinator = State(wrappedValue: AppCoordinator(container: container))
    }

    var body: some Scene {
        WindowGroup {
            RootView(coordinator: coordinator)
                .modelContainer(container)
                .preferredColorScheme(.light)
                .background(appBackground)
        }
    }
}

private struct RootView: View {
    let coordinator: AppCoordinator

    var body: some View {
        ZStack {
            // Base background — sits in every pixel including safe areas
            appBackground

            if coordinator.showOnboarding {
                OnboardingContainerView(
                    viewModel: coordinator.onboardingViewModel,
                    onComplete: { coordinator.finishOnboarding() }
                )
            } else {
                HomeView(viewModel: coordinator.homeViewModel)
            }
        }
        // Apply on the ZStack itself — this is what actually expands layout into safe areas
        .ignoresSafeArea(.all)
        .onAppear {
            // Belt-and-suspenders: set the UIWindow background so nothing shows black
            // on any iOS version before SwiftUI paints its first frame
            UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .forEach { $0.backgroundColor = UIColor(appBackground) }
        }
    }
}
