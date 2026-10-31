# Streakline — Agent Handover

> **Audience:** Future AI coding agents (and human contributors) picking up this repo cold.
> **Last updated:** 2026-10-29.
> **Repo:** `streakline`. Remote: `github.com:mihaigpm/streakline.git`, branch `main`.

This document is the **fast on-ramp**. It says which file to read, where the code lives, which invariants hold, and which gotchas are already paid for.

---

## 1. What this product is

**Streakline** is a private iPhone habit tracker. No account, no server, no paywall.

1. **Setup** — pick a drink unit and a starting weekly target, optionally turn on a local reminder, then start.
2. **Week** — three sessions (Hard, Strong, Long) whose template you can swap, and a drink budget that drops by 1 every two weeks until it floors at 5.
3. **Log** — one control to add or remove a drink, one path to tick exercises and finish a workout.
4. **Progress** — XP, nine ranks, twelve badges, dry days, and a streak that holds on two sessions. A perfect week is still three. All of it is computed from the weeks stored on the phone, plus one shield row.

**Domain / support:** `streakline.fit`, `support@streakline.fit`.

---

## 2. Read this first (doc priority)

| Priority | File | Use when |
|----------|------|----------|
| **P0** | `decisions.md` | Why something is built this way; append-only history |
| **P0** | `checklist.md` | What's open vs done; session start |
| **P0** | `ios-test-cases.md` | The only living manual test inventory |
| **P0** | `CI.md` | Xcode Cloud build number and TestFlight |
| **P1** | `Streakline/README.md` | iOS conventions, project generation, debug launch args |
| **P1** | `brand.md` | Color, type, and voice — source of truth for UI and store copy |
| **P1** | `README.md` | Product summary and how to build |
| **P2** | `docs/AppStoreSubmission.md` | Archive and upload, when you are actually shipping |
| **P2** | `docs/app-store/v1.0/` | Paste-ready listing draft. Check it against the binary before pasting |

A `manifest.json` under the Xcode project is not the workflow. Start conditions and the TestFlight action live in App Store Connect. See `CI.md`.

**Rule:** If this handover and the code disagree, **code wins** — then update this file in the same change. If `decisions.md` and another doc disagree, **`decisions.md` + live code** win.

There is one test inventory. If `ios-test-cases.md` goes stale, say so at the top of that file and point at whatever replaced it. Do not keep a second plan up to date beside it.

---

## 3. Repo layout

```
streakline/
├── AGENT_HANDOVER.md          ← you are here
├── decisions.md
├── checklist.md
├── brand.md
├── ios-test-cases.md
├── CI.md
├── README.md
├── Streakline/                ← Xcode project (Swift 6, iOS 17+)
│   ├── README.md              ← iOS conventions
│   ├── project.yml            ← xcodegen source
│   ├── Streakline.xcodeproj
│   ├── Streakline/            ← app sources
│   ├── StreaklineTests/
│   └── Tools/generate_icon.py
├── web/                       ← Next.js static site (privacy, support, landing)
└── docs/                      ← App Store draft and submission runbook
```

---

## 4. Release state (snapshot)

Verify with `git log` and the Xcode project before trusting dates or build numbers.

| Surface | Version | Status |
|---------|---------|--------|
| **iOS** | Marketing version `1.0.1`. Version `1.0` is approved and closed. Committed build number is **4** (`project.yml` and the app target). | Xcode Cloud archives to TestFlight and sets the build to `CI_BUILD_NUMBER` (the workflow run count). It does not commit that number. See `CI.md` |
| **Web** | Static Next.js | `streakline.fit` — landing, privacy, support |

`docs/app-store/v1.0/metadata.md` still says build 3. The binary's build number is the app target in `project.pbxproj`, not that draft.

---

## 5. Architecture — iOS

**Stack:** Swift 6, SwiftUI, SwiftData, iOS **17+**, strict concurrency. iPhone, portrait, dark.

**Entry:** `StreaklineApp` → `AppRootView`.

- SwiftData fails to open → in-memory container and `StorageUnavailableView` (nothing persists).
- Onboarding flag set, or any `AppWeek` already stored, or Debug `-skip-onboarding` → `HomeView`.
- Otherwise → `OnboardingView`.

There is no feature-folder MVVM layer. Screens use `@Query` and `@State`. Rules that must stay consistent live in stateless enums.

### Key files

