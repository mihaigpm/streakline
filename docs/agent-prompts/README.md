# Agent prompts for the Streakline roadmap

One prompt per feature. Paste a single file into a fresh agent as its whole task. Do not paste two features into one agent, and do not run two agents that list the same files at the same time.

Each prompt is self-contained. The product rules at the top of every file are the same on purpose.

## Order

Run them in this order. A later prompt tells the agent to stop if its dependency is missing.

| # | Prompt | Depends on | Touches |
| --- | --- | --- | --- |
| 1 | [01-unit-honest-floor.md](01-unit-honest-floor.md) | Nothing | `AppWeek`, `DrinkUnit`, onboarding, settings, tests |
| 2 | [02-session-slots.md](02-session-slots.md) | Nothing structural. Start after 1 so the branches do not collide. | `WorkoutDay`, `WorkoutLog`, exercise library, home, onboarding |
| 3 | [03-streak-shield.md](03-streak-shield.md) | 2, so “2 of 3 slots” matches the slot model | `WeekManager`, `Gamification`, `AppWeek` |
| 4 | [04-planned-nights.md](04-planned-nights.md) | 1 | `AppWeek`, drink logging |
| 5 | [05-drink-receipt.md](05-drink-receipt.md) | 1 and 4 | New estimates type, drink strip, home |
| 6 | [06-morning-line.md](06-morning-line.md) | 2 and 5 | Home, `Gamification` XP |
| 7 | [07-sunday-seal.md](07-sunday-seal.md) | 3, 5, and 6 | New Sunday view, home |
| 8 | [08-seasons.md](08-seasons.md) | 1 and 7 | Week header, Sunday seal |
| 9 | [09-month-screen.md](09-month-screen.md) | 1 | `ProgressScreen` |
| 10 | [10-week-card.md](10-week-card.md) | 7 | Sunday seal, share sheet |
| 11 | [11-streakline-plus.md](11-streakline-plus.md) | 3, 7, and 10 | StoreKit, settings, history |
| 12 | [12-anonymous-week-row.md](12-anonymous-week-row.md) | 1 and 7 | Settings, a POST that stays off until a URL exists |
| 13 | [13-nicotine-days.md](13-nicotine-days.md) | 6 and 11 | Optional day marks, Plus gate |
| 14 | [14-healthkit-slot.md](14-healthkit-slot.md) | 2 | Health read, slot completion |
| 15 | [15-home-widget.md](15-home-widget.md) | 1 and 2 | New widget target, app group |
| 16 | [16-morning-reminder.md](16-morning-reminder.md) | 6 | `NotificationManager` |
| 17 | [17-icloud-sync.md](17-icloud-sync.md) | 11 and 13, and only once you have stopped changing the schema | CloudKit, entitlements |

9 and 10 can run in parallel after 7 and 1 are merged. 14, 15, and 16 can run in parallel after their dependencies are merged. Nothing else should run in parallel.

## What these prompts refuse

No agent may add a course, a friends feed, an AI plan generator, a blood-alcohol estimate, a general habit grid, or a rule that awards extra drinks for training. Those are out of the roadmap.

## After each agent

Merge only when `StreaklineTests` pass and the prompt’s “Done when” list is true. Then start the next prompt on a fresh branch from that merge.
