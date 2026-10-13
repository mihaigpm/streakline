# Running checklist

The single source of truth for what's left. When a task lands, move it to **Done** at the bottom rather than deleting it.

Out of band:

- Strategic decisions go in `decisions.md`, not here.
- How to archive and upload lives in `docs/AppStoreSubmission.md`. This list tracks status. That file tracks steps.
- Manual cases live in `ios-test-cases.md`. Do not start a second test plan.

Legend: `[ ]` open · `[x]` done · `[/]` in progress · `[~]` blocked / waiting on external

---

## Now

- [ ] **Reconcile store draft with the binary.** `docs/app-store/v1.0/metadata.md` says build 3. A local archive is build 4. An Xcode Cloud archive is `10000 +` the workflow run count (`CI.md`). Fix the draft when the next build is chosen, not before.
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
- [ ] Another workout programme besides A / B / C
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