| Area | Path |
|------|------|
| Entry and routing | `Streakline/Streakline/StreaklineApp.swift` |
| Onboarding | `Streakline/Streakline/Views/OnboardingView.swift` |
| Home | `Streakline/Streakline/Views/HomeView.swift` |
| Workout | `Streakline/Streakline/Views/WorkoutDetailView.swift` |
| Exercise guide | `Streakline/Streakline/Views/ExerciseGuideView.swift` |
| Progress | `Streakline/Streakline/Views/ProgressScreen.swift` |
| History | `Streakline/Streakline/Views/HistoryView.swift` |
| Settings | `Streakline/Streakline/Views/SettingsView.swift` |
| Week model | `Streakline/Streakline/Models/AppWeek.swift` |
| Shield inventory | `Streakline/Streakline/Models/ProgrammeState.swift` |
| Week advance and home streak | `Streakline/Streakline/Utilities/WeekManager.swift` |
| XP, ranks, badges, dry days | `Streakline/Streakline/Utilities/Gamification.swift` |
| Reset and erase | `Streakline/Streakline/Utilities/AppDataManager.swift` |
| Local reminder | `Streakline/Streakline/Utilities/NotificationManager.swift` |
| Drink units and starting target | `Streakline/Streakline/Models/DrinkUnit.swift` |
| Drink receipt | `Streakline/Streakline/Models/ReceiptEstimates.swift` |
| Morning line | `Streakline/Streakline/Models/MorningLine.swift` |
| Sunday seal | `Streakline/Streakline/Models/WeekSeal.swift` |
| Exercise copy | `Streakline/Streakline/Models/ExerciseLibrary.swift` |
| Session templates | `Streakline/Streakline/Models/SessionTemplate.swift` |
| Programme preset | `Streakline/Streakline/Models/ProgrammePreset.swift` |
| Tokens | `Streakline/Streakline/Utilities/DesignSystem.swift` |
| Unit tests | `Streakline/StreaklineTests/StreaklineCoreTests.swift` |

### iOS conventions

See `Streakline/README.md`. Short version: one primary type per file, folders as they are now (`Models`, `Views`, `Components`, `Utilities`), strict concurrency, no third-party SDKs, no secrets in git.

### iOS build

```bash
cd Streakline
xcodegen generate   # keeps the build number in project.yml; Cloud replaces it later
xcodebuild test -project Streakline.xcodeproj -scheme Streakline \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```

Compile-only, when the simulator service is down:

```bash
xcodebuild -project Streakline/Streakline.xcodeproj -scheme Streakline \
  -destination 'generic/platform=iOS' -configuration Debug build \
  CODE_SIGNING_ALLOWED=NO
```

### Debug launch arguments

Debug builds only. Release ignores them.

| Argument | Effect |
|----------|--------|
| `-skip-onboarding` | Open Home even with no saved weeks |
| `-show-rankup` | Present the rank-up cover for the Disciplined rank |
| `-open-progress` | Push Progress |
| `-open-day "Day A"` | Push that workout (`Day A`, `Day B`, or `Day C`) |
| `-open-guide` | From a workout screen, open the exercise guide |
| `-ui-fixture home` | Replace saved data with `home`, `workout`, `progress`, or `onboarding`. UI tests and screenshot captures use this |

---

## 6. Product rules (do not break)

### 6.1 Where data lives

SwiftData on device: `AppWeek`, `WorkoutLog`, `DrinkLog`, and one `ProgrammeState` row for the shield. Preferences in `UserDefaults`:

| Key | Meaning |
|-----|---------|
| `hasCompletedOnboarding` | Setup finished |
| `startingDrinkBudget` | Baseline chosen in setup (5–30, default 10) |
| `drinkUnit` | `pints`, `units`, or `drinks` |
| `notificationsEnabled` | Daily reminder toggle |
| `reminderTime` | Time as `timeIntervalSinceReferenceDate`; 0 means 08:00 |
| `lastCelebratedRankIndex` | Highest rank celebration already shown; `-1` until first Home launch |

Deleting the app deletes the data. There is no Keychain session and no account to reset on a server.

### 6.2 Routing

```
SwiftData won't open → Storage unavailable
Else weeks exist, or onboarding flag, or Debug skip → Home
Else → Onboarding
```

A phone that already has weeks but never set `hasCompletedOnboarding` skips setup, writes the current drink unit onto those weeks, and sets the flag. That path is the beta migration in `AppRootView`.

### 6.3 Drink budget

`max(5, startingDrinkBudget - ((weekNumber - 1) / 2))`.

Default start is 10. Weeks 1–2 stay at the start, then the target drops by 1 every two weeks and stops at 5. The baseline is chosen in onboarding (stepper 5…30) and copied onto each new week. It is not recomputed from a later settings change.

