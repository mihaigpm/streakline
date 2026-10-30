# Streakline brand

The single source of truth for color, type, and voice. The iOS app, the website, and App Store copy defer to this file.

When something here changes, change it here first, then propagate to:

- `Streakline/Streakline/Utilities/DesignSystem.swift`
- `Streakline/Streakline/Assets.xcassets` (`BrandTeal`, `BrandAmber`, `LaunchBackground`)
- `web/app/globals.css`
- `Streakline/Tools/generate_icon.py` (icon and launch mark)
- `docs/app-store/` if a listing line changes

---

## Archetype

**Dark training log.**

Near-black field. Two signals, and only two: teal for training, amber for the drink target. Red is over-budget and destructive, not a third brand color. Big week number, one progress ring, one drink strip.

The product is a streak you keep, not a clinic and not a party. Copy is short, numeric, and calm when someone goes over.

---

## Color

All values are sRGB. The app is dark. `UIUserInterfaceStyle` is Dark, and the root view asks for `.dark`. There is no light theme.

Teal and amber in the app come from the asset catalog (`BrandTeal`, `BrandAmber`). The hex values below are those colors. Literals in `DesignSystem.Colors` match the rest of the table. Web tokens in `web/app/globals.css` match too.

### Surfaces and text

| Token | Hex | Used as |
|-------|-----|---------|
| `background` | `#0A0A0F` | Screen, launch background, text on a teal button |
| `surface` | `#13131A` | Cards |
| `surfaceHigh` | `#1C1C26` | Pills, tracks, raised rows |
| `border` | `#2A2A38` | Hairline |
| `textPrimary` | `#FFFFFF` | Primary text |
| `textSecondary` | `#8888A0` | Secondary text |
| `textTertiary` | `#555568` | Hints, chevrons |

### Signals

| Token | Hex | Used as |
|-------|-----|---------|
| `teal` | `#00E5C3` | Primary button, workout arc, dry day, rank, Day A and Day C |
| `tealDim` | `#00E5C3` at 15% | Selected pill fill |
| `amber` | `#F5A623` | Drink arc, budget badge, streak flame, Day B |
| `amberDim` | `#F5A623` at 15% | Budget badge fill, drink strip when over 70% |
| `red` | `#FF4D4D` | Over budget, destructive actions |

### Buttons

| Role | Treatment |
|------|-----------|
| Primary | Teal fill, `background` text |
| Destructive | Settings role `.destructive` (reset week, erase all data) |
| Toolbar | `textSecondary` icons |

White on teal is not the primary label. The label is the near-black background color.

### Ring and drink strip

| State | What changes |
|-------|----------------|
| Workouts | Outer arc, teal, 0…3 |
| Drinks under 70% of budget | Inner arc amber. Strip uses `surface` |
| Drinks over 70% and at or under budget | Strip shifts amber |
| Over budget | Inner arc and strip go red. Home badge stays "0 left", in red |

---

## Typography

**iOS:** system font. Display, headlines, and labels use `.rounded`. Body and `bodySmall` use the default system face. Do not add a second family in the app.

**Web:** Nunito, as the closest free face to SF Pro Rounded. Do not introduce a different web family for one page.

### iOS roles

| Token | Style | Where |
|-------|--------|--------|
| `displayLarge` / `displayMedium` | `.largeTitle`, rounded, black | Ring count, season title, setup title |
| `displaySmall` | `.title`, rounded, bold | Screen titles inside a flow, rank name |
| `headlineLarge` | `.title3`, rounded, bold | Card titles, primary button |
| `headlineSmall` | `.headline`, rounded, semibold | Section labels, drink total |
| `labelLarge` | `.subheadline`, rounded, semibold | Pills, meta |
| `labelSmall` | `.caption`, rounded, medium | Captions, version |
| `body` | `.body` | Running text |
| `bodySmall` | `.subheadline` | Supporting text |

Counts that change in place already use `.contentTransition(.numericText())`. Keep that when you add another live number.

---

## Mark

Two rising strokes on `#0A0A0F`: a teal lead line and a shorter amber line trailing it, plus a spark at the teal tip. Light, dark, and tinted icon variants are generated together.

**Source:** `Streakline/Tools/generate_icon.py` (needs Pillow).

```bash
cd Streakline
python3 Tools/generate_icon.py
```

Do not redraw the mark in a design tool and drop a one-off PNG into the asset catalog. Change the generator, then regenerate.

### Don'ts

- A third accent
- A light mode
- A wordmark locked up under the strokes inside the app icon
- Emoji in the product UI
- Drop shadows on the mark itself (the generator's glow behind the strokes is the exception)

---

## Voice

Locked lines, per surface. Do not merge them in a drive-by edit.

| Surface | Line |
|---------|------|
| App README | Train hard. Drink less. Keep the streak. |
| App Store subtitle | Drink less. Move more. |
| Website (`web/lib/site.ts`) | Drink less. Move more. Keep the streak. |

### How to write

- Short sentences. Name the number. "Drops by 1 every two weeks" beats "gradually improve".
- Coach, not clinic, not hype. No "wellness journey", "your best self", or "transform".
- Over budget is calm. The reminder says to stop here. It does not scold.
- One health notice, in the wording already on onboarding and in Settings: adults of legal drinking age, habit and fitness tracker, not medical advice or treatment, get medical advice first if withdrawal is a risk. Do not call the target a medically safe limit.
- No account, no server. Do not write "we sync" or "we save to your account".

### Buttons already in the app

| Action | Label |
|--------|--------|
| Finish setup | Start my streak |
| Complete a workout early | Mark as done |
| Complete after every exercise | Finish workout |
| Take a completion back | Undo |
| Wipe the phone's data | Erase all data |
