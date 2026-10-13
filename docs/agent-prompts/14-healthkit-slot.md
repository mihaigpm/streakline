# Feature: Apple Health fills a slot

You are a coding agent in the Streakline iOS repo. Implement only this feature.

## Rules

- iOS 17+, SwiftUI, SwiftData, Swift 6 with strict concurrency. Dark mode only. Portrait iPhone.
- Read workouts only. Do not write Health data. Do not read heart rate, sleep, HRV, alcohol, or mindfulness.
- No account and no network.
- Not a medical device. Do not interpret a workout as fitness advice.
- Training never awards extra drinks.
- If session templates are not in the tree, stop and say so.
- Extend tests with a fake workout provider. Do not edit the marketing site.
- Keep `DesignSystem`.

## Why

The person who already recorded a run will not log it a second time. Health can fill a slot. They choose the slot. The app does not guess and auto-complete behind their back.

## Build this

Add `NSHealthShareUsageDescription` in `project.yml` info properties: “Streakline reads workouts you saved so you can count one toward this week’s slots.”

`HealthWorkoutProviding` returns workouts from a day: id, activity name, start date, duration. `HealthKitWorkoutProvider` queries `HKWorkoutType` for the last 7 days, limited to 20, newest first. `PreviewWorkoutProvider` is what tests and SwiftUI previews use.

On an incomplete slot’s detail screen, a button “Use a workout from Apple Health”. The first tap requests share authorization for workouts only. Denial explains that they can turn it on in iOS Settings, and the slot still works by hand.

The list shows activity name, day, and duration. Choosing one:

- sets that slot’s `sessionTemplateRaw` to `logged` if the existing logged template means “I already trained”
- stores the activity name in `WorkoutLog.notes` as the visible title, without destroying a note the user already typed. If notes are non-empty, prefix only when notes do not already contain the activity name.
- marks the slot complete and sets `completedAt` to the workout’s end, or start if end is missing
- does not tick individual exercises

Do not auto-match a workout to a slot in the background. One explicit choice fills one slot. The same Health workout id should not fill two slots in the same week. Store `WorkoutLog.healthWorkoutId: String = ""` and refuse a second slot in that week with the same id.

## Do not

- Request write permission.
- Import routes, maps, or heart-rate samples.
- Complete a slot at launch because Health has a workout.

## Done when

- Choosing a fake workout completes the chosen slot and shows its activity name.
- The same fake id cannot complete a second slot in that week.
- A denied authorization leaves manual completion working.
- Tests use `PreviewWorkoutProvider` and never HealthKit. Unit tests pass.
