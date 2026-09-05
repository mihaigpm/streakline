# App Store submission runbook

This runbook is for the existing Streakline App Store Connect record and its permanent bundle ID, `com.mihaigarda.threshold`.

## Before creating a build

1. Pull `main` and confirm the working tree is clean.
2. Install Xcode 26 or newer, XcodeGen, and Python Pillow.
3. Update `MARKETING_VERSION` and increment `CURRENT_PROJECT_VERSION` in `Streakline/project.yml`.
4. Run:

   ```sh
   cd Streakline
   python3 Tools/generate_icon.py
   xcodegen generate
   xcodebuild test -project Streakline.xcodeproj -scheme Streakline \
     -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
   ```

5. Confirm `PrivacyInfo.xcprivacy` is included in the app target and run Xcode's privacy report.
6. Complete fresh-install and upgrade QA on the oldest supported iOS release and current iOS.

## Manual QA gate

- Complete onboarding with each drink unit and verify the selected starting target.
- Advance test dates across week 2, week 3, and the floor target.
- Log, undo, and complete all workout and drink actions.
- Verify historical weeks retain their original unit.
- Deny and allow notifications; confirm no permission prompt appears before user intent.
- Exercise Reset Current Week and Erase All Data.
- Walk every screen with VoiceOver, Larger Text, Reduce Motion, and Differentiate Without Color.
- Check iPhone SE-size and Pro Max-size layouts in portrait.
- Confirm privacy/support URLs and all three contact inboxes work.

## Archive and upload

1. Open the generated project and select the existing Apple Developer team under Signing & Capabilities. Do not change the bundle ID.
2. Select **Any iOS Device (arm64)** and choose **Product > Archive**.
3. In Organizer, run **Validate App** and resolve every error and privacy warning.
4. Distribute with **App Store Connect > Upload** and include symbols.
5. Wait for processing, then attach the build to version 1.0 in App Store Connect.

The project declares no non-exempt encryption and no collected data. Reconfirm both statements whenever dependencies or network features change.

## App Store Connect gate

- Copy reviewed metadata from `docs/app-store/`.
- Add the live privacy and support URLs.
- Complete content rights, pricing, tax, availability, category, accessibility, and age-rating questions truthfully.
- Upload screenshots captured from the submitted build with no debug or placeholder content.
- Add review notes explaining that the app has no account, backend, purchases, or review credentials.
- Re-test the processed TestFlight build before submission.

## Release and rollback

- Prefer a seven-day phased release for the first production version.
- Monitor App Store Connect diagnostics and support mail daily during the phase.
- Pause the phased release if data loss, launch failure, or incorrect week/budget calculations appear.
- Apple does not support binary rollback. Prepare a higher build/version hotfix, validate it, and request expedited review only for a critical production issue.
- After approval, set the production App Store URL in `web/lib/site.ts`, deploy the site, and verify the badge resolves to the correct listing.
