# Feature: slots, not a script

You are a coding agent in the Streakline iOS repo. Implement only this feature.

## Rules

- iOS 17+, SwiftUI, SwiftData, Swift 6 with strict concurrency. Dark mode only. Portrait iPhone.
- No account and no network. All data stays on device.
- Not a medical device. No diagnosis, treatment, or blood-alcohol copy.
- Training never awards extra drinks.
- Do not add shields, receipts, planned nights, the morning line, Sunday seal, seasons, paywall, nicotine, HealthKit, widgets, or iCloud.
- Keep `DesignSystem`. Teal is training. Amber is drinks.
- New SwiftData properties need defaults. Do not change `WorkoutDay` raw values `"Day A"`, `"Day B"`, or `"Day C"`. They are stored on `WorkoutLog.workoutDayRaw`.
- Extend `StreaklineTests`. Do not weaken tests that still describe unchanged behaviour.
- New files under `Streakline/Streakline` are included by XcodeGen. Do not edit the marketing site.

## Why

People like the week and reject the fixed glute circuit. The dose stays three sessions. The movement has to be theirs. Someone who already trained somewhere else must be able to count that session.

## Current code

- `WorkoutDay` in `Streakline/Streakline/Models/WorkoutDay.swift` is Day A (run + glute circuit), Day B (full-body weights), Day C (long run or circuit).
- Exercise lists live in `Streakline/Streakline/Models/ExerciseLibrary.swift` as `WorkoutDay.dayAExercises`, `dayBExercises`, `dayCRunExercises`, `dayCCircuitExercises`.
- `WorkoutLog` stores `workoutDayRaw`, `isCompleted`, and `completedExercises`. `WeekManager.seedWorkouts` inserts one log per `WorkoutDay`.
- Home shows three cards via `HomeView.workoutCards`. Detail and the guide use `day.exercises(dayCIsRun:)`.
- `AppWeek.dayC_wasRun` alternates Day C. Keep that flag working for the legacy template only.

## Build this

Three slots, stable ids, changeable templates.

| Slot | Persisted raw value | Role |
| --- | --- | --- |
| Hard | `Day A` | Something that raises heart rate |
| Strong | `Day B` | Weights or bodyweight |
| Long | `Day C` | The longer session |

Add `WorkoutLog.sessionTemplateRaw: String = ""`. Empty means the legacy template for that slot (today’s Day A / B / C content, including the Day C run/circuit alternation).

Templates, with these exact ids:

- Hard: `easy-run`, `intervals`, `ride`, `sport`, `logged`
- Strong: `full-body`, `upper`, `lower`, `home-circuit`, `logged`
- Long: `long-run`, `long-ride`, `long-circuit`, `logged`

`logged` is “I already trained”. Choosing it marks the slot complete immediately and does not open the exercise guide. The card title is “Trained”. It still counts as one completed workout.

Onboarding asks which week they live: Running, Gym, or Home. Store it in `AppStorage` under `programmePreset` (`running`, `gym`, `home`). Defaults for a new week:

- Running: `easy-run`, `full-body`, `long-run`
- Gym: `intervals`, `full-body`, `long-circuit`
- Home: `sport`, `home-circuit`, `long-circuit`

Map templates onto the existing exercise library wherever the content already fits (`easy-run` and the running hard slot use `dayAExercises`, `full-body` uses `dayBExercises`, `long-run` uses `dayCRunExercises`, `long-circuit` and `home-circuit` use `dayCCircuitExercises`). For a template that has no list yet, reuse the closest list and change the visible name, prescription, and note. Do not write a new exercise encyclopaedia. `ride`, `sport`, `upper`, `lower`, `intervals`, and `long-ride` may be a short list of 3–5 movements each, written in the same `Exercise` shape.

On the workout card and detail screen, show the template name, not “Day A”. Offer a menu to swap template for that slot only, this week only. Swapping resets that slot’s exercise ticks and completion. Do not swap the other two slots.

Existing logs with an empty `sessionTemplateRaw` keep today’s titles and exercises. Do not migrate them to a new template.

Home still completes the ring from `completedWorkouts / 3`. A `logged` slot counts.

## Do not

- Change the drink budget, streak rule, or XP numbers.
- Add an open workout builder, an AI plan, or a fourth slot.
- Rename `WorkoutDay` cases or raw values.

## Done when

- A new user who picks Home sees home templates, and can swap the strong slot to `full-body` without changing the other slots.
- “I already trained” completes the slot in one action and moves the ring.
- An old log with an empty template still shows the original Day A / B / C content.
- Tests cover template defaults per preset, the `logged` completion, and that empty `sessionTemplateRaw` stays on the legacy lists.
- Unit tests pass.
