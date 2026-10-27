import Foundation
import SwiftData

/// Creates and advances `AppWeek` records, and derives streaks.
///
/// All methods are pure functions over a `ModelContext` so they can be called
/// from view `onAppear`/`task` blocks without holding extra state.
enum WeekManager {

    /// Returns the Monday (start of week) for a given date.
    static func mondayOfWeek(for date: Date, calendar: Calendar = .current) -> Date {
        let comps = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        let monday = calendar.date(from: comps) ?? calendar.startOfDay(for: date)
        return calendar.startOfDay(for: monday)
    }

    /// Fetches the active week, creating Week 1 or advancing to a new week as needed.
    @MainActor
    static func currentWeek(in context: ModelContext, now: Date = .now) -> AppWeek {
        let descriptor = FetchDescriptor<AppWeek>(
            sortBy: [SortDescriptor(\.weekNumber, order: .reverse)]
        )
        let weeks = (try? context.fetch(descriptor)) ?? []
        let thisMonday = mondayOfWeek(for: now)

        guard let latest = weeks.first else {
            // New weeks opt into the guideline floor. Rows already saved stay legacy.
            let first = AppWeek(
                weekNumber: 1,
                startDate: thisMonday,
                startingDrinkBudget: ProgramPreferences.startingBudget,
                drinkUnit: .current,
                budgetRule: .guideline
            )
            context.insert(first)
            seedWorkouts(for: first, context: context)
            try? context.save()
            return first
        }

        // If the latest week is in the past (its week has fully elapsed), advance.
        let calendar = Calendar.current
        let latestMonday = mondayOfWeek(for: latest.startDate)
        if thisMonday > latestMonday {
            settleShield(for: latest, in: context)
            let weeksElapsed = calendar.dateComponents([.weekOfYear], from: latestMonday, to: thisMonday).weekOfYear ?? 1
            let newWeek = AppWeek(
                weekNumber: latest.weekNumber + max(1, weeksElapsed),
                startDate: thisMonday,
                startingDrinkBudget: latest.startingDrinkBudget,
                drinkUnit: .current,
                budgetRule: .guideline
            )
            // Carry the Day C run/circuit alternation forward.
            newWeek.dayC_wasRun = latest.dayC_wasRun
            context.insert(newWeek)
            seedWorkouts(for: newWeek, context: context)
            try? context.save()
            return newWeek
        }

        return latest
    }

    /// Inserts the three workout placeholders for a fresh week.
    ///
    /// A stored programme preset copies its templates onto the new logs.
    /// No preset leaves `sessionTemplateRaw` empty, which keeps the legacy lists.
    /// A swap on an older week is not copied forward.
    @MainActor
    private static func seedWorkouts(for week: AppWeek, context: ModelContext) {
        let preset = ProgrammePreset.current
        for day in WorkoutDay.allCases {
            let templateRaw = preset?.templateID(for: day) ?? ""
            let log = WorkoutLog(workoutDay: day, sessionTemplateRaw: templateRaw)
            log.week = week
            week.workoutLogs.append(log)
            context.insert(log)
        }
    }

    /// Consecutive past weeks that hold the streak or spent a shield, immediately before the current week.
    /// The open week never counts. A missing week number stops the run.
    @MainActor
    static func streak(in context: ModelContext, currentWeekNumber: Int) -> Int {
        let descriptor = FetchDescriptor<AppWeek>(
            sortBy: [SortDescriptor(\.weekNumber, order: .reverse)]
        )
        let weeks = (try? context.fetch(descriptor)) ?? []
        let byNumber = Dictionary(uniqueKeysWithValues: weeks.map { ($0.weekNumber, $0) })

        var streak = 0
        var n = currentWeekNumber - 1
        while n >= 1, let week = byNumber[n], week.countsTowardStreak {
            streak += 1
            n -= 1
        }
        return streak
    }

    /// Grants or spends one shield for the week that just ended. The open week is left alone.
    /// A perfect week with an empty inventory earns the only shield. A miss spends it.
    /// The same week never does both.
    @MainActor
    private static func settleShield(for endedWeek: AppWeek, in context: ModelContext) {
        let stored = (try? context.fetch(FetchDescriptor<ProgrammeState>())) ?? []
        let available = stored.first?.shieldsAvailable ?? 0

        if endedWeek.isPerfectWeek && available == 0 {
            let state = stored.first ?? ProgrammeState()
            if stored.isEmpty {
                context.insert(state)
            }
            state.shieldsAvailable = 1
        } else if !endedWeek.holdsStreak, available > 0, !endedWeek.shieldUsed, let state = stored.first {
            endedWeek.shieldUsed = true
            state.shieldsAvailable = available - 1
        }
    }
}
