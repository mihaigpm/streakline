# Feature: nicotine-free days

You are a coding agent in the Streakline iOS repo. Implement only this feature.

## Rules

- iOS 17+, SwiftUI, SwiftData, Swift 6 with strict concurrency. Dark mode only. Portrait iPhone.
- No account and no network, other than whatever Plus and the anonymous row already do. Do not add nicotine fields to the anonymous payload.
- Not a medical device. Do not write a quit course, craving tools, or cessation advice.
- Training never awards extra drinks.
- If `MorningLine` and `PlusEntitlement` are not in the tree, stop and say so.
- The track is off until the user turns it on, and the switch is part of Plus.
- Extend tests. Do not edit the marketing site.
- Keep `DesignSystem`.

## Why

One tester asked to track smoking. The job is the same week, not a second app. Smoke Free already owns the quit course. People who do not smoke should never see a cigarette in the interface.

## Build this

`AppStorage` `nicotineTrackingEnabled`, default false.

Settings shows the row only as a Plus row: “Nicotine-free days”. If `isPlus` is false, the row explains it is part of Streakline Plus and opens the existing paywall. If `isPlus` is true, the toggle works. Turning Plus off does not delete marks, but it hides the UI and stops the feature affecting the week.

New SwiftData model `NicotineMark`: `date: Date`, `smoked: Bool`, optional `week: AppWeek`. Register it on the `ModelContainer` in `StreaklineApp` and in the test container. Default absence of a mark means “not smoked”. Do not infer smoke-free history for days before they turned the toggle on.

When the toggle is on:

- The home day dots can show a smoked day. Keep it secondary to the drink dot. A smoked day is a small mark, not a new ring.
- `isPerfectWeek` also requires zero `smoked == true` marks in that week. `holdsStreak` does not. A smoking day can still hold the streak. It cannot be a perfect week, so it cannot earn a shield.
- `MorningLine`, if they smoked yesterday and a slot is open, uses the same shape as the drink line: “You smoked last night. [Slot] still counts, and it’s worth more if you show up.” If they both drank and smoked, one sentence: “You drank and smoked last night. [Slot] still counts, and it’s worth more if you show up.” The XP bonus stays the drink rule already implemented. Do not add a second XP bonus for nicotine.
- Sunday seal gains one line, “Nicotine-free” or “Smoked N days”, only when tracking is on.

When the toggle is off, none of those views mention nicotine, and perfect-week math ignores marks.

Logging is one control on the drink strip or the day: “Smoked today”. It writes a mark for today. Tapping again deletes it.

## Do not

- Add cigarettes, vapes, or pouches as separate products. One smoked flag is enough.
- Add a quit plan, a community, or a day counter in the style of a sobriety app.
- Put nicotine on the share card.
- Let nicotine change the drink budget.

## Done when

- With the toggle off, home, seal, and perfect-week math look as they do today.
- A plus user can mark today as smoked, the perfect week fails, and a 2-of-3 under-budget week still holds the streak.
- A non-plus user cannot turn the toggle on.
- Tests cover the perfect-week gate, the streak staying intact, and the morning-line copy for drank, smoked, and both.
- Unit tests pass.
