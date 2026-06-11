import Foundation
import UserNotifications

/// Local-only daily reminder scheduling. No server involvement.
enum NotificationManager {

    static let dailyReminderID = "fittrack.daily.reminder"

    /// Snapshot of week state used to compose the reminder body.
    struct WeekState {
        let completedWorkouts: Int
        let totalDrinks: Double
        let drinkBudget: Int

        var isOverBudget: Bool { totalDrinks > Double(drinkBudget) }
    }

    /// Optional gamification flavour appended to the reminder body.
    struct GamificationContext {
        let xpToNextRank: Int?
        let nextRankName: String?

        init(summary: Gamification.Summary) {
            xpToNextRank = summary.xpToNextRank
            nextRankName = summary.nextRank?.name
        }
    }

    /// Request alert + sound permission. Safe to call repeatedly.
    static func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        do {
            return try await center.requestAuthorization(options: [.alert, .sound])
        } catch {
            return false
        }
    }

    /// (Re)schedule the daily reminder at the given time with state-aware copy.
    /// Pass `enabled = false` to cancel the reminder.
    static func scheduleDailyReminder(
        enabled: Bool,
        at time: Date,
        state: WeekState,
        gamification: GamificationContext? = nil
    ) async {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [dailyReminderID])

        guard enabled else { return }

        let settings = await center.notificationSettings()
        guard settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional else {
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "Time to move"
        content.body = body(for: state, gamification: gamification)
        content.sound = .default

        let comps = Calendar.current.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        let request = UNNotificationRequest(identifier: dailyReminderID, content: content, trigger: trigger)

        try? await center.add(request)
    }

    /// State-adaptive reminder body text, optionally tailed with XP motivation.
    static func body(
        for state: WeekState,
        unit: DrinkUnit = .current,
        gamification: GamificationContext? = nil
    ) -> String {
        var text: String
        if state.isOverBudget {
            text = "You're over your \(unit.noun(for: 1)) budget this week. No sweat, just stop here."
        } else {
            switch state.completedWorkouts {
            case 0:
                text = "You haven't trained yet this week. Day A is waiting."
            case 1, 2:
                let remaining = 3 - state.completedWorkouts
                let plural = remaining == 1 ? "workout" : "workouts"
                text = "Good start. \(remaining) \(plural) to go this week."
            default:
                text = "Workouts done. Now hold the line on \(unit.pluralNoun)."
            }
        }

        if let gamification,
           let xp = gamification.xpToNextRank,
           let next = gamification.nextRankName,
           xp > 0 {
            text += " \(xp) XP to \(next)."
        }
        return text
    }
}
