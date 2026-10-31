# Feature: the month screen

You are a coding agent in the Streakline iOS repo. Implement only this feature.

## Rules

- iOS 17+, SwiftUI, SwiftData, Swift 6 with strict concurrency. Dark mode only. Portrait iPhone.
- No account and no network. This screen does not upload anything.
- Not a medical device. Say the comparison is their log, not a health score.
- Training never awards extra drinks.
- If `AlcoholUnits` is not in the tree, stop and say so.
- Do not add sharing, a paywall, or a backend.
- Extend tests. Do not edit the marketing site.
- Keep `DesignSystem`.

## Why

“Among people who reached week 4, weekly units moved” starts as a screen the person can read. Compare this week with their first week in real units, so pints and units are not added together.

## Current code

- `ProgressScreen` shows rank, XP, badges, and totals from `Gamification.summary`.
- `DrinkLog.amount` is in the week’s `DrinkUnit`. `AlcoholUnits.ukUnits(amount:unit:)` converts at the boundary. Do not rewrite stored amounts.

## Build this

Add `MonthComparison`, a pure value:

- `firstWeekUnits` and `currentWeekUnits`, both UK units, summed from that week’s logs
- `unitDelta` = current minus first. Negative means they drank less.
- `firstWeekSlots` and `currentWeekSlots`

Put a block at the top of `ProgressScreen`, above the rank content.

- With only week 1 in the store: “Your first week is the baseline. The comparison shows from week 2.”
- From week 2 on: “This week vs week 1”, the two unit figures rounded to one decimal, the delta, and the two slot counts.
- Copy for a drop: “Down 3.5 units from week 1.”
- Copy for a rise: “Up 2 units from week 1.”
- Copy when equal: “Level with week 1.”

Do not average every week. Do not show a chart library. The four numbers are the screen.

If week 1 and the current week used different display units, still compare UK units, and footnote “Compared in UK units so the two weeks mean the same thing.”

## Do not

- Call the delta a medical improvement.
- Hide a rise. The screen is honest.
- Gate it behind a purchase.

## Done when

- Week 1 with no later week shows the baseline sentence.
- A later week of 4 pints versus a first week of 8 pints shows a drop of 9.2 UK units (4 × 2.3).
- Tests cover the delta, the empty state, and a mixed-unit pair.
- Unit tests pass.
