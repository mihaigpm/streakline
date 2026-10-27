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
    /// True after a saved night plan. False uses the Friday and Saturday default.
    var planCustomized: Bool = false
    /// Monday amount in this week's unit. -1 means use the default.
    var plannedMonday: Double = -1
    /// Tuesday amount in this week's unit. -1 means use the default.
    var plannedTuesday: Double = -1
    /// Wednesday amount in this week's unit. -1 means use the default.
    var plannedWednesday: Double = -1
    /// Thursday amount in this week's unit. -1 means use the default.
    var plannedThursday: Double = -1
    /// Friday amount in this week's unit. -1 means use the default.
    var plannedFriday: Double = -1
    /// Saturday amount in this week's unit. -1 means use the default.
    var plannedSaturday: Double = -1
    /// Sunday amount in this week's unit. -1 means use the default.
    var plannedSunday: Double = -1

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
        self.planCustomized = false
        self.plannedMonday = -1
        self.plannedTuesday = -1
        self.plannedWednesday = -1
        self.plannedThursday = -1
        self.plannedFriday = -1
        self.plannedSaturday = -1
        self.plannedSunday = -1
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

    /// Result of trying to move the night plan by one step.
    struct PlanAdjustment: Equatable {
        var amounts: [Double]
        /// Unplaced budget when the extra was refused. Nil when the change landed.
        var refusedUnplaced: Double?
    }

    /// Monday-through-Sunday amounts in this week's unit.
    /// A fresh week puts the budget on Friday and Saturday. A saved plan uses the stored nights, including zeros.
    var plannedAmounts: [Double] {
        guard planCustomized else { return defaultPlan }
        return [
            plannedMonday, plannedTuesday, plannedWednesday, plannedThursday,
            plannedFriday, plannedSaturday, plannedSunday,
        ].map { $0 < 0 ? 0 : $0 }
    }

    /// Moves `delta` onto `night` (0 is Monday). A step that would pass the budget is refused whole.
    /// Does not change `drinkBudget` or the saved plan.
    func adjusting(_ amounts: [Double], by delta: Double, onNight night: Int) -> PlanAdjustment {
        guard amounts.count == 7, (0..<7).contains(night) else {
            return PlanAdjustment(amounts: amounts, refusedUnplaced: nil)
        }
        if delta <= 0 {
            var next = amounts
            next[night] = max(0, next[night] + delta)
            return PlanAdjustment(amounts: next, refusedUnplaced: nil)
        }
        let budget = Double(drinkBudget)
        let placed = amounts.reduce(0, +)
        if placed + delta > budget + 0.000_001 {
            return PlanAdjustment(amounts: amounts, refusedUnplaced: max(0, budget - placed))
        }
        var next = amounts
        next[night] += delta
        return PlanAdjustment(amounts: next, refusedUnplaced: nil)
    }

    /// Saves a plan that stays at or under the budget. A plan over the budget is left unsaved.
    func saveCustomPlan(_ amounts: [Double]) {
        guard amounts.count == 7 else { return }
        let cleaned = amounts.map { max(0, $0) }
        guard cleaned.reduce(0, +) <= Double(drinkBudget) + 0.000_001 else { return }
        plannedMonday = cleaned[0]
        plannedTuesday = cleaned[1]
        plannedWednesday = cleaned[2]
        plannedThursday = cleaned[3]
        plannedFriday = cleaned[4]
        plannedSaturday = cleaned[5]
        plannedSunday = cleaned[6]
        planCustomized = true
    }

    /// Clears a saved plan so Friday and Saturday share the budget again.
    func resetPlanToWeekend() {
        planCustomized = false
        plannedMonday = -1
        plannedTuesday = -1
        plannedWednesday = -1
        plannedThursday = -1
        plannedFriday = -1
        plannedSaturday = -1
        plannedSunday = -1
    }

    /// How much of the budget is still unplaced, in this week's unit.
    func planLimitMessage(unplaced: Double) -> String {
        "\(drinkUnit.format(unplaced)) \(drinkUnit.noun(for: unplaced)) left"
    }

    /// Friday and Saturday split the budget in `DrinkUnit.step` increments.
    /// Saturday keeps the leftover step when the two nights cannot match.
    private var defaultPlan: [Double] {
        let step = drinkUnit.step
        guard drinkBudget > 0, step > 0 else {
            return [0, 0, 0, 0, 0, 0, 0]
        }
        let steps = Int((Double(drinkBudget) / step).rounded())
        let friday = Double(steps / 2) * step
        let saturday = Double(drinkBudget) - friday
        return [0, 0, 0, 0, friday, saturday, 0]
    }
}
