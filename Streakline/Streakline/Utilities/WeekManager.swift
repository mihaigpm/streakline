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
            let first = AppWeek(weekNumber: 1, startDate: thisMonday)
            seedWorkouts(for: first, context: context)
            context.insert(first)
            try? context.save()
            return first
        }

        // If the latest week is in the past (its week has fully elapsed), advance.
        let calendar = Calendar.current
        let latestMonday = mondayOfWeek(for: latest.startDate)
        if thisMonday > latestMonday {
            let weeksElapsed = calendar.dateComponents([.weekOfYear], from: latestMonday, to: thisMonday).weekOfYear ?? 1
            let newWeek = AppWeek(weekNumber: latest.weekNumber + max(1, weeksElapsed), startDate: thisMonday)
            // Carry the Day C run/circuit alternation forward.
            newWeek.dayC_wasRun = latest.dayC_wasRun
            seedWorkouts(for: newWeek, context: context)
            context.insert(newWeek)
            try? context.save()
            return newWeek
        }

        return latest
    }

    /// Inserts the three workout placeholders for a fresh week.
    @MainActor
    private static func seedWorkouts(for week: AppWeek, context: ModelContext) {
        for day in WorkoutDay.allCases {
            let log = WorkoutLog(workoutDay: day)
            log.week = week
            week.workoutLogs.append(log)
            context.insert(log)
        }
    }

    /// Number of consecutive fully-complete weeks immediately before the current week.
    /// The current (in-progress) week never counts.
    @MainActor
    static func streak(in context: ModelContext, currentWeekNumber: Int) -> Int {
        let descriptor = FetchDescriptor<AppWeek>(
            sortBy: [SortDescriptor(\.weekNumber, order: .reverse)]
        )
        let weeks = (try? context.fetch(descriptor)) ?? []
        let byNumber = Dictionary(uniqueKeysWithValues: weeks.map { ($0.weekNumber, $0) })

        var streak = 0
        var n = currentWeekNumber - 1
        while n >= 1, let week = byNumber[n], week.isFullyComplete {
            streak += 1
            n -= 1
        }
        return streak
    }
}
