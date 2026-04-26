import Foundation

/// Deterministic daily tone rotation — same device always plays the same tone on the same day.
/// Seeded from the current calendar day so it's consistent across app restarts.
struct DailyRotationScheduler {
    static func toneForToday(from tones: [Tone]) -> Tone {
        guard !tones.isEmpty else { return ToneLibrary.defaultTone }
        let day = Calendar.current.ordinality(of: .day, in: .era, for: .now) ?? 0
        let index = day % tones.count
        return tones[index]
    }
}
