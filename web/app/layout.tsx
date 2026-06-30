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

// Bulletproof scroll-reveal: vanilla JS, independent of React hydration.
// Adds `.js` before first paint (so the hidden start state applies without a
// flash), observes elements on DOMContentLoaded, and a safety timer guarantees
// nothing can ever stay hidden. Opts out under reduced-motion.
const revealScript = `(function(){var d=document,r=d.documentElement;try{if(window.matchMedia&&window.matchMedia('(prefers-reduced-motion: reduce)').matches)return;}catch(e){}r.classList.add('js');function show(el){el.classList.add('is-visible');}function init(){var els=[].slice.call(d.querySelectorAll('[data-reveal]'));if(!('IntersectionObserver'in window)){els.forEach(show);return;}var io=new IntersectionObserver(function(es){es.forEach(function(e){if(e.isIntersecting){var el=e.target;if(el.dataset.revealDelay)el.style.animationDelay=el.dataset.revealDelay+'ms';show(el);io.unobserve(el);}});},{rootMargin:'0px 0px -10% 0px',threshold:.12});els.forEach(function(el){io.observe(el);});setTimeout(function(){els.forEach(show);},2500);}if(d.readyState!=='loading')init();else d.addEventListener('DOMContentLoaded',init);})();`;

export default function RootLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="en" className={`${nunito.variable} h-full`} suppressHydrationWarning>
      <body className="min-h-full antialiased">
        <script dangerouslySetInnerHTML={{ __html: revealScript }} />
        {children}
      </body>
    </html>
  );
}
