# Feature: the morning line

You are a coding agent in the Streakline iOS repo. Implement only this feature.

## Rules

- iOS 17+, SwiftUI, SwiftData, Swift 6 with strict concurrency. Dark mode only. Portrait iPhone.
- No account and no network.
- Not a medical device. The line is about the session, not impairment, sleep scores, or blood alcohol.
- Training never awards extra drinks.
- If session templates and `ReceiptEstimates` are not in the tree, stop and say so.
- Do not change notification copy in this task. A later prompt points the reminder at this type.
- Do not add Sunday seal, a share card, or a paywall.
- Extend tests. Do not edit the marketing site.
- Keep `DesignSystem`.

## Why

The home screen has two arcs. It needs one sentence. If they drank last night and a slot is still open, showing up is the rep that matters, and it is worth more XP than an easy sober session. Going over budget must not erase a workout.

## Build this

Add a pure type `MorningLine`.

`MorningLine.sentence(week:now:calendar:)` returns an optional string.

- Look at the calendar day before `now`. If that day’s logged drinks in this week (or the previous week, when today is Monday) are greater than 0, and at least one slot is incomplete, return: “You drank last night. [Slot name] still counts, and it’s worth more if you show up.”
- Slot name is the visible template title, not “Day A”.
- If they did not drink yesterday, or every slot is complete, return nil. The home screen shows nothing in that case. Do not invent a motivational fallback.

Put the sentence under the progress ring on `HomeView`, in `textSecondary`, one or two lines. VoiceOver reads it.

XP stays computed in `Gamification` from logs. Do not store an XP bonus.

- Completing a workout is still +50.
- If the completion’s calendar day is the day after a day with drinks > 0, that completion is +80 instead of +50. Use `completedAt` when it is set, otherwise do not apply the bonus.
- The extra 30 applies once per completed slot, not per exercise.
- Undoing the slot removes the bonus, because XP is derived.
- Perfect-week +150 is unchanged.

Do not delete or uncomplete a workout when drinks go over budget. Confirm `addDrink` does not touch `WorkoutLog`.

## Do not

- Mention health, hangover, or “you are impaired”.
- Award drinks, budget, or a shield from this bonus.
- Schedule a notification.

## Done when

- Saturday morning after Friday drinks, with a slot open, shows that exact sentence with the slot’s name.
- A sober morning shows no line.
- A slot completed the morning after drinks contributes 80, not 50, and a slot completed after a dry day still contributes 50.
- Tests cover both XP cases and both sentence cases.
- Unit tests pass.
