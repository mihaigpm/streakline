# Feature: the anonymous week row

You are a coding agent in the Streakline iOS repo. Implement only this feature.

## Rules

- iOS 17+, SwiftUI, SwiftData, Swift 6 with strict concurrency. Dark mode only.
- Default is off. With the switch off, no request leaves the phone. There is still no account.
- Not a medical device. Do not send health data, drink-by-drink logs, notes, or dates.
- Training never awards extra drinks.
- If `AlcoholUnits` and `WeekSeal` are not in the tree, stop and say so.
- Do not add a third-party analytics SDK.
- Extend tests. Do not edit the marketing site.
- Keep `DesignSystem`.

## Why

A raise needs a number that is not a spreadsheet on one laptop: among people who reached week 4, weekly units moved. The same month screen the user can see is the row they may opt in to send. Privacy stays the default.

## Build this

Settings, under Tracking, a toggle “Share an anonymous week summary”, default off. Footer: “Sends one row when a week seals: week number, units, slots, and whether you were under budget. No dates, no drink list, no name. Off unless you turn it on.”

`AppStorage` key `shareAnonymousWeekSummary`, default false.

Create a random UUID the first time they turn it on, stored in the keychain under `streakline.anonymousInstallId`. Do not use the vendor id. Do not regenerate it every launch. Deleting the toggle’s data on “Erase all data” must delete this id too. Find the existing erase path in `AppDataManager` and `SettingsView`.

`WeekSummary` JSON, schema 1, exact keys:

```json
{
  "schema": 1,
  "installId": "uuid",
  "weekNumber": 4,
  "unitsConsumed": 11.5,
  "unitsBudget": 14.0,
  "slotsCompleted": 2,
  "underBudget": true
}
```

`unitsConsumed` and `unitsBudget` are UK units from `AlcoholUnits`, rounded to 1 decimal. `underBudget` is `totalDrinks <= drinkBudget` in the week’s own unit. No other keys.

`WeekSummaryUploading` is a protocol. `NoopWeekSummaryUploader` does nothing. `HTTPWeekSummaryUploader` POSTs the JSON only when `Info.plist` key `StreaklineSummaryEndpoint` is a non-empty https URL. If the key is missing or empty, use the noop uploader even when the toggle is on. Add the key to `project.yml` info properties as an empty string.

Send at most once per sealed week, when the user opens `WeekSealView` for a past week or for the current week on Sunday, and only if the toggle is on. Persist the last sent `weekNumber` so dismissing the sheet twice does not send twice. Failure to send is silent. Do not block the seal and do not show an error alert.

The endpoint, when someone later hosts it, should accept that JSON and nothing else. Do not build the server in this repo.

## Do not

- Send on a schedule in the background.
- Include template names, nicotine, prices, or the shield flag.
- Turn the toggle on for existing users.

## Done when

- Toggle off produces no request and no id.
- Toggle on with an empty endpoint builds the payload and does not open a connection.
- The payload for a known week matches the schema in a unit test, including the UK-unit conversion.
- Erase-all removes the install id.
- Unit tests pass.
