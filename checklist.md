# Running checklist

The single source of truth for what's left. When a task lands, move it to **Done** at the bottom rather than deleting it.

Out of band:

- Strategic decisions go in `decisions.md`, not here.
- How to archive and upload lives in `docs/AppStoreSubmission.md`. This list tracks status. That file tracks steps.
- Manual cases live in `ios-test-cases.md`. Do not start a second test plan.

Legend: `[ ]` open · `[x]` done · `[/]` in progress · `[~]` blocked / waiting on external

---

## Now

- [ ] **Reconcile store draft with the binary.** `docs/app-store/v1.0/metadata.md` says build 3. A local archive is build 4. An Xcode Cloud archive uses `CI_BUILD_NUMBER`, the workflow run count (`CI.md`). Fix the draft when the next build is chosen, not before.
- [~] **Support mail.** As checked on 2026-09-05, `streakline.fit` had no MX record (`docs/app-store/v1.0/README.md`). Confirm `support@`, `privacy@`, and `hello@` actually receive mail before they go on a submission. Not rechecked on 2026-10-13.

## Before the next upload

Walk `ios-test-cases.md` (smoke, then P0) on a real iPhone for the notification cases. The unit tests do not cover permission dialogs.

- [ ] Fresh install through onboarding, one drink, one finished workout
- [ ] Deny notifications, then allow them from Settings
- [ ] Reset current week, then erase all data back to setup
- [ ] Upgrade path: existing weeks and no onboarding flag still open Home
- [ ] `xcodebuild test` for `StreaklineTests` on a current simulator

`Streakline.xcodeproj/xcshareddata/xcodecloud/manifest.json`, if Xcode writes one, is a local link. It is not the workflow. The workflow and the build-number rule are in `CI.md`.

## Later

Not in scope unless a task asks. Reasons live in `decisions.md` and the README roadmap.

- [ ] iCloud sync via CloudKit + SwiftData
- [ ] A fourth session or an open workout builder
- [ ] HealthKit, Apple Watch, home screen widget

---

## Done

- [x] **2026-06-11** iOS app: SwiftUI, SwiftData, onboarding, home, workouts, guide, progress, history, settings, local reminder.
- [x] **2026-06-11** Unit tests for budget curve, week rollover, streak XP, notification copy, reset, and erase (`StreaklineTests`).
- [x] **2026-06-11** README with build instructions.
- [x] **2026-06-30** Static marketing site in `web/` (landing, privacy, support).
- [x] **2026-09-05** App Store draft under `docs/app-store/v1.0/` and the archive runbook `docs/AppStoreSubmission.md`.
- [x] **2026-09-05** iOS GitHub Actions workflow removed. Uploads stay manual.
- [x] **2026-09-05** App target build number set to 4 in `project.pbxproj`.
- [x] **2026-10-13** Agent on-ramp: `AGENT_HANDOVER.md`, `decisions.md`, `checklist.md`, `brand.md`, `Streakline/README.md`, `ios-test-cases.md`.
- [x] **2026-10-13** Xcode Cloud build number: `Streakline/ci_scripts/ci_post_clone.sh` sets `10000 +` the workflow run count. `CI.md`. `project.yml` build number aligned to 4 for local archives.
- [x] **2026-10-31** Xcode Cloud build number is `CI_BUILD_NUMBER`. The `10000 +` offset disagreed with the build Prepare submits, so the archive failed at "Prepare build for App Store Connect". Local archives stay on the number in `project.yml`.
- [x] **2026-10-27** Session slots. Onboarding stores `programmePreset`. New weeks seed Hard / Strong / Long templates. A swap is one slot, this week only. "I already trained" completes that slot. An empty `sessionTemplateRaw` keeps Day A / B / C.
- [x] **2026-10-27** Streak shield. Two sessions under budget hold the streak. Three sessions remain the perfect week. One shield, earned on rollover from a perfect week and spent on a miss. Not for sale.
- [x] **2026-10-27** Drink receipt. The home strip estimates spend and calories from the week's own unit once the total is above 0. Over budget does not show money saved. The open-session clause drops when all three slots are done.
- [x] **2026-10-29** Morning line. Home shows one sentence under the ring when yesterday had drinks and a slot is open. That completion is +80 instead of +50. A dry morning shows nothing. Over budget does not clear the workout.
- [x] **2026-10-29** Sunday seal. Home can open it on Sunday. A past week opens it from History. Slots, drinks, money not spent, and perfect / held / shield / missed. No new saved flag and no XP.
- [x] **2026-10-30** Seasons. Home and the Sunday seal name the eight-week season, then “Hold” the week after the budget floor. The budget, XP, streak, and templates stay put.
- [x] **2026-10-30** UI test target. Debug fixtures launch Home, a workout, Progress, and onboarding. Screenshots attach for a later store or promo pass.
- [x] **2026-10-30** Month screen. Progress compares this week with week 1 in UK units. A rise stays visible. The line says it is the log, not a health score.
