import Foundation

/// An eight-week name for one week. Derived from `weekNumber` and the budget floor. Nothing is stored.
///
/// Cutting weeks are titled “Season N”. The first saved week whose budget sits on the floor stays in that season.
/// The next week on the same floor is titled “Hold”. Hold does not move the budget, and it does not reset XP, the streak, or templates.
struct Season: Equatable {
    /// 1 for weeks 1…8, 2 for weeks 9…16.
    var number: Int
    /// 1…8 inside the season. Week 9 is 1 again.
    var weekInSeason: Int
    /// True after an earlier saved week already sat on this week’s floor.
    var isHold: Bool

    /// “Season 2”, or “Hold” once the floor has already had a week.
    var title: String {
        isHold ? "Hold" : "Season \(number)"
    }

    /// “week 1 of 8”.
    var weekPhrase: String {
        "week \(weekInSeason) of 8"
    }

    /// Seal heading. “Season 1, week 1 of 8”, or “Hold, week 2 of 8”.
    var heading: String {
        "\(title), \(weekPhrase)"
    }

    /// Label for `week` among the weeks already saved.
    ///
    /// The scan is linear in `history.count`. `week` is included when the list omits it,
    /// so the first week on the floor is not marked Hold.
    ///
    /// - Parameters:
    ///   - week: The week being named.
    ///   - history: Saved weeks. An earlier week on the same floor is what starts Hold.
    init(week: AppWeek, history: [AppWeek] = []) {
        let weekNumber = week.weekNumber
        number = (weekNumber - 1) / 8 + 1
        weekInSeason = (weekNumber - 1) % 8 + 1
        let floor = Self.budgetFloor(for: week)
        let onFloor = week.drinkBudget == floor
        let first = Self.firstWeekNumber(on: floor, in: history + [week])
        isHold = onFloor && weekNumber > (first ?? weekNumber)
    }

    /// Legacy weeks stop at 5 of the week’s unit. Guideline weeks stop at the UK display floor for that unit.
    /// A starting budget already under the display floor is not that floor, so those weeks stay in a cutting season.
    static func budgetFloor(for week: AppWeek) -> Int {
        switch week.budgetRule {
        case .legacy:
            5
        case .guideline:
            AlcoholUnits.displayFloor(for: week.drinkUnit)
        }
    }

    /// Lowest week number whose own floor is `floor` and whose budget is already there.
    private static func firstWeekNumber(on floor: Int, in history: [AppWeek]) -> Int? {
        history.compactMap { candidate in
            guard Self.budgetFloor(for: candidate) == floor, candidate.drinkBudget == floor else { return nil }
            return candidate.weekNumber
        }.min()
    }
}
