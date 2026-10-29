import Foundation

/// What a week's logged drinks cost and contain, as a planning estimate.
///
/// The price list is rough 2026 UK averages for planning, not a till receipt.
/// A week is priced in the unit it was logged in. Training does not change the figures.
struct ReceiptEstimates: Equatable {
    /// Price and calories for one of the week's unit.
    struct Rate: Equatable {
        var price: Decimal
        var kcal: Int
    }

    /// Rough 2026 UK average for planning, not a till receipt.
    static let pint = Rate(price: pounds(550), kcal: 220)
    /// Rough 2026 UK average for planning, not a till receipt.
    static let ukUnit = Rate(price: pounds(240), kcal: 95)
    /// Rough 2026 UK average for planning, not a till receipt.
    static let standardDrink = Rate(price: pounds(600), kcal: 140)

    /// Shown on the estimate sheet. It carries no price and no calorie number.
    static let disclaimer = "Estimates use average pub prices and typical drink calories. They are not a measure of your night."

    var total: Double
    var unit: DrinkUnit
    /// Logged drinks times the price of this week's unit.
    var spent: Decimal
    /// Drinks still inside the budget, times the price. Zero when the week is over budget.
    var unspent: Decimal
    var kcal: Int
    /// Nil when every slot is complete.
    var sessionClause: String?

    /// The strip shows a line only after the first drink.
    var showsOnStrip: Bool { total > 0 }

    var amountText: String {
        "\(unit.format(total)) \(unit.noun(for: total))"
    }

    var spentText: String {
        "about \(Self.formatPounds(spent))"
    }

    var calorieText: String {
        "about \(Self.formatCalories(kcal)) kcal"
    }

    /// Amount, estimated spend, and estimated calories. The session clause is appended while a slot is open.
    var line: String {
        var text = "\(amountText) · \(spentText) · \(calorieText)"
        if let sessionClause {
            text += " · \(sessionClause)"
        }
        return text
    }

    /// Figures for `week`, computed from its logs. Nothing is stored.
    init(week: AppWeek, calendar: Calendar = .current) {
        let unit = week.drinkUnit
        let total = week.totalDrinks
        let rate = Self.rate(for: unit)
        self.total = total
        self.unit = unit
        self.spent = Self.money(amount: total, price: rate.price)
        self.unspent = Self.money(amount: max(0, week.drinksRemaining), price: rate.price)
        self.kcal = Self.calories(amount: total, each: rate.kcal)
        self.sessionClause = Self.sessionClause(for: week, calendar: calendar)
    }

    static func rate(for unit: DrinkUnit) -> Rate {
        switch unit {
        case .pints: pint
        case .units: ukUnit
        case .drinks: standardDrink
        }
    }

    /// Pounds from minor units. 550 is £5.50.
    private static func pounds(_ minorUnits: Int) -> Decimal {
        Decimal(sign: .plus, exponent: -2, significand: Decimal(minorUnits))
    }

    private static func quantity(_ amount: Double) -> Decimal {
        let hundredths = Int((amount * 100).rounded())
        let sign: FloatingPointSign = hundredths < 0 ? .minus : .plus
        return Decimal(sign: sign, exponent: -2, significand: Decimal(abs(hundredths)))
    }

    private static func money(amount: Double, price: Decimal) -> Decimal {
        rounded(quantity(amount) * price, scale: 2)
    }

    private static func calories(amount: Double, each: Int) -> Int {
        let whole = rounded(quantity(amount) * Decimal(each), scale: 0)
        return Int(truncating: whole as NSDecimalNumber)
    }

    private static func rounded(_ value: Decimal, scale: Int) -> Decimal {
        var input = value
        var output = Decimal()
        NSDecimalRound(&output, &input, scale, .plain)
        return output
    }

    static func formatPounds(_ value: Decimal) -> String {
        value.formatted(
            .currency(code: "GBP")
                .locale(Locale(identifier: "en_GB"))
                .precision(.fractionLength(2))
        )
    }

    static func formatCalories(_ value: Int) -> String {
        value.formatted(.number.grouping(.never).locale(Locale(identifier: "en_GB")))
    }

    /// The next open slot, named the way the card names it.
    ///
    /// Slots are not stored on calendar days. When a night plan has an amount and only one
    /// slot is open, that slot takes the weekday after the latest drink ("Saturday's long run
    /// is still open"). Several open slots make that day ambiguous, so the clause uses the
    /// first incomplete slot in Day A, B, C order and leaves the weekday off.
    private static func sessionClause(for week: AppWeek, calendar: Calendar) -> String? {
        let open = WorkoutDay.allCases.compactMap { day -> String? in
            let log = week.log(for: day)
            guard log?.isCompleted != true else { return nil }
            return log?.sessionTitle() ?? day.title
        }
        guard let first = open.first else { return nil }

        let hasPlannedNight = week.plannedAmounts.contains { $0 > 0 }
        let latestDrink = week.drinkLogs.filter { $0.amount > 0 }.map(\.date).max()
        if hasPlannedNight, open.count == 1, let latestDrink,
           let nextDay = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: latestDrink)) {
            let locale = calendar.locale ?? Locale(identifier: "en_GB")
            let weekday = nextDay.formatted(.dateTime.weekday(.wide).locale(locale))
            return "\(weekday)'s \(clauseName(first)) is still open"
        }
        return "\(first) is still open"
    }

    /// Lowercases the first letter so the name can follow a weekday.
    private static func clauseName(_ title: String) -> String {
        guard let first = title.first else { return title }
        return first.lowercased() + title.dropFirst()
    }
}
