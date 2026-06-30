import type { Metadata } from "next";
import Link from "next/link";
import { Mail, MessageSquare, Bell, RotateCcw } from "lucide-react";
import { SiteHeader } from "@/components/SiteHeader";
import { SiteFooter } from "@/components/SiteFooter";
import { site } from "@/lib/site";

export const metadata: Metadata = {
  title: "Support",
  description: `Get help with ${site.name} — contact, common questions, and beta feedback.`,
  alternates: { canonical: "/support" },
};

const tips = [
  {
    icon: Bell,
    title: "Reminders not showing up?",
    body: "Make sure notifications are enabled for Streakline in iOS Settings → Notifications, then re-open the app so it can reschedule your daily reminder.",
  },
  {
    icon: RotateCcw,
    title: "Need to start a week over?",
    body: "Open Settings inside the app and choose to reset the current week. Your past weeks and progress stay intact.",
  },
  {
    icon: MessageSquare,
    title: "Found a bug in the beta?",
    body: "Use the Share Beta Feedback option in TestFlight, or email us. Screenshots and the steps to reproduce help a lot.",
  },
];

export default function Support() {
  return (
    <>
      <SiteHeader />
      <main className="mx-auto max-w-3xl px-5 py-16 md:py-24">
        <h1 className="text-4xl font-black tracking-tight md:text-5xl">Support</h1>
        <p className="mt-4 text-lg text-ink-2">
          Happy to help. Most questions are answered below — and you can always
          reach a real person by email.
        </p>

        <a
          href={`mailto:${site.supportEmail}`}
          className="mt-8 flex items-center gap-4 rounded-2xl border border-teal/30 bg-teal-dim/40 p-6 transition-colors hover:border-teal/60"
        >
          <span className="flex h-12 w-12 items-center justify-center rounded-xl bg-teal text-[#04261f]">
            <Mail className="h-6 w-6" />
          </span>
          <span>
            <span className="block font-extrabold text-ink">Email support</span>
            <span className="block text-teal">{site.supportEmail}</span>
          </span>
        </a>
        <p className="mt-3 text-sm text-ink-3">
          We aim to reply within a couple of days.
        </p>

        <h2 className="mt-14 text-2xl font-black">Common topics</h2>
        <div className="mt-6 space-y-4">
          {tips.map((t) => (
            <div key={t.title} className="rounded-2xl border border-border bg-surface p-5">
              <div className="flex items-center gap-3">
                <span className="flex h-9 w-9 items-center justify-center rounded-lg bg-teal-dim text-teal">
                  <t.icon className="h-5 w-5" />
                </span>
                <h3 className="font-extrabold text-ink">{t.title}</h3>
              </div>
              <p className="mt-2 text-ink-2">{t.body}</p>
            </div>
          ))}
        </div>

        <p className="mt-12 text-ink-2">
          Looking for something else? Read the{" "}
          <Link href="/#faq" className="font-semibold text-teal hover:underline">
            FAQ
          </Link>{" "}
          or our{" "}
          <Link href="/privacy" className="font-semibold text-teal hover:underline">
            Privacy Policy
          </Link>
          .
        </p>
      </main>
      <SiteFooter />
    </>
  );
}
