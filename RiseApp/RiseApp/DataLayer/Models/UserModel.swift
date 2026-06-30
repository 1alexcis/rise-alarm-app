import Foundation

struct CheckInRecord: Codable, Identifiable, Equatable {
    let id: UUID
    let date: Date
    let success: Bool
    let alarmID: UUID
}
