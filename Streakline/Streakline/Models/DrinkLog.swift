import Foundation
import SwiftData

/// A single drink-logging session. The quantity is expressed in whatever
/// `DrinkUnit` the user has selected; increments come from `DrinkUnit.step`.
@Model
final class DrinkLog {
    var date: Date = Date.now
    /// Quantity in the user's chosen unit. (Stored under "pints" for compatibility.)
    @Attribute(originalName: "pints") var amount: Double = 0

    var week: AppWeek?

    init(date: Date = .now, amount: Double = 0.5) {
        self.date = date
        self.amount = amount
    }
}
