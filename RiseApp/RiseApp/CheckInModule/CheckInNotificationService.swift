import Foundation
import UserNotifications

/// Manages the full-screen notification shown when the check-in window is active
/// and the app is backgrounded.
final class CheckInNotificationService {
    static let categoryID = "CHECK_IN"

    static func registerCategory() {
        let confirmAction = UNNotificationAction(
            identifier: "CONFIRM_AWAKE",
            title: "I'm Up! ☀️",
            options: [.foreground]
        )
        let category = UNNotificationCategory(
            identifier: categoryID,
            actions: [confirmAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
}
