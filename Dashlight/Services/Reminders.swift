import Foundation
import UserNotifications

/// Local reminders. No server, no account.
enum Reminders {
    struct Pending: Identifiable {
        let id: String
        let title: String
        let body: String
        let date: Date?
    }

    @discardableResult
    static func requestAuthorization() async -> Bool {
        (try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])) ?? false
    }

    /// Schedules a one-off reminder at a date and hour. Replaces any reminder with the same id.
    static func schedule(id: String, title: String, body: String, on date: Date, hour: Int = 9) async {
        guard await requestAuthorization() else { return }
        var comps = Calendar.current.dateComponents([.year, .month, .day], from: date)
        comps.hour = hour
        comps.minute = 0

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [id])
        try? await center.add(request)
    }

    static func pending() async -> [Pending] {
        let requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        return requests
            .map { request in
                let date = (request.trigger as? UNCalendarNotificationTrigger)?.nextTriggerDate()
                return Pending(id: request.identifier, title: request.content.title, body: request.content.body, date: date)
            }
            .sorted { ($0.date ?? .distantFuture) < ($1.date ?? .distantFuture) }
    }

    static func cancel(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }
}
