import Foundation
import AVFoundation

/// Concrete AVFoundation-backed audio player for alarm tones.
final class AudioPlayer: AudioLibraryProtocol {

    var allTones: [Tone] { ToneLibrary.tones }

    var dailyTone: Tone { DailyRotationScheduler.toneForToday(from: ToneLibrary.tones) }

    private var alarmPlayer: AVAudioPlayer?
    private var previewPlayer: AVAudioPlayer?

    init() {
        configureAudioSession()
        registerForInterruptions()
    }

    // MARK: - Preview

    func previewTone(_ toneID: String) {
        stopPreview()
        guard let tone = ToneLibrary.tone(id: toneID),
              let url = Bundle.main.url(forResource: tone.filename, withExtension: nil) else {
            // Replace with real assets — stub silently fails
            return
        }
        previewPlayer = try? AVAudioPlayer(contentsOf: url)
        previewPlayer?.numberOfLoops = 0
        previewPlayer?.volume = 0.7
        previewPlayer?.play()
    }

    func stopPreview() {
        previewPlayer?.stop()
        previewPlayer = nil
    }

    // MARK: - Alarm playback

    func beginAlarmPlayback(toneID: String, targetVolume: Float) {
        stopAlarmPlayback()
        guard let tone = ToneLibrary.tone(id: toneID),
              let url = Bundle.main.url(forResource: tone.filename, withExtension: nil) else {
            return
        }
        alarmPlayer = try? AVAudioPlayer(contentsOf: url)
        alarmPlayer?.numberOfLoops = -1   // loop indefinitely
        alarmPlayer?.volume = VolumeRampController.startFraction * targetVolume
        alarmPlayer?.prepareToPlay()
        alarmPlayer?.play()
        rampVolume(to: targetVolume, over: VolumeRampController.rampDuration)
    }

    func rampVolume(to level: Float, over duration: TimeInterval) {
        alarmPlayer?.setVolume(level, fadeDuration: duration)
    }

    func stopAlarmPlayback() {
        alarmPlayer?.stop()
        alarmPlayer = nil
    }

    // MARK: - Audio session

    private func configureAudioSession() {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    private func registerForInterruptions() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInterruption),
            name: AVAudioSession.interruptionNotification,
            object: nil
        )
    }

    @objc private func handleInterruption(_ notification: Notification) {
        guard let info = notification.userInfo,
              let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else { return }

        switch type {
        case .began:
            // Phone call or other audio took over — alarm paused
            alarmPlayer?.pause()
        case .ended:
            // Resume alarm if alarm was active (interruption ended, e.g. call finished)
            if let options = info[AVAudioSessionInterruptionOptionKey] as? UInt,
               AVAudioSession.InterruptionOptions(rawValue: options).contains(.shouldResume) {
                try? AVAudioSession.sharedInstance().setActive(true)
                alarmPlayer?.play()
            }
        @unknown default:
            break
        }
    }
}
