import Foundation
import SwiftData

/// Which floor a saved week uses. Stored as a string so rows written before
/// this property existed migrate to the old floor without a rewrite.
enum BudgetRule: String {
    /// Floors at 5 of the week's unit. The default for missing values.
    case legacy
    /// Floors at the UK guideline in the week's unit. WeekManager sets this on new weeks.
    case guideline
}

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
    /// "legacy" keeps the old floor of 5. "guideline" uses the UK low-risk floor.
    /// Omitted values migrate as legacy so a saved week does not change.
    var budgetRuleRaw: String = "legacy"
    /// For Day C, tracks whether the *next* session is a run (true) or a circuit (false).
    var dayC_wasRun: Bool = true
    /// Set when a shield covered this week as it ended. Never set on the open week.
    var shieldUsed: Bool = false

    @Relationship(deleteRule: .cascade, inverse: \WorkoutLog.week)
    var workoutLogs: [WorkoutLog] = []

    @Relationship(deleteRule: .cascade, inverse: \DrinkLog.week)
    var drinkLogs: [DrinkLog] = []

    init(
        weekNumber: Int,
        startDate: Date,
        startingDrinkBudget: Int = 10,
        drinkUnit: DrinkUnit = .pints,
        budgetRule: BudgetRule = .legacy
    ) {
        self.weekNumber = weekNumber
        self.startDate = startDate
        self.startingDrinkBudget = startingDrinkBudget
        self.drinkUnitRaw = drinkUnit.rawValue
        self.budgetRuleRaw = budgetRule.rawValue
        self.dayC_wasRun = true
    }

    var drinkUnit: DrinkUnit {
        DrinkUnit(rawValue: drinkUnitRaw) ?? .pints
    }

    /// Missing or unknown values stay on the legacy floor.
    var budgetRule: BudgetRule {
        BudgetRule(rawValue: budgetRuleRaw) ?? .legacy
    }

    /// Max drinks allowed this week, in this week's unit.
    /// Drops by 1 of that unit every 2 weeks.
    /// Legacy weeks floor at 5. Guideline weeks floor at the UK guideline
    /// in the week's unit, and a starting budget already under that floor is left there.
    var drinkBudget: Int {
        let tapered = startingDrinkBudget - ((weekNumber - 1) / 2)
        switch budgetRule {
        case .legacy:
            return max(5, tapered)
        case .guideline:
            let displayFloor = AlcoholUnits.displayFloor(for: drinkUnit)
            let floor = min(startingDrinkBudget, displayFloor)
            return max(floor, tapered)
        }
    }

    /// Sum of all logged drinks this week.
    var totalDrinks: Double {
        drinkLogs.reduce(0) { $0 + $1.amount }
    }

    /// Number of workouts marked complete this week.
    var completedWorkouts: Int {
        workoutLogs.filter(\.isCompleted).count
    }

    /// Two sessions and drinks at or under budget. Holds a streak. Does not earn perfect-week XP or a shield.
    var holdsStreak: Bool {
        completedWorkouts >= 2 && totalDrinks <= Double(drinkBudget)
    }

    /// Three sessions and drinks at or under budget. The only way to earn a shield, and the only perfect-week XP.
    var isPerfectWeek: Bool {
        completedWorkouts >= 3 && totalDrinks <= Double(drinkBudget)
    }

    /// Perfect week. The name stays so older call sites still mean three sessions, not two.
    var isFullyComplete: Bool {
        isPerfectWeek
    }

    /// Keeps a streak when two sessions stayed under budget, or a shield was spent on a miss.
    var countsTowardStreak: Bool {
        holdsStreak || shieldUsed
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
