import Foundation

enum Weekday: Int, Codable, CaseIterable, Identifiable {
    case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday

    var id: Int { rawValue }

    var shortName: String {
        switch self {
        case .sunday:    return "S"
        case .monday:    return "M"
        case .tuesday:   return "T"
        case .wednesday: return "W"
        case .thursday:  return "T"
        case .friday:    return "F"
        case .saturday:  return "S"
        }
    }

    var fullName: String {
        switch self {
        case .sunday:    return "Sunday"
        case .monday:    return "Monday"
        case .tuesday:   return "Tuesday"
        case .wednesday: return "Wednesday"
        case .thursday:  return "Thursday"
        case .friday:    return "Friday"
        case .saturday:  return "Saturday"
        }
    }
}

struct AlarmModel: Codable, Identifiable, Equatable {
    let id: UUID
    var time: DateComponents           // hour + minute only
    var repeatDays: Set<Weekday>       // empty = one-time alarm
    var toneID: String
    var volumeLevel: Float             // 0.0 – 1.0
    var linkedNFCTagID: String?        // nil until paired with a sticker
    var isActive: Bool

    static var `default`: AlarmModel {
        AlarmModel(
            id: UUID(),
            time: DateComponents(hour: 7, minute: 30),
            repeatDays: [.monday, .tuesday, .wednesday, .thursday, .friday],
            toneID: "sunrise_chime",
            volumeLevel: 0.7,
            linkedNFCTagID: nil,
            isActive: true
        )
    }
}
