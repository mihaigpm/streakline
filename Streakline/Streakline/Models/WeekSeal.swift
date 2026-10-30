import Foundation

/// A read-only close of one week: slots, drinks, money not spent, and the streak result.
///
/// Nothing here is stored. Dismissing the seal does not mark the week sealed and does not award XP.
/// A shield that `WeekManager` will spend at rollover stays unspent while the week is still open.
struct WeekSeal: Equatable {
    /// How the week finished, or how the open week stands before rollover.
    enum Outcome: Equatable {
        /// Three slots, drinks at or under budget.
        case perfect
        /// Two slots, drinks at or under budget. Not a perfect week.
        case held
        /// `shieldUsed` is already set. The open week never gets this early.
        case shieldUsed
        /// The week neither held nor spent a shield.
        case missed
    }

    /// Shown instead of spending a shield on an open miss.
    static let shieldAppliesWhenTheWeekCloses = "Shield applies when the week closes"

    /// Slots in a week. The ring uses the same target.
    static let slotTarget = 3

    var weekNumber: Int
    var slotsCompleted: Int
    var drinks: Double
    var budget: Int
    var unit: DrinkUnit
    /// Estimated money still inside the budget. Nil when nothing is unspent, including over budget.
    var moneyNotSpent: Decimal?
    var outcome: Outcome
    /// Eight-week name for this week. Hold starts the week after the budget floor.
    var season: Season
    /// Season heading. “Season N, week X of 8”, or “Hold, week X of 8” once Hold has started.
    var title: String { season.heading }
    /// Set only for a missed open week that still has a shield.
    var closingNote: String?

    /// “2 of 3”.
    var slotsText: String {
        "\(slotsCompleted) of \(Self.slotTarget)"
    }

    /// Drinks against the budget, named in this week’s unit.
    var drinksText: String {
        "\(unit.format(drinks)) of \(budget) \(unit.noun(for: Double(budget)))"
    }

    /// “about £12.00 not spent”, or nil when `moneyNotSpent` is omitted.
    var moneyNotSpentText: String? {
        guard let moneyNotSpent else { return nil }
        return "about \(ReceiptEstimates.formatPounds(moneyNotSpent)) not spent"
    }

    /// The outcome in words. No rank, badge, or XP.
    var outcomeText: String {
        switch outcome {
        case .perfect: "Perfect week"
        case .held: "Streak held"
        case .shieldUsed: "Shield used"
        case .missed: "Missed"
        }
    }

    /// Home shows “Seal the week” on Sunday only.
    ///
    /// - Parameters:
    ///   - now: The moment Home is reading.
    ///   - calendar: Calendar whose weekday decides Sunday. Gregorian weekday 1 is Sunday.
    /// - Returns: True on Sunday, false on Wednesday and every other weekday.
    static func showsOnHome(now: Date, calendar: Calendar = .current) -> Bool {
        isSunday(now, calendar: calendar)
    }

    /// A week that started before the week containing `now`.
    ///
    /// History opens the seal for these. The open week, including on Sunday, is not past.
    static func isPastWeek(_ week: AppWeek, now: Date, calendar: Calendar = .current) -> Bool {
        let openStart = WeekManager.mondayOfWeek(for: now, calendar: calendar)
        let weekStart = WeekManager.mondayOfWeek(for: week.startDate, calendar: calendar)
        return weekStart < openStart
    }

    /// Summary of `week` as it stands at `now`. Does not write `shieldUsed` or any other field.
    ///
    /// - Parameters:
    ///   - week: The week being summarised.
    ///   - now: The moment Home or History is reading. Sunday still decides whether Home shows the button. The heading is the season on every day.
    ///   - calendar: Calendar for Sunday and for the receipt’s session clause. Money uses the same estimates as the strip.
    ///   - isOpenWeek: True for the week Home is showing. False for a past week in History.
    ///   - shieldAvailable: True when a shield is still in inventory. It is not spent here.
    ///   - history: Saved weeks. Hold starts only after an earlier one already sat on this floor.
    init(
        week: AppWeek,
        now _: Date,
        calendar: Calendar = .current,
        isOpenWeek: Bool,
        shieldAvailable: Bool,
        history: [AppWeek] = []
    ) {
        weekNumber = week.weekNumber
        slotsCompleted = week.completedWorkouts
        drinks = week.totalDrinks
        budget = week.drinkBudget
        unit = week.drinkUnit
        let unspent = ReceiptEstimates(week: week, calendar: calendar).unspent
        moneyNotSpent = unspent > 0 ? unspent : nil
        outcome = Self.outcome(for: week)
        season = Season(week: week, history: history)
        if isOpenWeek, outcome == .missed, shieldAvailable {
            closingNote = Self.shieldAppliesWhenTheWeekCloses
        } else {
            closingNote = nil
        }
    }

    /// Perfect, then a spent shield, then a held week, otherwise a miss.
    ///
    /// A perfect week is not relabelled as held. An open miss stays missed until rollover sets `shieldUsed`.
    static func outcome(for week: AppWeek) -> Outcome {
        if week.isPerfectWeek { return .perfect }
        if week.shieldUsed { return .shieldUsed }
        if week.holdsStreak { return .held }
        return .missed
    }

    /// Gregorian Sunday. `Calendar.firstWeekday` does not change this number.
    private static func isSunday(_ date: Date, calendar: Calendar) -> Bool {
        calendar.component(.weekday, from: date) == 1
    }
}
