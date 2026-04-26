import Foundation
import CoreNFC
import Combine

// OPEN QUESTION: Can NFC be detected from lock screen on iOS 17?
// As of iOS 17, background NFC tag reading requires the app to be in the foreground.
// Background tag reading via NFCTagReaderSession is restricted; the user must open the
// app first. Consider using a Today widget or Action extension as a workaround.
// Ticket: open with UX team before v1 launch.

final class NFCSessionManager: NSObject, NFCHandlerProtocol {

    private let pairingStateSubject = CurrentValueSubject<PairingState, Never>(.idle)
    var pairingStatePublisher: AnyPublisher<PairingState, Never> { pairingStateSubject.eraseToAnyPublisher() }

    private var activeContinuation: CheckedContinuation<String, Error>?
    private var dismissContinuation: CheckedContinuation<Void, Error>?
    private var expectedDismissTagID: String?
    private var pendingAlarmID: UUID?

    private var readerSession: NFCNDEFReaderSession?

    // MARK: - Pairing

    func beginPairingSession(for alarmID: UUID) async throws -> String {
        guard NFCNDEFReaderSession.readingAvailable else {
            throw NFCError.nfcUnavailable
        }
        pendingAlarmID = alarmID
        pairingStateSubject.send(.scanning)

        return try await withCheckedThrowingContinuation { continuation in
            self.activeContinuation = continuation
            let session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
            session.alertMessage = "Hold your iPhone near the sticker to pair it."
            self.readerSession = session
            session.begin()
        }
    }

    // MARK: - Dismiss

    func beginDismissSession(expectedTagID: String) async throws {
        guard NFCNDEFReaderSession.readingAvailable else {
            throw NFCError.nfcUnavailable
        }
        expectedDismissTagID = expectedTagID
        pairingStateSubject.send(.scanning)

        return try await withCheckedThrowingContinuation { continuation in
            self.dismissContinuation = continuation
            let session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
            session.alertMessage = "Hold your iPhone near your Rise sticker."
            self.readerSession = session
            session.begin()
        }
    }

    // OPEN QUESTION: UX flow for users traveling without their sticker
    // TODO: Implement a fallback dismiss flow (e.g. math puzzle, shake gesture, passcode)
    // coordinated with the UX team. For now this is a no-op stub.
    func activateFallbackDismiss() {
        // TODO: implement fallback dismiss
    }
}

// MARK: - NFCNDEFReaderSessionDelegate
extension NFCSessionManager: NFCNDEFReaderSessionDelegate {

    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {}

    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        if let continuation = activeContinuation {
            activeContinuation = nil
            let nfcCode = (error as? NFCReaderError)?.code
            if nfcCode == .readerSessionInvalidationErrorUserCanceled {
                continuation.resume(throwing: NFCError.noTagDetected)
            } else {
                continuation.resume(throwing: NFCError.writeFailed(underlying: error.localizedDescription))
            }
        }
        if let continuation = dismissContinuation {
            dismissContinuation = nil
            continuation.resume(throwing: NFCError.noTagDetected)
        }
        pairingStateSubject.send(.idle)
    }

    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        // This delegate is used for read-only sessions. For writing we use didDetect tags below.
        guard let dismissContinuation else { return }

        // Read the tag ID from the first record payload
        guard let record = messages.first?.records.first,
              let payload = String(data: record.payload, encoding: .utf8) else {
            self.dismissContinuation = nil
            dismissContinuation.resume(throwing: NFCError.noTagDetected)
            return
        }

        let expected = expectedDismissTagID ?? ""
        if payload == expected {
            self.dismissContinuation = nil
            session.invalidate()
            pairingStateSubject.send(.idle)
            dismissContinuation.resume()
        } else {
            self.dismissContinuation = nil
            session.invalidate(errorMessage: "Wrong sticker — please use your Rise sticker.")
            pairingStateSubject.send(.error(.wrongTag(expected: expected, found: payload)))
            dismissContinuation.resume(throwing: NFCError.wrongTag(expected: expected, found: payload))
        }
    }

    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        guard let tag = tags.first else {
            session.invalidate(errorMessage: "No tag detected.")
            activeContinuation?.resume(throwing: NFCError.noTagDetected)
            activeContinuation = nil
            return
        }

        session.connect(to: tag) { [weak self] error in
            guard let self else { return }
            if let error {
                session.invalidate(errorMessage: "Connection failed.")
                self.activeContinuation?.resume(throwing: NFCError.writeFailed(underlying: error.localizedDescription))
                self.activeContinuation = nil
                return
            }

            let tagID = UUID().uuidString
            self.pairingStateSubject.send(.writing)

            let payload = NFCNDEFPayload(
                format: .unknown,
                type: Data(),
                identifier: Data(),
                payload: tagID.data(using: .utf8)!
            )
            let message = NFCNDEFMessage(records: [payload])

            tag.writeNDEF(message) { [weak self] writeError in
                guard let self else { return }
                if let writeError {
                    session.invalidate(errorMessage: "Write failed. Try again.")
                    self.pairingStateSubject.send(.error(.writeFailed(underlying: writeError.localizedDescription)))
                    self.activeContinuation?.resume(throwing: NFCError.writeFailed(underlying: writeError.localizedDescription))
                } else {
                    session.alertMessage = "Sticker paired! ✓"
                    session.invalidate()
                    self.pairingStateSubject.send(.success(tagID: tagID))
                    self.activeContinuation?.resume(returning: tagID)
                }
                self.activeContinuation = nil
            }
        }
    }
}
