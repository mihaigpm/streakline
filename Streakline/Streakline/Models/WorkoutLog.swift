import Foundation
import SwiftData

/// A single workout entry within a week. At most one per `WorkoutDay`.
@Model
final class WorkoutLog {
    /// Stored as the enum's raw `String` value.
    var workoutDayRaw: String = WorkoutDay.dayA.rawValue
    var isCompleted: Bool = false
    var completedAt: Date?
    var notes: String = ""
    /// IDs (names) of individual exercises ticked off within this workout.
    var completedExercises: [String] = []

    var week: AppWeek?

    init(workoutDay: WorkoutDay, isCompleted: Bool = false, notes: String = "") {
        self.workoutDayRaw = workoutDay.rawValue
        self.isCompleted = isCompleted
        self.notes = notes
    }

    var workoutDay: WorkoutDay {
        get { WorkoutDay(rawValue: workoutDayRaw) ?? .dayA }
        set { workoutDayRaw = newValue.rawValue }
    }

    func markCompleted() {
        isCompleted = true
        completedAt = .now
    }

    func undoCompletion() {
        isCompleted = false
        completedAt = nil
    }

    // MARK: - Per-exercise completion

    func isExerciseDone(_ exercise: Exercise) -> Bool {
        completedExercises.contains(exercise.id)
    }

    func setExercise(_ exercise: Exercise, done: Bool) {
        if done {
            guard !completedExercises.contains(exercise.id) else { return }
            completedExercises.append(exercise.id)
        } else {
            completedExercises.removeAll { $0 == exercise.id }
        }
    }
}
