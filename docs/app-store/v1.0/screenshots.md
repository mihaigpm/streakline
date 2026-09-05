# Screenshot shot list — v1.0

Capture screenshots from the final Release build using realistic, internally
consistent sample data. Use an Apple-accepted iPhone screenshot size shown in
the current App Store Connect upload interface; export full-resolution images
without device frames unless the final creative is intentionally composited.

## Captured source screens

Four unframed 1320 × 2868 iPhone 17 Pro Max captures are available in
`docs/app-store/screenshots/`: onboarding, Home, guided workout, and Progress.
They have been visually checked for placeholder/debug UI. Re-capture from the
final uploaded build if the UI changes, and add marketing overlays only if every
claim remains legible and accurate.

## Recommended six-shot sequence

1. **One habit, two goals**
   - Screen: Home
   - Show: weekly workout progress, drink budget, and dry-day dots
   - Overlay: “Drink less. Move more.”

2. **Start where you are**
   - Screen: onboarding budget setup
   - Show: drink-unit choice and starting weekly budget
   - Overlay: “Choose your unit and starting budget”

3. **A target that changes gradually**
   - Screen: Home or history state that accurately shows the current target
   - Overlay: “Down by 1 every two weeks, to a floor of 5”
   - Do not use a fixed starting value in the creative.

4. **Three guided workouts each week**
   - Screen: weekly workout cards or workout detail
   - Show: Day A, Day B, and Day C with one completed state
   - Overlay: “A clear plan, three days a week”

5. **Form help for every move**
   - Screen: exercise focus mode
   - Show: steps, form cues, and common mistakes
   - Overlay: “Instructions when you need them”

6. **Progress worth keeping**
   - Screen: Progress
   - Show: XP, rank, streak, and a mix of locked/unlocked badges
   - Overlay: “Build streaks. Earn XP. Keep going.”

## Capture checklist

- [ ] All screens come from version 1.0's final UI
- [ ] Status bar time, battery, and connectivity are tidy and consistent
- [ ] Drink units and totals agree across screenshots
- [ ] Week number, target progression, streak, XP, rank, and badges are
      mathematically consistent
- [ ] No placeholder names, debug UI, personal data, notifications, or test
      banners are visible
- [ ] Copy remains readable at App Store thumbnail size
- [ ] Claims match actual v1.0 behavior
- [ ] Localisations use native captures or fully reviewed translated creative
- [ ] Final images are checked in App Store Connect for cropping and ordering

## Optional preview

Do not delay v1.0 solely for an app preview. If one is produced, keep it short,
show only captured in-app interaction, avoid medical claims, and verify its
format against current App Store Connect requirements.
