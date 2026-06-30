import Foundation
import Observation
import Combine

@Observable
final class HomeViewModel {
    var nextAlarm: AlarmModel?
    var allAlarms: [AlarmModel] = []
    var petState: PetModel = .default
    var streakCount: Int = 0
    var showAddAlarm: Bool = false

    private var cancellables = Set<AnyCancellable>()

    private let alarmEngine: any AlarmEngineProtocol
    private let gamification: any GamificationEngineProtocol
    private let dataLayer: any DataLayerProtocol

    init(
        alarmEngine: any AlarmEngineProtocol,
        gamification: any GamificationEngineProtocol,
        dataLayer: any DataLayerProtocol
    ) {
        self.alarmEngine = alarmEngine
        self.gamification = gamification
        self.dataLayer = dataLayer
        subscribe()
        load()
    }

    func load() {
        allAlarms = (try? dataLayer.fetchAlarms()) ?? []
        nextAlarm = allAlarms.first(where: { $0.isActive })
        petState = (try? dataLayer.fetchPetState()) ?? .default
        streakCount = (try? dataLayer.fetchStreakCount()) ?? 0
    }

    func deleteAlarm(_ alarm: AlarmModel) {
        try? alarmEngine.cancelAlarm(id: alarm.id)
        allAlarms.removeAll { $0.id == alarm.id }
        if nextAlarm?.id == alarm.id { nextAlarm = allAlarms.first }
    }

    func saveAlarm(_ alarm: AlarmModel) {
        try? alarmEngine.scheduleAlarm(alarm)
        load()
    }

    func toggleAlarm(_ alarm: AlarmModel) {
        var updated = alarm
        updated.isActive.toggle()
        try? alarmEngine.scheduleAlarm(updated)
        load()
    }

    private func subscribe() {
        gamification.petStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] pet in self?.petState = pet }
            .store(in: &cancellables)

        gamification.streakPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] streak in self?.streakCount = streak }
            .store(in: &cancellables)

        alarmEngine.statePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.load() }
            .store(in: &cancellables)
    }
}
