import Foundation

/// A single prescribed exercise. Value type — not persisted.
struct Exercise: Identifiable, Hashable {
    let name: String
    /// Sets x reps, or a duration descriptor (e.g. "1 x 5km", "3 x 45-60s").
    let prescription: String
    /// Muted coaching cue shown under the exercise name.
    let note: String
    /// SF symbol shown in the guide focus view.
    let symbol: String
    /// Ordered how-to steps for the guide.
    let steps: [String]
    /// Short form cues shown as chips.
    let cues: [String]
    /// Common mistakes to avoid.
    let mistakes: [String]

    var id: String { name }
}
