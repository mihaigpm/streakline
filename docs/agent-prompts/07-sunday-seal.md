# Feature: the Sunday seal

You are a coding agent in the Streakline iOS repo. Implement only this feature.

## Rules

- iOS 17+, SwiftUI, SwiftData, Swift 6 with strict concurrency. Dark mode only. Portrait iPhone.
- No account and no network. Do not add a share sheet or an image export. The next feature does that.
- Not a medical device. Money and calories stay estimates if you show them.
- Training never awards extra drinks.
- If the streak shield, `ReceiptEstimates`, and `MorningLine` are not in the tree, stop and say so.
- Do not add seasons, a paywall, or nicotine.
- Extend tests for any new pure summary type. Do not edit the marketing site.
- Keep `DesignSystem`.

## Why

The habit is closing the week, not opening a lesson. Sunday night should take about twenty seconds: slots, drinks, money not spent, and whether the streak held.

## Build this

Add `WeekSeal`, a pure summary of one `AppWeek` plus the streak result for that week:

- slots completed out of 3
- drinks versus budget, in the week’s unit
- estimated money not spent from `ReceiptEstimates`, or omitted when there is nothing unspent
- outcome: `perfect`, `held`, `shieldUsed`, or `missed`
  - perfect: `isPerfectWeek`
  - shieldUsed: `shieldUsed`
  - held: `holdsStreak` and not perfect
  - missed: neither held nor shield

`WeekSealView` shows those four facts and nothing else. No rank, no badge grid, no XP breakdown. Title: “Week N sealed” for a past week, or “Seal this week” on Sunday of the current week.

Entry points:

- On Sunday, home shows a button under the ring, above the morning line if both exist: “Seal the week”. It presents `WeekSealView` as a sheet.
- In `HistoryView`, a past week opens the same sheet.
- Before Sunday, the current week has no seal button. Do not let someone seal Monday’s week as if it were finished. They can still open a past week from history.

Dismissing the sheet does not write a new “sealed” flag. The seal is a view of data that already exists. Do not double-count XP.

If a shield will only be applied at rollover, say “Shield applies when the week closes” on a missed current week that has a shield available, rather than marking it `shieldUsed` early.

## Do not

- Add a share button, a photo, or a URL. Leave a single obvious empty action area out. The card prompt will add sharing.
- Change streak math.
- Send the summary anywhere.

## Done when

- Sunday home can open the seal. Wednesday home cannot seal the current week.
- A perfect week, a 2-of-3 held week, a shield week, and a missed week show the four different outcomes.
- Money not spent uses `ReceiptEstimates` and is hidden when they are over budget.
- Tests cover `WeekSeal` outcome selection. Unit tests pass.
