# Feature: Streakline Plus

You are a coding agent in the Streakline iOS repo. Implement only this feature.

## Rules

- iOS 17+, SwiftUI, SwiftData, StoreKit 2, Swift 6 with strict concurrency. Dark mode only. Portrait iPhone.
- No account and no server of your own. StoreKit talks to Apple. Entitlement is resolved on device.
- Not a medical device.
- Training never awards extra drinks.
- The current week stays free. Do not put a hard paywall on onboarding, the first workout, the drink log, the morning line, or the first Sunday seal.
- If shields, `WeekSeal`, and the week card are not in the tree, stop and say so.
- Extend tests with a fake entitlement. Do not edit the marketing site’s pricing. Do not claim a price in the UI that you hardcoded if StoreKit has a product; display `Product.displayPrice`.
- Keep `DesignSystem`.

## Why

People should pay to keep a record they have already felt, not to unlock the first session. Plus is about £35 a year. The price the user sees comes from App Store Connect. The product id is fixed.

## Build this

Product id: `com.mihaigarda.threshold.plus.annual`. One auto-renewing annual subscription. Add a StoreKit configuration file so the tests and the simulator can load it. Do not add a monthly plan.

`PlusEntitlement` is a small `@Observable` type that listens to `Transaction.currentEntitlements` and exposes `isPlus: Bool`. Inject a protocol so tests can force `isPlus` without StoreKit. Default in the running app is the real StoreKit check. Unknown or failed product load means not plus, and the free app still works.

Free, forever:

- The current week: slots, drink log, receipt, morning line, streak, one shield, the current season, the first Sunday seal, and the month screen.
- Swapping among the built-in templates.

Plus:

- History and Sunday seals older than the last 4 weeks. The last 4 weeks stay visible when not plus. Older rows in `HistoryView` show the week number and a lock, and open the paywall rather than the seal.
- Past week cards. Sharing the current week’s card stays free. Sharing an older card requires Plus.
- A second shield. When `isPlus` is true, `ProgrammeState` cap becomes 2. When it lapses, do not delete a shield they already hold, but do not grant above 1 again until they resubscribe.
- Custom template names: a Plus user can rename a slot’s template for the week. Free users keep the built-in names.

Offer the paywall once, the first time they dismiss their first Sunday seal. Store that in `AppStorage` `hasOfferedPlus`. Do not offer it during onboarding or on the first launch. Settings gets “Streakline Plus” with subscribe, restore, and the four Plus lines above. Restore uses `AppStore.sync()`.

If the product fails to load, the settings row says the plan is unavailable and the free app is unchanged.

## Do not

- Gate logging, the ring, or the first seal.
- Add a coin pack, a drink credit, or a consumable shield.
- Send receipts to a server you operate.

## Done when

- A non-plus user can use the current week and sees older-than-4-weeks history locked.
- A plus user sees that history, can hold two shields, and can rename a slot for the week.
- The offer appears after the first seal dismissal and not before.
- Tests use a fake entitlement for the lock and the shield cap. Unit tests pass.
