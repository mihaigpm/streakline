import SwiftUI
import SwiftData

@main
struct StreaklineApp: App {
    let modelContainer: ModelContainer
    let storageUnavailable: Bool

    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @AppStorage("reminderTime") private var reminderTimeInterval: Double = 0

    init() {
        do {
            modelContainer = try ModelContainer(
                for: AppWeek.self, WorkoutLog.self, DrinkLog.self
            )
            storageUnavailable = false
        } catch {
            do {
                let fallback = ModelConfiguration(isStoredInMemoryOnly: true)
                modelContainer = try ModelContainer(
                    for: AppWeek.self, WorkoutLog.self, DrinkLog.self,
                    configurations: fallback
                )
                storageUnavailable = true
            } catch {
                fatalError("Failed to create fallback ModelContainer: \(error)")
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            AppRootView(storageUnavailable: storageUnavailable) {
                await rescheduleReminder()
            }
                .preferredColorScheme(.dark)
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
        guard notificationsEnabled,
              UserDefaults.standard.bool(forKey: ProgramPreferences.onboardingCompletedKey) else { return }
        let week = WeekManager.currentWeek(in: modelContainer.mainContext)
        let state = NotificationManager.WeekState(
            completedWorkouts: week.completedWorkouts,
            totalDrinks: week.totalDrinks,
            drinkBudget: week.drinkBudget,
            drinkUnit: week.drinkUnit
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

private struct AppRootView: View {
    let storageUnavailable: Bool
    let onReady: @MainActor () async -> Void

    @Environment(\.modelContext) private var context
    @Query(sort: \AppWeek.weekNumber) private var weeks: [AppWeek]
    @AppStorage(ProgramPreferences.onboardingCompletedKey) private var hasCompletedOnboarding = false

    var body: some View {
        Group {
            if storageUnavailable {
                StorageUnavailableView()
            } else if hasCompletedOnboarding || !weeks.isEmpty || shouldSkipOnboarding {
                HomeView()
                    .task {
                        migrateBetaPreferencesIfNeeded()
                        await onReady()
                    }
            } else {
                OnboardingView {
                    hasCompletedOnboarding = true
                }
            }
        }
    }

    /// Existing TestFlight users keep their programme baseline and current unit.
    private func migrateBetaPreferencesIfNeeded() {
        #if DEBUG
        if shouldSkipOnboarding { return }
        #endif
        guard !hasCompletedOnboarding, !weeks.isEmpty else { return }
        for week in weeks {
            week.drinkUnitRaw = DrinkUnit.current.rawValue
        }
        try? context.save()
        hasCompletedOnboarding = true
    }

    private var shouldSkipOnboarding: Bool {
        #if DEBUG
        ProcessInfo.processInfo.arguments.contains("-skip-onboarding")
        #else
        false
        #endif
    }
}

private struct StorageUnavailableView: View {
    var body: some View {
        ContentUnavailableView {
            Label("Storage unavailable", systemImage: "externaldrive.badge.exclamationmark")
        } description: {
            Text("Streakline couldn't safely open your local data. Restart the app and contact support if this continues.")
        } actions: {
            Link("Contact Support", destination: URL(string: "mailto:support@streakline.fit")!)
        }
    }
}
