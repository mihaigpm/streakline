import SwiftData

@MainActor
enum AppDataManager {
    static func resetCurrentWeek(_ week: AppWeek, in context: ModelContext) throws {
        for log in week.workoutLogs {
            log.undoCompletion()
            log.notes = ""
            log.completedExercises.removeAll()
        }
        for drink in week.drinkLogs {
            context.delete(drink)
        }
        week.drinkLogs.removeAll()
        try context.save()
    }

    static func eraseAll(_ weeks: [AppWeek], in context: ModelContext) throws {
        for week in weeks {
            context.delete(week)
        }
        try context.save()
    }
}
