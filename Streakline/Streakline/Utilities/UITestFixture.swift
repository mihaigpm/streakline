import Foundation
import SwiftData

/// Deterministic app state for UI tests and simulator screenshots.
///
/// Debug builds only. Pass `-ui-fixture` and one of `home`, `workout`, `progress`, or `onboarding`.
/// The store and the programme preferences are replaced. A normal launch never reads this.
/// Release builds omit it, so an App Store binary cannot be switched into a fixture.
#if DEBUG
@MainActor
enum UITestFixture {
    static let argument = "-ui-fixture"

    /// A named scene. The raw value is the launch argument.
    enum Scene: String, CaseIterable {
        case home
        case workout
        case progress
        case onboarding
    }

    enum Failure: Error, CustomStringConvertible {
        case unknownScene(String)

        var description: String {
            switch self {
            case .unknownScene(let name):
                "Unknown UI fixture “\(name)”. Use home, workout, progress, or onboarding."
            }
        }
    }

    /// Applies the fixture named on the process arguments. Does nothing when the argument is absent.
    static func applyIfRequested(
        in context: ModelContext,
        arguments: [String] = ProcessInfo.processInfo.arguments,
        now: Date = .now
    ) throws {
        guard let index = arguments.firstIndex(of: argument) else { return }
        let name = index + 1 < arguments.count ? arguments[index + 1] : ""
        guard let scene = Scene(rawValue: name) else { throw Failure.unknownScene(name) }
        try apply(scene, in: context, now: now)
    }

    /// Replaces saved weeks and programme preferences with `scene`.
    static func apply(_ scene: Scene, in context: ModelContext, now: Date = .now) throws {
        let stored = try context.fetch(FetchDescriptor<AppWeek>())
        try AppDataManager.eraseAll(stored, in: context)
        resetPreferences()

        switch scene {
        case .onboarding:
            return
        case .home:
            insertWeek(number: 1, weeksAgo: 0, completed: [.dayA], drinks: 2, now: now, in: context)
        case .workout:
            insertWeek(number: 1, weeksAgo: 0, completed: [], drinks: 2, now: now, in: context)
        case .progress:
            insertWeek(number: 1, weeksAgo: 2, completed: Set(WorkoutDay.allCases), drinks: 0, now: now, in: context)
            insertWeek(number: 2, weeksAgo: 1, completed: Set(WorkoutDay.allCases), drinks: 0, now: now, in: context)
            insertWeek(number: 3, weeksAgo: 0, completed: [.dayA], drinks: 2, now: now, in: context)
        }

        let defaults = UserDefaults.standard
        defaults.set(true, forKey: ProgramPreferences.onboardingCompletedKey)
        defaults.set(10, forKey: ProgramPreferences.startingBudgetKey)
        defaults.set(DrinkUnit.pints.rawValue, forKey: DrinkUnit.storageKey)
        defaults.set(ProgrammePreset.running.rawValue, forKey: ProgrammePreset.storageKey)
        defaults.set(false, forKey: notificationsKey)
        let weeks = try context.fetch(FetchDescriptor<AppWeek>())
        let rankIndex = Gamification.summary(for: weeks, now: now).rankIndex
        defaults.set(rankIndex, forKey: celebratedRankKey)
        try context.save()
    }

    private static let notificationsKey = "notificationsEnabled"
    private static let reminderKey = "reminderTime"
    private static let celebratedRankKey = "lastCelebratedRankIndex"

    private static func resetPreferences() {
        let defaults = UserDefaults.standard
        for key in [
            ProgramPreferences.onboardingCompletedKey,
            ProgramPreferences.startingBudgetKey,
            DrinkUnit.storageKey,
            ProgrammePreset.storageKey,
            notificationsKey,
            reminderKey,
            celebratedRankKey,
        ] {
            defaults.removeObject(forKey: key)
        }
    }

    /// One guideline pint week on the running preset. `weeksAgo` 0 is the week that contains `now`.
    private static func insertWeek(
        number: Int,
        weeksAgo: Int,
        completed: Set<WorkoutDay>,
        drinks: Double,
        now: Date,
        in context: ModelContext
    ) {
        let calendar = Calendar.current
        let open = WeekManager.mondayOfWeek(for: now, calendar: calendar)
        let start = calendar.date(byAdding: .weekOfYear, value: -weeksAgo, to: open) ?? open
        let week = AppWeek(
            weekNumber: number,
            startDate: start,
            startingDrinkBudget: 10,
            drinkUnit: .pints,
            budgetRule: .guideline
        )
        context.insert(week)
        for day in WorkoutDay.allCases {
            let done = completed.contains(day)
            let log = WorkoutLog(
                workoutDay: day,
                isCompleted: done,
                sessionTemplateRaw: ProgrammePreset.running.templateID(for: day)
            )
            if done {
                log.completedAt = start
            }
            log.week = week
            week.workoutLogs.append(log)
            context.insert(log)
        }
        if drinks > 0 {
            let drink = DrinkLog(date: now, amount: drinks)
            drink.week = week
            week.drinkLogs.append(drink)
            context.insert(drink)
        }
    }
}
#endif
