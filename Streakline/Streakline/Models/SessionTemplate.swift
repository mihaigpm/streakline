import Foundation

/// A changeable session inside one of the three stable slots.
///
/// Slot raw values stay `Day A`, `Day B`, and `Day C` on `WorkoutLog.workoutDayRaw`.
/// The template id is stored separately on `sessionTemplateRaw`.
enum SessionTemplate: String, CaseIterable, Identifiable {
    case easyRun = "easy-run"
    case intervals
    case ride
    case sport
    case fullBody = "full-body"
    case upper
    case lower
    case homeCircuit = "home-circuit"
    case longRun = "long-run"
    case longRide = "long-ride"
    case longCircuit = "long-circuit"
    case logged

    var id: String { rawValue }

    /// Templates a slot is allowed to wear, including "I already trained".
    static func options(for slot: WorkoutDay) -> [SessionTemplate] {
        switch slot {
        case .dayA: [.easyRun, .intervals, .ride, .sport, .logged]
        case .dayB: [.fullBody, .upper, .lower, .homeCircuit, .logged]
        case .dayC: [.longRun, .longRide, .longCircuit, .logged]
        }
    }

    /// Name shown on the workout card and the detail screen.
    var title: String {
        switch self {
        case .easyRun: "Easy run"
        case .intervals: "Intervals"
        case .ride: "Ride"
        case .sport: "Sport"
        case .fullBody: "Full body"
        case .upper: "Upper body"
        case .lower: "Lower body"
        case .homeCircuit: "Home circuit"
        case .longRun: "Long run"
        case .longRide: "Long ride"
        case .longCircuit: "Long circuit"
        case .logged: "Trained"
        }
    }

    /// Menu label. `logged` names the action; the card still says "Trained".
    var menuTitle: String {
        self == .logged ? "I already trained" : title
    }

    var subtitle: String {
        switch self {
        case .easyRun: "Steady run and glute circuit"
        case .intervals: "Short hard efforts"
        case .ride: "Time on the bike"
        case .sport: "The game or class you already do"
        case .fullBody: "Weights for the whole body"
        case .upper: "Push, pull, and brace"
        case .lower: "Hinge, squat, and press"
        case .homeCircuit: "A circuit you can do at home"
        case .longRun: "Comfortable distance"
        case .longRide: "Easy time on the bike"
        case .longCircuit: "The longer conditioning session"
        case .logged: "Counted as one session"
        }
    }

    var symbol: String {
        switch self {
        case .easyRun, .intervals, .longRun: "figure.run"
        case .fullBody: "dumbbell.fill"
        case .upper: "figure.strengthtraining.traditional"
        case .lower: "figure.strengthtraining.functional"
        case .ride, .sport, .homeCircuit, .longRide, .longCircuit, .logged: "figure.mixed.cardio"
        }
    }

    var duration: String {
        switch self {
        case .easyRun, .sport, .lower, .longCircuit: "~45 min"
        case .intervals, .upper, .homeCircuit: "~40 min"
        case .ride, .fullBody, .longRun: "~50 min"
        case .longRide: "~75 min"
        case .logged: ""
        }
    }
}
