import Foundation
import Combine

// MARK: - Pairing state
enum PairingState: Equatable {
    case idle
    case scanning
    case writing
    case success(tagID: String)
    case error(NFCError)
}

// MARK: - Error types
enum NFCError: Error, Equatable {
    case wrongTag(expected: String, found: String)
    case noTagDetected
    case nfcUnavailable
    case writeFailed(underlying: String)  // String for Equatable conformance
}

// MARK: - Public protocol
protocol NFCHandlerProtocol: AnyObject {
    /// Begin a pairing session — writes a unique UUID to a blank NFC sticker.
    func beginPairingSession(for alarmID: UUID) async throws -> String  // returns tag ID written

    /// Begin a dismiss session — reads the tag and verifies it matches expectedTagID.
    func beginDismissSession(expectedTagID: String) async throws

    var pairingStatePublisher: AnyPublisher<PairingState, Never> { get }

    // OPEN QUESTION: UX flow for users traveling without their sticker
    func activateFallbackDismiss()
}
