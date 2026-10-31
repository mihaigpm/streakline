# CI and TestFlight

How Streakline gets a TestFlight build. Read this before changing the pipeline. The workflow in App Store Connect is the source of truth if this doc drifts.

There are no client secrets. Do not add a required environment variable to `ci_post_clone.sh` until the app has one.

## What runs when

The workflow is **not** in git. It lives in App Store Connect on the Streakline app (`com.mihaigarda.threshold`).

- Action: **Archive - iOS**, scheme `Streakline`, distribution **TestFlight**.
- Project path: `Streakline/Streakline.xcodeproj`.
- `ci_scripts` must stay next to that project: `Streakline/ci_scripts/ci_post_clone.sh` (executable).

Xcode writes `Streakline/Streakline.xcodeproj/xcshareddata/xcodecloud/manifest.json` locally when the project is linked. That file is not the workflow. Editing it does not change start conditions or the TestFlight action.

A build log that never prints `Set CURRENT_PROJECT_VERSION` did not run this script. The workflow's project path has to be the `.xcodeproj` above, so Cloud finds `ci_scripts` beside it.

## Version numbers

`MARKETING_VERSION` in `Streakline/project.yml` is the user-visible version. Change it by hand when testers should see a new version name, then regenerate the project.

`ci_post_clone.sh` overwrites every `CURRENT_PROJECT_VERSION` in `project.pbxproj` on the Xcode Cloud machine, before the archive. The build number is `CI_BUILD_NUMBER`, the Xcode Cloud run count for **this** workflow. The later "Prepare build for App Store Connect" step submits that same number. The binary has to match it. The script does not commit the number back. A local Xcode archive uses the number in git (`4` until you bump `project.yml`). It does not run this script.

Do not add an offset such as `10000 + CI_BUILD_NUMBER`. Prepare still submits the raw run count, so the archive step can succeed and then fail with **Preparing build for App Store Connect failed**. Do not delete and recreate the workflow: the run count starts over and can reuse a build number TestFlight already has for this marketing version, including the manual uploads `1`–`4`.

`ITSAppUsesNonExemptEncryption` is `false` in `Streakline/Streakline/Info.plist`. Leave it `false` unless the app adds its own non-exempt cryptography.

TestFlight rejects a repeated marketing version and build number. The compile and archive logs stay green. The failed issue is category `PrepareBuildForAppStoreConnect`, message **Preparing build for App Store Connect failed**, and the TestFlight action is skipped.

## Local project generation

`xcodegen generate` rewrites `project.pbxproj` from `project.yml`. Set `CURRENT_PROJECT_VERSION` there before you generate, or a local archive goes backwards. Cloud still replaces that number on the runner. You do not bump `project.yml` for a TestFlight run.