Each week stores `drinkUnitRaw`. Changing the unit in Settings applies on the **next** week. History keeps the unit it was logged in.

Steps: pints `0.5`, UK units `1`, standard drinks `1`.

`ReceiptEstimates` prices the logged total in that week's unit. The price list is rough 2026 UK averages for planning, not a till receipt: a pint is £5.50 and 220 kcal, a UK unit is £2.40 and 95 kcal, a standard drink is £6.00 and 140 kcal. The home strip shows amount, estimated spend, and estimated calories once the total is above 0. "about" sits on every price and calorie. Tapping the line opens a sheet with those three figures and the sentence that they are not a measure of the night. Unspent is drinks still inside the budget times the price, and 0 when over budget. The line does not show money saved. An open slot adds its card title and "is still open". One open slot on a week that has a planned night uses the weekday after the latest drink. Several open slots have no stored day, so the clause uses the first incomplete slot in Day A, B, C order. All three complete, and the clause is omitted. Nothing new is stored.

### 6.4 Week boundary

`WeekManager.mondayOfWeek` uses `Calendar.current`. The start of the week is that calendar's first weekday. A US region starts on Sunday. A UK region starts on Monday. Comments on `AppWeek.startDate` say Monday; the code follows the device calendar.

Moving the clock forward by more than one week inserts one new `AppWeek` whose `weekNumber` jumps by the elapsed week count. Skipped numbers are not backfilled. The home streak needs consecutive week numbers, so a gap breaks it.

### 6.5 Workouts

Three slots are seeded per week. Their stored raw values stay `Day A` (Hard), `Day B` (Strong), and `Day C` (Long).

`WorkoutLog.sessionTemplateRaw` picks the list. Empty means the original template: Day A is the run plus glute circuit, Day B is full-body weights, Day C is the long run or circuit. `dayC_wasRun` alternates only that empty Day C template. Marking a legacy Day C complete flips the flag. Undo flips it back. The next week copies the flag. Rollover itself does not flip it. A non-empty template does not flip the flag.

Onboarding stores `programmePreset` (`running`, `gym`, or `home`). A new week copies that preset. Running is `easy-run`, `full-body`, `long-run`. Gym is `intervals`, `full-body`, `long-circuit`. Home is `sport`, `home-circuit`, `long-circuit`. No preset leaves the logs empty, so they stay on the legacy lists. Swapping a template changes that slot for this week only, clears its ticks and completion, and leaves the other slots alone. The next week seeds from the preset again.

`logged` is "I already trained". Choosing it marks that slot complete, shows the title "Trained", and does not open the exercise guide. It still counts toward the ring of 3.

Cards, the detail screen, and history show the template name. Empty logs still show Day A, Day B, and Day C.

"Mark as done" completes a guided workout even if exercises are unticked. The label becomes "Finish workout" once every exercise is ticked. The guide can finish the workout only after every exercise is ticked.

### 6.6 Streak, dry days, XP

**Home streak** counts past weeks only. The open week never counts. A past week counts when it `holdsStreak` (2 sessions and drinks at or under budget) or when `shieldUsed` is true. A missing week number stops the run. The pill is hidden at 0.

**Perfect week** (`isPerfectWeek`, and `isFullyComplete`) is still 3 sessions and drinks at or under budget. That is the only +150 XP and the only perfect-week badge. Two sessions do not get it.

**Shield.** One `ProgrammeState` row, created when the first shield is earned. Cap is 1. It is not for sale. `WeekManager` settles it only when a week rolls over, for the week that just ended. A perfect week earns one shield when the inventory is empty. A week that does not hold the streak spends it, sets `shieldUsed`, and that week still counts. The same week never earns and spends. The open week does not spend. Home shows a quiet "1 shield" caption while one is available.

**Best streak** on Progress uses the same hold-or-shield rule and can include the current week once that week qualifies.

**Dry days** are fully elapsed days in that week with no drink logged. Today is never dry. Future days are not dry.

**XP** is derived, never stored:

| Event | XP |
|-------|----|
| Exercise ticked | +10 |
| Workout completed | +50 |
| Workout completed the calendar day after drinks | +80 |
| Dry day | +15 |
| Fully complete week | +150 |

The morning line sits under the home ring when yesterday’s logged drinks are above 0 and a slot is still open. Monday reads Sunday from the previous week. The name is the first incomplete slot’s template title, in Day A, B, C order, the same title the card shows. A dry morning or a week with every slot complete shows nothing. The extra 30 is derived from `completedAt` and the drink logs, once per slot, not per exercise. A completion with no `completedAt` stays at 50. Undo drops the bonus. Going over budget does not clear a workout. The line awards no drinks, budget, or shield. It is not a health, sleep, or impairment claim. Notification copy is unchanged. The progress legend still lists the base +50.

