# Manual test cases — Streakline

A pass through the iPhone app as it ships: setup, the week, drinks, the three sessions, and the screens already built on top of that (planned nights, the drink estimate, the morning line, the Sunday seal, seasons, and the week-1 comparison).

Run these on a simulator or a phone. Dark mode and portrait are the only layout. There is no account and no server. Data stays on the device.

**Fresh start.** Settings → Erase all data → Erase all data. Or delete the app. Either path returns to setup. The drink unit returns to Pints (UK). The reminder is cancelled.

**Region.** Note the simulator region before any week-boundary case. The week starts on the calendar’s first weekday: Monday in a UK region, Sunday in a US region. The Sunday seal uses Sunday itself, in either region.

**Simulator date.** Cases marked **Date** need a date change. In the simulator, turn off Settings → General → Date & Time → Set Automatically, set the date, then kill Streakline and cold launch. Move one week at a time unless a case says to jump. A jump does not create the weeks you skipped, and a skipped week number breaks a streak. Put the date back before a case that is not marked **Date**.

**Not in this build.** No share card, no purchase, no nicotine log, no Health, no home-screen widget, no iCloud, no sign-in. Do not look for those.

---

## 1. Setup

### 1.1 First launch is setup

1. Delete the app, or erase, then cold launch.

**Expected:** The screen is “Build a streak that helps”. “Start my streak” is dimmed. iOS does not ask for notifications.

### 1.2 A week type is required

1. Leave Running, Gym, and Home unselected.
2. Tap “Start my streak”.
3. Tap Home, then tap “Start my streak”. Leave the unit on Pints (UK) and the target on 10. Leave the reminder off.

**Expected:** Nothing happens while no week type is selected. After Home, Home opens. The header reads “Season 1” and “week 1 of 8”. VoiceOver on that header also says “Week 1”. The cards are Sport, Home circuit, and Long circuit. The badge reads “10 pints left”. The ring reads “0 of 3 workouts”. There is no streak pill and no “1 shield” line. The rank pill reads “Rookie”.

### 1.3 Running and Gym

1. Erase, then repeat setup with Running.
2. Erase again and repeat with Gym.

**Expected:** Running opens Easy run, Full body, and Long run. Gym opens Intervals, Full body, and Long circuit. Each choice’s subtitle on setup names those three sessions. “Start my streak” stays dimmed until one is chosen.

### 1.4 Drink unit and the target stepper

1. On a fresh setup, open the unit picker.
2. Set the target to 1, then hold minus, then hold plus.
3. Switch the unit and read the card under the stepper.

**Expected:** The picker lists Pints (UK), Units (UK), and Standard drinks. The stepper stops at 5 and at 30. One uses the singular (pint, unit, drink). The card says the target drops by 1 every two weeks and does not go below the guideline of 6 pints, 14 units, or 8 standard drinks, matching the unit on screen. It says this is a personal tracking target, not a medically safe limit. A start already under that guideline stays where you set it.

### 1.5 Health notice

1. Read the Important block on setup.
2. After starting, open Settings and read Health notice.

**Expected:** Both say Streakline is for adults of legal drinking age, that it is a habit and fitness tracker and not medical advice or treatment, and that someone at risk of withdrawal should seek medical advice first.

### 1.6 Reminder left off

1. On setup, do not touch Daily reminder. Start.

**Expected:** iOS never shows the notification permission dialog.

### 1.7 Reminder denied

1. On setup, turn Daily reminder on and tap Don’t Allow.

**Expected:** An alert titled “Notifications are off” says you can enable them later in iOS Settings. The toggle returns to off. “Start my streak” still opens Home.

### 1.8 Setup is not shown again

1. Finish setup. Kill the app. Cold launch.

**Expected:** Home, with the same week, drinks, and workouts. Setup does not return.

---

## 2. Home on an empty week

Use a fresh Running week, target 10 pints, before logging anything.

### 2.1 The empty week

1. Read the header, the ring, the cards, and the drink strip.

**Expected:** “Season 1” and “week 1 of 8”. Badge “10 pints left”. Ring “0 of 3 workouts”. Section “This week's workouts” with Easy run, Full body, and Long run. The strip reads “0 pints this week” and “10 pints budget”. Minus is dimmed. There is no estimate line under the total. There is no “Seal the week” button unless today is Sunday (case 8.1).

