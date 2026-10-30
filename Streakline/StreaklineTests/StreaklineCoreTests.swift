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
            for: AppWeek.self, WorkoutLog.self, DrinkLog.self, ProgrammeState.self,
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

    func testTwoOfThreeSessionsHoldTheStreakWithoutPerfectWeekXP() throws {
        let start = try programmeDate(year: 2026, month: 8, day: 3)
        let first = try advance(to: start, completing: 2)
        let second = try advance(to: try addingDays(7, to: start), completing: 2)
        let third = try advance(to: try addingDays(14, to: start), completing: 2)
        let fourth = try advance(to: try addingDays(21, to: start), completing: 0)

        XCTAssertEqual(fourth.weekNumber, 4)
        XCTAssertEqual(WeekManager.streak(in: context, currentWeekNumber: fourth.weekNumber), 3)
        XCTAssertTrue([first, second, third].allSatisfy(\.holdsStreak))
        XCTAssertTrue([first, second, third].allSatisfy { !$0.isPerfectWeek && !$0.isFullyComplete })
        XCTAssertEqual(try shieldsAvailable(), 0)

        let summary = Gamification.summary(for: [first, second, third], now: first.startDate)
        XCTAssertEqual(summary.totalWorkouts, 6)
        XCTAssertEqual(summary.totalDryDays, 0)
        XCTAssertEqual(summary.xp, 300)
        XCTAssertEqual(Gamification.bestStreak(in: [first, second, third]), 3)
        XCTAssertFalse(summary.badges.first { $0.id == "perfect-week" }?.isUnlocked ?? true)
    }

    func testOneSessionWithoutAShieldBreaksTheStreak() throws {
        let start = try programmeDate(year: 2026, month: 8, day: 3)
        let first = try advance(to: start, completing: 2)
        let missed = try advance(to: try addingDays(7, to: start), completing: 1)
        let third = try advance(to: try addingDays(14, to: start), completing: 2)
        let current = try advance(to: try addingDays(21, to: start), completing: 0)

        XCTAssertFalse(missed.holdsStreak)
        XCTAssertFalse(missed.shieldUsed)
        XCTAssertEqual(try shieldsAvailable(), 0)
        XCTAssertEqual(WeekManager.streak(in: context, currentWeekNumber: current.weekNumber), 1)
        XCTAssertEqual(Gamification.bestStreak(in: [first, missed, third]), 1)
    }

    func testPerfectWeekRolloverGrantsOneShield() throws {
        let start = try programmeDate(year: 2026, month: 8, day: 3)
        let first = try advance(to: start, completing: 3)
        XCTAssertTrue(first.isPerfectWeek)
        XCTAssertTrue(first.isFullyComplete)
        XCTAssertEqual(try shieldsAvailable(), 0)

        let second = try advance(to: try addingDays(7, to: start), completing: 0)
        XCTAssertEqual(second.weekNumber, 2)
        XCTAssertEqual(try shieldsAvailable(), 1)
        XCTAssertFalse(first.shieldUsed)
        XCTAssertEqual(WeekManager.streak(in: context, currentWeekNumber: second.weekNumber), 1)
    }

    func testMissedWeekSpendsShieldAndStaysOnTheStreak() throws {
        let start = try programmeDate(year: 2026, month: 8, day: 3)
        let first = try advance(to: start, completing: 3)
        let missed = try advance(to: try addingDays(7, to: start), completing: 1)

        XCTAssertEqual(try shieldsAvailable(), 1)
        XCTAssertFalse(missed.shieldUsed, "An open week does not spend a shield")

        let third = try advance(to: try addingDays(14, to: start), completing: 0)
        XCTAssertTrue(missed.shieldUsed)
        XCTAssertFalse(missed.holdsStreak)
        XCTAssertEqual(try shieldsAvailable(), 0)
        XCTAssertEqual(WeekManager.streak(in: context, currentWeekNumber: third.weekNumber), 2)
        XCTAssertEqual(Gamification.bestStreak(in: [first, missed]), 2)
    }

    func testSecondPerfectWeekDoesNotRaiseShieldsAboveOne() throws {
        let start = try programmeDate(year: 2026, month: 8, day: 3)
        _ = try advance(to: start, completing: 3)
        let second = try advance(to: try addingDays(7, to: start), completing: 3)
        XCTAssertEqual(try shieldsAvailable(), 1)

        let third = try advance(to: try addingDays(14, to: start), completing: 0)
        XCTAssertEqual(third.weekNumber, 3)
        XCTAssertTrue(second.isPerfectWeek)
        XCTAssertFalse(second.shieldUsed)
        XCTAssertEqual(try shieldsAvailable(), 1)
    }

    func testDefaultPlanSplitsFridayAndSaturday() {
        let pints = guidelineWeek(1, starting: 7, unit: .pints)
        XCTAssertEqual(pints.drinkBudget, 7)
        XCTAssertFalse(pints.planCustomized)
        XCTAssertEqual(pints.plannedAmounts, [0, 0, 0, 0, 3.5, 3.5, 0])

        let units = guidelineWeek(1, starting: 5, unit: .units)
        XCTAssertEqual(units.drinkBudget, 5)
        XCTAssertEqual(units.plannedAmounts, [0, 0, 0, 0, 2, 3, 0])
        XCTAssertEqual(units.plannedMonday, -1)
    }

    func testCustomPlanStaysWithinTheBudget() {
        let units = guidelineWeek(1, starting: 5, unit: .units)
        let moved = units.adjusting(units.plannedAmounts, by: -1, onNight: 5)
        let wednesday = units.adjusting(moved.amounts, by: 1, onNight: 2)
        XCTAssertNil(wednesday.refusedUnplaced)
        XCTAssertEqual(wednesday.amounts, [0, 0, 1, 0, 2, 2, 0])
        units.saveCustomPlan(wednesday.amounts)
        XCTAssertTrue(units.planCustomized)
        XCTAssertEqual(units.plannedWednesday, 1)
        XCTAssertEqual(units.drinkBudget, 5)

        units.saveCustomPlan([0, 0, 0, 0, 0, 0, 0])
        XCTAssertEqual(units.plannedAmounts, [0, 0, 0, 0, 0, 0, 0])

        units.saveCustomPlan([0, 0, 5, 0, 0, 0, 0])
        let refused = units.adjusting(units.plannedAmounts, by: 1, onNight: 0)
        XCTAssertEqual(refused.amounts, units.plannedAmounts)
        XCTAssertEqual(refused.refusedUnplaced, 0)
        XCTAssertEqual(units.planLimitMessage(unplaced: 0), "0 units left")
        XCTAssertEqual(units.drinkBudget, 5)

        units.saveCustomPlan([0, 0, 6, 0, 0, 0, 0])
        XCTAssertEqual(units.plannedWednesday, 5)

        let pints = guidelineWeek(1, starting: 7, unit: .pints)
        let short = [0.0, 0, 0, 0, 3.5, 3, 0]
        let placed = pints.adjusting(short, by: 0.5, onNight: 2)
        XCTAssertEqual(placed.amounts[2], 0.5)
        XCTAssertNil(placed.refusedUnplaced)
        let over = pints.adjusting(short, by: 1, onNight: 2)
        XCTAssertEqual(over.amounts, short)
        XCTAssertEqual(over.refusedUnplaced, 0.5)
        XCTAssertEqual(pints.planLimitMessage(unplaced: 0.5), "0.5 pints left")
        XCTAssertEqual(pints.drinkBudget, 7)
    }

    func testLoggingIgnoresTheNightPlan() throws {
        let calendar = Calendar.current
        let monday = WeekManager.mondayOfWeek(for: .now, calendar: calendar)
        let wednesday = try XCTUnwrap(calendar.date(byAdding: .day, value: 2, to: monday))
        let week = AppWeek(
            weekNumber: 1,
            startDate: monday,
            startingDrinkBudget: 7,
            drinkUnit: .pints,
            budgetRule: .guideline
        )
        context.insert(week)

        let before = Gamification.dayStates(for: week, now: wednesday, calendar: calendar)
        XCTAssertEqual(before, [.dry, .dry, .today, .future, .planned, .planned, .future])
        XCTAssertEqual(Gamification.dryDayCount(in: week, now: wednesday, calendar: calendar), 2)
        XCTAssertEqual(week.plannedAmounts[0], 0)

        let log = DrinkLog(date: monday, amount: week.drinkUnit.step)
        log.week = week
        week.drinkLogs.append(log)
        context.insert(log)

        XCTAssertEqual(week.totalDrinks, 0.5)
        XCTAssertFalse(week.planCustomized)
        XCTAssertEqual(week.plannedAmounts[0], 0)
        XCTAssertEqual(week.drinkBudget, 7)
        let after = Gamification.dayStates(for: week, now: wednesday, calendar: calendar)
        XCTAssertEqual(after[0], .drank)
        XCTAssertEqual(after[4], .planned)
        XCTAssertEqual(Gamification.dryDayCount(in: week, now: wednesday, calendar: calendar), 1)
    }

    func testResetPlanReturnsToTheWeekendDefault() {
        let week = guidelineWeek(1, starting: 5, unit: .units)
        week.saveCustomPlan([0, 0, 2, 0, 0, 3, 0])
        XCTAssertTrue(week.planCustomized)

        week.resetPlanToWeekend()

        XCTAssertFalse(week.planCustomized)
        XCTAssertEqual(week.plannedMonday, -1)
        XCTAssertEqual(week.plannedWednesday, -1)
        XCTAssertEqual(week.plannedSaturday, -1)
        XCTAssertEqual(week.plannedAmounts, [0, 0, 0, 0, 2, 3, 0])
        XCTAssertEqual(week.drinkBudget, 5)
    }

    func testNewWeekDoesNotCopyACustomNightPlan() throws {
        UserDefaults.standard.set(10, forKey: ProgramPreferences.startingBudgetKey)
        UserDefaults.standard.set(DrinkUnit.pints.rawValue, forKey: DrinkUnit.storageKey)

        let firstDate = try programmeDate(year: 2026, month: 8, day: 3)
        let first = WeekManager.currentWeek(in: context, now: firstDate)
        first.saveCustomPlan([0, 0, 2, 0, 0, 0, 0])
        try context.save()
        XCTAssertTrue(first.planCustomized)
        XCTAssertEqual(first.plannedWednesday, 2)

        let second = WeekManager.currentWeek(in: context, now: try addingDays(7, to: firstDate))
        XCTAssertNotEqual(second.weekNumber, first.weekNumber)
        XCTAssertFalse(second.planCustomized)
        XCTAssertEqual(second.plannedMonday, -1)
        XCTAssertEqual(second.plannedWednesday, -1)
        XCTAssertEqual(second.plannedAmounts[2], 0)
        XCTAssertEqual(second.plannedAmounts[4], 5)
        XCTAssertEqual(second.plannedAmounts[5], 5)
        XCTAssertTrue(first.planCustomized)
        XCTAssertEqual(first.plannedWednesday, 2)
    }

    func testReceiptRatesAreTheUKPlanningAverages() {
        XCTAssertEqual(ReceiptEstimates.rate(for: .pints).price, pounds(550))
        XCTAssertEqual(ReceiptEstimates.rate(for: .pints).kcal, 220)
        XCTAssertEqual(ReceiptEstimates.rate(for: .units).price, pounds(240))
        XCTAssertEqual(ReceiptEstimates.rate(for: .units).kcal, 95)
        XCTAssertEqual(ReceiptEstimates.rate(for: .drinks).price, pounds(600))
        XCTAssertEqual(ReceiptEstimates.rate(for: .drinks).kcal, 140)
    }

    func testThreeGuidelinePintsShowAboutSixteenFiftyAndSixSixtyKcal() throws {
        let week = try receiptWeek(unit: .pints, starting: 10, total: 3, completed: Set(WorkoutDay.allCases))
        XCTAssertEqual(week.budgetRule, .guideline)
        XCTAssertEqual(week.drinkBudget, 10)

        let receipt = ReceiptEstimates(week: week, calendar: receiptCalendar)
        XCTAssertEqual(receipt.spent, pounds(1650))
        XCTAssertEqual(receipt.kcal, 660)
        XCTAssertEqual(receipt.unspent, pounds(3850))
        XCTAssertEqual(receipt.line, "3 pints · about £16.50 · about 660 kcal")
        XCTAssertTrue(receipt.line.contains("about") || receipt.line.contains("est."))
        XCTAssertEqual(
            ReceiptEstimates.disclaimer,
            "Estimates use average pub prices and typical drink calories. They are not a measure of your night."
        )

        let half = try receiptWeek(unit: .pints, starting: 10, total: 2.5, completed: Set(WorkoutDay.allCases))
        let halfReceipt = ReceiptEstimates(week: half, calendar: receiptCalendar)
        XCTAssertEqual(halfReceipt.spent, pounds(1375))
        XCTAssertEqual(halfReceipt.kcal, 550)
    }

    func testReceiptPricesTheWeekInItsOwnUnit() throws {
        let units = try receiptWeek(unit: .units, starting: 14, total: 3, completed: Set(WorkoutDay.allCases))
        let unitReceipt = ReceiptEstimates(week: units, calendar: receiptCalendar)
        XCTAssertEqual(unitReceipt.spent, pounds(720))
        XCTAssertEqual(unitReceipt.kcal, 285)
        XCTAssertEqual(unitReceipt.line, "3 units · about £7.20 · about 285 kcal")

        let drinks = try receiptWeek(unit: .drinks, starting: 8, total: 3, completed: Set(WorkoutDay.allCases))
        let drinkReceipt = ReceiptEstimates(week: drinks, calendar: receiptCalendar)
        XCTAssertEqual(drinkReceipt.spent, pounds(1800))
        XCTAssertEqual(drinkReceipt.kcal, 420)
        XCTAssertEqual(drinkReceipt.line, "3 drinks · about £18.00 · about 420 kcal")
    }

    func testOverBudgetReceiptHasZeroUnspentAndNoSaving() throws {
        let week = try receiptWeek(unit: .pints, starting: 6, total: 8, completed: Set(WorkoutDay.allCases))
        XCTAssertEqual(week.drinkBudget, 6)
        XCTAssertTrue(week.isOverBudget)

        let receipt = ReceiptEstimates(week: week, calendar: receiptCalendar)
        XCTAssertEqual(receipt.spent, pounds(4400))
        XCTAssertEqual(receipt.kcal, 1760)
        XCTAssertEqual(receipt.unspent, 0)
        XCTAssertEqual(receipt.line, "8 pints · about £44.00 · about 1760 kcal")
        XCTAssertFalse(receipt.line.localizedCaseInsensitiveContains("sav"))
        XCTAssertTrue(receipt.spentText.contains("about") || receipt.spentText.contains("est."))
        XCTAssertTrue(receipt.calorieText.contains("about") || receipt.calorieText.contains("est."))
    }

    func testSessionClauseDisappearsWhenEverySlotIsComplete() throws {
        let week = try receiptWeek(
            unit: .pints,
            starting: 10,
            total: 3,
            templates: [.dayA: .easyRun, .dayB: .fullBody, .dayC: .longRun],
            completed: Set(WorkoutDay.allCases)
        )
        let receipt = ReceiptEstimates(week: week, calendar: receiptCalendar)
        XCTAssertNil(receipt.sessionClause)
        XCTAssertFalse(receipt.line.contains("still open"))
        XCTAssertTrue(receipt.line.contains("about £16.50"))
    }

    func testOneOpenSlotAfterADrinkNamesTheNextWeekday() throws {
        let calendar = receiptCalendar
        let friday = try receiptDate(year: 2026, month: 10, day: 2, calendar: calendar)
        let monday = try XCTUnwrap(calendar.date(byAdding: .day, value: -4, to: friday))
        let week = try receiptWeek(
            unit: .pints,
            starting: 10,
            total: 3,
            on: friday,
            start: monday,
            templates: [.dayA: .easyRun, .dayB: .fullBody, .dayC: .longRun],
            completed: [.dayA, .dayB]
        )
        let earlier = DrinkLog(date: try receiptDate(year: 2026, month: 9, day: 28, calendar: calendar), amount: 1)
        earlier.week = week
        week.drinkLogs.append(earlier)
        context.insert(earlier)

        let receipt = ReceiptEstimates(week: week, calendar: calendar)
        XCTAssertEqual(receipt.sessionClause, "Saturday's long run is still open")
        XCTAssertTrue(receipt.line.contains("about £"))
        XCTAssertTrue(receipt.line.contains("Saturday's long run is still open"))
    }

    func testSeveralOpenSlotsUseDayABCOrder() throws {
        let calendar = receiptCalendar
        let friday = try receiptDate(year: 2026, month: 10, day: 2, calendar: calendar)
        let week = try receiptWeek(
            unit: .pints,
            starting: 10,
            total: 3,
            on: friday,
            templates: [.dayA: .easyRun, .dayB: .fullBody, .dayC: .longRun],
            completed: [.dayA]
        )
        let receipt = ReceiptEstimates(week: week, calendar: calendar)
        XCTAssertEqual(receipt.sessionClause, "Full body is still open")
        XCTAssertFalse(receipt.line.contains("Saturday"))
    }

    func testNoPlannedNightsOmitTheWeekday() throws {
        let calendar = receiptCalendar
        let friday = try receiptDate(year: 2026, month: 10, day: 2, calendar: calendar)
        let week = try receiptWeek(
            unit: .pints,
            starting: 10,
            total: 3,
            on: friday,
            templates: [.dayA: .easyRun, .dayB: .fullBody, .dayC: .longRun],
            completed: [.dayA, .dayB]
        )
        week.saveCustomPlan([0, 0, 0, 0, 0, 0, 0])
        let receipt = ReceiptEstimates(week: week, calendar: calendar)
        XCTAssertEqual(receipt.sessionClause, "Long run is still open")
        XCTAssertTrue(receipt.showsOnStrip)
    }

    func testReceiptStaysHiddenUntilThereIsADrink() throws {
        let week = try receiptWeek(unit: .pints, starting: 10, total: 0)
        let receipt = ReceiptEstimates(week: week, calendar: receiptCalendar)
        XCTAssertFalse(receipt.showsOnStrip)
        XCTAssertEqual(receipt.spent, 0)
        XCTAssertEqual(receipt.kcal, 0)
    }

    func testSaturdayMorningAfterFridayDrinksNamesTheOpenSlot() throws {
        let calendar = morningCalendar
        let start = calendar.startOfDay(for: try morningDate(year: 2026, month: 10, day: 26, hour: 8, calendar: calendar))
        let friday = try morningDate(year: 2026, month: 10, day: 30, hour: 21, calendar: calendar)
        let saturday = try morningDate(year: 2026, month: 10, day: 31, hour: 8, calendar: calendar)
        XCTAssertEqual(calendar.component(.weekday, from: friday), 6)
        XCTAssertEqual(calendar.component(.weekday, from: saturday), 7)

        let week = morningWeek(number: 1, start: start)
        attachDrink(amount: 2, on: friday, to: week)
        attachSlot(.dayA, template: .easyRun, to: week, completedAt: friday)
        attachSlot(.dayB, template: .fullBody, to: week)
        attachSlot(.dayC, template: .longRun, to: week)

        let line = MorningLine.sentence(week: week, now: saturday, calendar: calendar)
        XCTAssertEqual(
            line,
            "You drank last night. Full body still counts, and it\u{2019}s worth more if you show up."
        )
        XCTAssertFalse(line?.contains("Day A") ?? true)
        XCTAssertFalse(line?.contains("Day B") ?? true)
    }

    func testSoberMorningAndAFinishedWeekShowNoMorningLine() throws {
        let calendar = morningCalendar
        let start = calendar.startOfDay(for: try morningDate(year: 2026, month: 10, day: 26, hour: 8, calendar: calendar))
        let friday = try morningDate(year: 2026, month: 10, day: 30, hour: 21, calendar: calendar)
        let saturday = try morningDate(year: 2026, month: 10, day: 31, hour: 8, calendar: calendar)

        let sober = morningWeek(number: 1, start: start)
        attachSlot(.dayA, template: .easyRun, to: sober)
        XCTAssertNil(MorningLine.sentence(week: sober, now: saturday, calendar: calendar))

        let zero = morningWeek(number: 2, start: start)
        attachDrink(amount: 0, on: friday, to: zero)
        attachSlot(.dayA, template: .easyRun, to: zero)
        XCTAssertNil(MorningLine.sentence(week: zero, now: saturday, calendar: calendar))

        let done = morningWeek(number: 3, start: start)
        attachDrink(amount: 2, on: friday, to: done)
        attachSlot(.dayA, template: .easyRun, to: done, completedAt: saturday)
        attachSlot(.dayB, template: .fullBody, to: done, completedAt: saturday)
        attachSlot(.dayC, template: .longRun, to: done, completedAt: saturday)
        XCTAssertNil(MorningLine.sentence(week: done, now: saturday, calendar: calendar))
    }

    func testMondayMorningReadsSundayDrinksFromThePreviousWeek() throws {
        let calendar = morningCalendar
        let previousStart = calendar.startOfDay(for: try morningDate(year: 2026, month: 10, day: 26, hour: 8, calendar: calendar))
        let sunday = try morningDate(year: 2026, month: 11, day: 1, hour: 22, calendar: calendar)
        let monday = try morningDate(year: 2026, month: 11, day: 2, hour: 8, calendar: calendar)
        XCTAssertEqual(calendar.component(.weekday, from: monday), 2)

        let previous = morningWeek(number: 1, start: previousStart)
        attachDrink(amount: 1, on: sunday, to: previous)
        let current = morningWeek(number: 2, start: calendar.startOfDay(for: monday))
        attachSlot(.dayA, template: .easyRun, to: current)

        let line = MorningLine.sentence(
            week: current,
            now: monday,
            calendar: calendar,
            previousWeek: previous
        )
        XCTAssertEqual(
            line,
            "You drank last night. Easy run still counts, and it\u{2019}s worth more if you show up."
        )
        XCTAssertNil(MorningLine.sentence(week: current, now: monday, calendar: calendar))
    }

    func testMorningAfterDrinksPaysEightyAndADryMorningStaysFifty() throws {
        let calendar = morningCalendar
        let monday = try morningDate(year: 2026, month: 10, day: 26, hour: 8, calendar: calendar)
        let start = calendar.startOfDay(for: monday)
        let wednesday = try morningDate(year: 2026, month: 10, day: 28, hour: 9, calendar: calendar)
        let friday = try morningDate(year: 2026, month: 10, day: 30, hour: 21, calendar: calendar)
        let saturday = try morningDate(year: 2026, month: 10, day: 31, hour: 8, calendar: calendar)

        let week = morningWeek(number: 1, start: start)
        attachDrink(amount: 2, on: friday, to: week)
        attachSlot(.dayA, template: .easyRun, to: week, completedAt: wednesday)
        attachSlot(.dayB, template: .fullBody, to: week, completedAt: saturday, exercises: ["Squat"])
        attachSlot(.dayC, template: .longRun, to: week)

        let summary = Gamification.summary(for: [week], now: start, calendar: calendar)
        XCTAssertEqual(summary.totalDryDays, 0)
        XCTAssertEqual(summary.totalWorkouts, 2)
        XCTAssertFalse(week.isFullyComplete)
        XCTAssertEqual(summary.xp, 140)
        XCTAssertEqual(week.drinkBudget, 10)
        XCTAssertEqual(try shieldsAvailable(), 0)
    }

    func testTwoSlotsTheMorningAfterEachEarnEighty() throws {
        let calendar = morningCalendar
        let start = calendar.startOfDay(for: try morningDate(year: 2026, month: 10, day: 26, hour: 8, calendar: calendar))
        let friday = try morningDate(year: 2026, month: 10, day: 30, hour: 21, calendar: calendar)
        let saturday = try morningDate(year: 2026, month: 10, day: 31, hour: 8, calendar: calendar)

        let week = morningWeek(number: 1, start: start)
        attachDrink(amount: 1, on: friday, to: week)
        attachSlot(.dayA, template: .easyRun, to: week, completedAt: saturday, exercises: ["Run"])
        attachSlot(.dayB, template: .fullBody, to: week, completedAt: saturday)
        attachSlot(.dayC, template: .longRun, to: week)

        let summary = Gamification.summary(for: [week], now: start, calendar: calendar)
        XCTAssertEqual(summary.totalWorkouts, 2)
        XCTAssertFalse(week.isFullyComplete)
        XCTAssertEqual(summary.xp, 170)
    }

    func testCompletionWithoutATimeStaysAtFifty() throws {
        let calendar = morningCalendar
        let start = calendar.startOfDay(for: try morningDate(year: 2026, month: 10, day: 26, hour: 8, calendar: calendar))
        let friday = try morningDate(year: 2026, month: 10, day: 30, hour: 21, calendar: calendar)
        let saturday = try morningDate(year: 2026, month: 10, day: 31, hour: 8, calendar: calendar)

        let week = morningWeek(number: 1, start: start)
        attachDrink(amount: 2, on: friday, to: week)
        let log = attachSlot(.dayA, template: .easyRun, to: week, completedWithoutTime: true)
        XCTAssertTrue(log.isCompleted)
        XCTAssertNil(log.completedAt)

        let summary = Gamification.summary(for: [week], now: start, calendar: calendar)
        XCTAssertEqual(summary.totalDryDays, 0)
        XCTAssertEqual(summary.xp, 50)
    }

    func testUndoDropsTheMorningAfterBonus() throws {
        let calendar = morningCalendar
        let start = calendar.startOfDay(for: try morningDate(year: 2026, month: 10, day: 26, hour: 8, calendar: calendar))
        let friday = try morningDate(year: 2026, month: 10, day: 30, hour: 21, calendar: calendar)
        let saturday = try morningDate(year: 2026, month: 10, day: 31, hour: 8, calendar: calendar)

        let week = morningWeek(number: 1, start: start)
        attachDrink(amount: 2, on: friday, to: week)
        let log = attachSlot(.dayA, template: .easyRun, to: week, completedAt: saturday)
        XCTAssertEqual(Gamification.summary(for: [week], now: start, calendar: calendar).xp, 80)

        log.undoCompletion()
        let after = Gamification.summary(for: [week], now: start, calendar: calendar)
        XCTAssertEqual(after.xp, 0)
        XCTAssertEqual(after.totalWorkouts, 0)
        XCTAssertNil(log.completedAt)
    }

    func testMondayWorkoutAfterSundayDrinksIsEighty() throws {
        let calendar = morningCalendar
        let previousStart = calendar.startOfDay(for: try morningDate(year: 2026, month: 10, day: 26, hour: 8, calendar: calendar))
        let sunday = try morningDate(year: 2026, month: 11, day: 1, hour: 22, calendar: calendar)
        let monday = try morningDate(year: 2026, month: 11, day: 2, hour: 8, calendar: calendar)

        let previous = morningWeek(number: 1, start: previousStart)
        attachDrink(amount: 1, on: sunday, to: previous)
        let current = morningWeek(number: 2, start: calendar.startOfDay(for: monday))
        attachSlot(.dayA, template: .easyRun, to: current, completedAt: monday)

        let summary = Gamification.summary(for: [previous, current], now: previousStart, calendar: calendar)
        XCTAssertEqual(summary.totalDryDays, 0)
        XCTAssertEqual(summary.xp, 80)
    }

    func testPerfectWeekBonusStaysOneHundredFifty() throws {
        let calendar = morningCalendar
        let start = calendar.startOfDay(for: try morningDate(year: 2026, month: 10, day: 26, hour: 8, calendar: calendar))
        let wednesday = try morningDate(year: 2026, month: 10, day: 28, hour: 9, calendar: calendar)
        let thursday = try morningDate(year: 2026, month: 10, day: 29, hour: 9, calendar: calendar)
        let friday = try morningDate(year: 2026, month: 10, day: 30, hour: 21, calendar: calendar)
        let saturday = try morningDate(year: 2026, month: 10, day: 31, hour: 8, calendar: calendar)

        let week = morningWeek(number: 1, start: start)
        attachDrink(amount: 2, on: friday, to: week)
        attachSlot(.dayA, template: .easyRun, to: week, completedAt: wednesday)
        attachSlot(.dayB, template: .fullBody, to: week, completedAt: thursday)
        attachSlot(.dayC, template: .longRun, to: week, completedAt: saturday)

        XCTAssertTrue(week.isFullyComplete)
        XCTAssertEqual(week.drinkBudget, 10)
        let summary = Gamification.summary(for: [week], now: start, calendar: calendar)
        XCTAssertEqual(summary.totalDryDays, 0)
        XCTAssertEqual(summary.xp, 330)
    }

    func testDrinksOverBudgetLeaveTheCompletedWorkout() throws {
        let calendar = morningCalendar
        let saturday = try morningDate(year: 2026, month: 10, day: 31, hour: 8, calendar: calendar)
        let start = calendar.startOfDay(for: try morningDate(year: 2026, month: 10, day: 26, hour: 8, calendar: calendar))
        let week = morningWeek(number: 1, start: start)
        let log = attachSlot(.dayA, template: .easyRun, to: week, completedAt: saturday, exercises: ["Run"])
        let completedAt = try XCTUnwrap(log.completedAt)
        let logsBefore = week.workoutLogs.count

        // HomeView.addDrink only grows a DrinkLog. Repeat that write until the week is over budget.
        let step = week.drinkUnit.step
        var logged = 0.0
        while logged <= Double(week.drinkBudget) {
            if let todays = week.drinkLogs.first(where: { calendar.isDate($0.date, inSameDayAs: saturday) }) {
                todays.amount += step
            } else {
                attachDrink(amount: step, on: saturday, to: week)
            }
            logged += step
        }

        XCTAssertTrue(week.isOverBudget)
        XCTAssertTrue(log.isCompleted)
        XCTAssertEqual(log.completedAt, completedAt)
        XCTAssertEqual(log.completedExercises, ["Run"])
        XCTAssertEqual(week.workoutLogs.count, logsBefore)
        XCTAssertEqual(Gamification.summary(for: [week], now: start, calendar: calendar).totalWorkouts, 1)
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
        context.insert(ProgrammeState(shieldsAvailable: 1))
        try context.save()

        try AppDataManager.eraseAll(weeks, in: context)

        XCTAssertTrue(try context.fetch(FetchDescriptor<AppWeek>()).isEmpty)
        XCTAssertTrue(try context.fetch(FetchDescriptor<ProgrammeState>()).isEmpty)
    }

    func testWeekSealSelectsPerfectHeldShieldAndMissed() throws {
        let calendar = morningCalendar
        let perfect = try receiptWeek(unit: .pints, starting: 10, total: 3, completed: Set(WorkoutDay.allCases))
        let perfectSeal = WeekSeal(week: perfect, now: .now, calendar: calendar, isOpenWeek: false, shieldAvailable: false)
        XCTAssertEqual(perfectSeal.outcome, .perfect)
        XCTAssertEqual(perfectSeal.slotsText, "3 of 3")
        XCTAssertEqual(perfectSeal.drinksText, "3 of 10 pints")
        XCTAssertEqual(perfectSeal.moneyNotSpent, pounds(3850))
        XCTAssertEqual(perfectSeal.moneyNotSpentText, "about £38.50 not spent")
        XCTAssertEqual(perfectSeal.outcomeText, "Perfect week")

        let held = try receiptWeek(unit: .pints, starting: 10, total: 3, completed: [.dayA, .dayB])
        let heldSeal = WeekSeal(week: held, now: .now, calendar: calendar, isOpenWeek: false, shieldAvailable: true)
        XCTAssertTrue(held.holdsStreak)
        XCTAssertFalse(held.isPerfectWeek)
        XCTAssertEqual(heldSeal.outcome, .held)
        XCTAssertEqual(heldSeal.slotsText, "2 of 3")
        XCTAssertEqual(heldSeal.outcomeText, "Streak held")
        XCTAssertNil(heldSeal.closingNote)

        let shielded = try receiptWeek(unit: .pints, starting: 10, total: 1, completed: [.dayA])
        shielded.shieldUsed = true
        let shieldSeal = WeekSeal(week: shielded, now: .now, calendar: calendar, isOpenWeek: false, shieldAvailable: false)
        XCTAssertFalse(shielded.holdsStreak)
        XCTAssertEqual(shieldSeal.outcome, .shieldUsed)
        XCTAssertEqual(shieldSeal.outcomeText, "Shield used")
        XCTAssertNil(shieldSeal.closingNote)

        let missed = try receiptWeek(unit: .pints, starting: 10, total: 1, completed: [.dayA])
        let missedSeal = WeekSeal(week: missed, now: .now, calendar: calendar, isOpenWeek: false, shieldAvailable: false)
        XCTAssertEqual(missedSeal.outcome, .missed)
        XCTAssertEqual(missedSeal.outcomeText, "Missed")
        XCTAssertEqual(missedSeal.slotsCompleted, 1)
    }

    func testWeekSealOmitsMoneyWhenNothingIsUnspent() throws {
        let calendar = morningCalendar
        let over = try receiptWeek(unit: .pints, starting: 6, total: 8, completed: Set(WorkoutDay.allCases))
        let overSeal = WeekSeal(week: over, now: .now, calendar: calendar, isOpenWeek: false, shieldAvailable: false)
        XCTAssertTrue(over.isOverBudget)
        XCTAssertFalse(over.isPerfectWeek)
        XCTAssertEqual(overSeal.outcome, .missed)
        XCTAssertNil(overSeal.moneyNotSpent)
        XCTAssertNil(overSeal.moneyNotSpentText)
        XCTAssertEqual(ReceiptEstimates(week: over, calendar: calendar).unspent, 0)

        let exact = try receiptWeek(unit: .pints, starting: 10, total: 10, completed: [.dayA, .dayB])
        let exactSeal = WeekSeal(week: exact, now: .now, calendar: calendar, isOpenWeek: false, shieldAvailable: false)
        XCTAssertEqual(exactSeal.outcome, .held)
        XCTAssertNil(exactSeal.moneyNotSpent)
        XCTAssertNil(exactSeal.moneyNotSpentText)

        let dry = try receiptWeek(unit: .units, starting: 14, total: 0, completed: [.dayA, .dayB])
        let drySeal = WeekSeal(week: dry, now: .now, calendar: calendar, isOpenWeek: false, shieldAvailable: false)
        XCTAssertEqual(drySeal.drinksText, "0 of 14 units")
        XCTAssertEqual(drySeal.moneyNotSpent, ReceiptEstimates(week: dry, calendar: calendar).unspent)
        XCTAssertEqual(drySeal.moneyNotSpentText, "about £33.60 not spent")
    }

    func testSundayCanSealAndWednesdayCannot() throws {
        let calendar = morningCalendar
        let start = calendar.startOfDay(for: try morningDate(year: 2026, month: 10, day: 26, hour: 8, calendar: calendar))
        let wednesday = try morningDate(year: 2026, month: 10, day: 28, hour: 12, calendar: calendar)
        let sunday = try morningDate(year: 2026, month: 11, day: 1, hour: 18, calendar: calendar)
        let nextMonday = try morningDate(year: 2026, month: 11, day: 2, hour: 8, calendar: calendar)
        XCTAssertEqual(calendar.component(.weekday, from: sunday), 1)
        XCTAssertEqual(calendar.component(.weekday, from: wednesday), 4)

        XCTAssertTrue(WeekSeal.showsOnHome(now: sunday, calendar: calendar))
        XCTAssertFalse(WeekSeal.showsOnHome(now: wednesday, calendar: calendar))

        let week = try receiptWeek(unit: .pints, starting: 10, total: 2, start: start, completed: [.dayA, .dayB])
        XCTAssertFalse(WeekSeal.isPastWeek(week, now: wednesday, calendar: calendar))
        XCTAssertFalse(WeekSeal.isPastWeek(week, now: sunday, calendar: calendar))
        XCTAssertTrue(WeekSeal.isPastWeek(week, now: nextMonday, calendar: calendar))

        let openSunday = WeekSeal(week: week, now: sunday, calendar: calendar, isOpenWeek: true, shieldAvailable: false)
        XCTAssertEqual(openSunday.title, "Season 1, week 1 of 8")
        XCTAssertEqual(openSunday.season.heading, openSunday.title)
        XCTAssertEqual(openSunday.outcome, .held)

        let openWednesday = WeekSeal(week: week, now: wednesday, calendar: calendar, isOpenWeek: true, shieldAvailable: false)
        XCTAssertEqual(openWednesday.title, "Season 1, week 1 of 8")
        XCTAssertFalse(WeekSeal.showsOnHome(now: wednesday, calendar: calendar))

        let past = WeekSeal(week: week, now: sunday, calendar: calendar, isOpenWeek: false, shieldAvailable: true)
        XCTAssertEqual(past.title, "Season 1, week 1 of 8")
        XCTAssertNil(past.closingNote)
    }

    func testOpenMissLeavesTheShieldUntilTheWeekCloses() throws {
        let calendar = morningCalendar
        let sunday = try morningDate(year: 2026, month: 11, day: 1, hour: 18, calendar: calendar)
        let week = try receiptWeek(unit: .pints, starting: 10, total: 4, completed: [.dayA])
        XCTAssertFalse(week.holdsStreak)
        XCTAssertFalse(week.shieldUsed)
        let before = Gamification.summary(for: [week], now: sunday, calendar: calendar).xp

        let seal = WeekSeal(week: week, now: sunday, calendar: calendar, isOpenWeek: true, shieldAvailable: true)
        XCTAssertEqual(seal.outcome, .missed)
        XCTAssertEqual(seal.closingNote, "Shield applies when the week closes")
        XCTAssertEqual(seal.title, "Season 1, week 1 of 8")
        XCTAssertFalse(week.shieldUsed)
        XCTAssertEqual(Gamification.summary(for: [week], now: sunday, calendar: calendar).xp, before)

        let withoutShield = WeekSeal(week: week, now: sunday, calendar: calendar, isOpenWeek: true, shieldAvailable: false)
        XCTAssertEqual(withoutShield.outcome, .missed)
        XCTAssertNil(withoutShield.closingNote)
        XCTAssertFalse(week.shieldUsed)
    }

    func testSeasonIndexSplitsEveryEightWeeks() {
        let weeks = plannedWeeks(count: 9, starting: 10, unit: .pints, rule: .guideline)
        let first = Season(week: weeks[0], history: weeks)
        XCTAssertEqual(first.number, 1)
        XCTAssertEqual(first.weekInSeason, 1)
        XCTAssertEqual(first.title, "Season 1")
        XCTAssertEqual(first.weekPhrase, "week 1 of 8")
        XCTAssertEqual(first.heading, "Season 1, week 1 of 8")
        XCTAssertFalse(first.isHold)

        let eighth = Season(week: weeks[7], history: weeks)
        XCTAssertEqual(eighth.number, 1)
        XCTAssertEqual(eighth.weekInSeason, 8)
        XCTAssertEqual(eighth.title, "Season 1")
        XCTAssertFalse(eighth.isHold)

        let ninth = Season(week: weeks[8], history: weeks)
        XCTAssertEqual(ninth.number, 2)
        XCTAssertEqual(ninth.weekInSeason, 1)
        XCTAssertEqual(ninth.title, "Season 2")
        XCTAssertEqual(ninth.weekPhrase, "week 1 of 8")
        XCTAssertFalse(ninth.isHold)
        XCTAssertEqual(weeks[8].drinkBudget, 6)
    }

    func testHoldStartsTheWeekAfterTheFloor() throws {
        let calendar = morningCalendar
        let sunday = try morningDate(year: 2026, month: 11, day: 1, hour: 18, calendar: calendar)
        let budgetsBefore = [10, 10, 9, 9, 8, 8, 7, 7, 6, 6]

        let pints = plannedWeeks(count: 10, starting: 10, unit: .pints, rule: .guideline)
        XCTAssertEqual(pints.map(\.drinkBudget), budgetsBefore)
        let arrived = Season(week: pints[8], history: pints)
        XCTAssertEqual(pints[8].weekNumber, 9)
        XCTAssertEqual(pints[8].drinkBudget, 6)
        XCTAssertEqual(arrived.title, "Season 2")
        XCTAssertFalse(arrived.isHold)

        let next = Season(week: pints[9], history: pints)
        XCTAssertEqual(pints[9].weekNumber, 10)
        XCTAssertEqual(pints[9].drinkBudget, 6)
        XCTAssertEqual(pints[9].startingDrinkBudget, 10)
        XCTAssertTrue(next.isHold)
        XCTAssertEqual(next.number, 2)
        XCTAssertEqual(next.weekInSeason, 2)
        XCTAssertEqual(next.title, "Hold")
        XCTAssertEqual(next.heading, "Hold, week 2 of 8")
        XCTAssertEqual(pints.map(\.drinkBudget), budgetsBefore)
        XCTAssertEqual(pints.map(\.startingDrinkBudget), Array(repeating: 10, count: 10))

        let seal = WeekSeal(
            week: pints[9],
            now: sunday,
            calendar: calendar,
            isOpenWeek: true,
            shieldAvailable: false,
            history: pints
        )
        XCTAssertEqual(seal.title, "Hold, week 2 of 8")
        XCTAssertEqual(seal.season, next)

        let legacy = plannedWeeks(count: 12, starting: 10, unit: .pints, rule: .legacy)
        let legacyPassingSix = Season(week: legacy[8], history: legacy)
        XCTAssertEqual(legacy[8].weekNumber, 9)
        XCTAssertEqual(legacy[8].drinkBudget, 6)
        XCTAssertFalse(legacyPassingSix.isHold)
        XCTAssertEqual(legacyPassingSix.title, "Season 2")

        let legacyArrived = Season(week: legacy[10], history: legacy)
        XCTAssertEqual(legacy[10].weekNumber, 11)
        XCTAssertEqual(legacy[10].drinkBudget, 5)
        XCTAssertEqual(legacyArrived.weekInSeason, 3)
        XCTAssertFalse(legacyArrived.isHold)
        XCTAssertEqual(legacyArrived.title, "Season 2")

        let legacyHold = Season(week: legacy[11], history: legacy)
        XCTAssertEqual(legacy[11].weekNumber, 12)
        XCTAssertEqual(legacy[11].drinkBudget, 5)
        XCTAssertTrue(legacyHold.isHold)
        XCTAssertEqual(legacyHold.title, "Hold")
        XCTAssertEqual(legacyHold.heading, "Hold, week 4 of 8")

        let underFloor = plannedWeeks(count: 2, starting: 5, unit: .pints, rule: .guideline)
        XCTAssertEqual(underFloor[1].drinkBudget, 5)
        XCTAssertNotEqual(underFloor[1].drinkBudget, AlcoholUnits.displayFloor(for: .pints))
        let stayedCutting = Season(week: underFloor[1], history: underFloor)
        XCTAssertFalse(stayedCutting.isHold)
        XCTAssertEqual(stayedCutting.title, "Season 1")
    }

    func testMonthComparisonDropsNinePointTwoUnitsAndIgnoresTheMiddleWeek() {
        let first = loggedWeek(number: 1, unit: .pints, drinks: 8, completedSlots: 3)
        let middle = loggedWeek(number: 2, unit: .pints, drinks: 20, completedSlots: 3)
        let current = loggedWeek(number: 3, unit: .pints, drinks: 4, completedSlots: 1)

        let comparison = MonthComparison(weeks: [current, middle, first])

        XCTAssertEqual(comparison.firstWeekUnits, 18.4, accuracy: 0.001)
        XCTAssertEqual(comparison.currentWeekUnits, 9.2, accuracy: 0.001)
        XCTAssertEqual(comparison.unitDelta, -9.2, accuracy: 0.001)
        XCTAssertEqual(comparison.deltaSentence, "Down 9.2 units from week 1.")
        XCTAssertEqual(comparison.firstWeekFigure, "18.4")
        XCTAssertEqual(comparison.currentWeekFigure, "9.2")
        XCTAssertEqual(comparison.firstWeekSlots, 3)
        XCTAssertEqual(comparison.currentWeekSlots, 1)
        XCTAssertEqual(comparison.firstWeekSlotsText, "3 of 3")
        XCTAssertEqual(comparison.currentWeekSlotsText, "1 of 3")
        XCTAssertTrue(comparison.showsComparison)
        XCTAssertFalse(comparison.unitsDiffer)
        XCTAssertEqual(first.drinkLogs.map(\.amount), [8])
        XCTAssertEqual(current.drinkLogs.map(\.amount), [4])
        XCTAssertEqual(middle.totalDrinks, 20)
    }

    func testMonthComparisonStaysOnTheBaselineUntilWeekTwo() {
        XCTAssertFalse(MonthComparison(weeks: []).showsComparison)
        XCTAssertEqual(
            MonthComparison.baselineSentence,
            "Your first week is the baseline. The comparison shows from week 2."
        )

        let onlyFirst = loggedWeek(number: 1, unit: .pints, drinks: 8, completedSlots: 3)
        let baseline = MonthComparison(weeks: [onlyFirst])
        XCTAssertFalse(baseline.showsComparison)
        XCTAssertEqual(baseline.firstWeekUnits, 18.4, accuracy: 0.001)
        XCTAssertEqual(baseline.currentWeekUnits, 18.4, accuracy: 0.001)

        let laterOnly = loggedWeek(number: 3, unit: .pints, drinks: 4, completedSlots: 1)
        XCTAssertFalse(MonthComparison(weeks: [laterOnly]).showsComparison)
    }

    func testMonthComparisonConvertsAMixedUnitPairIntoUKUnits() {
        let first = loggedWeek(number: 1, unit: .pints, drinks: 8, completedSlots: 2)
        let current = loggedWeek(number: 2, unit: .units, drinks: 10, completedSlots: 3)
        let comparison = MonthComparison(weeks: [first, current])

        XCTAssertEqual(comparison.firstWeekUnits, 18.4, accuracy: 0.001)
        XCTAssertEqual(comparison.currentWeekUnits, 10, accuracy: 0.001)
        XCTAssertEqual(comparison.unitDelta, -8.4, accuracy: 0.001)
        XCTAssertEqual(comparison.deltaSentence, "Down 8.4 units from week 1.")
        XCTAssertTrue(comparison.unitsDiffer)
        XCTAssertEqual(
            MonthComparison.mixedUnitFootnote,
            "Compared in UK units so the two weeks mean the same thing."
        )
        XCTAssertEqual(MonthComparison.logNote, "This is your log, not a health score.")
        XCTAssertEqual(first.drinkLogs.map(\.amount), [8])
        XCTAssertEqual(current.drinkLogs.map(\.amount), [10])
    }

    func testMonthComparisonSaysUpTwoAndLevelWithoutATrailingZero() {
        let dry = loggedWeek(number: 1, unit: .units, drinks: 0, completedSlots: 3)
        let twoMore = loggedWeek(number: 2, unit: .units, drinks: 2, completedSlots: 1)
        let rise = MonthComparison(weeks: [dry, twoMore])
        XCTAssertEqual(rise.unitDelta, 2, accuracy: 0.001)
        XCTAssertEqual(rise.deltaSentence, "Up 2 units from week 1.")
        XCTAssertEqual(rise.currentWeekFigure, "2")
        XCTAssertFalse(rise.unitsDiffer)

        let sameFirst = loggedWeek(number: 1, unit: .pints, drinks: 4, completedSlots: 3)
        let sameCurrent = loggedWeek(number: 4, unit: .pints, drinks: 4, completedSlots: 2)
        let level = MonthComparison(weeks: [sameCurrent, sameFirst])
        XCTAssertEqual(level.unitDelta, 0, accuracy: 0.001)
        XCTAssertEqual(level.deltaSentence, "Level with week 1.")
        XCTAssertTrue(level.showsComparison)
    }

    #if DEBUG
    func testUITestFixturesSeedHomeProgressAndOnboarding() throws {
        defer { clearFixturePreferences() }
        let now = try programmeDate(year: 2026, month: 10, day: 28)

        try UITestFixture.apply(.home, in: context, now: now)
        let home = try context.fetch(FetchDescriptor<AppWeek>(sortBy: [SortDescriptor(\.weekNumber)]))
        XCTAssertEqual(home.map(\.weekNumber), [1])
        XCTAssertEqual(home[0].drinkBudget, 10)
        XCTAssertEqual(home[0].totalDrinks, 2)
        XCTAssertEqual(home[0].completedWorkouts, 1)
        XCTAssertEqual(Season(week: home[0], history: home).heading, "Season 1, week 1 of 8")
        XCTAssertEqual(ProgrammePreset.current, .running)
        XCTAssertTrue(UserDefaults.standard.bool(forKey: ProgramPreferences.onboardingCompletedKey))

        try UITestFixture.apply(.workout, in: context, now: now)
        let workout = try XCTUnwrap(try context.fetch(FetchDescriptor<AppWeek>()).first)
        XCTAssertEqual(workout.completedWorkouts, 0)
        XCTAssertEqual(workout.totalDrinks, 2)

        try UITestFixture.apply(.progress, in: context, now: now)
        let progress = try context.fetch(FetchDescriptor<AppWeek>(sortBy: [SortDescriptor(\.weekNumber)]))
        XCTAssertEqual(progress.map(\.weekNumber), [1, 2, 3])
        XCTAssertEqual(Season(week: progress[2], history: progress).weekPhrase, "week 3 of 8")
        XCTAssertEqual(WeekManager.streak(in: context, currentWeekNumber: 3), 2)
        XCTAssertTrue(progress[0].isPerfectWeek)
        XCTAssertTrue(progress[1].isPerfectWeek)
        XCTAssertEqual(progress[2].totalDrinks, 2)

        try UITestFixture.apply(.onboarding, in: context, now: now)
        XCTAssertTrue(try context.fetch(FetchDescriptor<AppWeek>()).isEmpty)
        XCTAssertFalse(UserDefaults.standard.bool(forKey: ProgramPreferences.onboardingCompletedKey))
        XCTAssertNil(ProgrammePreset.current)
    }

    private func clearFixturePreferences() {
        for key in [
            ProgramPreferences.onboardingCompletedKey,
            ProgramPreferences.startingBudgetKey,
            DrinkUnit.storageKey,
            ProgrammePreset.storageKey,
            "notificationsEnabled",
            "reminderTime",
            "lastCelebratedRankIndex",
        ] {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }
    #endif

    private var receiptCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_GB")
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        calendar.firstWeekday = 2
        return calendar
    }

    private func pounds(_ minorUnits: Int) -> Decimal {
        Decimal(sign: .plus, exponent: -2, significand: Decimal(minorUnits))
    }

    private func receiptDate(year: Int, month: Int, day: Int, calendar: Calendar) throws -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = 12
        return try XCTUnwrap(calendar.date(from: components))
    }

    private func receiptWeek(
        unit: DrinkUnit,
        starting: Int,
        total: Double,
        on date: Date = .now,
        start: Date = .now,
        templates: [WorkoutDay: SessionTemplate] = [:],
        completed: Set<WorkoutDay> = []
    ) throws -> AppWeek {
        let week = AppWeek(
            weekNumber: 1,
            startDate: start,
            startingDrinkBudget: starting,
            drinkUnit: unit,
            budgetRule: .guideline
        )
        context.insert(week)
        if total > 0 {
            let log = DrinkLog(date: date, amount: total)
            log.week = week
            week.drinkLogs.append(log)
            context.insert(log)
        }
        for day in WorkoutDay.allCases {
            let log = WorkoutLog(
                workoutDay: day,
                isCompleted: completed.contains(day),
                sessionTemplateRaw: templates[day]?.rawValue ?? ""
            )
            log.week = week
            week.workoutLogs.append(log)
            context.insert(log)
        }
        return week
    }

    private func plannedWeeks(count: Int, starting: Int, unit: DrinkUnit, rule: BudgetRule) -> [AppWeek] {
        (1...count).map { number in
            AppWeek(
                weekNumber: number,
                startDate: .now,
                startingDrinkBudget: starting,
                drinkUnit: unit,
                budgetRule: rule
            )
        }
    }

    private func loggedWeek(number: Int, unit: DrinkUnit, drinks: Double, completedSlots: Int) -> AppWeek {
        let week = AppWeek(
            weekNumber: number,
            startDate: .now,
            startingDrinkBudget: 10,
            drinkUnit: unit,
            budgetRule: .guideline
        )
        context.insert(week)
        if drinks > 0 {
            let log = DrinkLog(date: .now, amount: drinks)
            log.week = week
            week.drinkLogs.append(log)
            context.insert(log)
        }
        for day in WorkoutDay.allCases.prefix(completedSlots) {
            let log = WorkoutLog(workoutDay: day, isCompleted: true)
            log.week = week
            week.workoutLogs.append(log)
            context.insert(log)
        }
        return week
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

    private func programmeDate(year: Int, month: Int, day: Int) throws -> Date {
        let calendar = Calendar(identifier: .iso8601)
        return try XCTUnwrap(calendar.date(from: DateComponents(year: year, month: month, day: day)))
    }

    private func addingDays(_ days: Int, to date: Date) throws -> Date {
        try XCTUnwrap(Calendar(identifier: .iso8601).date(byAdding: .day, value: days, to: date))
    }

    /// Opens the week that contains `date`, then marks the first `count` slots done.
    private func advance(to date: Date, completing count: Int) throws -> AppWeek {
        let week = WeekManager.currentWeek(in: context, now: date)
        for day in WorkoutDay.allCases.prefix(count) {
            try XCTUnwrap(week.log(for: day)).markCompleted()
        }
        try context.save()
        return week
    }

    private func shieldsAvailable() throws -> Int {
        let rows = try context.fetch(FetchDescriptor<ProgrammeState>())
        return rows.first?.shieldsAvailable ?? 0
    }

    private var morningCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_GB")
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        calendar.firstWeekday = 2
        return calendar
    }

    private func morningDate(year: Int, month: Int, day: Int, hour: Int, calendar: Calendar) throws -> Date {
        var components = DateComponents()
        components.calendar = calendar
        components.timeZone = calendar.timeZone
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        return try XCTUnwrap(calendar.date(from: components))
    }

    private func morningWeek(number: Int, start: Date) -> AppWeek {
        let week = AppWeek(
            weekNumber: number,
            startDate: start,
            startingDrinkBudget: 10,
            drinkUnit: .pints,
            budgetRule: .guideline
        )
        context.insert(week)
        return week
    }

    private func attachDrink(amount: Double, on date: Date, to week: AppWeek) {
        let log = DrinkLog(date: date, amount: amount)
        log.week = week
        week.drinkLogs.append(log)
        context.insert(log)
    }

    @discardableResult
    private func attachSlot(
        _ day: WorkoutDay,
        template: SessionTemplate,
        to week: AppWeek,
        completedAt: Date? = nil,
        completedWithoutTime: Bool = false,
        exercises: [String] = []
    ) -> WorkoutLog {
        let log = WorkoutLog(
            workoutDay: day,
            isCompleted: completedAt != nil || completedWithoutTime,
            sessionTemplateRaw: template.rawValue
        )
        log.completedAt = completedAt
        log.completedExercises = exercises
        log.week = week
        week.workoutLogs.append(log)
        context.insert(log)
        return log
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
