import Foundation

/// The kind of week chosen during onboarding. New weeks copy its three templates.
///
/// Stored in `UserDefaults` under `programmePreset`. A missing value leaves new logs
/// on the original Day A / B / C lists.
enum ProgrammePreset: String, CaseIterable, Identifiable {
    case running
    case gym
    case home

    static let storageKey = "programmePreset"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .running: "Running"
        case .gym: "Gym"
        case .home: "Home"
        }
    }

    /// The three template names, in Hard / Strong / Long order.
    var detail: String {
        switch self {
        case .running: "Easy run, full body, long run"
        case .gym: "Intervals, full body, long circuit"
        case .home: "Sport, home circuit, long circuit"
        }
    }

    /// Template seeded onto `slot` for a new week.
    func template(for slot: WorkoutDay) -> SessionTemplate {
        switch (self, slot) {
        case (.running, .dayA): .easyRun
        case (.running, .dayB): .fullBody
        case (.running, .dayC): .longRun
        case (.gym, .dayA): .intervals
        case (.gym, .dayB): .fullBody
        case (.gym, .dayC): .longCircuit
        case (.home, .dayA): .sport
        case (.home, .dayB): .homeCircuit
        case (.home, .dayC): .longCircuit
        }
    }

    func templateID(for slot: WorkoutDay) -> String {
        template(for: slot).rawValue
    }

    /// The preset currently stored on device, if onboarding saved one.
    static var current: ProgrammePreset? {
        guard let raw = UserDefaults.standard.string(forKey: storageKey) else { return nil }
        return ProgrammePreset(rawValue: raw)
    }
}
