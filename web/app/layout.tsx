import type { Metadata, Viewport } from "next";
import { Nunito } from "next/font/google";
import { site } from "@/lib/site";
import "./globals.css";

// Nunito is the closest free web face to the app's SF Pro Rounded:
// geometric, rounded, with a heavy display weight for headlines.
const nunito = Nunito({
  subsets: ["latin"],
  variable: "--font-nunito",
  display: "swap",
});

export const metadata: Metadata = {
  metadataBase: new URL(site.url),
  title: {
    default: `${site.name} — ${site.tagline}`,
    template: `%s — ${site.name}`,
  },
  description: site.description,
  applicationName: site.name,
  keywords: [
    "drink less",
    "cut back drinking",
    "sober curious",
    "alcohol tracker",
    "habit tracker",
    "fitness app",
    "workout streak",
    "dry days",
    "iPhone app",
  ],
  authors: [{ name: site.name }],
  alternates: { canonical: "/" },
  openGraph: {
    type: "website",
    siteName: site.name,
    title: `${site.name} — ${site.tagline}`,
    description: site.description,
    url: site.url,
    locale: "en_US",
  },
  twitter: {
    card: "summary_large_image",
    title: `${site.name} — ${site.tagline}`,
    description: site.description,
  },
  category: "health",
};

export const viewport: Viewport = {
  themeColor: "#0a0a0f",
  colorScheme: "dark",
  width: "device-width",
  initialScale: 1,
};

// Adds `.js` before first paint so [data-reveal] can start hidden without a
// flash. Does not touch element classes or styles — those are applied after
// hydration by ScrollReveal. Opts out under reduced motion, which leaves the
// content visible. `suppressHydrationWarning` on <html> covers this one class.
const revealScript = `(function(){try{if(window.matchMedia&&window.matchMedia('(prefers-reduced-motion: reduce)').matches)return;}catch(e){}document.documentElement.classList.add('js');})();`;

export default function RootLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  return (
    <html
      lang="en"
      className={`${nunito.variable} h-full`}
      data-scroll-behavior="smooth"
      suppressHydrationWarning
    >
      <body className="min-h-full antialiased">
        <script dangerouslySetInnerHTML={{ __html: revealScript }} />
        {children}
      </body>
    </html>
  );
}
