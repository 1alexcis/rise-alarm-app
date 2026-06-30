import Foundation
import Combine

/// High-level coordinator: pairs a sticker, saves the tag ID to DataLayer,
/// and updates the alarm's linkedNFCTagID.
final class StickerPairingService {
    private let nfcHandler: any NFCHandlerProtocol
    private let dataLayer: any DataLayerProtocol

    init(nfcHandler: any NFCHandlerProtocol, dataLayer: any DataLayerProtocol) {
        self.nfcHandler = nfcHandler
        self.dataLayer = dataLayer
    }

    /// Pairs a sticker and updates the alarm in persistent storage.
    /// Returns the written tag ID on success.
    func pairSticker(for alarm: AlarmModel) async throws -> String {
        let tagID = try await nfcHandler.beginPairingSession(for: alarm.id)
        var updated = alarm
        updated.linkedNFCTagID = tagID
        try dataLayer.saveAlarm(updated)
        return tagID
    }
}
