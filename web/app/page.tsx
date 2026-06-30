import {
  Beer,
  Dumbbell,
  Droplet,
  Trophy,
  Flame,
  ShieldCheck,
  TrendingDown,
  ChevronDown,
  Check,
  Bell,
} from "lucide-react";
import { site } from "@/lib/site";
import { SiteHeader } from "@/components/SiteHeader";
import { SiteFooter } from "@/components/SiteFooter";
import { LogoMark } from "@/components/Logo";
import { PrimaryCTA, AppStoreBadge } from "@/components/cta";
import { PhoneFrame } from "@/components/phone/PhoneFrame";
import { HomeMock } from "@/components/phone/HomeMock";
import { ProgressMock } from "@/components/phone/ProgressMock";

const features = [
  {
    icon: TrendingDown,
    title: "A shrinking drink budget",
    body: "Set a weekly budget in pints, units, or standard drinks. It shrinks a little each week, so cutting back feels gradual — not like going cold turkey.",
  },
  {
    icon: Dumbbell,
    title: "Guided workouts, 3 days a week",
    body: "A simple A / B / C split with step-by-step form cues, common-mistake tips, and a focus mode for every exercise. No gym required.",
  },
  {
    icon: Droplet,
    title: "Dry-day tracking",
    body: "Log a drink with a tap, or leave the day clean. Your week fills up with dots — a teal one for every alcohol-free day.",
  },
  {
    icon: Trophy,
    title: "Ranks, XP & badges",
    body: "Earn XP for every workout and dry day, climb nine ranks from Rookie to Legend, and unlock twelve badges along the way.",
  },
  {
    icon: Bell,
    title: "Streaks that stick",
    body: "A weekly streak counter and a daily reminder keep you honest — with your XP-to-next-rank baked right into the nudge.",
  },
  {
    icon: ShieldCheck,
    title: "Private by design",
    body: "Everything lives on your iPhone. No account, no sign-up, no analytics — nothing ever leaves your device.",
  },
];

const steps = [
  {
    n: "01",
    title: "Set your budget",
    body: "Tell Streakline how much you drink in a typical week and pick your unit. That is your starting line.",
  },
  {
    n: "02",
    title: "Train and log",
    body: "Do the workout, tick off each exercise, log your drinks, and mark the days you stay dry.",
  },
  {
    n: "03",
    title: "Keep the streak",
    body: "Earn XP, climb the ranks, and watch your weekly budget shrink — week after week.",
  },
];

const ranks = [
  "Rookie",
  "Starter",
  "Consistent",
  "Committed",
  "Disciplined",
  "Relentless",
  "Machine",
  "Unbreakable",
  "Legend",
];

const xpRules = [
  { label: "Tick off an exercise", xp: "+10" },
  { label: "Complete a workout", xp: "+50" },
  { label: "Stay dry for a day", xp: "+15" },
  { label: "Finish a perfect week", xp: "+150" },
];

const faqs = [
  {
    q: "Is Streakline free?",
    a: "Yes. Streakline is free while it is in beta on TestFlight. If a paid tier ever arrives, anything you have already tracked stays yours.",
  },
  {
    q: "Do I need a gym or equipment?",
    a: "No. The workouts are built around running and bodyweight movements, with optional dumbbells. You can do them at home.",
  },
  {
    q: "Can I track pints, units, or standard drinks?",
    a: "All three. Streakline works in UK pints, UK units, or US-style standard drinks, and you can switch any time in Settings.",
  },
  {
    q: "Is my data private?",
    a: "Completely. Everything is stored locally on your iPhone, with no account and no analytics. Nothing is uploaded to a server.",
  },
  {
    q: "Is there an Android version?",
    a: "Not yet. Streakline is iPhone-first. Join the beta and we will keep you posted if that changes.",
  },
  {
    q: "Is this medical advice?",
    a: "No. Streakline is a habit and fitness tracker, not medical or clinical advice. If alcohol is seriously affecting your health or your life, please talk to a doctor or a support service.",
  },
];

const budget = [12, 11, 10, 9, 8, 7, 6, 5];

const jsonLd = {
  "@context": "https://schema.org",
  "@type": "SoftwareApplication",
  name: site.name,
  applicationCategory: "HealthApplication",
  operatingSystem: "iOS",
  description: site.shortDescription,
  url: site.url,
  offers: { "@type": "Offer", price: "0", priceCurrency: "USD" },
};

