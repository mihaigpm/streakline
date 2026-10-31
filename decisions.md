# Decision log

The canonical record of major project decisions, why they were made, and what would make us reconsider. Append-only — when a decision changes, add a new dated entry that supersedes the old one rather than editing history.

Format: each entry has a date, a one-line decision, the reasoning, and a "reconsider if" trigger. Keep entries short. Strategy does not go in `checklist.md`.

Dates below are the commit that put the decision in the tree, or 2026-10-13 where the decision is recorded from the code that was already there.

---

## Product

### 2026-06-11 — One programme: train three days, shrink a weekly drink target

- **Decision:** Streakline ships a fixed 3-day workout plan plus a weekly drink budget. The plan does the thinking. The user logs against it.
- **Rationale:** The product is a personal streak, not a workout builder and not a drink diary with charts. Day A / B / C and a single +/- drink control are the whole loop.
- **Reconsider if:** People who finish the built-in plan have nowhere to go, and a second programme can ship without a settings maze.

### 2026-06-11 — Drink target starts at 10, drops by 1 every two weeks, floors at 5

- **Decision:** Default `startingDrinkBudget` is 10. Onboarding can set 5…30. `drinkBudget` is `max(5, start - ((weekNumber - 1) / 2))`.
- **Rationale:** The cut is slow enough to keep, and it stops at a floor instead of marching to zero. The number is a personal tracking target. Copy says it is not a medically safe limit.
- **Reconsider if:** The floor or the two-week step is wrong for how people actually log, and the unit tests in `StreaklineCoreTests` are updated in the same change.

### 2026-06-11 — Three drink units, snapshotted per week

- **Decision:** Users count UK pints (step 0.5), UK units (step 1), or standard drinks (step 1). Each `AppWeek` stores the unit it was created with. Settings changes apply on the next week.
- **Rationale:** History has to stay readable after a unit change. Relabelling old weeks would rewrite what "3" meant.
- **Reconsider if:** A week needs to change unit mid-week without destroying the meaning of logs already stored.

### 2026-06-11 — No account and no backend

- **Decision:** SwiftData and `UserDefaults` on the phone are the whole store. No sign-in, no sync, no analytics SDK.
- **Rationale:** The privacy claim in the app and on `streakline.fit` is that data stays on device. A backend would make that claim false.
- **Reconsider if:** iCloud sync is actually built. That still is not a Streakline account. Update the privacy page and `decisions.md` in the same change.

### 2026-06-11 — No paywall in v1

- **Decision:** The app does not sell a subscription or a consumable.
- **Rationale:** There is nothing gated. Adding a paywall before the loop is solid would invent a product the binary does not have.
- **Reconsider if:** There is a real ongoing feature to charge for, and the listing, privacy answers, and tests are updated together.

### 2026-06-11 — XP is computed from weeks

- **Decision:** Exercise ticks, completed workouts, dry days, and perfect weeks produce XP in `Gamification.summary`. Nothing stores an XP total.
- **Rationale:** A stored counter drifts the moment an undo or a week reset forgets to subtract. Deriving it means undo is free.
- **Reconsider if:** The derivation becomes too expensive to run on every Home render, and a cache can be rebuilt from the same weeks.

### 2026-06-11 — Home streak excludes the week you are in

- **Decision:** The flame on Home counts fully complete weeks before the current week. Progress "Best streak" can include the current week once it is fully complete.
- **Rationale:** A streak you can light on Monday by finishing early is a different claim from a finished week. The two numbers answer two questions.
- **Reconsider if:** Testers consistently read the Home pill as "including this week" and the copy cannot fix that.

### 2026-06-11 — Health notice stays on setup and Settings

- **Decision:** The app is for adults of legal drinking age. It is a habit and fitness tracker, not medical advice or treatment. The withdrawal sentence stays on onboarding and in Settings.
- **Rationale:** The product asks people to drink less. That sentence is the boundary. It is not a medical-device claim, and it is not optional decoration.
- **Reconsider if:** A lawyer replaces the wording. Replace it in both screens and on the site together.

### 2026-10-27 — Three slots with templates, not a fixed circuit

- **Decision:** The week stays three sessions, stored as `Day A`, `Day B`, and `Day C`. Each log stores `sessionTemplateRaw`. Empty keeps the original Day A / B / C lists, including Day C run/circuit alternation. Onboarding stores `programmePreset` (`running`, `gym`, `home`) and new weeks seed those templates. A swap changes that slot for this week only. `logged` completes the slot, titles the card "Trained", and does not open the guide.
- **Rationale:** People keep the week and reject the fixed glute circuit. The dose stays three. A session trained somewhere else still counts. This is not a workout builder. Supersedes the fixed-plan part of 2026-06-11 — One programme. The drink budget is unchanged.
- **Reconsider if:** A fourth slot or an open exercise builder is actually required.

