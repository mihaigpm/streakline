import Foundation

/// Exercise lists for session templates.
///
/// Templates that already match a day list use that list unchanged.
/// The other templates reuse 3–5 movements from the closest list and change
/// only the visible name, prescription, and note. Steps, cues, and mistakes
/// stay with the source exercise.
extension SessionTemplate {
    var exercises: [Exercise] {
        switch self {
        case .easyRun:
            WorkoutDay.dayAExercises
        case .fullBody:
            WorkoutDay.dayBExercises
        case .longRun:
            WorkoutDay.dayCRunExercises
        case .longCircuit, .homeCircuit:
            WorkoutDay.dayCCircuitExercises
        case .logged:
            []
        case .intervals:
            Self.intervalExercises
        case .ride:
            Self.rideExercises
        case .sport:
            Self.sportExercises
        case .upper:
            Self.upperExercises
        case .lower:
            Self.lowerExercises
        case .longRide:
            Self.longRideExercises
        }
    }

    private static let intervalExercises: [Exercise] = [
        adapted(dayA("5km Run"), name: "Interval run", prescription: "8 x 1 min", note: "Hard effort, then jog until you recover"),
        adapted(dayCRun("Jump Squat"), name: "Power jumps", prescription: "3 x 10", note: "Fast up, soft landing"),
        adapted(dayCRun("Mountain Climbers"), name: "Fast climbers", prescription: "3 x 20 each", note: "Hips stay level as the pace rises"),
        adapted(dayA("Glute Bridge"), name: "Glute bridge finisher", prescription: "3 x 15", note: "Slow the heart rate down, pause at the top"),
    ]

    private static let rideExercises: [Exercise] = [
        adapted(dayA("5km Run"), name: "Steady ride", prescription: "1 x 45 min", note: "Cadence you could talk through"),
        adapted(dayA("Glute Bridge"), name: "Hip bridge", prescription: "3 x 15", note: "Open the hips after the saddle"),
        adapted(dayA("Single-leg Hip Thrust"), name: "Single-leg hip lift", prescription: "3 x 10 each", note: "One side at a time"),
        adapted(dayA("KB Single-leg RDL"), name: "Single-leg hinge", prescription: "3 x 8 each", note: "Hamstrings after pedalling"),
    ]

    private static let sportExercises: [Exercise] = [
        adapted(dayA("5km Run"), name: "Sport session", prescription: "1 x 40 min", note: "The game or class you already do"),
        adapted(dayCRun("Jump Squat"), name: "Jump primer", prescription: "2 x 10", note: "Wake the legs up first"),
        adapted(dayA("Lateral Band Walk"), name: "Lateral step", prescription: "2 x 12 each", note: "Side to side before you start"),
        adapted(dayCRun("Mountain Climbers"), name: "Climber burst", prescription: "3 x 20 each", note: "A short burst to raise your heart rate"),
    ]

    private static let upperExercises: [Exercise] = [
        adapted(dayB("Romanian Deadlift"), name: "Dumbbell row", prescription: "4 x 8", note: "Pull toward your ribs and keep the back flat"),
        adapted(dayB("Bulgarian Split Squat"), name: "Overhead press", prescription: "3 x 8", note: "Ribs down, finish without leaning back"),
        adapted(dayB("Single-leg Press"), name: "Push-up", prescription: "3 x 10", note: "Body in one line, chest toward the floor"),
        adapted(dayB("Pallof Press"), name: "Band press-out", prescription: "3 x 12 each", note: "Resist the twist as you reach"),
    ]

    private static let lowerExercises: [Exercise] = [
        adapted(dayB("Romanian Deadlift"), name: "Hamstring hinge", prescription: "4 x 8", note: "Hinge until the hamstrings stretch"),
        adapted(dayB("Bulgarian Split Squat"), name: "Rear-foot split squat", prescription: "3 x 8 each", note: "Drive through the front heel"),
        adapted(dayB("Single-leg Press"), name: "One-leg press", prescription: "3 x 10 each", note: "Full range, heel stays planted"),
        adapted(dayB("Cable Pull-Through"), name: "Hip pull-through", prescription: "3 x 12", note: "Hips come through, glutes finish the rep"),
    ]

    private static let longRideExercises: [Exercise] = [
        adapted(dayCRun("7-8km Run"), name: "Long ride", prescription: "1 x 75 min", note: "Easy gears, conversational effort"),
        adapted(dayCRun("Jump Squat"), name: "Easy jump squat", prescription: "2 x 10", note: "Light and soft, not a finisher"),
        adapted(dayCRun("Mountain Climbers"), name: "Easy climbers", prescription: "2 x 15 each", note: "Unhurried, hips level"),
        adapted(dayCRun("Dead Bug"), name: "Slow dead bug", prescription: "2 x 8 each", note: "Lower back stays down"),
    ]

    private static func dayA(_ name: String) -> Exercise {
        source(WorkoutDay.dayAExercises, named: name)
    }

    private static func dayB(_ name: String) -> Exercise {
        source(WorkoutDay.dayBExercises, named: name)
    }

    private static func dayCRun(_ name: String) -> Exercise {
        source(WorkoutDay.dayCRunExercises, named: name)
    }

    private static func source(_ exercises: [Exercise], named name: String) -> Exercise {
        guard let exercise = exercises.first(where: { $0.name == name }) else {
            preconditionFailure("Missing exercise \(name)")
        }
        return exercise
    }

    private static func adapted(
        _ source: Exercise,
        name: String,
        prescription: String,
        note: String
    ) -> Exercise {
        Exercise(
            name: name,
            prescription: prescription,
            note: note,
            symbol: source.symbol,
            steps: source.steps,
            cues: source.cues,
            mistakes: source.mistakes
        )
    }
}
