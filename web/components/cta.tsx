import Link from "next/link";
import { ArrowRight } from "lucide-react";
import { site } from "@/lib/site";

function AppleGlyph({ className }: { className?: string }) {
  return (
    <svg viewBox="0 0 384 512" className={className} aria-hidden="true">
      <path
        fill="currentColor"
        d="M318.7 268.7c-.2-36.7 16.4-64.4 50-84.8-18.8-26.9-47.2-41.7-84.7-44.6-35.5-2.8-74.3 20.7-88.5 20.7-15 0-49.4-19.7-76.4-19.7-39.6.6-82 33.5-100.2 88.6-21.9 64.9-5.6 130.9 38.5 192.4 21.5 30.4 47 64.5 80.5 63.3 32.3-1.3 44.5-20.9 83.6-20.9 38.8 0 50 20.9 83.9 20.2 34.6-.6 56.5-30.4 78-60.9 24.8-35.5 35-69.9 35.2-71.6-1-.4-67.5-25.9-67.6-103.1zM263.9 65.5c19.6-24 33.3-57.3 29.6-90.5-28.5 1.2-63 19.1-83.3 43.1-18.3 21.3-34.4 55-30.1 87.1 31.8 2.5 64.1-16.2 83.8-39.7z"
      />
    </svg>
  );
}

/** Official-style "Download on the App Store" badge, or a coming-soon state. */
export function AppStoreBadge({ className }: { className?: string }) {
  const live = site.appStoreUrl.length > 0;
  const inner = (
    <span
      className={`inline-flex items-center gap-3 rounded-xl border border-white/15 bg-black px-5 py-2.5 transition-colors ${
        live ? "hover:border-white/30" : "opacity-90"
      } ${className ?? ""}`}
    >
      <AppleGlyph className="h-7 w-7 text-white" />
      <span className="flex flex-col leading-tight text-left">
        <span className="text-[11px] font-medium text-ink-2">
          {live ? "Download on the" : "Coming soon to the"}
        </span>
        <span className="text-lg font-bold text-white">App Store</span>
      </span>
    </span>
  );
  return live ? (
    <a href={site.appStoreUrl} aria-label="Download on the App Store">
      {inner}
    </a>
  ) : (
    <span aria-label="Coming soon to the App Store">{inner}</span>
  );
}

/** Primary action — the TestFlight beta while the App Store listing is pending. */
export function PrimaryCTA({
  className,
  label = "Join the beta",
}: {
  className?: string;
  label?: string;
}) {
  return (
    <Link
      href={site.testFlightUrl}
      className={`group inline-flex items-center justify-center gap-2 rounded-xl bg-teal px-6 py-3.5 text-base font-extrabold text-[#04261f] shadow-[0_0_40px_-8px_#00e5c388] transition-transform hover:scale-[1.02] active:scale-[0.99] ${className ?? ""}`}
    >
      {label}
      <ArrowRight className="h-5 w-5 transition-transform group-hover:translate-x-0.5" />
    </Link>
  );
}
