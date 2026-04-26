import SwiftUI
import SwiftData

@main
struct RiseApp: App {
    @State private var coordinator = AppCoordinator()

    var body: some Scene {
        WindowGroup {
            coordinator.rootView()
                .modelContainer(for: [AlarmEntry.self, PetEntry.self, CheckInEntry.self, OnboardingEntry.self])
        }
    }
}