On Sunday, Home shows “Seal the week” under the ring and above that sentence. `WeekSeal` is computed, not stored. It reports slots out of 3, drinks against the week’s own budget, estimated money not spent when `ReceiptEstimates.unspent` is above 0, and one outcome: perfect, held, shield used, or missed. The sheet heading is the season: “Season N, week X of 8”, or “Hold, week X of 8” once Hold has started. A past week opens the same sheet from History. The open week before Sunday does not. Dismissing the sheet does not write a sealed flag and does not change XP. A missed open week with a shield still available says “Shield applies when the week closes” and leaves `shieldUsed` false until rollover.

`Season` is also computed. `number` is `(weekNumber - 1) / 8 + 1` and `weekInSeason` is `(weekNumber - 1) % 8 + 1`. Home replaces the “Week N” title with the season title and “week X of 8”. The accessibility label still includes the absolute week number. A week is in Hold when its budget equals the floor for its own rule — legacy 5, or the guideline display floor — and an earlier saved week already sat on that same floor. The first week on the floor keeps its cutting title. A start already under the display floor never counts as that floor. Hold does not change the budget, XP, streak, templates, or logs, and it adds no badge and no confetti.

`MonthComparison` is computed the same way. Progress shows it above the rank. It sums `DrinkLog.amount` through `AlcoholUnits.ukUnits` and rounds each week to a tenth before subtracting. Only week 1 and the highest `weekNumber` count. A negative delta reads “Down 9.2 units from week 1.” A positive one reads “Up 2 units from week 1.” Zero reads “Level with week 1.” Week 1 alone, or a store with no week 1, shows “Your first week is the baseline. The comparison shows from week 2.” Slots are `completedWorkouts` as “N of 3”. When the two weeks used different `drinkUnit` values, the card adds “Compared in UK units so the two weeks mean the same thing.” It always adds “This is your log, not a health score.” Stored amounts are not rewritten. The delta is not coloured as a win or a miss.

Ranks: Rookie 0, Starter 150, Consistent 400, Committed 800, Disciplined 1400, Relentless 2200, Machine 3200, Unbreakable 4500, Legend 6000.

A rank-up cover waits until the user is back on Home. If XP drops below the celebrated rank, the baseline drops quietly so the same rank can celebrate again.

### 6.7 Reminders

One local repeating notification, id `fittrack.daily.reminder`. Default 08:00. Copy depends on workouts left, whether the week is over budget, and XP to the next rank. Permission is requested only when the user turns the toggle on. Denial leaves the toggle off. The app reschedules when it becomes active, and only after onboarding is complete.

Do not rename the notification id without removing the pending request that uses the old id.

### 6.8 Reset

Settings → Reset current week clears this week's completions, notes, ticked exercises, and drinks. The week row stays.

Settings → Erase all data deletes every week and the shield row, cancels the reminder, resets unit to pints, clears the starting budget, the programme preset, and the rank baseline, and returns to onboarding.

### 6.9 What v1 does not do

- Accounts, sign-in, or a backend
- Purchases, subscriptions, or a paywall
- Analytics or crash SDKs
- Camera, HealthKit, Watch, widgets, iCloud sync
- An open workout builder or a fourth session

### 6.10 Copy

Streakline is a habit and fitness tracker for adults of legal drinking age. Onboarding and Settings already say it is not medical advice or treatment, and that someone at risk of withdrawal should get medical advice first. Keep that notice on those surfaces. Do not add treatment, diagnosis, or "safe limit" claims. New UI copy defers to `brand.md`.

---

## 7. Web

`web/` is a static Next.js site: landing, `/privacy`, `/support`. URLs and contact addresses live in `web/lib/site.ts`. The App Store URL stays empty until Apple issues a real one.

Do not claim analytics, accounts, or a server in the privacy page unless the app actually has them.

---

## 8. Testing for agents

The case list is `ios-test-cases.md`. It was filled from this code, using the public skills named in that file.

**Fresh user:** delete the app, or Settings → Erase all data. Both are enough. There is no server user to delete.

**Unit tests** already cover the budget curve, week rollover and unit snapshot, the hold-or-shield streak, shield earn and spend, best streak, the morning line, the Sunday seal, notification copy, reset, and erase. Run those before inventing a UI test for the same math.

