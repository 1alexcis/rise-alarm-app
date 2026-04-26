import Foundation

/// Curated catalog of 8 initial alarm tones.
/// Replace filename values with real audio assets before shipping.
struct ToneLibrary {
    static let tones: [Tone] = [
        Tone(id: "sunrise_chime",    name: "Sunrise Chime",    filename: "sunrise_chime.mp3",    bpm: nil, mood: .gentle,    isDefault: true),
        Tone(id: "morning_breeze",   name: "Morning Breeze",   filename: "morning_breeze.mp3",   bpm: nil, mood: .gentle,    isDefault: false),
        Tone(id: "soft_piano",       name: "Soft Piano",       filename: "soft_piano.mp3",       bpm: 72,  mood: .gentle,    isDefault: false),
        Tone(id: "golden_hour",      name: "Golden Hour",      filename: "golden_hour.mp3",      bpm: 80,  mood: .uplifting, isDefault: false),
        Tone(id: "new_day",          name: "New Day",          filename: "new_day.mp3",          bpm: 90,  mood: .uplifting, isDefault: false),
        Tone(id: "rise_and_shine",   name: "Rise & Shine",     filename: "rise_and_shine.mp3",   bpm: 100, mood: .uplifting, isDefault: false),
        Tone(id: "morning_pulse",    name: "Morning Pulse",    filename: "morning_pulse.mp3",    bpm: 110, mood: .energetic, isDefault: false),
        Tone(id: "electric_dawn",    name: "Electric Dawn",    filename: "electric_dawn.mp3",    bpm: 125, mood: .energetic, isDefault: false),
    ]

    static func tone(id: String) -> Tone? {
        tones.first(where: { $0.id == id })
    }

    static var defaultTone: Tone {
        tones.first(where: { $0.isDefault }) ?? tones[0]
    }
}
