import {
  Dumbbell,
  Droplet,
  Flame,
  CheckCircle2,
  BadgeCheck,
  Footprints,
  Trophy,
  Lock,
  TrendingDown,
} from "lucide-react";

function StatCard({
  value,
  label,
  Icon,
  accent,
}: {
  value: string;
  label: string;
  Icon: typeof Dumbbell;
  accent: "teal" | "amber";
}) {
  return (
    <div className="flex flex-1 flex-col items-center gap-1 rounded-md border border-border bg-surface py-2.5">
      <Icon className={`h-4 w-4 ${accent === "teal" ? "text-teal" : "text-amber"}`} />
      <span className="text-lg font-black leading-none text-ink">{value}</span>
      <span className="text-[9px] text-ink-2">{label}</span>
    </div>
  );
}

function XpRow({
  Icon,
  text,
  xp,
}: {
  Icon: typeof Dumbbell;
  text: string;
  xp: string;
}) {
  return (
    <div className="flex items-center gap-2">
      <Icon className="h-3.5 w-3.5 text-teal" />
      <span className="text-[11px] text-ink-2">{text}</span>
      <span className="ml-auto text-[11px] font-bold text-teal">{xp}</span>
    </div>
  );
}

function Badge({
  name,
  Icon,
  unlocked,
}: {
  name: string;
  Icon: typeof Dumbbell;
  unlocked: boolean;
}) {
  return (
    <div
      className={`flex flex-col items-center gap-1.5 rounded-md border bg-surface py-2.5 ${
        unlocked ? "border-teal/40" : "border-border"
      }`}
    >
      <span
        className={`flex h-9 w-9 items-center justify-center rounded-full ${
          unlocked ? "bg-teal-dim" : "bg-surface-high"
        }`}
      >
        {unlocked ? (
          <Icon className="h-4 w-4 text-teal" />
        ) : (
          <Lock className="h-4 w-4 text-ink-3" />
        )}
      </span>
      <span className={`text-[9px] font-bold ${unlocked ? "text-ink" : "text-ink-3"}`}>
        {name}
      </span>
    </div>
  );
}

export function ProgressMock() {
  const r = 50;
  const c = 2 * Math.PI * r;
  const frac = 0.72;
  return (
    <div className="flex h-full flex-col gap-3 px-4 pt-2 text-ink">
      <h3 className="text-[26px] font-black tracking-tight">Progress</h3>

      {/* rank hero */}
      <div className="flex flex-col items-center">
        <div className="relative h-[130px] w-[130px]">
          <svg viewBox="0 0 120 120" className="h-full w-full" aria-hidden="true">
            <g transform="rotate(-90 60 60)">
              <circle cx="60" cy="60" r={r} fill="none" stroke="var(--color-surface-high)" strokeWidth="9" />
              <circle
                cx="60"
                cy="60"
                r={r}
                fill="none"
                stroke="var(--color-teal)"
                strokeWidth="9"
                strokeLinecap="round"
                strokeDasharray={c}
                strokeDashoffset={c * (1 - frac)}
                style={{ filter: "drop-shadow(0 0 4px #00e5c399)" }}
              />
            </g>
          </svg>
          <div className="absolute inset-0 flex flex-col items-center justify-center">
            <span className="text-2xl font-black leading-none">1850</span>
            <span className="text-[9px] font-semibold text-ink-2">XP</span>
          </div>
        </div>
        <div className="mt-1 text-lg font-extrabold text-teal">Disciplined</div>
        <div className="text-[10px] text-ink-2">350 XP to Relentless</div>
      </div>

      {/* stats */}
      <div className="flex gap-2">
        <StatCard value="14" label="Workouts" Icon={Dumbbell} accent="teal" />
        <StatCard value="22" label="Dry days" Icon={Droplet} accent="teal" />
        <StatCard value="3" label="Best streak" Icon={Flame} accent="amber" />
      </div>

      {/* xp legend */}
      <div className="rounded-md border border-border bg-surface p-3">
        <div className="mb-2 text-[12px] font-extrabold">How you earn XP</div>
        <div className="flex flex-col gap-1.5">
          <XpRow Icon={CheckCircle2} text="Tick off an exercise" xp="+10" />
          <XpRow Icon={Dumbbell} text="Complete a workout" xp="+50" />
          <XpRow Icon={Droplet} text="Stay dry for a day" xp="+15" />
          <XpRow Icon={BadgeCheck} text="Finish a perfect week" xp="+150" />
        </div>
      </div>

      {/* badges */}
      <div className="flex items-baseline justify-between">
        <span className="text-[13px] font-extrabold">Badges</span>
        <span className="text-[10px] text-ink-2">4/12</span>
      </div>
      <div className="grid grid-cols-3 gap-2">
        <Badge name="First Steps" Icon={Footprints} unlocked />
        <Badge name="Hat-Trick" Icon={Trophy} unlocked />
        <Badge name="Dry Spell" Icon={Droplet} unlocked />
        <Badge name="Back to Back" Icon={Flame} unlocked={false} />
        <Badge name="Budget Boss" Icon={TrendingDown} unlocked={false} />
        <Badge name="Iron Will" Icon={Dumbbell} unlocked={false} />
      </div>
    </div>
  );
}
