# Feature: the drink receipt

You are a coding agent in the Streakline iOS repo. Implement only this feature.

## Rules

- iOS 17+, SwiftUI, SwiftData, Swift 6 with strict concurrency. Dark mode only. Portrait iPhone.
- No account and no network. All data stays on device.
- Not a medical device. Estimates are labelled estimates. No blood alcohol, impairment, or driving copy.
- Training never awards extra drinks. Do not offer extra budget because someone trained.
- If planned nights and `AlcoholUnits` are not in the tree, stop and say so.
- Do not add the morning line, Sunday seal, share card, or paywall.
- Extend tests. Do not edit the marketing site.
- Keep `DesignSystem`. Amber is drinks.

## Why

The number that makes someone screenshot the app is what the night cost, not another badge. Cost and calories are rough public averages. They must look like estimates.

## Build this

Add `ReceiptEstimates` as a pure type. These constants are the whole price list. Comment that they are rough 2026 UK averages for planning, not a till receipt.

| Unit | Estimated price | Estimated kcal |
| --- | --- | --- |
| Pint | £5.50 | 220 |
| UK unit | £2.40 | 95 |
| Standard drink | £6.00 | 140 |

For a given week, from its logged drinks:

- `spent` = total drinks × price of that week’s unit
- `unspent` = `drinksRemaining` × price, and 0 when they are over budget. Never show a negative “saving”.
- `kcal` = total drinks × kcal of that unit

Copy uses “about” or “est.” every time a price or calorie number appears.

Show a receipt line on the home drink strip once the week’s total is greater than 0: amount, estimated spend, estimated calories. If a slot is still open, add the name of the next open slot (“Saturday’s long run is still open” or whatever that template is called). If every slot is complete, omit the session clause. If planned nights exist, prefer the next open slot on a day after the most recent drink; if that is ambiguous, use the first incomplete slot in Day A, B, C order.

Tapping the line opens a small sheet with the same three figures and one sentence: “Estimates use average pub prices and typical drink calories. They are not a measure of your night.”

No new persisted fields. Compute from logs.

## Do not

- Fetch prices from the network.
- Convert the user’s logs into a different unit before multiplying. Price the week in the unit it was logged in.
- Add a paywall around the receipt.

## Done when

- 3 pints on a guideline week show about £16.50 and about 660 kcal, labelled as estimates.
- An over-budget week shows spend and calories and does not show money saved.
- The session clause disappears when all three slots are complete.
- Tests cover the arithmetic, the over-budget zero unspent amount, and that the copy contains an estimate qualifier.
- Unit tests pass.
