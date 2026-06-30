import Foundation

enum ToneMood: String, Codable, CaseIterable {
    case gentle
    case uplifting
    case energetic
}

struct Tone: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let filename: String     // replace with real audio file names before shipping
    let bpm: Int?
    let mood: ToneMood
    let isDefault: Bool
}

// MARK: - Public protocol
protocol AudioLibraryProtocol: AnyObject {
    var allTones: [Tone] { get }
    var dailyTone: Tone { get }

    func previewTone(_ toneID: String)
    func stopPreview()

    func beginAlarmPlayback(toneID: String, targetVolume: Float)
    func rampVolume(to level: Float, over duration: TimeInterval)
    func stopAlarmPlayback()
}
