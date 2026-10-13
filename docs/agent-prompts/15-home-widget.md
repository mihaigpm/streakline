# Feature: the home-screen widget

You are a coding agent in the Streakline iOS repo. Implement only this feature.

## Rules

- iOS 17+, SwiftUI, WidgetKit, Swift 6 with strict concurrency. Dark mode. The widget supports system small and medium.
- The widget does not open SwiftData and does not open a network connection.
- Not a medical device.
- Training never awards extra drinks.
- If slots and the drink budget exist as they do after the unit-floor feature, build against those. If `drinkBudget` is still the only budget API, use it.
- Edit `Streakline/project.yml` for the new target and the app group. Regenerate the Xcode project.
- Do not edit the marketing site.
- Keep `DesignSystem` colours in the widget by duplicating the few colours you need. Do not import the app target into the widget.

## Why

The week should be visible on the days they do not open the app. Slots left and budget left are the whole widget.

## Build this

App group id: `group.com.mihaigarda.threshold`. Add the capability to the app target and the widget target in `project.yml`.

`WeekSnapshot` is a `Codable` struct in a file both targets compile, or duplicated if sharing a file is awkward. Prefer one file in a shared XcodeGen source path if you can do it cleanly. Fields: `weekNumber`, `slotsCompleted`, `slotsTotal` (always 3), `drinksText` (already formatted, such as “4/6 pints”), `updatedAt`.

The app writes `week-snapshot.json` into the app group container whenever the current week is refreshed and whenever a slot or a drink changes. Then call `WidgetCenter.shared.reloadAllTimelines()`.

Widget:

- Small: “2/3” and “4/6 pints”, plus “Week N”
- Medium: the same, with the words “Slots” and “Budget”
- Placeholder and empty snapshot: “Open Streakline”
- Tapping opens the app via the widget URL `streakline://week`
- Handle that URL in the app by showing home. Home is already the root, so do not push a new screen.

No ranks, no XP, no charts, no amber-versus-teal ring unless it is a simple two-number layout you can do without the app’s `ProgressRingView`.

## Do not

- Read HealthKit from the widget.
- Show drink logs drink by drink.
- Add a configurable widget intent. One snapshot is enough.

## Done when

- Completing a slot or logging a drink updates the JSON the widget reads.
- The widget target builds with an empty app group and shows the placeholder.
- A unit test encodes and decodes `WeekSnapshot`.
- Unit tests pass.
