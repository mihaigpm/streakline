# Feature: the reminder is the morning line

You are a coding agent in the Streakline iOS repo. Implement only this feature.

## Rules

- iOS 17+, SwiftUI, Swift 6 with strict concurrency. Local notifications only. No server.
- Not a medical device. The notification must not say they are impaired, hungover, or unsafe to train.
- Training never awards extra drinks.
- If `MorningLine` is not in the tree, stop and say so. Do not copy its sentence into a second implementation.
- Extend `StreaklineTests`. The existing test `testNotificationCopyUsesTheWeeksUnit` must still pass, or you replace it with a test that still checks the unit noun when the morning line does not apply.
- Do not edit the marketing site.

## Why

The daily reminder already changes with the week. On the morning after a drink, it should say the same sentence as the home screen. Two copies will drift.

## Current code

- `NotificationManager.body(for:gamification:)` in `Streakline/Streakline/Utilities/NotificationManager.swift`.
- Title is always “Time to move”.
- `WeekState` has completed workouts, total drinks, budget, and unit. It does not know about yesterday.

## Build this

Extend the inputs to `body` so it can receive an optional morning-line sentence. The app, when it reschedules, computes `MorningLine.sentence` for the current week and passes it in.

- If the sentence is non-nil, the notification body is that sentence and nothing else. Do not append “N XP to Rank”.
- If the sentence is nil, keep today’s copy, including the unit noun and the optional XP tail.
- Title stays “Time to move”.

Do not schedule a second notification. Do not change the time picker or the permission flow.

`MorningLine` must be usable from `NotificationManager` without importing SwiftUI. If it currently sits in a SwiftUI file, move the pure function to a Foundation file both can call.

## Do not

- Mention nicotine unless `MorningLine` already returns that sentence. If it does, pass it through unchanged.
- Add a “you drank, skip the gym” branch.

## Done when

- A non-nil morning line is the entire body, with no XP suffix.
- A nil morning line still mentions the week’s unit, so the existing unit test’s intent holds.
- Tests cover both branches. Unit tests pass.
