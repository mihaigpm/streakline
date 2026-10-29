# Feature: planned nights

You are a coding agent in the Streakline iOS repo. Implement only this feature.

## Rules

- iOS 17+, SwiftUI, SwiftData, Swift 6 with strict concurrency. Dark mode only. Portrait iPhone.
- No account and no network. All data stays on device.
- Not a medical device. No diagnosis, treatment, or blood-alcohol copy.
- Training never awards extra drinks.
- Do not add a receipt, prices, calories, the morning line, Sunday seal, or a paywall.
- If `AlcoholUnits` and the guideline budget rule are not in the tree, stop and say so.
- New SwiftData properties need defaults. Extend tests. Do not edit the marketing site.
- Keep `DesignSystem`. Amber is drinks.

## Why

A weekly integer is hard to live inside. People drink on Friday and Saturday. The budget should be placeable on nights. Logging on an unplanned night still counts. The plan is a placement, not a lock.

## Current code

- Drinks are `DrinkLog` rows with a `date` and an `amount` in the week’s `DrinkUnit`. The home strip adds and subtracts via `HomeView`.
- `Gamification.dayStates` draws the seven dots (dry, drank, today, future).
- The week runs Monday to Sunday from `AppWeek.startDate`.

## Build this

On `AppWeek`, add:

- `planCustomized: Bool = false`
- `plannedMonday` through `plannedSunday`: `Double = -1`

`-1` means “use the default”. A customized plan stores zeros and positive amounts in the week’s display unit.

Default plan, used when `planCustomized` is false:

- Monday through Thursday and Sunday: 0
- Friday and Saturday split `drinkBudget` as evenly as `DrinkUnit.step` allows. If the budget is not divisible by the step, Saturday takes the remainder. Example: 7 pints, step 0.5, so 3.5 and 3.5. Example: 5 units, step 1, so Friday 2 and Saturday 3.

The sum of a customized plan may be less than the budget and must not exceed it. If the user tries to place more than the budget, refuse the extra and say how much is left. Do not change `drinkBudget`.

UI: from the drink strip or the budget badge, a sheet of the seven nights. They can move the budget onto nights. Saving sets `planCustomized` true. A “Reset to weekend” action clears it back to the default.

Logging behaviour does not change. Adding a drink still creates a `DrinkLog` for today even if today’s plan is 0. The dot for a planned night that has not happened yet can show a quiet mark that it is a planned night. Do not block the add button.

Subtracting drinks still removes amount from today’s logs only, as it does now.

When the displayed budget changes between weeks, do not copy a customized plan forward. Each new week starts from the default.

## Do not

- Turn an over-plan night into a punishment, a notification, or lost XP.
- Convert stored drink amounts into a different unit.
- Add prices or a receipt line. The next feature does that.

## Done when

- A fresh week shows the budget on Friday and Saturday only.
- The user can move it onto Wednesday, the sum never exceeds the budget, and a drink logged on Monday still records.
- Reset returns the week to the weekend default.
- Tests cover the Friday/Saturday split for pints and units, the cap at the budget, and that logging ignores the plan.
- Unit tests pass.
