import Foundation

/// The one sentence under the home ring the morning after a night with drinks.
///
/// The line is about showing up for an open session. It is not a claim about
/// health, sleep, or impairment, and it does not award drinks.
enum MorningLine {

    /// The sentence for `now`, or nil when yesterday had no drinks or every slot is done.
    ///
    /// Yesterday’s drinks are read from `week`. When today is Monday they may sit on
    /// `previousWeek` instead. The name is the first incomplete slot’s visible template
    /// title, in Day A, B, C order.
    ///
    /// - Parameters:
    ///   - week: The open week. Its incomplete slots supply the name.
    ///   - now: The morning the sentence is for.
    ///   - calendar: Calendar that decides which day is yesterday.
    ///   - previousWeek: The week before, used when yesterday’s drinks are not on `week`.
    /// - Returns: The morning line, or nil when Home should show nothing.
    static func sentence(
        week: AppWeek,
        now: Date,
        calendar: Calendar,
        previousWeek: AppWeek? = nil
    ) -> String? {
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: now)) else {
            return nil
        }
        let earlier = previousWeek?.weekNumber == week.weekNumber ? nil : previousWeek
        let drank = loggedDrinks(on: yesterday, in: week, calendar: calendar)
            + loggedDrinks(on: yesterday, in: earlier, calendar: calendar)
        guard drank > 0, let name = openSlotTitle(in: week) else { return nil }
        return "You drank last night. \(name) still counts, and it’s worth more if you show up."
    }

    /// Sum of logged drinks on `day`. Zero when `week` is missing.
    private static func loggedDrinks(on day: Date, in week: AppWeek?, calendar: Calendar) -> Double {
        guard let week else { return 0 }
        return week.drinkLogs.reduce(0) { total, log in
            calendar.isDate(log.date, inSameDayAs: day) ? total + log.amount : total
        }
    }

    /// Visible title of the first slot that is not complete. Nil when all three are done.
    private static func openSlotTitle(in week: AppWeek) -> String? {
        for day in WorkoutDay.allCases {
            let log = week.log(for: day)
            guard log?.isCompleted != true else { continue }
            return log?.sessionTitle() ?? day.title
        }
        return nil
    }
}
