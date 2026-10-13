# Feature: iCloud sync

You are a coding agent in the Streakline iOS repo. Implement only this feature.

## Rules

- iOS 17+, SwiftUI, SwiftData, CloudKit private database only. Swift 6 strict concurrency.
- No public CloudKit database, no sharing, no account UI of your own. Apple’s iCloud account is the account.
- Not a medical device.
- Do this only after the schema has stopped moving. If nicotine marks, `ProgrammeState`, or Plus fields are mid-refactor on this branch, stop and say so.
- Do not add Android, a watch app, or a server.
- Keep existing local behaviour when iCloud is unavailable. The app must still open.
- Extend tests for any mapping you add. The suite uses an in-memory container and must keep doing so.
- Do not edit the marketing site. Do update `docs/app-store/v1.0/app-privacy.md` only to say that iCloud sync is optional via the user’s iCloud account and that Streakline still has no account of its own. If that file’s structure does not match the change, leave a note in the PR instead of inventing a privacy answer.

## Why

Someone who paid for a season must not lose it when they get a new iPhone. Sync is a retention tool. It is not a feature you redesign the week around.

## Current code

- `StreaklineApp` creates a `ModelContainer` for `AppWeek`, `WorkoutLog`, and `DrinkLog`, and falls back to an in-memory store.
- Later features may have added `ProgrammeState`, `NicotineMark`, and other models. Include every SwiftData model that is registered on the container. Do not leave a new model local-only if it holds streak or shield state.
- Shield inventory must sync. If it is still in `UserDefaults` or the keychain, move the inventory and `shieldUsed` (if not already on `AppWeek`) into SwiftData before turning on CloudKit. The anonymous install id stays in the keychain and does not sync.

## Build this

Container identifier: `iCloud.com.mihaigarda.threshold`. Private database. Add the iCloud and CloudKit entitlements and the background remote-notification mode in `project.yml`.

Use a `ModelConfiguration` with `cloudKitDatabase: .private("iCloud.com.mihaigarda.threshold")` when the entitlement is present. If creating that container throws, fall back to the current on-device store and set the existing `storageUnavailable` path only for a real store failure, not for “iCloud is off”. iCloud off means local SwiftData still works.

CloudKit rules you must satisfy:

- Every stored property has a default or is optional. Relationships stay optional.
- Do not add unique constraints that CloudKit cannot honour.
- Do not sync derived state by storing a second copy of XP.

Settings gets one row, “Sync with iCloud”, on by default when the CloudKit container loads, with a footer: “Uses your iCloud account. Streakline still has no account of its own.” Turning it off in this version can be a note that they turn iCloud off for Streakline in iOS Settings, if a runtime toggle is not honest. Do not pretend a toggle works if SwiftData cannot detach CloudKit at runtime. Prefer an honest footer over a fake switch.

`ProgrammeState` is one row. On sync, if two rows appear, keep the one with the higher `shieldsAvailable` and the latest update, and delete the other. Add `updatedAt` if you need that comparison.

## Do not

- Upload the anonymous week row as part of CloudKit. That opt-in POST stays as it is.
- Sync HealthKit samples.
- Require iCloud to finish onboarding.

## Done when

- The in-memory test container still builds without CloudKit.
- The app container lists every persistent model, including shields.
- A second `ProgrammeState` row collapses by the rule above, covered by a unit test that does not need a CloudKit account.
- Local launch still works when the CloudKit configuration cannot be created.
- Unit tests pass.