### 2.2 History on the first week

1. Tap the calendar button.

**Expected:** History opens. It lists Week 1, “0/3 workouts”, and “0/10 pints”. It does not show “No history yet”. That empty title exists only when the phone has no saved week, which setup does not leave behind.

### 2.3 Progress on the first week

1. Go back. Tap the Rookie pill.

**Expected:** Progress. At the top: “Your first week is the baseline. The comparison shows from week 2.” and “This is your log, not a health score.” Then 0 XP, Rookie, and “150 XP to Starter”. Stats for workouts, dry days, and best streak. “How you earn XP” lists +10 for an exercise, +50 for a workout, +15 for a dry day, and +150 for a perfect week. Twelve badges, all locked: First Steps, Hat-Trick, Perfect Week, Back to Back, Month Strong, Dry Spell, Budget Boss, The Long Game, Iron Will, Machine, Half Century, Century Club.

Dry days already count for each day of this week before today, if you logged nothing on those days. Today is not a dry day. On the first morning of the week the dry-day count is 0.

---

## 3. Logging drinks

### 3.1 Plus and minus, in pints

1. On Home, tap plus twice, then minus once.
2. Tap minus until the total is 0, then tap minus again.

**Expected:** The strip goes “0.5 pints this week”, then “1 pint this week”, then “0.5 pints this week”. One uses the singular. A whole number has no “.0”. The badge falls and rises by the same steps: 9.5, then 9, then 9.5 pints left. Minus at 0 does nothing and stays dimmed. Today’s dot is the drank colour once today’s total is above 0. Today is still not counted as a dry day.

### 3.2 Other units step by 1

1. Erase, start in Units (UK) or Standard drinks, and tap plus once.

**Expected:** The total rises by 1, not by 0.5. The noun matches the unit.

### 3.3 Approaching the budget, then passing it

1. On a 10 pint week, add until the total is 7, then 7.5, then 10, then 10.5.

**Expected:** At 7 the strip is still the calm surface. At 7.5 it shifts to the drink colour. At 10 the badge is “0 pints left” in that same colour, and the week is not treated as over. At 10.5 the badge stays “0 pints left”, now in red, and the strip is red. The ring’s inner arc is red. The strip still shows the real total, 10.5. Any workout you already finished stays finished.

### 3.4 Minus takes the latest entry

**Date.** Log a drink, move to the next day, log another, then minus.

**Expected:** The later entry shrinks first. When that entry hits 0 it disappears. The earlier day is unchanged until it is the latest one left.

### 3.5 A finished dry day

**Date.** Set the clock to the next day without logging a drink on the day you left.

**Expected:** The day you left is a dry day (teal) and the dry-day count includes it. Today is an outline, not a dry day. Days still ahead are plain, or an amber ring if that night is in the plan (case 4.1).

---

## 4. Planned nights

Open the plan from the budget badge (“10 pints left”) or from “10 pints budget” on the strip. The sheet title is “Plan nights”.

### 4.1 A new week sits on Friday and Saturday

1. On a fresh 10 pint week, open Plan nights.
2. Erase, start again at 5 units, and open Plan nights.
3. Erase, start at 7 pints, and open Plan nights.

**Expected:** Monday through Thursday, and Sunday, are 0. Friday and Saturday share the budget. 10 pints is 5 and 5. 5 units is Friday 2 and Saturday 3. 7 pints is 3.5 and 3.5. The header shows what is still unplaced (“0 pints left” when the weekend already holds the whole budget). The sentence under it says a drink still logs on any night. On Home, a future Friday or Saturday with a plan and no drinks is an amber ring, and VoiceOver includes the planned-night count. Today stays the today outline even if that night has a plan.

### 4.2 Move the budget, and stop at the budget

1. On the 10 pint plan, take Friday and Saturday down to 0.
2. Put 4 pints on Wednesday. Save.
3. Open the plan again and try to place more than the 6 pints still unplaced.

