# Feature: one floor, every unit

You are a coding agent in the Streakline iOS repo. Implement only this feature.

## Rules

- iOS 17+, SwiftUI, SwiftData, Swift 6 with strict concurrency. Dark mode only. Portrait iPhone.
- No account and no network. All data stays on device.
- This is a habit tracker, not a medical device. Do not add diagnosis, treatment, withdrawal, or blood-alcohol copy.
- Training never awards extra drinks.
- Do not add other roadmap features (slots, shields, receipts, seasons, paywall, nicotine, HealthKit, widgets, iCloud).
- Keep `DesignSystem`. Teal is training. Amber is drinks.
- New SwiftData properties need default values so existing installs migrate. Do not rewrite old drink amounts. History keeps the unit it was logged in.
- Extend `StreaklineTests`. Do not weaken existing tests to make them pass. Update a test only when this feature deliberately changes that rule, and rename the test so the new rule is obvious.
- New source files under `Streakline/Streakline` are picked up by XcodeGen from `Streakline/project.yml`. Regenerate the project if you add a file outside that tree.
- Do not edit the marketing site.

## Why

`AppWeek.drinkBudget` floors at the integer 5 in whatever unit the user picked. Five pints, five UK units, and five standard drinks are different plans. The floor has to mean the UK low-risk guideline of 14 units, shown in the user’s unit. Weeks already saved must keep the old floor so history does not change under people.

## Current code

- `Streakline/Streakline/Models/AppWeek.swift` — `drinkBudget` is `max(5, startingDrinkBudget - ((weekNumber - 1) / 2))`. `drinkUnitRaw` snapshots the unit for that week. Amounts on `DrinkLog` are in that unit.
- `Streakline/Streakline/Models/DrinkUnit.swift` — `pints`, `units`, `drinks`. `ProgramPreferences.startingBudget` is 5...30, default 10.
- `Streakline/Streakline/Views/OnboardingView.swift` and `SettingsView.swift` say the target drops by 1 every two weeks to 5.
- `StreaklineTests/StreaklineCoreTests.swift` — `testCustomBudgetDropsEveryTwoWeeksAndStopsAtFive` locks the old floor.

## Build this

Add `budgetRuleRaw: String` on `AppWeek`, default `"legacy"`. Existing rows stay legacy. Weeks created from now on set `"guideline"`.

Legacy budget, unchanged: `max(5, startingDrinkBudget - ((weekNumber - 1) / 2))`.

Guideline budget uses these fixed conversions. Put them in one type, `AlcoholUnits`, with comments that they are planning constants, not a lab measure.

- 1 UK unit = 1 unit
- 1 pint = 2.3 UK units (a pint of 4% beer)
- 1 standard drink = 1.75 UK units (14 g / 8 g)

The guideline floor is 14 UK units. Display floors, rounded to the nearest whole number:

- units: 14
- pints: 6
- standard drinks: 8

Guideline `drinkBudget` is `max(displayFloor, startingDrinkBudget - ((weekNumber - 1) / 2))`. If the starting budget is already under the display floor, the budget stays at the starting budget. Do not raise someone’s plan up to the guideline.

Shrinking is still 1 of the week’s display unit every two weeks. Do not shrink in UK units for a person who counts pints.

Add `AlcoholUnits.ukUnits(amount:unit:)` for later features. Do not migrate stored `DrinkLog.amount` values. Convert at the boundary when something needs a comparable number.

Onboarding and the settings footer explain the floor in the selected unit: the plan drops by 1 every two weeks and does not go below the guideline (6 pints, 14 units, or 8 standard drinks). Keep the health notice that this is not medical advice.

`WeekManager` sets `budgetRuleRaw` to `"guideline"` on every newly inserted `AppWeek`.

## Do not

- Recompute or relabel existing weeks.
- Change XP, streaks, or the workout plan.
- Add prices, calories, or a receipt.

## Done when

- A new week with starting budget 10 pints reads 10, then 9, and never goes below 6.
- A new week with starting budget 10 units reads 10 and never goes below 10, because 10 is already under 14.
- A new week with starting budget 20 units falls by 1 every two weeks and stops at 14.
- A week loaded without `budgetRuleRaw` still floors at 5.
- `testCustomBudgetDropsEveryTwoWeeksAndStopsAtFive` still describes legacy weeks. New tests cover the guideline floors.
- Unit tests pass.