### 2026-10-27 — Two sessions hold the streak. One shield, not for sale.

- **Decision:** A past week holds the streak at 2 sessions under budget, or when `shieldUsed` is set. Home still ignores the open week. `isFullyComplete` stays the 3-session perfect week and is the only +150 XP. Rolling over a perfect week grants one shield when `ProgrammeState.shieldsAvailable` is 0. Rolling over a miss spends it. Cap is 1. The shield is not sold. Supersedes the "fully complete" counting rule in 2026-06-11 — Home streak excludes the week you are in. That entry still stands on one point: Progress best streak can include the open week, now once the week holds or has spent a shield.
- **Rationale:** One missed session was deleting long streaks and the app with them. Three of three stays the perfect week. The inventory is a SwiftData row because sync will need it later.
- **Reconsider if:** A paid shield raises the cap. That is a later prompt, and it does not sell the first one.

### 2026-10-27 — The drink receipt is a labelled estimate, priced in the week's unit

- **Decision:** `ReceiptEstimates` prices logged drinks with rough 2026 UK averages: pint £5.50 / 220 kcal, UK unit £2.40 / 95 kcal, standard drink £6.00 / 140 kcal. Copy says "about" on every price and calorie. Unspent is zero when the week is over budget and is not shown as money saved. Nothing new is stored. Training does not change the price.
- **Rationale:** The number worth a screenshot is what the night cost. It has to look like an estimate, not a till receipt and not a blood-alcohol figure.
- **Reconsider if:** Those averages stop being a fair planning figure, or the disclosure sentence has to change.

### 2026-10-29 — The morning after drinks is worth more XP, and the workout stays

- **Decision:** Home shows one sentence under the ring when yesterday’s drinks are above 0 and a slot is still open. The name is that slot’s template title. A completion whose `completedAt` is the next calendar day is +80 instead of +50, once per slot, derived in `Gamification`. No `completedAt` stays at +50. Perfect-week +150 is unchanged. Going over budget does not clear a workout. The line awards no drinks, budget, or shield, and it is not a health claim.
- **Rationale:** Showing up the morning after is the rep that matters. A stored bonus would survive an undo. The sentence has to disappear when the morning was dry or the week is already done.
- **Reconsider if:** The bonus should depend on something other than the calendar day before `completedAt`.

### 2026-10-29 — Sunday seal is a view, not a saved close

- **Decision:** `WeekSeal` reads one week: slots out of 3, drinks against that week’s budget, estimated money not spent from `ReceiptEstimates` when some budget is left, and an outcome of perfect, held, shield used, or missed. Home shows “Seal the week” only on Sunday, under the ring and above the morning line. History opens the same sheet for a past week. The open week before Sunday has no seal button. Dismissing the sheet writes nothing and does not spend a shield. A missed open week that still has a shield says “Shield applies when the week closes”.
- **Rationale:** Closing the week should take a few seconds and must not invent a second XP path or mark a shield used before rollover.
- **Reconsider if:** The seal needs to be shared. That is a later prompt. It does not add a share control here.

### 2026-10-30 — Seasons name the week. Hold starts the week after the floor.

- **Decision:** `Season` is derived. Weeks 1–8 are Season 1, weeks 9–16 are Season 2, and the index repeats every 8. Home shows that title plus “week X of 8”, and the accessibility label still says the absolute week number. The seal heading uses the same words. A week is titled “Hold” only when its budget equals its own floor (legacy 5, or the guideline display floor) and a saved week before it already sat on that floor. The arriving week keeps “Season N”. A start under the display floor stays a cutting season. Nothing is persisted. XP, streak, templates, logs, and the budget curve are unchanged. No badge and no confetti.
- **Rationale:** Once the countdown hits the floor the week needs a name, and that name must not pretend the budget started over.
- **Reconsider if:** Hold needs its own shrinking schedule. That would be a different product. This label does not add one.

### 2026-10-30 — The month screen compares week 1 with this week, in UK units.

