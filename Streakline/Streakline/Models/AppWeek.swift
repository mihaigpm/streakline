import Foundation
import SwiftData

/// One week of the Streakline programme. Week 1 is the first week of app use.
@Model
final class AppWeek {
    var weekNumber: Int = 1
    /// Monday of this week.
    var startDate: Date = Date.now
    /// Programme baseline selected during onboarding. Existing beta data defaults to 10.
    var startingDrinkBudget: Int = 10
    /// Unit snapshot for this week so history is never relabelled later.
    var drinkUnitRaw: String = DrinkUnit.pints.rawValue
    /// For Day C, tracks whether the *next* session is a run (true) or a circuit (false).
    var dayC_wasRun: Bool = true

    @Relationship(deleteRule: .cascade, inverse: \WorkoutLog.week)
    var workoutLogs: [WorkoutLog] = []

    @Relationship(deleteRule: .cascade, inverse: \DrinkLog.week)
    var drinkLogs: [DrinkLog] = []

    init(
        weekNumber: Int,
        startDate: Date,
        startingDrinkBudget: Int = 10,
        drinkUnit: DrinkUnit = .pints
    ) {
        self.weekNumber = weekNumber
        self.startDate = startDate
        self.startingDrinkBudget = startingDrinkBudget
        self.drinkUnitRaw = drinkUnit.rawValue
        self.dayC_wasRun = true
    }

    var drinkUnit: DrinkUnit {
        DrinkUnit(rawValue: drinkUnitRaw) ?? .pints
    }

    /// Max drinks allowed this week (in the user's chosen unit).
    /// Drops 1 every 2 weeks, floors at 5.
    var drinkBudget: Int {
        max(5, startingDrinkBudget - ((weekNumber - 1) / 2))
    }

    /// Sum of all logged drinks this week.
    var totalDrinks: Double {
        drinkLogs.reduce(0) { $0 + $1.amount }
    }

    /// Number of workouts marked complete this week.
    var completedWorkouts: Int {
        workoutLogs.filter(\.isCompleted).count
    }

    /// A week is fully complete when all 3 workouts are done and drinks are within budget.
    var isFullyComplete: Bool {
        completedWorkouts >= 3 && totalDrinks <= Double(drinkBudget)
    }

    /// Inclusive end date of the week (Sunday).
    var endDate: Date {
        Calendar.current.date(byAdding: .day, value: 6, to: startDate) ?? startDate
    }

    /// Fraction of drink budget consumed, clamped to [0, 1] for ring rendering.
    var drinkFraction: Double {
        guard drinkBudget > 0 else { return 0 }
        return min(1, totalDrinks / Double(drinkBudget))
    }

    var isOverBudget: Bool {
        totalDrinks > Double(drinkBudget)
    }

    var drinksRemaining: Double {
        max(0, Double(drinkBudget) - totalDrinks)
    }

    /// Fraction of workout target completed, [0, 1].
    var workoutFraction: Double {
        min(1, Double(completedWorkouts) / 3.0)
    }

    /// The persisted log for a given workout day, if it exists.
    func log(for day: WorkoutDay) -> WorkoutLog? {
        workoutLogs.first { $0.workoutDay == day }
    }
}
