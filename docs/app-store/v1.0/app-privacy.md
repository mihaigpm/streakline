# App Privacy questionnaire draft — v1.0

## Proposed App Store Connect answer

Select **“No, we do not collect data from this app.”**

This draft is based on the v1.0 design:

- No account or sign-in
- No backend or cloud sync
- No analytics or advertising SDK
- No third-party tracking
- Drink, workout, streak, progress, and preference data stored only on device
- Notifications created and scheduled locally

Apple generally treats data as “collected” when it is transmitted off the
device in a way that allows the developer or a third party to access it. Data
that remains solely on the device is not declared as collected in the App
Privacy form.

## Required verification against the archive

Before answering, inspect the exact release archive and confirm:

- [ ] No networking code sends user-entered or device data
- [ ] No analytics, crash-reporting, attribution, ad, or telemetry SDK is linked
- [ ] No web view or embedded service collects app data
- [ ] No CloudKit, iCloud sync, remote notification, or server API is enabled
- [ ] No diagnostics are transmitted directly by the developer
- [ ] Third-party SDK privacy manifests and required-reason API declarations are
      present and accurate, if any SDKs are added
- [ ] The live privacy policy matches the shipped binary

If any release-build behavior transmits data, do not use the proposed answer.
Declare each applicable data type, purpose, identity linkage, and tracking use
truthfully in App Store Connect.

## Tracking

Proposed answer: **No tracking.**

Do not request App Tracking Transparency permission unless tracking is later
introduced and the App Privacy answers and policy are updated first.