**UI tests** (`StreaklineUITests`) launch Debug fixtures (`-ui-fixture home|workout|progress|onboarding`) and attach screenshots. Use them to drive the simulator and to grab consistent frames for a store pass or a promo. They are not the regression suite. `Tools/prepare_screenshot_status_bar.sh` tidies the booted simulator clock and battery. Set `STREAKLINE_SCREENSHOT_DIR` on the test action to also write PNGs. Release builds ignore the fixture.

**Real device** for notification permission and a delivered reminder. Simulator green does not prove that. There is no camera and no StoreKit path to prove.

---

## 9. Agent playbook

| Task | Where to start |
|------|----------------|
| Change setup | `OnboardingView.swift` |
| Change routing | `AppRootView` in `StreaklineApp.swift` |
| Change the budget or week advance | `AppWeek.drinkBudget`, `WeekManager` |
| Change XP, badges, dry days | `Gamification.swift` |
| Change reminder copy | `NotificationManager.body` |
| Change colors or type | `brand.md` first, then `DesignSystem.swift` and the asset catalog |
| User-facing copy | `brand.md`, and keep the health notice |
| Privacy-affecting feature | `web` privacy page, Settings, and a `decisions.md` entry |
| Pre-release pass | `ios-test-cases.md`, then `docs/AppStoreSubmission.md` |
| Store listing text | `docs/app-store/v1.0/` after checking it against the binary |

---

## 10. Pitfalls

1. **Bundle id is `com.mihaigarda.threshold`.** The display name is Streakline. Changing the bundle id orphans the App Store Connect record. Do not "fix" it.
2. **Cloud build numbers are `CI_BUILD_NUMBER`.** `ci_post_clone.sh` writes that into `project.pbxproj` on the runner and does not commit it. Prepare submits the same number; an offset makes that step fail. A local archive still uses the number in git. Do not delete and recreate the TestFlight workflow, or the run count starts over and can reuse a build TestFlight already has.
3. **Marketing version is `1.0.1`.** Version `1.0` is approved and closed. A new build of `1.0` fails at Prepare with ITMS-90186 and ITMS-90062. The build-number script does not change `MARKETING_VERSION`.
4. **`docs/app-store/v1.0/metadata.md` says build 3.** Trust the app target, then update the draft.
5. **Week start follows the device calendar**, not a hard-coded Monday. Say which region you tested.
6. **Home streak ignores the current week.** Progress "Best streak" does not. They are different numbers on purpose.
7. **Drink unit on a week is a snapshot.** Settings changes the preference used for the next week.
8. **Minus removes from the latest drink log by date**, not "today" specifically.
9. **Over budget still shows "0 left"** on the home badge, in red. The strip shows the real total.
10. **Beta migration rewrites `drinkUnitRaw`** on existing weeks when the onboarding flag was never set.
11. **Notification id is still `fittrack.daily.reminder`.** Leave it, or cancel the old request in the same change.
12. **Storage failure looks like an empty app** but writes go to memory and vanish. The screen says storage is unavailable.
13. **Xcode Cloud `manifest.json`** can appear when the project is linked. It does not define start conditions or TestFlight. Those live in App Store Connect. `CI.md` describes the build-number script.

---

## 11. Git

- **Do not commit** secrets, `xcuserdata`, or a future `Config.local.xcconfig`.
- **Commit only when the user asks.**
- **`project.yml` is the project definition.** The `xcodeproj` is committed so a clone opens. Regenerate after editing `project.yml`, with the build number set.

---

## 12. Backlog

From `checklist.md`. Do not build these unless the task asks:

- iCloud sync
- A fourth session or an open workout builder
- HealthKit, Apple Watch, home screen widget

---

## 13. When you finish a task

1. Run the unit tests, or a `generic/platform=iOS` build if the simulator service is down. Say which one you ran.
2. If behavior changed, update `ios-test-cases.md` in the same change.
3. If you changed an architectural, privacy, or product rule, **append** `decisions.md`. Do not rewrite old entries.
4. If the listing or the release steps changed, update `checklist.md` and the file under `docs/` that testers will paste from.
5. If this handover and the code disagree, code wins — update this file in the same change.
6. A TestFlight upload from Xcode Cloud takes its build number from `CI.md`. Do not recreate that workflow, or the counter starts over.

---

## 14. Quick reference

| | Value |
|---|--------|
| Display name | Streakline |
| Bundle id | `com.mihaigarda.threshold` |
| Min OS | iOS 17 |
| Devices | iPhone, portrait |
| Appearance | Dark |
| Auth | None |
| Data | On device |
| Category | Health & Fitness |

*If this handover conflicts with code, **code wins** — then update this file in the same change.*
