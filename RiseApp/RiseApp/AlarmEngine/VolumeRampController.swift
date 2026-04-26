import Foundation
import AVFoundation

/// Gradually ramps system volume from startFraction to targetVolume over rampDuration seconds.
/// Actual volume ramp is delegated to AudioLibrary; this class drives the timing signal.
final class VolumeRampController {
    static let rampDuration: TimeInterval = 30
    static let startFraction: Float = 0.2    // start at 20% of target volume

    private var timer: Timer?
    private var elapsed: TimeInterval = 0
    private let tickInterval: TimeInterval = 0.5

    var onTick: ((Float) -> Void)?  // called with current volume fraction (0–1)
    var onComplete: (() -> Void)?

    func start(targetVolume: Float) {
        elapsed = 0
        timer = Timer.scheduledTimer(withTimeInterval: tickInterval, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.elapsed += self.tickInterval
            let progress = Float(min(self.elapsed / Self.rampDuration, 1.0))
            let current = Self.startFraction + (targetVolume - Self.startFraction) * progress
            self.onTick?(current)
            if progress >= 1.0 {
                self.timer?.invalidate()
                self.onComplete?()
            }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }
}