**Expected:** Save closes the sheet. Reopening shows Wednesday at 4 and the weekend at 0. Plus on a night that would pass the budget does nothing to that night. The sheet says “That's the whole budget.” and how much is left (0 when nothing is left). Minus on a night stops at 0 and dims. The weekly badge on Home is still the drink budget, not the night plan.

### 4.3 A drink on an unplanned night still counts

1. Save a plan that leaves Monday at 0.
2. On Monday, tap plus once. If today is not Monday, use **Date** and cold launch on that Monday first.

**Expected:** The drink is logged. The strip and the badge move. The app does not refuse the plus.

### 4.4 Close, reset, and the next week

1. Change a night and tap Close without Save.
2. Open the plan, tap Reset to weekend, then Close.
3. **Date.** Move one week forward and cold launch. Open Plan nights.

**Expected:** Close drops edits that were not saved. Reset to weekend puts the budget back on Friday and Saturday immediately, without a separate Save. The new week starts from that weekend split again. Last week’s custom nights are not copied. Last week’s drinks are not copied.

---

## 5. Drink estimate

Prices are a rough average, in the unit of that week: a pint is about £5.50 and 220 kcal, a UK unit is about £2.40 and 95 kcal, a standard drink is about £6.00 and 140 kcal. The word “about” is on every price and every calorie figure.

### 5.1 No line until the first drink

1. Read the strip on a week whose total is 0.

**Expected:** There is no estimate line and nothing to tap.

### 5.2 Three pints, with a session still open

1. On a fresh Running week, add 3 pints (six taps). Leave every session unfinished.
2. Tap the estimate line.

**Expected:** The line reads “3 pints · about £16.50 · about 660 kcal · Easy run is still open”. The sheet is titled “Estimate”. It repeats “3 pints”, “about £16.50”, and “about 660 kcal”, plus “Estimates use average pub prices and typical drink calories. They are not a measure of your night.” Close returns to Home. The drink total is unchanged.

### 5.3 One open session names the next day

1. Finish Easy run and Full body, leave Long run open, and log a drink on Friday. Use **Date** if today is not Friday.
2. Read the line.

**Expected:** With only one session open, the clause names the weekday after that drink: “Saturday's long run is still open”. If more than one session is open, the clause names the first unfinished card and does not name a weekday (“Easy run is still open” on a Running week).

### 5.4 The session clause goes away when the week is trained

1. Finish all three sessions. Keep the drinks.

**Expected:** The line still shows the amount, the price, and the calories. It does not name a session.

### 5.5 Over the budget

1. Take a 10 pint week to 10.5 pints and open the estimate. Then open the Sunday seal on a Sunday if you want the money row (case 8.3).

**Expected:** The strip and the sheet still show the spend and the calories for 10.5 pints (about £57.75 and about 2310 kcal). They do not say the money was saved. The seal’s money row is hidden once nothing is left inside the budget, including when the total is over the budget.

---

## 6. Sessions

### 6.1 Finish with one exercise ticked

1. Open Easy run.
2. Tick one exercise. Leave the rest. Tap “Mark as done”.

**Expected:** The title is Easy run, not Day A. The subtitle is the steady run, about 45 min. The workout completes without every exercise ticked. You get a success haptic, a short celebration, then Home. Easy run shows completed. The ring reads “1 of 3 workouts”. The drink total does not change. First Steps unlocks on Progress. The XP includes 10 for the tick and 50 for the workout.

### 6.2 Finish from a full list, then undo

1. Open Full body (about 50 min). Tick every exercise.
2. Tap “Finish workout”.
3. Open it again and tap Undo.

**Expected:** The button label becomes “Finish workout” only once every exercise is ticked. Completing it moves the ring. Undo clears the completion and the completed time. Ticked exercises and the note stay. The ring drops by one.

### 6.3 A note stays

1. Type a note on a workout, leave, kill the app, and cold launch. Open the workout.

**Expected:** The note is still there.

### 6.4 The exercise guide

1. Open a workout and tap the first exercise.
2. Tap “Mark exercise done”.
3. Close the guide before the workout is finished.
4. Tick every exercise, open the guide, and tap “Finish workout”.

**Expected:** The guide ticks the same exercise as the list behind it. Closing leaves the workout incomplete if it was incomplete, and keeps ticks already made. “Finish workout” appears in the guide only after every exercise is ticked, and it completes the workout.

