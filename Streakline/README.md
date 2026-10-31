# Streakline — iOS app

Native iPhone app. Swift 6, SwiftUI, SwiftData, iOS 17+.

- **Display name:** Streakline
- **Bundle id:** `com.mihaigarda.threshold` (do not change; it is the App Store Connect id)
- **Domain:** `streakline.fit`

Conventions below describe this target. `AGENT_HANDOVER.md` is the product on-ramp. If this file and the code disagree, code wins, then fix this file in the same change.

## Project conventions

- **Screens read SwiftData.** Views use `@Query` and `@State`. Shared rules live in stateless enums: `WeekManager`, `Gamification`, `AppDataManager`, `NotificationManager`. Do not add `ObservableObject`. If a screen outgrows `@State`, use `@Observable`.
- **One primary type per file.** A few files still nest a private helper (`AppRootView`, `WeekDetailSheet`). New files should not add a second public type.
- **Folders stay as they are.** `Models/`, `Views/`, `Components/`, `Utilities/`. Do not invent a `Features/` tree unless a task asks for a restructure.
- **Modern APIs for new code.** `NavigationStack`, SwiftData `@Model`, `foregroundStyle`, `.formatted()` for dates, `Task.sleep(for:)`. Do not add `DateFormatter`, `ObservableObject`, or `Task.sleep(nanoseconds:)`. `DrinkUnit.format` still uses `String(format:)`; leave it until a change is already touching that function, then switch that call to `FormatStyle`.
- **Strict concurrency.** The target sets `SWIFT_STRICT_CONCURRENCY = complete`. `@MainActor` on `WeekManager` and `AppDataManager` matches their SwiftData use. Do not mark a type `@MainActor` only to silence a warning.
- **No third-party frameworks.**
- **No client secrets today.** If one is added, put it in a gitignored xcconfig and read it through the build. Do not commit it, and do not add that file before a secret exists.
- **Dark, portrait, iPhone.** `UIUserInterfaceStyle` is Dark. `TARGETED_DEVICE_FAMILY` is `1`.

## Folder layout

The Xcode project is `Streakline.xcodeproj`, generated from `project.yml`. Sources live under `Streakline/`:

```
Streakline/
├── project.yml                 xcodegen definition
├── Streakline.xcodeproj
├── Tools/generate_icon.py      app icon and launch mark
├── StreaklineTests/            unit tests
├── StreaklineUITests/          XCUITest launch fixtures and screenshot capture
└── Streakline/
    ├── StreaklineApp.swift     entry, routing, storage failure
    ├── Info.plist
    ├── Models/                 SwiftData models, workout days, exercise text
    ├── Views/                  onboarding, home, workout, guide, progress, history, settings
    ├── Components/             ring, cards, drink strip, confetti
    ├── Utilities/              week advance, XP, notifications, design tokens, reset, UI fixtures
    └── Assets.xcassets
```

Unit tests are `StreaklineTests/StreaklineCoreTests.swift`. UI tests are `StreaklineUITests`. They launch a Debug fixture. They do not replace the unit tests.

## Generate the project

`project.yml` is the source. The `xcodeproj` is committed so a clone opens. `CURRENT_PROJECT_VERSION` there is **4**, which matches the app target. That is the number a local archive uploads.

Xcode Cloud does not use it. `ci_scripts/ci_post_clone.sh` sets every `CURRENT_PROJECT_VERSION` to `CI_BUILD_NUMBER` after clone, and does not commit. That is the number "Prepare build for App Store Connect" submits. See [`../CI.md`](../CI.md). Bump the value in `project.yml` before `xcodegen generate` when you want the next local archive to be a new build.

```bash
cd Streakline
xcodegen generate
```

Brand images:

```bash
python3 Tools/generate_icon.py   # Pillow
```

## Build and test

```bash
cd Streakline
xcodebuild test -project Streakline.xcodeproj -scheme Streakline \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -only-testing:StreaklineTests
```

UI tests, on a booted iPhone simulator. This also attaches a screenshot of each scene to the result bundle:

```bash
xcodebuild test -project Streakline.xcodeproj -scheme Streakline \
  -destination 'platform=iOS Simulator,name=iPhone 18 Pro' \
  -only-testing:StreaklineUITests
```

For App Store or promo stills, tidy the status bar first, then write PNGs by enabling `STREAKLINE_SCREENSHOT_DIR` on the test action:

```bash
sh Tools/prepare_screenshot_status_bar.sh
```

Fixtures are Debug-only: `-ui-fixture home`, `workout`, `progress`, or `onboarding`. They replace the simulator’s saved weeks. Release ignores them. Final store screenshots still come from the uploaded build; use these captures to check the frame and the copy first.

Manual cases: [`../ios-test-cases.md`](../ios-test-cases.md).

## Debug launch arguments

Honored only in Debug. Scheme → Run → Arguments.

| Argument | Effect |
|----------|--------|
| `-skip-onboarding` | Home with no saved weeks |
| `-show-rankup` | Rank-up cover (Disciplined) |
| `-open-progress` | Push Progress |
| `-open-day "Day A"` | Push Day A, Day B, or Day C |
| `-open-guide` | Open the exercise guide from that workout |
| `-ui-fixture home` | Replace saved data with a named scene: `home`, `workout`, `progress`, or `onboarding` |

## Capabilities

Shipped:

- Local notifications only (no push entitlement)

Not in the target:

- Sign in with Apple, iCloud, HealthKit, App Groups, Associated Domains, In-App Purchase

`ITSAppUsesNonExemptEncryption` is false. Leave it false unless the app adds its own non-exempt cryptography.

## Data

No backend. See `AGENT_HANDOVER.md` §6 for keys, the budget formula, and the week boundary.
