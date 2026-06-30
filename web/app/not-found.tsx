import type { Metadata } from "next";
import Link from "next/link";
import { SiteHeader } from "@/components/SiteHeader";
import { SiteFooter } from "@/components/SiteFooter";
import { LogoMark } from "@/components/Logo";
import { PrimaryCTA } from "@/components/cta";

export const metadata: Metadata = {
  title: "Page not found",
  robots: { index: false },
};

export default function NotFound() {
  return (
    <>
      <SiteHeader />
      <main className="ambient flex min-h-[60vh] flex-col items-center justify-center px-5 py-24 text-center">
        <LogoMark className="h-14 w-14 [filter:drop-shadow(0_0_18px_#00e5c355)]" title="" />
        <p className="mt-6 text-sm font-bold uppercase tracking-widest text-teal">404</p>
        <h1 className="mt-2 text-4xl font-black tracking-tight md:text-5xl">
          This page broke the streak
        </h1>
        <p className="mt-4 max-w-md text-lg text-ink-2">
          The page you are looking for does not exist or has moved.
        </p>
        <div className="mt-8 flex flex-wrap items-center justify-center gap-4">
          <Link
            href="/"
            className="rounded-xl border border-border bg-surface px-6 py-3.5 text-base font-bold text-ink transition-colors hover:border-teal/40"
          >
            Back home
          </Link>
          <PrimaryCTA label="Join the beta" />
        </div>
      </main>
      <SiteFooter />
    </>
  );
}
