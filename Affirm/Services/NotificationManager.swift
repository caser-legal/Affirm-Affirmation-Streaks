import Foundation
import UserNotifications
import SwiftUI
import Observation

@Observable @MainActor class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    var pendingAffirmationID: UUID?
    
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if let idString = response.notification.request.content.userInfo["affirmationID"] as? String,
           let id = UUID(uuidString: idString) {
            Task { @MainActor in
                self.pendingAffirmationID = id
            }
        }
        completionHandler()
    }
    
    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
    
    func clearNotifications() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().setBadgeCount(0)
    }
}