### 6.5 Swap one session

1. Start with Home, so the cards are Sport, Home circuit, and Long circuit.
2. On the Home circuit card, open the ellipsis (Change Strong) and choose Full body.
3. **Date.** Move one week forward and cold launch.

**Expected:** Only that card changes, to Full body. Sport and Long circuit stay. Any ticks or completion on Strong are cleared by the swap. The other two cards are not cleared. The next week puts Strong back on Home circuit. The swap does not carry forward.

### 6.6 I already trained

1. On any unfinished card, open its Change menu and tap “I already trained”.
2. Open that card.

**Expected:** The slot completes in that tap. The card title is “Trained”. The ring moves by one. The exercise guide does not open. The detail screen has no exercise list. Undo is available. Choosing “I already trained” again after Undo completes it again.

### 6.7 The other templates are names, not a new programme

1. Open Change Hard, Change Strong, and Change Long.

**Expected:** Hard offers Easy run, Intervals, Ride, Sport, and I already trained. Strong offers Full body, Upper body, Lower body, Home circuit, and I already trained. Long offers Long run, Long ride, Long circuit, and I already trained. There is no fourth card and no way to build a session from scratch.

---

## 7. The morning line

The line sits under the ring, in the secondary text colour. It is one sentence. It does not change the drink budget and it does not grant a shield.

### 7.1 The morning after a drink

**Date.** Log a drink today. Leave Full body unfinished and finish Easy run. Set the clock to the next morning and cold launch.

**Expected:** Under the ring: “You drank last night. Full body still counts, and it’s worth more if you show up.” VoiceOver reads that sentence. The name is the first unfinished card, not “Day A”.

### 7.2 No line on a dry morning, or when the week is done

**Date.**

1. Set the clock to a morning whose previous day has no drinks. Read under the ring.
2. On a morning after drinks, finish all three sessions. Read under the ring.

**Expected:** Neither screen shows the sentence. There is no replacement sentence.

### 7.3 That workout is worth 80

**Date.** With the morning line showing, complete the named session. Open Progress. Then Undo that session and look again.

**Expected:** The workout contributes 80 XP, not 50. The XP list on Progress still prints “+50” for a workout; the total is what changes. A workout you complete on a morning after a dry day stays at 50. Undo removes the 80, because the total is calculated from the log. A perfect week is still +150 on top of the sessions, not instead of them. Adding drinks past the budget does not clear the finished workout.

### 7.4 The line can see last night across the week boundary

**Date.** Log a drink on the last day of the week. Move to the first morning of the next week, with a session still open, and cold launch.

**Expected:** The new week’s drinks are 0 and its sessions are unfinished, and the sentence is still there, naming an open session on the new week.

---

## 8. Sunday seal

The seal is a view. Closing it saves nothing, spends nothing, and adds no XP. It shows slots, drinks, money not spent when some budget remains, and one outcome. It does not show rank, badges, XP, confetti, or a share button.

### 8.1 Sunday can open it. Another day cannot.

**Date.**

1. Set the clock to Sunday of the open week and cold launch. Read under the ring.
2. Set the clock to Wednesday of that same week and cold launch.

**Expected:** Sunday shows “Seal the week” under the ring. If the morning line is also showing, the button is above that line. Wednesday has no “Seal the week” button. History still opens a past week (case 9.2).

### 8.2 What the sheet says

1. On Sunday, tap “Seal the week”.
2. Close it. Read Home.

**Expected:** The title is “Season 1, week 1 of 8” on week 1, or “Hold, week X of 8” once Hold has started (case 11.3). The rows are slots out of 3, drinks against this week’s budget and unit (“0 of 10 pints” on an empty 10 pint week), an estimate row “about £55.00 not spent” while the whole budget is untouched, and an outcome. With nothing trained, the outcome is “Missed”. Home is unchanged after Close.

### 8.3 The four outcomes

Build each one, then open the seal on Sunday, or open that week from History after it has ended.

**Expected:**

