import SwiftData
import XCTest
@testable import Streakline

@MainActor
final class StreaklineCoreTests: XCTestCase {
    private var container: ModelContainer!
    private var context: ModelContext!

    override func setUpWithError() throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(
            for: AppWeek.self, WorkoutLog.self, DrinkLog.self,
            configurations: configuration
        )
        context = container.mainContext
        UserDefaults.standard.removeObject(forKey: ProgramPreferences.startingBudgetKey)
        UserDefaults.standard.removeObject(forKey: DrinkUnit.storageKey)
        UserDefaults.standard.removeObject(forKey: ProgrammePreset.storageKey)
    }

    override func tearDownWithError() throws {
        UserDefaults.standard.removeObject(forKey: ProgramPreferences.startingBudgetKey)
        UserDefaults.standard.removeObject(forKey: DrinkUnit.storageKey)
        UserDefaults.standard.removeObject(forKey: ProgrammePreset.storageKey)
        context = nil
        container = nil
    }

    func testCustomBudgetDropsEveryTwoWeeksAndStopsAtFive() {
        XCTAssertEqual(AppWeek(weekNumber: 1, startDate: .now, startingDrinkBudget: 12).drinkBudget, 12)
        XCTAssertEqual(AppWeek(weekNumber: 2, startDate: .now, startingDrinkBudget: 12).drinkBudget, 12)
        XCTAssertEqual(AppWeek(weekNumber: 3, startDate: .now, startingDrinkBudget: 12).drinkBudget, 11)
        XCTAssertEqual(AppWeek(weekNumber: 99, startDate: .now, startingDrinkBudget: 12).drinkBudget, 5)
    }

    func testMissingBudgetRuleStaysOnTheLegacyFloorOfFive() {
        let pints = AppWeek(weekNumber: 99, startDate: .now, startingDrinkBudget: 12, drinkUnit: .pints)
        XCTAssertEqual(pints.budgetRuleRaw, "legacy")
        XCTAssertEqual(pints.drinkBudget, 5)

        pints.budgetRuleRaw = ""
        XCTAssertEqual(pints.budgetRule, .legacy)
        XCTAssertEqual(pints.drinkBudget, 5)

        let units = AppWeek(weekNumber: 99, startDate: .now, startingDrinkBudget: 20, drinkUnit: .units)
        XCTAssertEqual(units.drinkBudget, 5)
        let drinks = AppWeek(weekNumber: 99, startDate: .now, startingDrinkBudget: 20, drinkUnit: .drinks)
        XCTAssertEqual(drinks.drinkBudget, 5)
    }

    func testGuidelinePintsDropEveryTwoWeeksAndStopAtSix() {
        XCTAssertEqual(guidelineWeek(1, starting: 10, unit: .pints).drinkBudget, 10)
        XCTAssertEqual(guidelineWeek(2, starting: 10, unit: .pints).drinkBudget, 10)
        XCTAssertEqual(guidelineWeek(3, starting: 10, unit: .pints).drinkBudget, 9)
        XCTAssertEqual(guidelineWeek(4, starting: 10, unit: .pints).drinkBudget, 9)
        XCTAssertEqual(guidelineWeek(99, starting: 10, unit: .pints).drinkBudget, 6)
        XCTAssertEqual(guidelineWeek(99, starting: 5, unit: .pints).drinkBudget, 5)
    }

    func testGuidelineUnitsUnderTheFloorStayAtTheStartingBudget() {
        XCTAssertEqual(guidelineWeek(1, starting: 10, unit: .units).drinkBudget, 10)
        XCTAssertEqual(guidelineWeek(3, starting: 10, unit: .units).drinkBudget, 10)
        XCTAssertEqual(guidelineWeek(99, starting: 10, unit: .units).drinkBudget, 10)
    }

    func testGuidelineUnitsDropEveryTwoWeeksAndStopAtFourteen() {
        XCTAssertEqual(guidelineWeek(1, starting: 20, unit: .units).drinkBudget, 20)
        XCTAssertEqual(guidelineWeek(2, starting: 20, unit: .units).drinkBudget, 20)
        XCTAssertEqual(guidelineWeek(3, starting: 20, unit: .units).drinkBudget, 19)
        XCTAssertEqual(guidelineWeek(12, starting: 20, unit: .units).drinkBudget, 15)
        XCTAssertEqual(guidelineWeek(13, starting: 20, unit: .units).drinkBudget, 14)
        XCTAssertEqual(guidelineWeek(99, starting: 20, unit: .units).drinkBudget, 14)
    }

    func testGuidelineStandardDrinksStopAtEight() {
        XCTAssertEqual(guidelineWeek(1, starting: 12, unit: .drinks).drinkBudget, 12)
        XCTAssertEqual(guidelineWeek(3, starting: 12, unit: .drinks).drinkBudget, 11)
        XCTAssertEqual(guidelineWeek(99, starting: 12, unit: .drinks).drinkBudget, 8)
        XCTAssertEqual(guidelineWeek(99, starting: 5, unit: .drinks).drinkBudget, 5)
    }

    func testAlcoholUnitsConversionsAndDisplayFloors() {
        XCTAssertEqual(AlcoholUnits.ukUnits(amount: 1, unit: .units), 1, accuracy: 0.0001)
        XCTAssertEqual(AlcoholUnits.ukUnits(amount: 1, unit: .pints), 2.3, accuracy: 0.0001)
        XCTAssertEqual(AlcoholUnits.ukUnits(amount: 1, unit: .drinks), 1.75, accuracy: 0.0001)
        XCTAssertEqual(AlcoholUnits.ukUnits(amount: 2, unit: .pints), 4.6, accuracy: 0.0001)
        XCTAssertEqual(AlcoholUnits.displayFloor(for: .units), 14)
        XCTAssertEqual(AlcoholUnits.displayFloor(for: .pints), 6)
        XCTAssertEqual(AlcoholUnits.displayFloor(for: .drinks), 8)
        XCTAssertEqual(AlcoholUnits.displayFloorLabel(for: .pints), "6 pints")
        XCTAssertEqual(AlcoholUnits.displayFloorLabel(for: .units), "14 units")
        XCTAssertEqual(AlcoholUnits.displayFloorLabel(for: .drinks), "8 standard drinks")
    }

    func testWeekManagerCreatesGuidelineWeeks() throws {
        UserDefaults.standard.set(10, forKey: ProgramPreferences.startingBudgetKey)
        UserDefaults.standard.set(DrinkUnit.pints.rawValue, forKey: DrinkUnit.storageKey)

        let calendar = Calendar(identifier: .iso8601)
        let firstDate = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 8, day: 3)))
        let first = WeekManager.currentWeek(in: context, now: firstDate)
        XCTAssertEqual(first.budgetRuleRaw, BudgetRule.guideline.rawValue)
        XCTAssertEqual(first.drinkUnit, .pints)
        XCTAssertEqual(first.drinkBudget, 10)

        let thirdDate = try XCTUnwrap(calendar.date(byAdding: .day, value: 14, to: firstDate))
        let third = WeekManager.currentWeek(in: context, now: thirdDate)
        XCTAssertEqual(third.weekNumber, 3)
        XCTAssertEqual(third.budgetRuleRaw, "guideline")
        XCTAssertEqual(third.startingDrinkBudget, 10)
        XCTAssertEqual(third.drinkBudget, 9)
        XCTAssertEqual(first.budgetRuleRaw, "guideline")
        XCTAssertEqual(first.drinkBudget, 10)
    }

    func testProgrammePresetTemplates() {
        XCTAssertEqual(ProgrammePreset.running.templateID(for: .dayA), "easy-run")
        XCTAssertEqual(ProgrammePreset.running.templateID(for: .dayB), "full-body")
        XCTAssertEqual(ProgrammePreset.running.templateID(for: .dayC), "long-run")
        XCTAssertEqual(ProgrammePreset.gym.templateID(for: .dayA), "intervals")
        XCTAssertEqual(ProgrammePreset.gym.templateID(for: .dayB), "full-body")
        XCTAssertEqual(ProgrammePreset.gym.templateID(for: .dayC), "long-circuit")
        XCTAssertEqual(ProgrammePreset.home.templateID(for: .dayA), "sport")
        XCTAssertEqual(ProgrammePreset.home.templateID(for: .dayB), "home-circuit")
        XCTAssertEqual(ProgrammePreset.home.templateID(for: .dayC), "long-circuit")
    }

    func testSessionTemplateOptionsUseThePromptIds() {
        XCTAssertEqual(
            SessionTemplate.options(for: .dayA).map(\.rawValue),
            ["easy-run", "intervals", "ride", "sport", "logged"]
        )
        XCTAssertEqual(
            SessionTemplate.options(for: .dayB).map(\.rawValue),
            ["full-body", "upper", "lower", "home-circuit", "logged"]
        )
        XCTAssertEqual(
            SessionTemplate.options(for: .dayC).map(\.rawValue),
            ["long-run", "long-ride", "long-circuit", "logged"]
        )
        XCTAssertEqual(SessionTemplate.logged.title, "Trained")
    }

    func testKnownTemplatesReuseExistingLists() {
        XCTAssertEqual(SessionTemplate.easyRun.exercises, WorkoutDay.dayAExercises)
        XCTAssertEqual(SessionTemplate.fullBody.exercises, WorkoutDay.dayBExercises)
        XCTAssertEqual(SessionTemplate.longRun.exercises, WorkoutDay.dayCRunExercises)
        XCTAssertEqual(SessionTemplate.longCircuit.exercises, WorkoutDay.dayCCircuitExercises)
        XCTAssertEqual(SessionTemplate.homeCircuit.exercises, WorkoutDay.dayCCircuitExercises)
        XCTAssertTrue(SessionTemplate.logged.exercises.isEmpty)
    }

    func testShortTemplatesReuseExistingSteps() {
        let sources = WorkoutDay.dayAExercises
            + WorkoutDay.dayBExercises
            + WorkoutDay.dayCRunExercises
            + WorkoutDay.dayCCircuitExercises
        for template in [SessionTemplate.intervals, .ride, .sport, .upper, .lower, .longRide] {
            let exercises = template.exercises
            XCTAssertTrue((3...5).contains(exercises.count), template.rawValue)
            for exercise in exercises {
                XCTAssertTrue(
                    sources.contains { $0.steps == exercise.steps },
                    "\(template.rawValue) \(exercise.name) should reuse an existing list"
                )
                XCTAssertFalse(
                    sources.contains {
                        $0.name == exercise.name
                            && $0.prescription == exercise.prescription
                            && $0.note == exercise.note
                    },
                    "\(template.rawValue) \(exercise.name) should change the visible name, prescription, and note"
                )
            }
        }
    }

    func testEmptyTemplateStaysOnLegacyLists() {
        let dayA = WorkoutLog(workoutDay: .dayA)
        XCTAssertEqual(dayA.sessionTemplateRaw, "")
        XCTAssertTrue(dayA.usesLegacySession)
        XCTAssertEqual(dayA.sessionTitle(), "Day A")
        XCTAssertEqual(dayA.sessionSubtitle(), "Run + glute circuit")
        XCTAssertEqual(dayA.sessionExercises(dayCIsRun: true), WorkoutDay.dayAExercises)

        let dayB = WorkoutLog(workoutDay: .dayB)
        XCTAssertEqual(dayB.sessionTitle(), "Day B")
        XCTAssertEqual(dayB.sessionExercises(dayCIsRun: true), WorkoutDay.dayBExercises)

        let dayC = WorkoutLog(workoutDay: .dayC)
        XCTAssertEqual(dayC.sessionTitle(), "Day C")
        XCTAssertEqual(dayC.sessionSubtitle(), "Long run or circuit")
        XCTAssertEqual(dayC.sessionExercises(dayCIsRun: true), WorkoutDay.dayCRunExercises)
        XCTAssertEqual(dayC.sessionExercises(dayCIsRun: false), WorkoutDay.dayCCircuitExercises)
    }

    func testLegacyDayCStillAlternatesAndTemplatesDoNot() {
        let week = AppWeek(weekNumber: 1, startDate: .now)
        XCTAssertTrue(week.dayC_wasRun)

        let legacy = WorkoutLog(workoutDay: .dayC)
        legacy.markSessionCompleted(in: week)
        XCTAssertFalse(week.dayC_wasRun)
        legacy.undoSession(in: week)
        XCTAssertTrue(week.dayC_wasRun)

        let templated = WorkoutLog(workoutDay: .dayC, sessionTemplateRaw: "long-run")
        templated.markSessionCompleted(in: week)
        XCTAssertTrue(week.dayC_wasRun)
        templated.undoSession(in: week)
        XCTAssertTrue(week.dayC_wasRun)

        let logged = WorkoutLog(workoutDay: .dayC)
        logged.apply(template: .logged, in: week)
        XCTAssertTrue(week.dayC_wasRun)
        XCTAssertTrue(logged.isCompleted)
        XCTAssertEqual(logged.sessionTitle(), "Trained")

        legacy.markSessionCompleted(in: week)
        XCTAssertFalse(week.dayC_wasRun)
        legacy.apply(template: .longRun, in: week)
        XCTAssertTrue(week.dayC_wasRun)
        XCTAssertFalse(legacy.isCompleted)
        XCTAssertEqual(legacy.sessionTemplateRaw, "long-run")
    }

    func testLoggedTemplateCompletesTheSlotAndMovesTheRing() {
        let week = AppWeek(weekNumber: 1, startDate: .now)
        let log = WorkoutLog(workoutDay: .dayA, sessionTemplateRaw: "easy-run")
        log.completedExercises = ["5km Run"]
        log.week = week
        week.workoutLogs = [log]

        log.apply(template: .logged, in: week)

        XCTAssertEqual(log.sessionTemplateRaw, "logged")
        XCTAssertTrue(log.isCompleted)
        XCTAssertTrue(log.completedExercises.isEmpty)
        XCTAssertEqual(log.sessionTitle(), "Trained")
        XCTAssertTrue(log.sessionExercises(dayCIsRun: true).isEmpty)
        XCTAssertEqual(week.completedWorkouts, 1)
        XCTAssertEqual(week.workoutFraction, 1.0 / 3.0, accuracy: 0.0001)

        log.undoSession(in: week)
        XCTAssertFalse(log.isCompleted)
        XCTAssertEqual(week.completedWorkouts, 0)
        log.apply(template: .logged, in: week)
        XCTAssertTrue(log.isCompleted)
    }

    func testHomePresetSeedsTemplatesAndSwapKeepsTheOtherSlots() throws {
        UserDefaults.standard.set(ProgrammePreset.home.rawValue, forKey: ProgrammePreset.storageKey)
        let calendar = Calendar(identifier: .iso8601)
        let firstDate = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 8, day: 3)))
        let week = WeekManager.currentWeek(in: context, now: firstDate)

        let hard = try XCTUnwrap(week.log(for: .dayA))
        let strong = try XCTUnwrap(week.log(for: .dayB))
        let long = try XCTUnwrap(week.log(for: .dayC))
        XCTAssertEqual(hard.sessionTemplateRaw, "sport")
        XCTAssertEqual(strong.sessionTemplateRaw, "home-circuit")
        XCTAssertEqual(long.sessionTemplateRaw, "long-circuit")
        XCTAssertEqual(hard.sessionTitle(), "Sport")
        XCTAssertNotEqual(hard.sessionTitle(), "Day A")
        XCTAssertEqual(strong.sessionExercises(dayCIsRun: true), WorkoutDay.dayCCircuitExercises)

        strong.completedExercises = ["KB Swings"]
        strong.markCompleted()
        strong.apply(template: .fullBody, in: week)

        XCTAssertEqual(strong.sessionTemplateRaw, "full-body")
        XCTAssertTrue(strong.completedExercises.isEmpty)
        XCTAssertFalse(strong.isCompleted)
        XCTAssertEqual(strong.sessionExercises(dayCIsRun: true), WorkoutDay.dayBExercises)
        XCTAssertEqual(hard.sessionTemplateRaw, "sport")
        XCTAssertEqual(long.sessionTemplateRaw, "long-circuit")
        XCTAssertEqual(week.completedWorkouts, 0)
    }

    func testNewWeekUsesThePresetRatherThanLastWeeksSwap() throws {
        UserDefaults.standard.set(ProgrammePreset.home.rawValue, forKey: ProgrammePreset.storageKey)
        let calendar = Calendar(identifier: .iso8601)
        let firstDate = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 8, day: 3)))
        let first = WeekManager.currentWeek(in: context, now: firstDate)
        try XCTUnwrap(first.log(for: .dayB)).apply(template: .fullBody, in: first)
        try context.save()

        let nextDate = try XCTUnwrap(calendar.date(byAdding: .day, value: 7, to: firstDate))
        let second = WeekManager.currentWeek(in: context, now: nextDate)
        XCTAssertEqual(second.weekNumber, 2)
        XCTAssertEqual(second.log(for: .dayA)?.sessionTemplateRaw, "sport")
        XCTAssertEqual(second.log(for: .dayB)?.sessionTemplateRaw, "home-circuit")
        XCTAssertEqual(second.log(for: .dayC)?.sessionTemplateRaw, "long-circuit")
        XCTAssertEqual(first.log(for: .dayB)?.sessionTemplateRaw, "full-body")
    }

    func testMissingPresetLeavesLegacyTemplates() throws {
        let calendar = Calendar(identifier: .iso8601)
        let firstDate = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 8, day: 10)))
        let week = WeekManager.currentWeek(in: context, now: firstDate)
        XCTAssertEqual(week.workoutLogs.count, 3)
        XCTAssertTrue(week.workoutLogs.allSatisfy(\.usesLegacySession))
        XCTAssertEqual(week.log(for: .dayA)?.sessionTitle(), "Day A")
    }

    func testExistingDataDefaultsRemainCompatible() {
        let week = AppWeek(weekNumber: 3, startDate: .now)
        XCTAssertEqual(week.startingDrinkBudget, 10)
        XCTAssertEqual(week.drinkBudget, 9)
        XCTAssertEqual(week.drinkUnit, .pints)
    }

    func testWeekRolloverPreservesBaselineAndUsesProspectiveUnit() throws {
        UserDefaults.standard.set(14, forKey: ProgramPreferences.startingBudgetKey)
        UserDefaults.standard.set(DrinkUnit.units.rawValue, forKey: DrinkUnit.storageKey)

        let calendar = Calendar(identifier: .iso8601)
        let firstDate = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 8, day: 3)))
        let first = WeekManager.currentWeek(in: context, now: firstDate)
        XCTAssertEqual(first.weekNumber, 1)
        XCTAssertEqual(first.startingDrinkBudget, 14)
        XCTAssertEqual(first.drinkUnit, .units)
        XCTAssertEqual(first.workoutLogs.count, 3)

        UserDefaults.standard.set(DrinkUnit.drinks.rawValue, forKey: DrinkUnit.storageKey)
        let thirdWeekDate = try XCTUnwrap(calendar.date(byAdding: .day, value: 14, to: firstDate))
        let third = WeekManager.currentWeek(in: context, now: thirdWeekDate)
        XCTAssertEqual(third.weekNumber, 3)
        XCTAssertEqual(third.startingDrinkBudget, 14)
        XCTAssertEqual(third.drinkUnit, .drinks)
        XCTAssertEqual(first.drinkUnit, .units)
    }

    func testConsecutiveCompletedWeeksProduceBestStreak() {
        let first = completedWeek(number: 1)
        let second = completedWeek(number: 2)
        XCTAssertEqual(Gamification.bestStreak(in: [second, first]), 2)
        XCTAssertGreaterThan(Gamification.summary(for: [first, second]).xp, 0)
    }

    func testNotificationCopyUsesTheWeeksUnit() {
        let state = NotificationManager.WeekState(
            completedWorkouts: 3,
            totalDrinks: 2,
            drinkBudget: 8,
            drinkUnit: .units
        )
        XCTAssertTrue(NotificationManager.body(for: state).contains("units"))
    }

    func testResetClearsCurrentWeekButPreservesWeek() throws {
        let week = completedWeek(number: 1)
        let drink = DrinkLog(amount: 2)
        drink.week = week
        week.drinkLogs.append(drink)
        context.insert(week)
        context.insert(drink)
        try context.save()

        try AppDataManager.resetCurrentWeek(week, in: context)

        XCTAssertEqual(week.completedWorkouts, 0)
        XCTAssertTrue(week.workoutLogs.allSatisfy { $0.notes.isEmpty && $0.completedExercises.isEmpty })
        XCTAssertTrue(week.drinkLogs.isEmpty)
        XCTAssertEqual(try context.fetch(FetchDescriptor<AppWeek>()).count, 1)
    }

    func testEraseAllDeletesHistory() throws {
        let weeks = [completedWeek(number: 1), completedWeek(number: 2)]
        weeks.forEach(context.insert)
        try context.save()

        try AppDataManager.eraseAll(weeks, in: context)

        XCTAssertTrue(try context.fetch(FetchDescriptor<AppWeek>()).isEmpty)
    }

    private func guidelineWeek(_ weekNumber: Int, starting: Int, unit: DrinkUnit) -> AppWeek {
        AppWeek(
            weekNumber: weekNumber,
            startDate: .now,
            startingDrinkBudget: starting,
            drinkUnit: unit,
            budgetRule: .guideline
        )
    }

    private func completedWeek(number: Int) -> AppWeek {
        let week = AppWeek(weekNumber: number, startDate: .now)
        week.workoutLogs = WorkoutDay.allCases.map { day in
            let log = WorkoutLog(workoutDay: day)
            log.week = week
            log.notes = "Done"
            log.completedExercises = ["exercise"]
            log.markCompleted()
            return log
        }
        return week
    }
}
