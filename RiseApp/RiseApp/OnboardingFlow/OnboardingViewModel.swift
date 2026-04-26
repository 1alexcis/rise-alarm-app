import Foundation
import Observation

@Observable
final class OnboardingViewModel {
    var selectedTime: DateComponents = DateComponents(hour: 7, minute: 30)
    var selectedToneID: String = "sunrise_chime"
    var volumeLevel: Float = 0.7
    var repeatDays: Set<Weekday> = [.monday, .tuesday, .wednesday, .thursday, .friday]
    var pairedTagID: String?
    var isLoading: Bool = false
    var errorMessage: String?

    private let dataLayer: any DataLayerProtocol
    private let alarmEngine: any AlarmEngineProtocol
    private let nfcHandler: any NFCHandlerProtocol

    init(
        dataLayer: any DataLayerProtocol,
        alarmEngine: any AlarmEngineProtocol,
        nfcHandler: any NFCHandlerProtocol
    ) {
        self.dataLayer = dataLayer
        self.alarmEngine = alarmEngine
        self.nfcHandler = nfcHandler
    }

    func beginNFCPairing(alarmID: UUID) async {
        isLoading = true
        errorMessage = nil
        do {
            pairedTagID = try await nfcHandler.beginPairingSession(for: alarmID)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func completeOnboarding() async throws {
        let alarm = AlarmModel(
            id: UUID(),
            time: selectedTime,
            repeatDays: repeatDays,
            toneID: selectedToneID,
            volumeLevel: volumeLevel,
            linkedNFCTagID: pairedTagID,
            isActive: true
        )
        try alarmEngine.scheduleAlarm(alarm)
        try dataLayer.markOnboardingComplete()
    }
}
