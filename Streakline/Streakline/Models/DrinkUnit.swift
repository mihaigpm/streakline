import Foundation

/// How the user counts alcohol. The weekly budget engine is unit-agnostic;
/// this only controls labels and the +/- increment.
enum DrinkUnit: String, CaseIterable, Identifiable {
    case pints
    case units
    case drinks

    var id: String { rawValue }

    /// Title shown in Settings.
    var displayName: String {
        switch self {
        case .pints: "Pints (UK)"
        case .units: "Units (UK)"
        case .drinks: "Standard drinks"
        }
    }

    /// Increment used by the +/- buttons.
    var step: Double {
        switch self {
        case .pints: 0.5
        case .units, .drinks: 1
        }
    }

    /// Lowercase noun, pluralised for `count` (e.g. "pint" / "pints").
    func noun(for count: Double) -> String {
        let singular: String
        switch self {
        case .pints: singular = "pint"
        case .units: singular = "unit"
        case .drinks: singular = "drink"
        }
        return count == 1 ? singular : singular + "s"
    }

    var pluralNoun: String { noun(for: 2) }

    /// Format a quantity, dropping a trailing ".0" (e.g. "3", "2.5").
    func format(_ value: Double) -> String {
        value == value.rounded()
            ? String(format: "%.0f", value)
            : String(format: "%.1f", value)
    }

    static let storageKey = "drinkUnit"

    /// Current selection from `UserDefaults`, for use outside SwiftUI views.
    /// Defaults to pints (UK-first, matching the original programme).
    static var current: DrinkUnit {
        guard let raw = UserDefaults.standard.string(forKey: storageKey),
              let unit = DrinkUnit(rawValue: raw) else { return .pints }
        return unit
    }
}