- **Decision:** `MonthComparison` is derived. Progress shows it above the rank. Week 1 alone says the comparison starts at week 2. From week 2 it shows this week and week 1 in UK units, the slot counts out of 3, and one sentence: down, up, or level. A week in between is ignored. Pints and units are converted with `AlcoholUnits` and the stored amounts stay as logged. Different display units add the footnote that the comparison is in UK units. The card always says this is the log, not a health score. A rise uses the same colour as a drop. No chart, no average, no share, no paywall.
- **Rationale:** Adding a pint to a unit would invent a number. The first week is the only baseline the user can still see.
- **Reconsider if:** The comparison should use a different pair of weeks. That is a different product. This screen does not average the month.

### 2026-10-30 — UI tests launch a fixture. They do not own the math.

- **Decision:** `StreaklineUITests` drives the simulator. `-ui-fixture` in a Debug build replaces the saved weeks with `home`, `workout`, `progress`, or `onboarding`. The same launch writes screenshots into the test result, and into `STREAKLINE_SCREENSHOT_DIR` when that variable is set. Release ignores the argument. Budget, streak, and XP stay in `StreaklineTests`.
- **Rationale:** An agent needs to open the app on a known screen, and later store or promo frames need the same data twice. A UI test per arithmetic case would be rewritten every time the layout moves.
- **Reconsider if:** A flow is stable and a flake in it would ship. Add that one case. Do not import the unit suite.

---

## Engineering

### 2026-06-11 — Native SwiftUI, iOS 17+, iPhone only

- **Decision:** Swift 6, SwiftUI, SwiftData, strict concurrency. Deployment target iOS 17. `TARGETED_DEVICE_FAMILY` is iPhone. Portrait. Dark.
- **Rationale:** One platform, one appearance, no tablet layout to maintain.
- **Reconsider if:** An iPad or Android client is a real project, with its own test column. Do not pretend this app is universal before that exists.

### 2026-06-11 — Bundle id stays `com.mihaigarda.threshold`

- **Decision:** The display name is Streakline. The bundle id is the existing App Store Connect id `com.mihaigarda.threshold`.
- **Rationale:** `docs/AppStoreSubmission.md` treats that id as permanent. Renaming it creates a different app.
- **Reconsider if:** App Store Connect has no record under this id and a rename is deliberate.

### 2026-06-11 — Project file is generated, and also committed

- **Decision:** `Streakline/project.yml` is the xcodegen definition. `Streakline.xcodeproj` is committed so a clone opens without a generate step.
- **Rationale:** Agents and CI need a project on disk. Editing only the pbxproj gets overwritten on the next generate.
- **Reconsider if:** Generate stops being the way the project is updated. Until then, change `project.yml`, set the build number there, then generate.

### 2026-06-30 — Marketing site is a static Next.js export

- **Decision:** `web/` is Next.js, `output: "export"`, served as static files for `streakline.fit`.
- **Rationale:** Privacy and support URLs have to exist for the store. The site has no server features to justify a Node runtime.
- **Reconsider if:** A page needs a server. Say so in the privacy policy if that page touches user data.

### 2026-09-05 — iOS GitHub Actions workflow removed

- **Decision:** There is no `.github` workflow that builds the iOS app.
- **Rationale:** Commit `e2b4cf2` removed it. Uploads are a manual archive described in `docs/AppStoreSubmission.md`.
- **Reconsider if:** A TestFlight workflow is created. Document it in a new `CI.md` at that moment, including how the build number is assigned. Do not recreate that workflow later or the counter restarts.

### 2026-10-13 — One living test inventory

- **Decision:** Manual cases live only in `ios-test-cases.md`. Older plans are not kept current beside it.
- **Rationale:** Two inventories drift. The header of the living file is where a stale doc admits it and points at the replacement.
- **Reconsider if:** A store runbook needs a procedure this file does not contain. Add the procedure to the living file, or mark the other doc stale in its first lines.

### 2026-10-13 — TestFlight build number is 10000 plus the Xcode Cloud run count

- **Decision:** `Streakline/ci_scripts/ci_post_clone.sh` overwrites `CURRENT_PROJECT_VERSION` on the Xcode Cloud runner with `10000 + CI_BUILD_NUMBER`. It does not commit. Local archives stay on the number in `project.yml` (4).
- **Rationale:** TestFlight rejects a repeated marketing version and build number. The workflow run count started at 1, which is already used by manual builds 1–4. The offset matches the Posturato pipeline. Supersedes the upload path in the 2026-09-05 entry: GitHub Actions stays gone; this workflow is the TestFlight path.
- **Reconsider if:** Someone deletes and recreates the workflow. The run count starts over and can reuse a build number. Do not do that. Raise the offset only if `10000 +` the current run collides with a build already on TestFlight.

---

## Superseded

None yet. New entries go above this heading, in the section they belong to, with a later date. Do not edit the entries above to match a new decision.
