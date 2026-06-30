/**
 * Single source of truth for site-wide copy, links and contact details.
 * Edit URLs / emails here once the App Store listing and inboxes exist.
 */
export const site = {
  name: "Streakline",
  domain: "streakline.fit",
  url: "https://streakline.fit",
  tagline: "Drink less. Move more. Keep the streak.",
  description:
    "Streakline turns cutting back and getting fit into one daily habit — a shrinking weekly drink budget, guided workouts, dry-day tracking, and a streak you won't want to break. iPhone, private, no account.",
  shortDescription:
    "A drinking-less and getting-fit habit tracker for iPhone. Shrinking drink budget, guided workouts, streaks.",

  // Availability. Leave appStoreUrl empty until the public listing is live —
  // the UI falls back to a "coming soon" state and the TestFlight CTA.
  appStoreUrl: "",
  testFlightUrl: "https://testflight.apple.com/",

  // Contact — point these at real inboxes on the streakline.fit domain.
  email: "hello@streakline.fit",
  supportEmail: "support@streakline.fit",
  privacyEmail: "privacy@streakline.fit",

  // Optional socials (rendered only when set).
  social: {
    x: "",
    instagram: "",
    github: "",
  },

  // Used in legal copy.
  legalEntity: "Streakline",
  lastUpdated: "June 2026",
} as const;

export type Site = typeof site;
