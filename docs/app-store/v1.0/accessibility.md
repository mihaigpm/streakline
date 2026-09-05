# Accessibility declaration checklist — v1.0

Apple's accessibility declarations must reflect tested support in the submitted
version. Do not check a supported feature in App Store Connect based only on
SwiftUI defaults or source inspection.

## Test setup

- [ ] Test the archived Release build on a supported physical iPhone
- [ ] Test onboarding, Home, workout detail/focus mode, Progress, History, and
      Settings
- [ ] Test first launch, populated data, empty states, alerts, and permission
      prompts
- [ ] Record device, iOS version, app version/build, tester, and date

## Features to evaluate and declare truthfully

### VoiceOver

- [ ] Every actionable control has a clear spoken label and trait
- [ ] Drink plus/minus controls announce purpose, current value, and result
- [ ] Workout completion controls announce selected/completed state
- [ ] Progress rings, charts, badges, and day dots have meaningful alternatives
- [ ] Decorative images are hidden from accessibility
- [ ] Focus order follows the visual and task order
- [ ] Alerts, sheets, and rank-up states move focus appropriately

### Larger Text

- [ ] Primary flows remain usable at all supported Dynamic Type sizes
- [ ] Text does not clip, overlap, or become unreachable
- [ ] Controls retain usable touch targets and labels
- [ ] Scrolling exposes content that no longer fits

### Dark Interface / sufficient contrast

- [ ] Text and controls meet appropriate contrast in the app's dark interface
- [ ] Teal, amber, and red states are not communicated by colour alone
- [ ] Increased Contrast and Reduce Transparency do not hide information

### Differentiate Without Colour

- [ ] Drink/day states include text, shape, icon, or spoken alternatives
- [ ] Completion and warning states remain understandable without colour

### Reduced Motion

- [ ] Reduce Motion avoids or simplifies nonessential rank, progress, and
      transition animation
- [ ] No required information depends on animation

### Captions and audio descriptions

- [ ] Confirm whether the release contains audio or video
- [ ] If none is present, answer related questions accordingly
- [ ] If media is added, test and document captions and audio descriptions

## Sign-off

- **Tested build:** `[CONFIRM VERSION AND BUILD]`
- **Tester/date:** `[CONFIRM]`
- **Features declared supported:** `[CONFIRM AFTER TESTING]`
- **Known limitations:** `[CONFIRM]`
- **Evidence location:** `[CONFIRM SCREEN RECORDINGS OR TEST NOTES]`
