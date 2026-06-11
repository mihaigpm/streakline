import SwiftUI
import SwiftData

@main
struct StreaklineApp: App {
    let modelContainer: ModelContainer

    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @AppStorage("reminderTime") private var reminderTimeInterval: Double = 0

    init() {
        do {
            modelContainer = try ModelContainer(
                for: AppWeek.self, WorkoutLog.self, DrinkLog.self
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
                .preferredColorScheme(.dark)
                .task {
                    #if DEBUG
                    // Skip the permission prompt during UI verification deep-launches.
                    guard !ProcessInfo.processInfo.arguments.contains("-skip-notification-prompt") else { return }
                    #endif
                    _ = await NotificationManager.requestAuthorization()
                    await rescheduleReminder()
                }
        }
        .modelContainer(modelContainer)
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                Task { await rescheduleReminder() }
            }
        }
    }

    /// Keep the daily reminder's body text aligned with current week state.
    @MainActor
    private func rescheduleReminder() async {
        guard notificationsEnabled else { return }
        let week = WeekManager.currentWeek(in: modelContainer.mainContext)
        let state = NotificationManager.WeekState(
            completedWorkouts: week.completedWorkouts,
            totalDrinks: week.totalDrinks,
            drinkBudget: week.drinkBudget
        )
        let weeks = (try? modelContainer.mainContext.fetch(FetchDescriptor<AppWeek>())) ?? []
        let gamification = NotificationManager.GamificationContext(
            summary: Gamification.summary(for: weeks)
        )
        let time = reminderTimeInterval == 0
            ? defaultReminderTime()
            : Date(timeIntervalSinceReferenceDate: reminderTimeInterval)
        await NotificationManager.scheduleDailyReminder(
            enabled: true, at: time, state: state, gamification: gamification
        )
    }

    private func defaultReminderTime() -> Date {
        var comps = DateComponents()
        comps.hour = 8
        comps.minute = 0
        return Calendar.current.date(from: comps) ?? .now
    }
}
