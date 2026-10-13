# Feature: seasons, and Hold after the floor

You are a coding agent in the Streakline iOS repo. Implement only this feature.

## Rules

- iOS 17+, SwiftUI, SwiftData, Swift 6 with strict concurrency. Dark mode only. Portrait iPhone.
- No account and no network.
- Not a medical device.
- Training never awards extra drinks.
- If the guideline budget rule and `WeekSeal` are not in the tree, stop and say so.
- Do not add a paywall, a share card, nicotine, or iCloud.
- Seasons are derived from `weekNumber`. Do not add a new persisted model unless a test proves you cannot derive the label.
- Extend tests. Do not edit the marketing site.
- Keep `DesignSystem`.

## Why

From a start of 10, the budget stops moving at the floor and the app goes quiet. An eight-week season gives the week a name after the countdown ends. Hold is that season. It does not change the budget math. The floor already stops the drop.

## Build this

Add a pure type `Season`.

- `number = (weekNumber - 1) / 8 + 1`
- `weekInSeason = (weekNumber - 1) % 8 + 1`
- A week is in Hold when its `drinkBudget` equals the floor for its budget rule (legacy floor 5, or the guideline display floor) and `weekNumber` is greater than the first week in this user’s history that sat on that floor. The first week on the floor is still part of the cutting season. The next one is Hold.
- Cutting seasons are titled “Season N”. Hold seasons are titled “Hold”.

Show the season title and “week X of 8” in the home header where it currently says only “Week N”. Keep the absolute week number available in the accessibility label.

`WeekSealView` uses the season title in its heading.

Do not reset XP, streak, or templates at a season boundary. Do not copy or wipe logs. A new season is a label plus the budget behaviour that already exists.

When a Hold season starts, the Sunday seal heading is “Hold, week X of 8”. No confetti and no new badge.

## Do not

- Invent a second shrinking schedule inside Hold.
- Raise or lower the floor.
- Build the month-versus-week-1 screen. That is the next prompt.

## Done when

- Week 1 is Season 1, week 1 of 8. Week 8 is Season 1, week 8 of 8. Week 9 is Season 2, week 1 of 8.
- A guideline pint plan that reaches 6 and stays there labels the following week Hold.
- A legacy week that floors at 5 still follows the legacy floor for this label.
- Tests cover the season index and the Hold boundary. Unit tests pass.