- Three sessions, drinks at or under the budget: “Perfect week”.
- Two sessions, drinks at or under the budget: “Streak held”. Not “Perfect week”.
- A past week that spent a shield (case 10.4): “Shield used”.
- Anything else: “Missed”.

The estimate row is hidden when the week is exactly on the budget or over it. Over budget does not show money saved.

### 8.4 An open miss does not spend the shield

**Date.** Have “1 shield” on Home (case 10.3). On a later Sunday, leave the open week short of two sessions, or take it over the budget. Open “Seal the week”.

**Expected:** The outcome is “Missed”. A note reads “Shield applies when the week closes”. Home still says “1 shield”. The shield is still there after you close the sheet.

---

## 9. History

### 9.1 The open week is a detail sheet

1. From Home, open History and tap the current week. Do this on a Sunday as well.

**Expected:** A sheet titled “Week N”, with the date span, workouts as n/3, and drinks over that week’s own budget and unit. Completed sessions list their names and times. This sheet is not the Sunday seal, including on Sunday.

### 9.2 A past week opens the seal

**Date.** After at least one week has ended, open History and tap that past week.

**Expected:** The Sunday seal opens, with the same four facts as on Home. The title uses that week’s season, including “Hold, week X of 8” when that week is in Hold. There is no share button. The open week in the list still opens the detail sheet.

---

## 10. Streak and shield

The flame on Home counts finished weeks before the one you are in. The open week never lights it. Progress “Best streak” can include the open week once that week already holds. Two sessions at or under the budget hold the streak. Three sessions at or under the budget are a perfect week: that is the only +150, and the only way to earn a shield. The shield is not for sale. The caption is “1 shield” or it is absent. It never says 2.

Advance with **Date**, one week at a time, and cold launch.

### 10.1 The open week does not light the flame

1. Finish all three sessions with drinks at or under the budget. Stay inside the week. Read Home, then Progress.

**Expected:** No streak pill. No “1 shield”. Progress “Best streak” can already be 1. Perfect Week is unlocked. Hat-Trick unlocks from three sessions even if you later go over the budget; Perfect Week does not.

### 10.2 Two sessions hold. They do not earn a shield.

**Date.** Finish exactly two sessions, stay at or under the budget, and move to the next week.

**Expected:** Home shows “1 week streak”. The word stays “week” at 2 and above as well. There is no “1 shield” caption. Progress does not add the +150.

### 10.3 A perfect week earns one shield on the next week

**Date.** Finish three sessions at or under the budget, and move to the next week.

**Expected:** “1 week streak” and, under the pills, “1 shield”. The new week’s sessions are unfinished and its drinks are 0.

### 10.4 A miss spends the shield and stays on the streak

**Date.** With “1 shield” showing, take the next week to fewer than two sessions, or over the budget. Move one more week forward.

**Expected:** The flame is still there and includes the missed week. “1 shield” is gone. History for the missed week says “Shield used”. A second perfect week, while you already have the shield, does not bring the caption back to a second shield. You still see “1 shield”, not two.

### 10.5 One session and no shield breaks it

**Date.** With no shield, finish only one session and move to the next week.

**Expected:** No streak pill.

### 10.6 Over the budget is not a hold and not a perfect week

**Date.** Finish three sessions, then go over the budget, with no shield in hand. Move to the next week.

**Expected:** No streak pill and no “1 shield”. Three sessions alone do not hold the streak.

### 10.7 Skipping a week breaks the run

**Date.** Finish a perfect week 1. Jump the clock two weeks ahead and cold launch.

**Expected:** The header’s week number jumps by the weeks you skipped. The missing number is not filled in. The streak pill is absent, because the weeks are not consecutive. “1 shield” can still be there, because the perfect week you did finish earned it.

---

## 11. The budget, seasons, and Hold

A new week uses the guideline floor: 6 pints, 14 units, or 8 standard drinks. The target drops by 1 of that unit every two weeks and stops at the floor. A start that is already under the floor never rises to it. Weeks already saved keep the budget they were given. Seasons are a label. They do not reset XP, the streak, the sessions, or the budget.

Home shows “Season N” and “week X of 8”. VoiceOver also says the absolute week number. Week 1 through week 8 are Season 1. Week 9 is Season 2, “week 1 of 8”.

