import type { Metadata } from "next";
import { SiteHeader } from "@/components/SiteHeader";
import { SiteFooter } from "@/components/SiteFooter";
import { site } from "@/lib/site";

export const metadata: Metadata = {
  title: "Privacy Policy",
  description: `How ${site.name} handles your data. Short version: it never leaves your iPhone.`,
  alternates: { canonical: "/privacy" },
};

export default function Privacy() {
  return (
    <>
      <SiteHeader />
      <main className="mx-auto max-w-3xl px-5 py-16 md:py-24">
        <h1 className="text-4xl font-black tracking-tight md:text-5xl">Privacy Policy</h1>
        <p className="mt-3 text-sm text-ink-3">Last updated {site.lastUpdated}</p>

        <div className="mt-10 space-y-8 text-ink-2 leading-relaxed">
          <div className="rounded-2xl border border-teal/30 bg-teal-dim/40 p-6">
            <p className="font-bold text-ink">
              The short version: Streakline does not collect your data.
            </p>
            <p className="mt-2">
              Everything you log — drinks, workouts, streaks, and progress — is
              stored only on your iPhone. There is no account, no server, and no
              analytics. Nothing you enter is ever uploaded or shared.
            </p>
          </div>

          <Section title="Information we collect">
            None on our side. Streakline has no user accounts and no backend.
            The data you create in the app (such as your weekly drink budget,
            logged drinks, completed workouts, and earned XP) is saved locally on
            your device using Apple&apos;s on-device storage and never transmitted
            to us or anyone else.
          </Section>

          <Section title="Analytics and tracking">
            We do not use analytics, advertising identifiers, third-party
            tracking SDKs, or cookies. We do not build a profile of you and we
            have no way to identify individual users.
          </Section>

          <Section title="Notifications">
            If you enable reminders, Streakline schedules them locally on your
            device through iOS. These notifications are generated on your phone —
            they are not sent from a server, and they involve no data leaving your
            device.
          </Section>

          <Section title="Data sharing and selling">
            We do not share, sell, rent, or trade your information, because we do
            not have it. There is nothing to share.
          </Section>

          <Section title="Your control over your data">
            Your data lives on your device, so you are always in control. You can
            reset your current week from within Settings, and deleting the app
            removes all Streakline data from your iPhone permanently.
          </Section>

          <Section title="Children">
            Because Streakline relates to alcohol tracking, it is intended for
            adults of legal drinking age and is not directed at children.
          </Section>

          <Section title="Changes to this policy">
            If this policy changes, we will update this page and revise the date
            above. Material changes will also be reflected in the app.
          </Section>

          <Section title="Contact">
            Questions about privacy? Email{" "}
            <a className="font-semibold text-teal hover:underline" href={`mailto:${site.privacyEmail}`}>
              {site.privacyEmail}
            </a>
            .
          </Section>
        </div>
      </main>
      <SiteFooter />
    </>
  );
}

function Section({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <section>
      <h2 className="text-xl font-extrabold text-ink">{title}</h2>
      <p className="mt-2">{children}</p>
    </section>
  );
}
