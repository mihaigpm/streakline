import Foundation

/// This week’s logged drinks and slots against week 1.
///
/// Amounts stay in each week’s own unit. The figures here are UK units, rounded to a tenth.
/// A drop is not a health score. A rise is shown the same way.
struct MonthComparison: Equatable {
    /// UK units logged in week 1. Zero when that week is missing.
    var firstWeekUnits: Double
    /// UK units logged in the latest week.
    var currentWeekUnits: Double
    /// Current minus week 1. Negative means the latest week logged less.
    var unitDelta: Double
    /// Completed slots in week 1.
    var firstWeekSlots: Int
    /// Completed slots in the latest week.
    var currentWeekSlots: Int
    /// True from week 2 onward, once week 1 is in the store.
    var showsComparison: Bool
    /// True when the two weeks were logged in different display units.
    var unitsDiffer: Bool

    static let baselineSentence = "Your first week is the baseline. The comparison shows from week 2."
    static let comparisonTitle = "This week vs week 1"
    static let mixedUnitFootnote = "Compared in UK units so the two weeks mean the same thing."
    static let logNote = "This is your log, not a health score."
    static let slotsInAWeek = 3

    /// “Down 9.2 units from week 1.”, “Up 2 units from week 1.”, or “Level with week 1.”
    var deltaSentence: String {
        if abs(unitDelta) < 0.05 { return "Level with week 1." }
        let magnitude = Self.figure(abs(unitDelta))
        if unitDelta < 0 {
            return "Down \(magnitude) units from week 1."
        }
        return "Up \(magnitude) units from week 1."
    }

    /// Week 1’s UK units, rounded to one decimal and written without a trailing “.0”.
    var firstWeekFigure: String { Self.figure(firstWeekUnits) }

    /// The latest week’s UK units, rounded the same way.
    var currentWeekFigure: String { Self.figure(currentWeekUnits) }

    /// “2 of 3”.
    var firstWeekSlotsText: String { "\(firstWeekSlots) of \(Self.slotsInAWeek)" }

    /// “1 of 3”.
    var currentWeekSlotsText: String { "\(currentWeekSlots) of \(Self.slotsInAWeek)" }

    /// Compares week 1 with the highest `weekNumber`. Weeks in between are ignored.
    init(weeks: [AppWeek]) {
        let first = weeks.first { $0.weekNumber == 1 }
        let current = weeks.max { $0.weekNumber < $1.weekNumber }
        firstWeekUnits = Self.tenth(Self.loggedUKUnits(in: first))
        currentWeekUnits = Self.tenth(Self.loggedUKUnits(in: current))
        unitDelta = Self.tenth(currentWeekUnits - firstWeekUnits)
        firstWeekSlots = first?.completedWorkouts ?? 0
        currentWeekSlots = current?.completedWorkouts ?? 0
        showsComparison = (current?.weekNumber ?? 0) >= 2 && first != nil
        unitsDiffer = showsComparison && first?.drinkUnit != current?.drinkUnit
    }

    /// Sum of logged drinks in UK units. Stored amounts are not changed.
    private static func loggedUKUnits(in week: AppWeek?) -> Double {
        guard let week else { return 0 }
        return week.drinkLogs.reduce(0) { total, log in
            total + AlcoholUnits.ukUnits(amount: log.amount, unit: week.drinkUnit)
        }
    }

    /// Nearest tenth, so 4 pints land on 9.2 rather than a binary leftover.
    private static func tenth(_ value: Double) -> Double {
        (value * 10).rounded() / 10
    }

    /// One decimal at most, in en_GB, so the sentence stays “9.2” and “2”.
    private static func figure(_ value: Double) -> String {
        tenth(value).formatted(
            .number
                .precision(.fractionLength(0...1))
                .locale(Locale(identifier: "en_GB"))
        )
    }
}