Hold is the week after a saved week that already sat on the floor. The first week on the floor keeps its Season title.

### 11.1 Week 1 and the first drop

1. Start at 10 pints. Read the badge.
2. **Date.** Advance one week and cold launch, then advance one more week and cold launch. Open History.

**Expected:** Week 1 and week 2 stay at 10. Week 3 is 9. Jumping straight from week 1 to week 3 skips week 2, and History will not list a week that was never opened. The same drop holds for other units, except a start of 10 units, which is already under 14 and stays at 10.

### 11.2 The floor, and a start under it

**Date.** Advance week by week, or jump only when you do not need the weeks in between.

**Expected:**

- 10 pints never goes below 6. Week 9 is the first week at 6.
- 20 units falls by 1 every two weeks and stops at 14.
- 10 units stays at 10. It does not climb to 14.
- 10 standard drinks stops at 8.
- A start of 5 stays at 5.

Settings says the same thing in the Tracking footer, in the unit you have selected. It also says a unit change applies from the next week, and that weeks already saved keep their target.

### 11.3 Season titles, then Hold

**Date.** Start at 10 pints. Cold launch on week 8, then week 9, then week 10. Open the app on week 9 before you move to week 10. Jumping straight from week 1 to week 10 does not save week 9.

**Expected:** Week 8 reads “Season 1” and “week 8 of 8”, budget 7 pints. Week 9 reads “Season 2” and “week 1 of 8”, budget 6 pints. It does not say Hold. Week 10 reads “Hold” and “week 2 of 8”, budget still 6. The Sunday seal title is “Hold, week 2 of 8”. No new badge and no confetti for the new name. A start of 10 units never says Hold, because the budget never sits on 14.

### 11.4 The Long Game stays locked on a new plan

1. Reach the guideline floor (6 pints, 14 units, or 8 standard drinks) and open Progress.

**Expected:** The Long Game stays locked. That badge looks for a saved week whose budget is 5. A week created now does not use that old floor, so a person testing a fresh install does not unlock it.

---

## 12. This week against week 1

Progress puts the comparison above the rank. Figures are UK units. A pint counts as 2.3, a UK unit as 1, a standard drink as 1.75. Amounts saved on each week stay in the unit you logged. A week in between is ignored. A rise is shown. The card always says “This is your log, not a health score.”

### 12.1 Week 1 has no comparison yet

1. On week 1, open Progress.

**Expected:** “Your first week is the baseline. The comparison shows from week 2.” There are no two columns and no “Up” or “Down” sentence.

### 12.2 A drop

**Date.** On week 1, log 8 pints. Move to week 2 and log 4 pints. Open Progress. Then move to week 3, log a different amount, and look again.

**Expected:** The title is “This week vs week 1”. Week 2 shows “9.2 UK units” against week 1’s “18.4 UK units”, each with slots as “N of 3”, and “Down 9.2 units from week 1.” The rise and the drop use the same text colour. On week 3 the numbers follow week 3 and week 1. Week 2’s drinks do not appear in the sum.

### 12.3 A rise, and a level week

**Date.** Use Units so the figures match what you tap. Log 4 on week 1.

1. On a later week, log 6. Open Progress.
2. On another run, log 4 again.

**Expected:** 6 against 4 reads “Up 2 units from week 1.” The 2 has no “.0”. Equal weeks read “Level with week 1.”

### 12.4 Mixed units

**Date.** Log week 1 in pints. In Settings, change Drink unit to Units (UK). Move to the next week, log in units, and open Progress. Then open History.

**Expected:** The comparison is still in UK units, and it adds “Compared in UK units so the two weeks mean the same thing.” History still labels week 1 in pints and the new week in units. The logged amounts are not rewritten.

---

## 13. Rank

### 13.1 Crossing into Starter

1. Tick exercises and finish workouts until Progress is at 150 XP or more. Land on Home.

**Expected:** A full-screen cover appears on Home, not over the workout. It says “RANK UP”, the new rank name, and “Keep going”. Dismissing it means that same rank does not cover again.

### 13.2 Losing the rank and earning it again

1. Undo enough that XP falls below the rank you just celebrated.
2. Earn it again and return to Home.

**Expected:** The cover shows again for the rank you earned back.

