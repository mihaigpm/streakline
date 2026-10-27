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
    /// Template id for this slot. Empty keeps the original Day A / B / C list.
    var sessionTemplateRaw: String = ""

    var week: AppWeek?

    init(
        workoutDay: WorkoutDay,
        isCompleted: Bool = false,
        notes: String = "",
        sessionTemplateRaw: String = ""
    ) {
        self.workoutDayRaw = workoutDay.rawValue
        self.isCompleted = isCompleted
        self.notes = notes
        self.sessionTemplateRaw = sessionTemplateRaw
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

    // MARK: - Session template

    /// Empty means this log still uses the original Day A / B / C content.
    var usesLegacySession: Bool { sessionTemplateRaw.isEmpty }

    var isLoggedSession: Bool { sessionTemplateRaw == SessionTemplate.logged.rawValue }

    var sessionTemplate: SessionTemplate? {
        guard !sessionTemplateRaw.isEmpty else { return nil }
        return SessionTemplate(rawValue: sessionTemplateRaw)
    }

    func sessionTitle() -> String {
        sessionTemplate?.title ?? workoutDay.title
    }

    func sessionSubtitle() -> String {
        if usesLegacySession {
            return workoutDay.subtitle
        }
        if isLoggedSession {
            switch workoutDay {
            case .dayA: return "Heart-rate session"
            case .dayB: return "Strength session"
            case .dayC: return "Long session"
            }
        }
        return sessionTemplate?.subtitle ?? workoutDay.subtitle
    }

    func sessionSymbol() -> String {
        if usesLegacySession || isLoggedSession || sessionTemplate == nil {
            return workoutDay.sfSymbol
        }
        return sessionTemplate?.symbol ?? workoutDay.sfSymbol
    }

    func sessionDuration() -> String {
        sessionTemplate?.duration ?? workoutDay.estimatedDuration
    }

    /// Exercises for this log. Legacy Day C still follows `dayCIsRun`.
    func sessionExercises(dayCIsRun: Bool) -> [Exercise] {
        guard let template = sessionTemplate else {
            return workoutDay.exercises(dayCIsRun: dayCIsRun)
        }
        if template == .logged {
            return []
        }
        return template.exercises
    }

    /// Completes the session. The Day C run/circuit flag flips only for a legacy log.
    func markSessionCompleted(in week: AppWeek) {
        markCompleted()
        if usesLegacySession, workoutDay == .dayC {
            week.dayC_wasRun.toggle()
        }
    }

    /// Clears completion. Reverses the legacy Day C flag when this log had flipped it.
    func undoSession(in week: AppWeek) {
        let reversesLegacyDayC = usesLegacySession && workoutDay == .dayC && isCompleted
        undoCompletion()
        if reversesLegacyDayC {
            week.dayC_wasRun.toggle()
        }
    }

    /// Replaces this slot's template for the current week and clears its ticks and completion.
    ///
    /// Choosing `logged` marks the slot complete. The other slots are left alone.
    /// Selecting the template already stored does nothing, except `logged` after an undo,
    /// which completes the slot again.
    func apply(template: SessionTemplate, in week: AppWeek) {
        if sessionTemplateRaw == template.rawValue {
            if template == .logged, !isCompleted {
                markCompleted()
            }
            return
        }

        let reversesLegacyDayC = usesLegacySession && workoutDay == .dayC && isCompleted
        completedExercises.removeAll()
        if isCompleted {
            undoCompletion()
        }
        if reversesLegacyDayC {
            week.dayC_wasRun.toggle()
        }
        sessionTemplateRaw = template.rawValue
        if template == .logged {
            markCompleted()
        }
    }
}
