import Link from "next/link";
import { Logo } from "./Logo";
import { site } from "@/lib/site";

export function SiteFooter() {
  const year = new Date().getFullYear();
  return (
    <footer className="border-t border-white/5 bg-bg">
      <div className="mx-auto max-w-6xl px-5 py-12">
        <div className="flex flex-col gap-8 md:flex-row md:items-start md:justify-between">
          <div className="max-w-xs">
            <Logo />
            <p className="mt-3 text-sm leading-relaxed text-ink-2">{site.tagline}</p>
          </div>

          <nav className="grid grid-cols-2 gap-x-12 gap-y-2 text-sm sm:grid-cols-3">
            <div className="flex flex-col gap-2">
              <span className="text-xs font-bold uppercase tracking-wider text-ink-3">
                Product
              </span>
              <Link href="/#features" className="text-ink-2 hover:text-ink">Features</Link>
              <Link href="/#how" className="text-ink-2 hover:text-ink">How it works</Link>
              <Link href="/#progress" className="text-ink-2 hover:text-ink">Ranks &amp; badges</Link>
              <Link href="/#faq" className="text-ink-2 hover:text-ink">FAQ</Link>
            </div>
            <div className="flex flex-col gap-2">
              <span className="text-xs font-bold uppercase tracking-wider text-ink-3">
                Legal
              </span>
              <Link href="/privacy" className="text-ink-2 hover:text-ink">Privacy</Link>
              <Link href="/support" className="text-ink-2 hover:text-ink">Support</Link>
            </div>
            <div className="flex flex-col gap-2">
              <span className="text-xs font-bold uppercase tracking-wider text-ink-3">
                Contact
              </span>
              <a href={`mailto:${site.email}`} className="text-ink-2 hover:text-ink">
                {site.email}
              </a>
            </div>
          </nav>
        </div>

        <div className="mt-10 flex flex-col gap-2 border-t border-white/5 pt-6 text-xs text-ink-3 sm:flex-row sm:items-center sm:justify-between">
          <p>
            © {year} {site.legalEntity}. All rights reserved.
          </p>
          <p>
            Streakline is a habit &amp; fitness tracker, not medical advice. Made for iPhone.
          </p>
        </div>
      </div>
    </footer>
  );
}
