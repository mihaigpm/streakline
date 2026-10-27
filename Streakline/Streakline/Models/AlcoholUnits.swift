import Foundation

/// Fixed conversions used to plan a weekly drink budget.
///
/// These are programme constants, not a lab measure of a particular drink.
/// 1 UK unit = 1 unit.
/// 1 pint = 2.3 UK units (a pint of 4% beer).
/// 1 standard drink = 1.75 UK units (14 g / 8 g).
enum AlcoholUnits {
    /// UK low-risk guideline, used only as a planning floor.
    static let guidelineUKUnits = 14.0

    private static let unitInUKUnits = 1.0
    private static let pintInUKUnits = 2.3
    private static let standardDrinkInUKUnits = 1.75

    /// Converts a logged or planned amount into UK units for comparison.
    /// Stored `DrinkLog.amount` values stay in the week's own unit.
    static func ukUnits(amount: Double, unit: DrinkUnit) -> Double {
        amount * ukUnits(per: unit)
    }

    private static func ukUnits(per unit: DrinkUnit) -> Double {
        switch unit {
        case .units: unitInUKUnits
        case .pints: pintInUKUnits
        case .drinks: standardDrinkInUKUnits
        }
    }

    /// Nearest whole number of `unit` to 14 UK units.
    /// Units 14, pints 6, standard drinks 8.
    static func displayFloor(for unit: DrinkUnit) -> Int {
        Int((guidelineUKUnits / ukUnits(per: unit)).rounded())
    }

    /// Floor written the way the screens describe it, for the selected unit.
    static func displayFloorLabel(for unit: DrinkUnit) -> String {
        let floor = displayFloor(for: unit)
        switch unit {
        case .pints: "\(floor) pints"
        case .units: "\(floor) units"
        case .drinks: "\(floor) standard drinks"
        }
    }
}
