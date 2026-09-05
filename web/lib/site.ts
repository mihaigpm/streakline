/**
 * Single source of truth for site-wide copy, links and contact details.
 * Edit URLs / emails here once the App Store listing and inboxes exist.
 */
type SiteConfig = {
  name: string;
  domain: string;
  url: string;
  tagline: string;
  description: string;
  shortDescription: string;
  appStoreUrl: string;
  testFlightUrl: string;
  email: string;
  supportEmail: string;
  privacyEmail: string;
  social: {
    x: string;
    instagram: string;
    github: string;
  };
  legalEntity: string;
  lastUpdated: string;
};

export const site: SiteConfig = {
  name: "Streakline",
  domain: "streakline.fit",
  url: "https://streakline.fit",
  tagline: "Drink less. Move more. Keep the streak.",
  description:
    "Streakline turns cutting back and getting fit into one daily habit — a shrinking weekly drink budget, guided workouts, dry-day tracking, and a streak you won't want to break. iPhone, private, no account.",
  shortDescription:
    "A drinking-less and getting-fit habit tracker for iPhone. Shrinking drink budget, guided workouts, streaks.",

  // Availability. Only paste a real product or invite URL. Empty and generic
  // Apple landing-page URLs are intentionally treated as unavailable.
  appStoreUrl: "",
  testFlightUrl: "",

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
  lastUpdated: "September 5, 2026",
};

export type Site = typeof site;

function hasAppleUrl(
  value: string,
  hostname: string,
  pathPattern: RegExp,
): boolean {
  try {
    const url = new URL(value);
    return (
      url.protocol === "https:" &&
      url.hostname === hostname &&
      pathPattern.test(url.pathname)
    );
  } catch {
    return false;
  }
}

export const hasAppStoreUrl = hasAppleUrl(
  site.appStoreUrl,
  "apps.apple.com",
  /\/app\/(?:[^/]+\/)?id\d+\/?$/,
);

export const hasTestFlightUrl = hasAppleUrl(
  site.testFlightUrl,
  "testflight.apple.com",
  /\/join\/[A-Za-z0-9]+\/?$/,
);
