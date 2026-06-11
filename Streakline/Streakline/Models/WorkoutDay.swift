import SwiftUI

/// The three fixed workout days of the Streakline programme.
enum WorkoutDay: String, Codable, CaseIterable, Identifiable {
    case dayA = "Day A"
    case dayB = "Day B"
    case dayC = "Day C"

    var id: String { rawValue }

    var title: String { rawValue }

    var subtitle: String {
        switch self {
        case .dayA: "Run + glute circuit"
        case .dayB: "Full-body weights"
        case .dayC: "Long run or circuit"
        }
    }

    var sfSymbol: String {
        switch self {
        case .dayA: "figure.run"
        case .dayB: "dumbbell.fill"
        case .dayC: "figure.mixed.cardio"
        }
    }

    var accentColor: Color {
        switch self {
        case .dayA: DesignSystem.Colors.teal
        case .dayB: DesignSystem.Colors.amber
        case .dayC: DesignSystem.Colors.teal
        }
    }

    /// Rough session length, shown in the detail header.
    var estimatedDuration: String {
        switch self {
        case .dayA: "~45 min"
        case .dayB: "~50 min"
        case .dayC: "~50 min"
        }
    }

    /// Exercises for this day. Day C varies by run vs circuit.
    func exercises(dayCIsRun: Bool = true) -> [Exercise] {
        switch self {
        case .dayA: Self.dayAExercises
        case .dayB: Self.dayBExercises
        case .dayC: dayCIsRun ? Self.dayCRunExercises : Self.dayCCircuitExercises
        }
    }

    /// Convenience for the static, run-default list.
    var exercises: [Exercise] { exercises(dayCIsRun: true) }
}
