# iOS test cases — Streakline

Manual inventory for the iPhone app, checked against the code on 2026-10-29.

This is the only living test inventory. If it drifts, say so in this header and point at the file that replaced it. Do not keep a second plan up to date beside it.

Legend: `[ ]` open · `[x]` pass · `[!]` fail · `[~]` skipped (note why)

**Priority:** P0 blocks a build you would upload. P1 is a release regression. P2 is edge, cosmetic, or easy to miss.

---

## How these cases were shaped

Filled from the current code (routing, onboarding, home, workouts, progress, history, settings, notifications), using four public skills as the checklist of what a mobile suite has to include.

| Skill | What it adds here |
|-------|-------------------|
| [qa-testing-mobile](https://github.com/vasilyu1983/AI-Agents-public/tree/main/skills/universal/qa-testing-mobile) | Device tiers, permissions, offline, backgrounding, accessibility, and when not to automate. |
| [qa-testing-ios](https://github.com/vasilyu1983/AI-Agents-public/tree/main/skills/universal/qa-testing-ios) | Simulator green is not notification proof. Real device for the permission dialog and a delivered reminder. |
| [mobile-testing](https://github.com/petrkindlmann/qa-skills/blob/main/skills/mobile-testing/SKILL.md) | Grant and deny, cold start, background, poor network. Deep links and biometrics are omitted because the app has neither. |
| [qa-test-planner](https://github.com/softaworks/agent-toolkit/blob/main/skills/qa-test-planner/SKILL.md) | One behavior per case. Preconditions, action, expected result, P0 / P1 / P2. |

**Automation.** Budget math, week rollover, the unit snapshot, the hold-or-shield streak, shield earn and spend, best streak, the morning line, the +80 workout the morning after drinks, the Sunday seal’s outcome, the month comparison in UK units, notification copy, reset, erase, programme-preset templates, the `logged` completion, and empty-template legacy lists belong in `Streakline/StreaklineTests/StreaklineCoreTests.swift` and already live there (XCTest). `StreaklineUITests` launches a Debug fixture and checks that Home, onboarding, Progress, and a workout open. The Progress fixture also checks the week-1 comparison line. It also attaches screenshots for a later store or promo pass. Do not move the math cases into that target. Permission dialogs, a delivered reminder, Dynamic Type, and layout stay manual.

**Not built, so not tested as if it were:** accounts, paywall, camera, HealthKit, Watch, widgets, iCloud, deep links, biometrics, push.

---

## Tester reset

There is no server user. Either path is a fresh start.

1. **Erase in the app:** Settings → Erase all data → confirm. Lands on onboarding. Unit returns to pints. Reminder is cancelled.
2. **Delete the app.** SwiftData and `UserDefaults` go with it.

Record the device **region** on any week-boundary case. The week starts on `Calendar.current`'s first weekday (Sunday in a US region, Monday in a UK region). Comments in `WeekManager` say Monday. The expected result below follows the code.

Debug arguments (`-skip-onboarding`, `-open-day`, and the others in `Streakline/README.md`) work in Debug builds only.

---

## Device matrix

Run TC-SMOKE on Tier 1 before an upload. Sample P1 on the small phone. Notifications are the only row that must be a real device.

| Tier | Device | OS | Why |
|------|--------|----|-----|
| 1 | Any recent iPhone, real device | Current iOS | Notification grant, deny, and a delivered reminder |
| 1 | iPhone simulator | Current Xcode iOS | Everything except a real permission dialog and delivery |
| 2 | iPhone SE width and a Pro Max width, simulator | Current | Layout, Dynamic Type |
| 2 | iPhone, real or simulator | iOS 17 | Minimum deployment target |

iPad is out of scope. The target is iPhone-only.

---

## Smoke

One path. If this fails, stop.

### TC-SMOKE-001 — First session: setup, one drink, one workout

**Priority:** P0 · **Type:** Functional

**Preconditions:** Fresh install (reset procedure). Region noted. Notifications not pre-granted.

**Steps**

1. Cold launch.
   **Expected:** Onboarding. Title "Build a streak that helps". No crash. No notification prompt yet.
2. Leave the unit on Pints (UK) and the target on 10. Choose Running. Read the health notice. Tap "Start my streak". Do not turn the reminder on.
   **Expected:** "Start my streak" stays disabled until Running, Gym, or Home is chosen. Home. "Week 1". Badge "10 pints left". Whole numbers have no trailing ".0". Rank pill "Rookie". No streak pill. Ring "0 of 3 workouts". Three cards: Easy run, Full body, Long run. Not the titles Day A, Day B, Day C. Drink strip "0 pints this week" and "10 pints budget". Minus is disabled.
3. Tap plus once.
   **Expected:** "0.5 pints this week". Badge "9.5 pints left". Today’s dry-day dot is the drank state (amber), not a dry day. The dry-day count stays 0 because today is not a finished dry day.
4. Open Easy run, tick one exercise, tap "Mark as done".
   **Expected:** The workout completes without every exercise ticked. A success haptic, then a short celebration, then Home. Easy run shows completed. Ring "1 of 3 workouts". Still no streak pill. The exercise list is still the run and glute circuit.
5. Kill the app and cold launch.
   **Expected:** Home, not onboarding. The drink and the completed workout are still there.

---

## 1. Launch and routing

| ID | Pri | Preconditions | Action | Expected |
|----|-----|---------------|--------|----------|
| TC-ROUTE-001 | P0 | Fresh install | Cold launch | Onboarding. Not Home. |
| TC-ROUTE-002 | P0 | Onboarding finished | Kill and cold launch | Home. Setup does not return. |
| TC-ROUTE-003 | P0 | Any data on device | Settings → Erase all data → confirm | Onboarding. A later launch is still onboarding until "Start my streak". |
| TC-ROUTE-004 | P1 | Weeks exist in the store, `hasCompletedOnboarding` is false (upgrade from a build that never set the flag) | Cold launch | Home, not onboarding. The flag becomes true. Those weeks’ drink unit is rewritten to the current `drinkUnit` preference. |
| TC-ROUTE-005 | P1 | Debug build | Launch with `-skip-onboarding` and an empty store | Home. The migration in TC-ROUTE-004 does not run. |
| TC-ROUTE-006 | P2 | Release build | Same arguments as TC-ROUTE-005 | Arguments do nothing. Fresh install still shows onboarding. |

---

## 2. Onboarding

| ID | Pri | Preconditions | Action | Expected |
|----|-----|---------------|--------|----------|
| TC-ONB-001 | P0 | Fresh install | Open the unit picker | Three choices: Pints (UK), Units (UK), Standard drinks. |
| TC-ONB-002 | P0 | Fresh install | Move the stepper from the default 10 down to the stop, then up to the stop | Stops at 5 and at 30. The noun matches the unit (pint/pints, unit/units, drink/drinks). 1 uses the singular. |
| TC-ONB-003 | P0 | Unit = Units, target = 14 | Tap "Start my streak", then read Home | Badge uses "units". Budget is 14. |
| TC-ONB-004 | P0 | Reminder off | Stay on setup and do not touch the toggle | iOS does not ask for notification permission. |
| TC-ONB-005 | P0 | Reminder toggled on, then Deny | Respond to the system prompt | Toggle returns to off. Alert "Notifications are off" says to enable them later in iOS Settings. Home still opens after Start. |
| TC-ONB-006 | P1 | Reminder toggled on, then Allow | Start | Toggle stays on. A daily reminder exists (confirm on a real device). |
| TC-ONB-007 | P1 | Fresh install | Read the Important block | It says adults of legal drinking age, not medical advice or treatment, and to seek medical advice if withdrawal is a risk. The card above says the target is not a medically safe limit. |
| TC-ONB-008 | P2 | Largest Dynamic Type | Scroll setup | Title, stepper, week choices, notice, and "Start my streak" stay reachable. Nothing is stuck under the button. |
| TC-ONB-009 | P0 | Fresh install | Read "Which week do you live?" and tap Start before choosing | Three choices: Running, Gym, Home. Start stays disabled. Choosing Home, then Start, opens Home with cards Sport, Home circuit, and Long circuit. |

---

## 3. Home, drinks, and the ring

| ID | Pri | Preconditions | Action | Expected |
|----|-----|---------------|--------|----------|
| TC-HOME-001 | P0 | Week 1, 0 drinks, pints | Tap plus twice, then minus once | Totals go 0.5, then 1, then 0.5. The value 1 renders as "1", not "1.0". |
| TC-HOME-002 | P0 | Total is 0 | Tap minus | Nothing changes. The button is disabled. |
| TC-HOME-003 | P0 | Pints, budget 10 | Add to 7, then 7.5, then 10, then 10.5 | At 7 the strip is still the calm surface (the threshold is above 70%). At 7.5 the strip shifts amber. At 10 the badge is amber "0 pints left" and the week is not over. At 10.5 the badge is still "0 pints left", in red, and the strip is red. The ring’s inner arc is red. The strip’s number is the real total. |
| TC-HOME-004 | P1 | Units or standard drinks | Tap plus | Step is 1, not 0.5. |
| TC-HOME-005 | P1 | A drink logged on an earlier day and one today | Tap minus | The later log shrinks. At 0 that log is removed. |
| TC-HOME-006 | P1 | Monday of the current week, no drinks on previous days | Read the dry-day row | Count is 0. Today is not dry. Dots for later days are future. |
| TC-HOME-007 | P1 | Device date moved to the next day, no drinks on the day that just ended | Read the dry-day row | The elapsed day is dry (teal). The count includes it. Today is still not dry. |
| TC-HOME-008 | P1 | No prior week with 2 sessions under budget, and no shielded miss | Read the header | No "week streak" pill. Rank pill reads Rookie and opens Progress. No "1 shield" caption. |
| TC-HOME-009 | P0 | Week 1 fully complete (3 workouts, drinks at or under budget), still inside week 1 | Read Home | Streak pill still hidden. No "1 shield" caption yet. Progress "Best streak" can already be 1. |
| TC-HOME-010 | P0 | Week 1 fully complete, device date in the next week | Cold launch | A new week. Home streak pill reads "1 week streak". The word stays "week" at 2 and above as well. A quiet "1 shield" caption is under the pills. The new week’s workouts are incomplete and its drinks are 0. |
| TC-HOME-011 | P2 | Reduce Motion on | Add a drink and finish a workout | Numbers update. The workout does not play the confetti wait; it dismisses. |
| TC-HOME-012 | P0 | Week 1 has 2 workouts and drinks at or under budget, device date in the next week | Cold launch | Home streak pill reads "1 week streak". There is no "1 shield" caption. Progress does not add the +150 perfect-week XP. |
| TC-HOME-013 | P0 | Guideline week, pints, 3 drinks logged, one slot still open | Read the drink strip, then tap the estimate | The line shows 3 pints, about £16.50, and about 660 kcal, and names the open session. At 0 drinks the line is absent. The sheet repeats the three figures and says the estimates are not a measure of the night. Over budget still shows spend and calories and does not show money saved. The session sentence disappears when all three slots are complete. |
| TC-HOME-014 | P0 | Friday had drinks, Saturday morning, Full body still open, Easy run already done | Read under the ring | One sentence: "You drank last night. Full body still counts, and it’s worth more if you show up." VoiceOver reads it. A morning with no drinks yesterday shows no sentence. Every slot complete shows no sentence. Adding drinks past the budget leaves the finished workout finished. |
| TC-HOME-015 | P0 | Sunday of the open week, and on another run Wednesday of that week | Read under the ring, then open the seal | Sunday shows “Seal the week” under the ring and above the morning line when that line is also there. The sheet title is “Season N, week X of 8”, or “Hold, week X of 8” once the week after the floor has started. It shows slots out of 3, drinks against the week’s budget, money not spent only when some budget is left, and one outcome: Perfect week, Streak held, Shield used, or Missed. No rank, badges, XP, or confetti. Dismissing it leaves the week unchanged. Wednesday has no seal button. A missed Sunday with a shield still available says “Shield applies when the week closes” and does not mark the shield used. |
| TC-HOME-016 | P0 | Week 1 of a new plan, then a later week whose budget has sat on the floor for a second week | Read the home header. On the Hold week, open the Sunday seal | Week 1 reads “Season 1” and “week 1 of 8”. VoiceOver also says “Week 1”. The first week on the floor still uses its Season title. The next week on that floor reads “Hold” and “week X of 8”, and the Sunday sheet title is “Hold, week X of 8”. The drink budget does not jump back up. |

---

## 4. Workouts and the guide

| ID | Pri | Preconditions | Action | Expected |
|----|-----|---------------|--------|----------|
| TC-WORK-001 | P0 | New user, Running chosen | Open Easy run, Full body, Long run | Titles are the template names, not Day A / B / C. Easy run is the run plus glute circuit, about 45 min. Full body is the weights list, about 50 min. Long run is the long-run list, about 50 min. No "Run week" pill. |
| TC-WORK-002 | P0 | Easy run, not complete | Tick the circle on one exercise, leave the rest, tap "Mark as done" | Workout completes. Home shows Easy run done. Ring increments by 1. |
| TC-WORK-003 | P0 | Day not complete | Tick every exercise from the list | The bottom button label becomes "Finish workout". Tapping it completes the workout. |
| TC-WORK-004 | P0 | Day complete | Tap Undo | Completion clears. The ring drops. Notes and ticked exercises stay (Undo only clears the completion flag and time). |
| TC-WORK-005 | P0 | A week saved before templates, so Day C `sessionTemplateRaw` is empty and the screen shows "Run week" | Finish Day C, open Day C again | Variant reads "Circuit week". The exercise list is the circuit, not the run. A templated Long run does not flip this flag. |
| TC-WORK-006 | P1 | Legacy Day C just finished as a run | Undo | Variant returns to "Run week". |
| TC-WORK-007 | P1 | Legacy Day C flipped, then the clock moves to the next week, and the new week also has an empty Day C template | Open Day C on the new week | The new week keeps the flag. Rollover itself does not flip it. A week seeded from a preset does not show the run/circuit pill. |
| TC-WORK-008 | P1 | A workout | Type a note, leave, come back | The note is still there. |
| TC-WORK-009 | P0 | Guide opened from the first exercise | Swipe through, tap "Mark exercise done" | That exercise ticks. The list behind the guide matches. "Finish workout" appears in the guide only after every exercise is ticked, and it completes the workout. |
| TC-WORK-010 | P1 | Guide open | Tap the close control before finishing | Guide dismisses. Workout stays incomplete if it was incomplete. Ticks already made stay. |
| TC-WORK-011 | P2 | Reduce Motion on | Finish a workout | No confetti hold. The screen dismisses. |
| TC-WORK-012 | P0 | New user, Home chosen | On the Strong card, open Change Strong and choose Full body | Home circuit becomes Full body. Sport and Long circuit stay. Ticks and completion on Strong clear. The other two slots do not change. The next week returns Strong to Home circuit. |
| TC-WORK-013 | P0 | Any slot not complete | Choose "I already trained" | The slot completes in that action. The card title is "Trained". The ring moves by one. The exercise guide does not open. |
| TC-WORK-014 | P1 | A log with an empty `sessionTemplateRaw` | Open that card | The title and exercises are still Day A, Day B, or Day C. Nothing rewrites the empty template. |

---

## 5. Week advance, budget, streak

Unit tests cover the arithmetic. These cases check the device calendar and the clock.

| ID | Pri | Preconditions | Action | Expected |
|----|-----|---------------|--------|----------|
| TC-WEEK-001 | P0 | Starting budget 10, inside week 1 | Read the badge | 10 left before any drinks. |
| TC-WEEK-002 | P0 | Starting budget 10, device date at the start of programme week 3 | Cold launch | Week 3. Budget 9. Weeks 1 and 2, if you open History, still show budget 10. |
| TC-WEEK-003 | P1 | Starting budget 10, far enough ahead that the formula would go below 5 | Cold launch | Budget is 5, not lower. Progress can unlock "The Long Game" once a stored week has budget 5. |
| TC-WEEK-004 | P1 | US region (first weekday Sunday) and, on another run, a Monday-first region | Note the date Home treats as the start of "this week" | It matches the device’s first weekday. It is not always Monday. |
| TC-WEEK-005 | P1 | Week 1 perfect, clock jumps two weeks | Cold launch | `weekNumber` increases by the elapsed weeks. The skipped number is not inserted. Home streak is 0 because the weeks are not consecutive. The header can still say "1 shield", because the finished perfect week earned one. |
| TC-WEEK-006 | P1 | Week 1 has 3 workouts but is over budget | Enter the next week | No streak pill. Over budget does not hold the streak. Three workouts alone are not a perfect week. |

---

## 6. Progress, history, rank-up

| ID | Pri | Preconditions | Action | Expected |
|----|-----|---------------|--------|----------|
| TC-PROG-001 | P0 | New user, still on week 1 | Open the rank pill | Progress. 0 XP, Rookie, "150 XP to Starter". Above the rank: "Your first week is the baseline. The comparison shows from week 2." and "This is your log, not a health score." Legend lists +10 exercise, +50 workout, +15 dry day, +150 perfect week. Twelve badges, all locked. |
| TC-PROG-002 | P1 | One exercise ticked and one workout completed on a day that does not follow drinks | Open Progress | XP includes 10 for the tick and 50 for the workout. "First Steps" unlocks on the first completed workout. A workout completed the morning after drinks counts 80 instead of 50, once for that slot. Undo removes it. |
| TC-PROG-003 | P1 | XP crosses a rank threshold while a workout screen is open | Finish and land on Home | The rank-up cover presents on Home, not over the workout. Dismissing it means the same rank does not cover again. |
| TC-PROG-004 | P1 | A rank was celebrated, then Undo drops XP below that rank, then the rank is earned again | Watch Home | The cover shows again for the re-earned rank. |
| TC-PROG-005 | P1 | At least one week, and the tapped row is the open week | Open History, tap the open week | Sheet shows the week number, date span, workouts as n/3, and drinks over that week’s own budget and unit. It is not the Sunday seal. |
| TC-PROG-007 | P0 | A past week exists | Open History, tap that week | The Sunday seal opens. Title is “Season N, week X of 8”, or “Hold, week X of 8” when that week is in Hold. The same four facts as Home. No share button. |
| TC-PROG-008 | P0 | Week 1 logged 8 pints. A later week logged 4 pints. On another run, week 1 is pints and the later week is units | Open Progress | “This week vs week 1”, both figures in UK units, slots as “N of 3”, and “Down 9.2 units from week 1.” for the pint pair. A rise says “Up … units from week 1.” The same colour either way. Equal weeks say “Level with week 1.” A week between them does not change the figures. Mixed units add “Compared in UK units so the two weeks mean the same thing.” The card says “This is your log, not a health score.” Logged amounts stay in the unit they were entered in. |
| TC-PROG-006 | P2 | Accessibility Dynamic Type on Progress | Open Progress | Badge grid is one column. Rank and XP stay readable. |

---

## 7. Settings

| ID | Pri | Preconditions | Action | Expected |
|----|-----|---------------|--------|----------|
| TC-SET-001 | P0 | Current week is pints, with drinks logged | Change Drink unit to Units | This week’s labels stay pints. The footer says the change applies from the next week. The next week uses units. History rows keep their own unit. |
| TC-SET-002 | P0 | Current week has completions, notes, ticks, and drinks. An older week exists | Reset current week → confirm | This week’s workouts are not complete, notes and ticks are empty, drinks are 0. The older week is unchanged. The week number does not reset to 1. |
| TC-SET-003 | P0 | Several weeks, reminder on | Erase all data → confirm | Onboarding. The week choice is cleared. Start stays disabled until Running, Gym, or Home is chosen. After Start with Running and the other defaults: Week 1, pints, budget 10, cards Easy run, Full body, Long run, no reminder scheduled. |
| TC-SET-004 | P1 | Reminder off, permission not determined | Turn Daily reminder on and allow | Time picker appears, default 08:00. A repeating reminder is scheduled. |
| TC-SET-005 | P1 | Permission previously denied | Turn Daily reminder on | Toggle snaps off. Alert offers "Open iOS Settings". |
| TC-SET-006 | P1 | Reminder on | Change the time, background the app, return | The pending reminder matches the new time. Body matches the week: no workouts yet mentions Day A; 1 or 2 left names the count; all 3 tells you to hold the line; over budget says to stop here. |
| TC-SET-007 | P1 | Any build | Open Privacy Policy, Support, Email Support | Privacy and Support open `https://streakline.fit/privacy/` and `https://streakline.fit/support/`. Email opens `mailto:support@streakline.fit`. |
| TC-SET-008 | P2 | Any build | Read Health notice and the version line | Same health notice as setup. Version line matches the binary’s marketing version and build, not a draft in `docs/`. |

---

## 8. Offline, background, cold start

The app does not call a Streakline server. Links are the only network.

| ID | Pri | Preconditions | Action | Expected |
|----|-----|---------------|--------|----------|
| TC-LIFE-001 | P0 | Airplane mode | Finish setup if needed, log a drink, complete a workout, kill, cold launch | Data is still there. No error about being offline. |
| TC-LIFE-002 | P1 | Airplane mode | Settings → Privacy Policy | The link fails because the phone is offline. Local data is unchanged. |
| TC-LIFE-003 | P1 | Mid-workout, note typed, one exercise ticked | Send the app to the background for a minute, return, then kill and cold launch | Note and tick are still there. |
| TC-LIFE-004 | P1 | Reminder enabled, onboarding complete | Cold launch after the week’s drinks or workouts changed | The pending reminder body matches the new week state (real device). |
| TC-LIFE-005 | P2 | Poor network (conditioner, high latency) | Use the app, ignore Safari | Logging never waits on the network. |

---

## 9. Accessibility

| ID | Pri | Preconditions | Action | Expected |
|----|-----|---------------|--------|----------|
| TC-A11Y-001 | P1 | VoiceOver | Move through the ring, the rank pill, and a workout’s exercise progress | Ring announces workouts done and whether the drink target is exceeded. Rank pill announces the rank and that it opens progress. Exercise progress announces "n of m complete". |
| TC-A11Y-002 | P1 | Differentiate Without Color, if you can set it | Over-budget week | Over budget is not color alone: the badge reads "0 left" and the strip shows a total above the budget. |
| TC-A11Y-003 | P2 | Bold Text, larger text, SE width | Home and a workout | Week title, cards, and the drink strip remain tappable. Horizontal workout cards still scroll. |

---

## What the unit tests already own

Do not duplicate these as the only evidence. A device pass still matters for the rows above.

| Test | Behavior |
|------|----------|
| `testCustomBudgetDropsEveryTwoWeeksAndStopsAtFive` | Drop every two weeks, floor 5 |
| `testExistingDataDefaultsRemainCompatible` | Default start 10, week 3 budget 9, pints |
| `testWeekRolloverPreservesBaselineAndUsesProspectiveUnit` | New week keeps the baseline, takes the current unit, leaves the old week’s unit |
| `testConsecutiveCompletedWeeksProduceBestStreak` | Two perfect weeks, best streak 2 |
| `testTwoOfThreeSessionsHoldTheStreakWithoutPerfectWeekXP` | Three past weeks of 2 sessions, streak 3, no +150 |
| `testOneSessionWithoutAShieldBreaksTheStreak` | One session and no shield stops the run |
| `testPerfectWeekRolloverGrantsOneShield` | A perfect week grants one shield on rollover |
| `testMissedWeekSpendsShieldAndStaysOnTheStreak` | A miss spends the shield and stays on the streak |
| `testSecondPerfectWeekDoesNotRaiseShieldsAboveOne` | A second perfect week leaves the inventory at 1 |
| `testNotificationCopyUsesTheWeeksUnit` | Reminder body uses the week’s unit |
| `testResetClearsCurrentWeekButPreservesWeek` | Reset clears logs and keeps the week |
| `testEraseAllDeletesHistory` | Erase deletes the weeks and the shield row |
| `testThreeGuidelinePintsShowAboutSixteenFiftyAndSixSixtyKcal` | 3 guideline pints are about £16.50 and about 660 kcal |
| `testOverBudgetReceiptHasZeroUnspentAndNoSaving` | Over budget keeps spend and calories, unspent is 0, and the line does not say saved |
| `testSessionClauseDisappearsWhenEverySlotIsComplete` | The session clause is omitted when all three slots are done |
| `testOneOpenSlotAfterADrinkNamesTheNextWeekday` | One open long run after Friday drinks says Saturday's long run is still open |
| `testSaturdayMorningAfterFridayDrinksNamesTheOpenSlot` | Saturday after Friday drinks names the open template, not Day A |
| `testSoberMorningAndAFinishedWeekShowNoMorningLine` | A dry morning and a finished week show no sentence |
| `testMorningAfterDrinksPaysEightyAndADryMorningStaysFifty` | The morning after drinks is 80, a dry morning stays 50 |
| `testUndoDropsTheMorningAfterBonus` | Undo removes the 80 because XP is derived |
| `testPerfectWeekBonusStaysOneHundredFifty` | Perfect week stays +150 when one slot was 80 |
| `testDrinksOverBudgetLeaveTheCompletedWorkout` | Drinks past the budget leave the workout completed |
| `testWeekSealSelectsPerfectHeldShieldAndMissed` | Perfect, 2-of-3 held, shield, and missed are four outcomes |
| `testWeekSealOmitsMoneyWhenNothingIsUnspent` | Money not spent is hidden at budget and over budget |
| `testSundayCanSealAndWednesdayCannot` | Sunday can open the seal. Wednesday cannot. The sheet title is the season |
| `testOpenMissLeavesTheShieldUntilTheWeekCloses` | An open miss with a shield does not spend it or add XP |
| `testSeasonIndexSplitsEveryEightWeeks` | Week 1 and week 8 are Season 1. Week 9 is Season 2, week 1 of 8 |
| `testHoldStartsTheWeekAfterTheFloor` | Guideline pints go to Hold the week after 6. Legacy still uses the floor of 5 |
| `testUITestFixturesSeedHomeProgressAndOnboarding` | Debug fixtures seed Home, an open workout, Progress history, and a fresh onboarding store |
| `testMonthComparisonDropsNinePointTwoUnitsAndIgnoresTheMiddleWeek` | 4 pints against a first week of 8 pints is down 9.2 UK units. The middle week is ignored |
| `testMonthComparisonStaysOnTheBaselineUntilWeekTwo` | Week 1 alone, an empty store, and a later week with no week 1 stay on the baseline sentence |
| `testMonthComparisonConvertsAMixedUnitPairIntoUKUnits` | 8 pints against 10 units is down 8.4, with the mixed-unit footnote. Stored amounts stay put |
| `testMonthComparisonSaysUpTwoAndLevelWithoutATrailingZero` | A rise of 2 UK units says “Up 2 units from week 1.” Equal weeks say “Level with week 1.” |
