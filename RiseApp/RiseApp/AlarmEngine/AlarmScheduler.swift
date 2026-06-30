import Foundation

/// Computes the next fire date for an alarm given its time and repeat days.
struct AlarmScheduler {
    static func nextFireDate(for alarm: AlarmModel, after reference: Date = .now) -> Date? {
        let calendar = Calendar.current
        guard let hour = alarm.time.hour, let minute = alarm.time.minute else { return nil }

        if alarm.repeatDays.isEmpty {
            // One-time: next occurrence of this time today or tomorrow
            var components = calendar.dateComponents([.year, .month, .day], from: reference)
            components.hour = hour
            components.minute = minute
            components.second = 0
            if let candidate = calendar.date(from: components), candidate > reference {
                return candidate
            }
            return calendar.date(byAdding: .day, value: 1, to: calendar.date(from: components)!)
        }

        // Repeating: find the soonest matching weekday
        let weekdayValues = alarm.repeatDays.map { $0.rawValue }.sorted()
        for offset in 0..<8 {
            guard let candidate = calendar.date(byAdding: .day, value: offset, to: reference) else { continue }
            let weekday = calendar.component(.weekday, from: candidate)
            guard weekdayValues.contains(weekday) else { continue }

            var components = calendar.dateComponents([.year, .month, .day], from: candidate)
            components.hour = hour
            components.minute = minute
            components.second = 0
            if let fireDate = calendar.date(from: components), fireDate > reference {
                return fireDate
            }
        }
        return nil
    }
}