---

## 14. Reminders

Delivered notifications need a real iPhone. The simulator can confirm the toggle, the time, and the permission alert.

### 14.1 Allow, and the default time

1. In Settings, turn Daily reminder on and allow notifications.

**Expected:** A time picker appears. The default is 08:00. A daily reminder is scheduled. Confirm delivery on a phone.

### 14.2 Permission already denied

1. Deny notifications in iOS Settings, then turn Daily reminder on inside Streakline.

**Expected:** The toggle snaps off. An alert titled “Notifications are disabled” offers “Open iOS Settings” and “Not now”.

### 14.3 The reminder text follows the week

1. On a phone, with the reminder on, change the time. Background the app and return.
2. Compare the pending text after each of these weeks: no sessions finished, one or two finished, all three finished, and over the budget.

**Expected:** The pending reminder uses the new time. The body matches the week: no sessions yet mentions Day A; one or two left names how many workouts remain; all three says to hold the line on the unit you are counting; over the budget says to stop here. If a rank is still ahead, the body can add the XP left to that rank.

---

## 15. Settings, reset, and erase

### 15.1 Change the unit

1. Log drinks on the current week in pints.
2. Settings → Drink unit → Units (UK). Read this week’s Home strip and the Tracking footer.
3. **Date.** Cold launch next week. Open History.

**Expected:** This week still says pints. The footer says the change applies from the next week. The next week uses units, and its step is 1. History rows keep the unit they were logged in.

### 15.2 Reset this week

1. Give the current week a finished session, a note, ticked exercises, drinks, and a saved night plan. Have an older week in History.
2. Settings → Reset current week → Reset week.

**Expected:** The dialog is “Reset this week?” and “This can't be undone.” Cancel leaves the week alone. Reset clears this week’s completions, notes, ticks, and drinks. The night plan you saved is still there. The older week is unchanged. The week number does not return to 1. The shield, if you had one, is still there.

### 15.3 Erase all data

1. Build a few weeks, turn the reminder on, and earn a shield if you can.
2. Settings → Erase all data → Erase all data.
3. Read setup. Start again with Running and the defaults. Kill the app and cold launch.

**Expected:** The dialog says this permanently deletes the history and returns Streakline to setup. Cancel stays on Settings. Confirming lands on setup. The week type is cleared, so “Start my streak” is dimmed until you choose Running, Gym, or Home. After a default Running start: Week 1, pints, budget 10, cards Easy run, Full body, and Long run, no streak, no shield, and no reminder scheduled. A later launch is still Home, not a leftover week.

### 15.4 Support links and the version

1. Open Privacy Policy, Support, and Email Support.
2. Read the version line.

**Expected:** Privacy opens `https://streakline.fit/privacy/`. Support opens `https://streakline.fit/support/`. Email opens a message to `support@streakline.fit`. The version line matches the app’s own version and build.

---

## 16. It keeps what you logged

### 16.1 Offline

1. Turn on airplane mode. Log a drink, finish a workout, kill the app, and cold launch.

**Expected:** The drink and the workout are still there. The app does not show an offline error.

### 16.2 Leave mid-workout

1. Tick one exercise and type a note. Background the app for a minute, return, then kill it and cold launch.

**Expected:** The tick and the note are still there.

### 16.3 A link needs the network

1. Stay in airplane mode and open Privacy Policy.

**Expected:** The page fails because the phone is offline. Drinks and workouts on the phone are unchanged.

---

## 17. What a normal pass will not show

These are in the app and are not a step in the cases above.

- **Storage unavailable.** If the phone cannot open its local store, the screen is “Storage unavailable” with a Contact Support mail link. Nothing you tap in Settings causes that.
- **Day A, Day B, and Day C.** A week saved with no week type still uses those titles, and the long session can show “Run week” or “Circuit week”. Finishing setup always stores Running, Gym, or Home, so a fresh test does not show those titles.
- **Debug fixtures.** A Debug build can be launched with `-ui-fixture` and `home`, `workout`, `progress`, or `onboarding`. That replaces the saved weeks with a fixed scene for screenshots. Release ignores it. It is not a screen in the app, and it wipes whatever you had logged.
