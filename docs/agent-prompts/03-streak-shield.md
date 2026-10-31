# Feature: a streak with one miss

You are a coding agent in the Streakline iOS repo. Implement only this feature.

## Rules

- iOS 17+, SwiftUI, SwiftData, Swift 6 with strict concurrency. Dark mode only. Portrait iPhone.
- No account and no network. All data stays on device.
- Not a medical device. No diagnosis, treatment, or blood-alcohol copy.
- Training never awards extra drinks.
- Do not add receipts, planned nights, the morning line, Sunday seal, seasons, paywall, nicotine, HealthKit, widgets, or iCloud.
- If session templates from the slots feature are not in the tree, stop and say so. Do not invent a second workout model.
- New SwiftData properties need defaults. Extend tests. Do not edit the marketing site.
- Keep `DesignSystem`.

## Why

`AppWeek.isFullyComplete` requires all 3 workouts and an under-budget week. `WeekManager.streak` walks backward over that flag. One sore week deletes a long streak, and people delete the app. Two of three sessions should hold the streak. Three of three should be the only way to earn a single shield. The first shield is never sold.

## Current code

- `AppWeek.isFullyComplete` is `completedWorkouts >= 3 && totalDrinks <= Double(drinkBudget)`.
- `WeekManager.streak` counts consecutive fully complete weeks before the current one. The current week never counts.
- `Gamification` uses `isFullyComplete` for perfect-week XP (+150), `bestStreak`, and the perfect-week badge.
- Home shows the streak from `WeekManager.streak`.

## Build this

Split the two ideas. Do not silently redefine `isFullyComplete`.

- `holdsStreak`: `completedWorkouts >= 2 && totalDrinks <= Double(drinkBudget)`.
- `isPerfectWeek`: the current `isFullyComplete` rule (3 sessions and under budget). Keep the name `isFullyComplete` as a wrapper of `isPerfectWeek` so old call sites stay honest, and move streak math off it.

Streak walk in `WeekManager.streak`:

- A past week counts if `holdsStreak` is true, or if `shieldUsed` is true.
- It stops on the first past week that is neither.

Add `AppWeek.shieldUsed: Bool = false`.

Shield inventory lives on a small SwiftData model `ProgrammeState` (a single row, created lazily): `shieldsAvailable: Int = 0`. Cap is 1. Do not use `UserDefaults` for this. Cloud sync will need it in SwiftData later.

Apply shields only when a week rolls over, inside `WeekManager`, for the week that just ended:

- If that week `isPerfectWeek` and `shieldsAvailable == 0`, set `shieldsAvailable` to 1.
- Else if that week does not `holdsStreak` and `shieldsAvailable > 0` and `shieldUsed` is false, set `shieldUsed` true and decrement `shieldsAvailable`.
- Never earn and spend on the same week.
- Do not auto-spend during the current, still-open week. The user can still finish it.

Perfect-week XP and the perfect-week badge still require 3 sessions, not 2. A held-but-not-perfect week does not get +150.

Home streak pill uses the new streak. If a shield is available, a quiet caption can say “1 shield”. Do not add a shop.

`Gamification.bestStreak` must use the same hold-or-shield rule as `WeekManager.streak`.

## Do not

- Raise the shield cap above 1. A later paywall prompt does that.
- Let the user buy a shield.
- Change drink budgets or session templates.
- Count the in-progress week toward the streak.

## Done when

- Three past weeks of 2 sessions under budget produce a streak of 3, and no perfect-week XP.
- A past week with 1 session and no shield breaks the streak.
- Rolling over from a perfect week grants one shield when the inventory is empty.
- Rolling over from a missed week with a shield spends it, marks `shieldUsed`, and the streak includes that week.
- A second perfect week does not raise the inventory above 1.
- Tests cover those four cases. Unit tests pass.
