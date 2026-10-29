# Feature: the week card

You are a coding agent in the Streakline iOS repo. Implement only this feature.

## Rules

- iOS 17+, SwiftUI, SwiftData, Swift 6 with strict concurrency. Dark mode only. Portrait iPhone.
- No account, no feed, no followers, and no upload of the card.
- Not a medical device. Prices on the card stay estimates.
- Training never awards extra drinks.
- If `WeekSeal` is not in the tree, stop and say so.
- Do not add a paywall in this task. Render the card for everyone. A later prompt may limit the archive.
- Extend tests for any pure caption logic. Do not edit the marketing site except if you need the public URL, which is already `https://streakline.fit`.
- Keep `DesignSystem`. The card uses the same colours, flat, no gradient.

## Why

The growth loop is a picture they drop into a chat they already have. It says they trained. It does not say they are in recovery.

## Build this

`WeekCardView` is a fixed-size card (about 360×450) rendered for `ImageRenderer`, not a scrolling page. Contents, in this order:

- “Streakline”
- Season title if `Season` exists, otherwise “Week N”
- Slots completed out of 3
- Drink line, only when the include-drinks toggle is on
- Estimated money not spent, only when the seal has a positive unspent amount and drinks are included
- Outcome word: Perfect, Held, Shield, or Missed
- `streakline.fit` in small type at the bottom

No rank, no XP, no badge icons, no confetti.

On `WeekSealView`, add “Share”. It presents the card with a toggle “Include drinks”, default on, and a `ShareLink` of the rendered `UIImage`. Sharing does not require an account. If rendering fails, show the existing save-error pattern rather than a new alert style.

The image is generated on device and handed to the system share sheet. Do not write it to a server. You may write it to a temporary file if `ShareLink` needs a URL, and you should not put that file in the app’s documents as a history.

## Do not

- Add a social graph, comments, or a public profile.
- Include the person’s name. The app does not have one.
- Include nicotine, even if a later model exists. This card is the week of training and drinks.

## Done when

- Sunday seal can share a card.
- With drinks off, the image contains no drink count and no money figure.
- With drinks on and an under-budget week, the image contains the count and the estimate.
- A test builds `WeekSeal` caption strings for all four outcomes and for the drinks-hidden case. Unit tests pass.
