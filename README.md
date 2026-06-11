# Streakline

**Train hard. Drink less. Keep the streak.**

Streakline is a personal fitness and alcohol-reduction tracker for iOS. It pairs a baked-in 3-day/week workout plan with a weekly drink budget that automatically shrinks over time — and gamifies the discipline of sticking to both.

It is opinionated by design: the plan does the thinking, you log against it. One tap to mark a workout done. One tap to log a drink.

## Features

- **3-day workout plan** — Day A (run + glute circuit), Day B (full-body weights), Day C (long run / circuit, alternating weekly). Exercises are predefined with sets, reps, and coaching notes.
- **Guided exercise focus mode** — swipe through full-screen exercise guides with step-by-step instructions, form cues, and common mistakes. Tick off exercises as you go.
- **Shrinking drink budget** — starts at 10/week, drops by 1 every 2 weeks, floors at 5. Configurable units: UK pints, UK units, or standard drinks.
- **Dry-day tracking** — daily dots make alcohol-free days visible and collectible.
- **Gamification** — XP for every exercise, workout, dry day, and perfect week. 9 ranks from Rookie to Legend, 12 badges, rank-up celebrations, and weekly streaks.
- **Progress ring home screen** — dual-arc ring showing workout completion (teal) and budget consumption (amber) at a glance.
- **Smart daily reminders** — local notification copy adapts to your week state and XP progress. No account, no server: all data stays on device.

## Tech stack

- **SwiftUI + SwiftData** (iOS 17+), MVVM with `@Query`-driven views
- **Swift 6** with strict concurrency
- **[xcodegen](https://github.com/yonaskolb/XcodeGen)** for project generation
- Local notifications via UserNotifications — no backend

## Repository layout

```
Streakline/            The iOS app
  project.yml          xcodegen project definition
  Streakline/          App sources (Models, Views, Components, Utilities)
  Tools/               Brand asset generator (app icon + launch logo)
.agents/               Agent skills used during development
FitTrack_iOS_Spec.docx Original build spec (v1.0, pre-rename)
```

## Building

Requirements: Xcode 16+, [xcodegen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`).

```bash
cd Streakline
xcodegen generate
open Streakline.xcodeproj
```

The Xcode project is committed, so a plain clone also opens directly — regenerate it after editing `project.yml`.

### Regenerating brand assets

The app icon (light/dark/tinted) and launch logo are generated programmatically:

```bash
cd Streakline
python3 Tools/generate_icon.py   # requires Pillow
```

## Roadmap

- iCloud sync via CloudKit + SwiftData
- Preset workout programs beyond the built-in plan
- HealthKit integration, Apple Watch companion, home screen widget
