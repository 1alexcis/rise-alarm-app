import Foundation

// MARK: - Public protocol — all other modules use this, never concrete types
protocol DataLayerProtocol: AnyObject {

    // MARK: Alarms
    func saveAlarm(_ alarm: AlarmModel) throws
    func fetchAlarms() throws -> [AlarmModel]
    func deleteAlarm(id: UUID) throws

    // MARK: Streaks & Check-ins
    func recordCheckIn(success: Bool, date: Date, alarmID: UUID) throws
    func fetchStreakCount() throws -> Int
    func fetchCheckInHistory() throws -> [CheckInRecord]

    // MARK: Pet State
    func savePetState(_ state: PetModel) throws
    func fetchPetState() throws -> PetModel

    // MARK: Onboarding
    func markOnboardingComplete() throws
    func isOnboardingComplete() throws -> Bool
}

// MARK: - Error types
enum DataLayerError: Error, LocalizedError {
    case notFound(String)
    case encodingFailed(underlying: Error)
    case decodingFailed(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .notFound(let entity):     return "Entity not found: \(entity)"
        case .encodingFailed(let e):    return "Encoding failed: \(e.localizedDescription)"
        case .decodingFailed(let e):    return "Decoding failed: \(e.localizedDescription)"
        }
    }
}