export default function Home() {
  return (
    <>
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
      />
      <SiteHeader />

      <main>
        {/* ---------------------------------------------------------- Hero */}
        <section className="ambient grid-texture relative overflow-hidden">
          <div className="mx-auto grid max-w-6xl items-center gap-12 px-5 py-16 md:grid-cols-2 md:py-24">
            <div data-reveal>
              <span className="inline-flex items-center gap-2 rounded-full border border-white/10 bg-surface/60 px-3 py-1 text-xs font-bold text-ink-2">
                <span className="h-1.5 w-1.5 rounded-full bg-teal" />
                iPhone · Private · In beta
              </span>
              <h1 className="mt-5 text-balance text-5xl font-black leading-[1.02] tracking-tight md:text-6xl">
                Drink less. Move more.{" "}
                <span className="text-teal">Keep the streak.</span>
              </h1>
              <p className="mt-5 max-w-md text-lg leading-relaxed text-ink-2">
                Streakline turns cutting back and getting fit into one simple
                daily habit — a shrinking weekly drink budget, guided workouts,
                and a streak you will not want to break.
              </p>
              <div className="mt-8 flex flex-wrap items-center gap-4">
                <PrimaryCTA label="Join the beta" />
                <AppStoreBadge />
              </div>
              <p className="mt-4 text-sm text-ink-3">
                Free · No account · Your data never leaves your phone
              </p>
            </div>

            <div className="flex justify-center" data-reveal data-reveal-delay="120">
              <div className="w-[260px] sm:w-[290px]">
                <PhoneFrame>
                  <HomeMock />
                </PhoneFrame>
              </div>
            </div>
          </div>
        </section>

        {/* --------------------------------------------------- Features */}
        <section id="features" className="border-t border-white/5 py-20 md:py-28">
          <div className="mx-auto max-w-6xl px-5">
            <div className="max-w-2xl" data-reveal>
              <h2 className="text-4xl font-black tracking-tight md:text-5xl">
                Two hard things, one habit
              </h2>
              <p className="mt-4 text-lg text-ink-2">
                Most apps track your drinking or your training. Streakline does
                both, because the discipline is the same muscle.
              </p>
            </div>

            <div className="mt-12 grid gap-5 sm:grid-cols-2 lg:grid-cols-3">
              {features.map((f, i) => (
                <div
                  key={f.title}
                  data-reveal
                  data-reveal-delay={(i % 3) * 80}
                  className="group rounded-2xl border border-border bg-surface p-6 transition-colors hover:border-teal/40"
                >
                  <span className="inline-flex h-11 w-11 items-center justify-center rounded-xl bg-teal-dim text-teal">
                    <f.icon className="h-5 w-5" />
                  </span>
                  <h3 className="mt-4 text-lg font-extrabold">{f.title}</h3>
                  <p className="mt-2 text-sm leading-relaxed text-ink-2">{f.body}</p>
                </div>
              ))}
            </div>
          </div>
        </section>

        {/* ------------------------------------------ Shrinking budget */}
        <section className="border-t border-white/5 py-20 md:py-28">
          <div className="mx-auto grid max-w-6xl items-center gap-12 px-5 md:grid-cols-2">
            <div data-reveal>
              <span className="inline-flex items-center gap-2 rounded-full bg-amber-dim px-3 py-1 text-xs font-bold text-amber">
                <Beer className="h-3.5 w-3.5" /> The budget
              </span>
              <h2 className="mt-4 text-4xl font-black tracking-tight md:text-5xl">
                Progress that feels{" "}
                <span className="text-amber">inevitable</span>
              </h2>
              <p className="mt-4 text-lg leading-relaxed text-ink-2">
                Quitting overnight rarely sticks. Streakline starts from where
                you actually are and trims your weekly budget a little at a time.
                Each week is a number you can beat — not a wall you crash into.
              </p>
              <ul className="mt-6 space-y-3">
                {[
                  "Start at your real weekly amount",
                  "The budget steps down automatically",
                  "Stay under to earn a perfect week",
                ].map((t) => (
                  <li key={t} className="flex items-center gap-3 text-ink">
                    <span className="flex h-5 w-5 items-center justify-center rounded-full bg-teal-dim text-teal">
                      <Check className="h-3 w-3" strokeWidth={3} />
                    </span>
                    <span className="text-sm font-semibold">{t}</span>
                  </li>
                ))}
              </ul>
            </div>

            <div
              className="rounded-2xl border border-border bg-surface p-6"
              data-reveal
              data-reveal-delay="100"
            >
              <div className="flex items-baseline justify-between">
                <span className="text-sm font-bold text-ink-2">Weekly budget</span>
                <span className="text-sm font-extrabold text-amber">
                  12 → 5 pints
                </span>
              </div>
              <div className="mt-6 flex items-end gap-2">
                {budget.map((v, i) => {
                  const max = budget[0];
                  const h = Math.round((v / max) * 160);
                  const last = i === budget.length - 1;
                  return (
                    <div key={i} className="flex flex-1 flex-col items-center gap-2">
                      <span className="text-[10px] font-bold text-ink-2">{v}</span>
                      <div
                        className={`w-full rounded-t-md ${
                          last ? "bg-teal" : "bg-amber/70"
                        }`}
                        style={{ height: `${h}px` }}
                      />
                      <span className="text-[10px] font-semibold text-ink-3">
                        W{i + 1}
                      </span>
                    </div>
                  );
                })}
              </div>
            </div>
          </div>
        </section>

        {/* ----------------------------------------- Guided workouts */}
        <section className="border-t border-white/5 py-20 md:py-28">
          <div className="mx-auto grid max-w-6xl items-center gap-12 px-5 md:grid-cols-2">
            <div
              className="order-2 rounded-2xl border border-border bg-surface p-6 md:order-1"
              data-reveal
            >
              <div className="flex items-center justify-between">
                <span className="text-xs font-bold uppercase tracking-wider text-ink-3">
                  Focus mode
                </span>
                <span className="rounded-full bg-surface-high px-2.5 py-1 text-[11px] font-bold text-ink-2">
                  2 / 6
                </span>
              </div>
              <h3 className="mt-3 text-2xl font-black">Goblet squat</h3>
              <p className="mt-1 text-sm text-ink-2">3 sets · 10 reps</p>
              <ol className="mt-5 space-y-2.5">
                {[
                  "Hold a weight at your chest, feet shoulder-width.",
                  "Sit back and down, knees tracking over toes.",
                  "Drive through your heels back to standing.",
                ].map((s, i) => (
                  <li key={i} className="flex gap-3 text-sm text-ink">
                    <span className="flex h-5 w-5 shrink-0 items-center justify-center rounded-full bg-teal text-[11px] font-black text-[#04261f]">
                      {i + 1}
                    </span>
                    {s}
                  </li>
                ))}
              </ol>
              <div className="mt-5 flex flex-wrap gap-2">
                {["Chest up", "Knees out", "Brace your core", "Full depth"].map((c) => (
                  <span
                    key={c}
                    className="rounded-full bg-teal-dim px-3 py-1 text-xs font-bold text-teal"
                  >
                    {c}
                  </span>
                ))}
              </div>
            </div>

            <div className="order-1 md:order-2" data-reveal data-reveal-delay="100">
              <span className="inline-flex items-center gap-2 rounded-full bg-teal-dim px-3 py-1 text-xs font-bold text-teal">
                <Dumbbell className="h-3.5 w-3.5" /> The training
              </span>
              <h2 className="mt-4 text-4xl font-black tracking-tight md:text-5xl">
                Never wonder{" "}
                <span className="text-teal">what to do</span>
              </h2>
              <p className="mt-4 text-lg leading-relaxed text-ink-2">
                Three workouts a week, each one laid out for you. Swipe through
                every exercise in focus mode with clear steps, form cues, and the
                mistakes to avoid — then tick it off and bank the XP.
              </p>
              <div className="mt-6 grid grid-cols-3 gap-3">
                {[
                  { d: "Day A", s: "Run + glutes" },
                  { d: "Day B", s: "Full-body weights" },
                  { d: "Day C", s: "Run or circuit" },
                ].map((w) => (
                  <div
                    key={w.d}
                    className="rounded-xl border border-border bg-surface p-3"
                  >
                    <div className="text-sm font-extrabold">{w.d}</div>
                    <div className="text-[11px] text-ink-2">{w.s}</div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </section>

        {/* --------------------------------------------- How it works */}
        <section id="how" className="border-t border-white/5 py-20 md:py-28">
          <div className="mx-auto max-w-6xl px-5">
            <div className="max-w-2xl" data-reveal>
              <h2 className="text-4xl font-black tracking-tight md:text-5xl">
                How it works
              </h2>
              <p className="mt-4 text-lg text-ink-2">
                Three steps. About a minute a day.
              </p>
            </div>
            <div className="mt-12 grid gap-6 md:grid-cols-3">
              {steps.map((s, i) => (
                <div key={s.n} data-reveal data-reveal-delay={i * 90} className="relative">
                  <div className="text-5xl font-black text-surface-high">{s.n}</div>
                  <h3 className="mt-2 text-xl font-extrabold">{s.title}</h3>
                  <p className="mt-2 text-ink-2">{s.body}</p>
                </div>
              ))}
            </div>
          </div>
        </section>

        {/* ------------------------------------------ Ranks & badges */}
        <section
          id="progress"
          className="ambient border-t border-white/5 py-20 md:py-28"
        >
          <div className="mx-auto grid max-w-6xl items-center gap-12 px-5 md:grid-cols-2">
            <div className="flex justify-center" data-reveal>
              <div className="w-[260px] sm:w-[290px]">
                <PhoneFrame glow={false}>
                  <ProgressMock />
                </PhoneFrame>
              </div>
            </div>

            <div data-reveal data-reveal-delay="100">
              <span className="inline-flex items-center gap-2 rounded-full bg-teal-dim px-3 py-1 text-xs font-bold text-teal">
                <Trophy className="h-3.5 w-3.5" /> The reward
              </span>
              <h2 className="mt-4 text-4xl font-black tracking-tight md:text-5xl">
                Discipline, made{" "}
                <span className="text-teal">addictive</span>
              </h2>
              <p className="mt-4 text-lg leading-relaxed text-ink-2">
                Every workout and every dry day earns XP. Climb nine ranks, build
                your best streak, and unlock badges for the milestones that matter.
              </p>

              <div className="mt-6 flex flex-wrap gap-2">
                {ranks.map((r, i) => (
                  <span
                    key={r}
                    className={`rounded-full px-3 py-1 text-xs font-bold ${
                      i === 4
                        ? "bg-teal text-[#04261f]"
                        : "bg-surface text-ink-2 ring-1 ring-border"
                    }`}
                  >
                    {r}
                  </span>
                ))}
              </div>

              <div className="mt-8 rounded-2xl border border-border bg-surface p-5">
                <div className="flex items-center gap-2 text-sm font-extrabold">
                  <Flame className="h-4 w-4 text-amber" /> How you earn XP
                </div>
                <div className="mt-4 grid grid-cols-2 gap-x-6 gap-y-3">
                  {xpRules.map((r) => (
                    <div key={r.label} className="flex items-center justify-between gap-3">
                      <span className="text-sm text-ink-2">{r.label}</span>
                      <span className="text-sm font-bold text-teal">{r.xp}</span>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* ---------------------------------------------------- FAQ */}
        <section id="faq" className="border-t border-white/5 py-20 md:py-28">
          <div className="mx-auto max-w-3xl px-5">
            <h2 className="text-4xl font-black tracking-tight md:text-5xl" data-reveal>
              Questions
            </h2>
            <div className="mt-10 space-y-3">
              {faqs.map((f) => (
                <details
                  key={f.q}
                  className="group rounded-xl border border-border bg-surface px-5 [&_summary::-webkit-details-marker]:hidden"
                  data-reveal
                >
                  <summary className="flex cursor-pointer list-none items-center justify-between py-4 text-base font-bold">
                    {f.q}
                    <ChevronDown className="h-5 w-5 text-ink-2 transition-transform group-open:rotate-180" />
                  </summary>
                  <p className="pb-5 text-ink-2">{f.a}</p>
                </details>
              ))}
            </div>
          </div>
        </section>

        {/* ------------------------------------------------ CTA band */}
        <section className="ambient border-t border-white/5 py-24">
          <div className="mx-auto max-w-3xl px-5 text-center" data-reveal>
            <LogoMark className="mx-auto h-14 w-14 [filter:drop-shadow(0_0_18px_#00e5c355)]" title="" />
            <h2 className="mt-6 text-4xl font-black tracking-tight md:text-5xl">
              Start your streak today
            </h2>
            <p className="mx-auto mt-4 max-w-md text-lg text-ink-2">
              {site.tagline} Join the beta and build the habit that builds you.
            </p>
            <div className="mt-8 flex flex-wrap items-center justify-center gap-4">
              <PrimaryCTA label="Join the beta" />
              <AppStoreBadge />
            </div>
          </div>
        </section>
      </main>

      <SiteFooter />
    </>
  );
}
