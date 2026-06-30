import {
  Calendar,
  Settings,
  Zap,
  Flame,
  ChevronRight,
  Footprints,
  Dumbbell,
  Activity,
  Beer,
  Check,
  Minus,
  Plus,
} from "lucide-react";
import { Ring } from "./Ring";

function WorkoutCard({
  label,
  sub,
  Icon,
  accent,
  done = false,
}: {
  label: string;
  sub: string;
  Icon: typeof Footprints;
  accent: "teal" | "amber";
  done?: boolean;
}) {
  return (
    <div
      className={`flex h-[104px] w-[104px] shrink-0 flex-col justify-between rounded-lg border p-3 ${
        done ? "border-teal/70 bg-surface opacity-70" : "border-border bg-surface"
      }`}
    >
      <div className="flex items-start justify-between">
        <Icon className={`h-5 w-5 ${accent === "teal" ? "text-teal" : "text-amber"}`} />
        {done && <Check className="h-4 w-4 text-teal" strokeWidth={3} />}
      </div>
      <div>
        <div className="text-sm font-extrabold text-ink">{label}</div>
        <div className="text-[10px] leading-tight text-ink-2">{sub}</div>
      </div>
    </div>
  );
}

export function HomeMock() {
  // Sample state: week 3, 2 of 3 workouts, 4 of 8 pints, 3 dry days.
  const dots: ("dry" | "drank" | "today" | "future")[] = [
    "dry",
    "dry",
    "drank",
    "dry",
    "today",
    "future",
    "future",
  ];
  const dotClass: Record<string, string> = {
    dry: "bg-teal",
    drank: "bg-amber",
    today: "border-2 border-teal",
    future: "bg-surface-high",
  };

  return (
    <div className="flex h-full flex-col px-4 pb-3 pt-2 text-ink">
      {/* toolbar */}
      <div className="flex items-center justify-between text-ink-2">
        <Calendar className="h-[18px] w-[18px]" />
        <Settings className="h-[18px] w-[18px]" />
      </div>

      {/* week header */}
      <div className="mt-2 flex items-start justify-between">
        <h3 className="text-[26px] font-black leading-none tracking-tight">Week 3</h3>
        <span className="rounded-full bg-amber-dim px-2.5 py-1 text-[10px] font-bold text-amber">
          4 pints left
        </span>
      </div>

      {/* pills */}
      <div className="mt-2.5 flex items-center gap-2">
        <span className="inline-flex items-center gap-1 rounded-full bg-teal-dim px-2.5 py-1 text-[11px] font-bold">
          <Zap className="h-3 w-3 text-teal" />
          Disciplined
          <ChevronRight className="h-2.5 w-2.5 text-ink-3" />
        </span>
        <span className="inline-flex items-center gap-1 rounded-full bg-surface-high px-2.5 py-1 text-[11px] font-bold">
          <Flame className="h-3 w-3 text-amber" />3 week streak
        </span>
      </div>

      {/* ring */}
      <div className="relative mx-auto my-3 h-[156px] w-[156px]">
        <Ring workoutFrac={2 / 3} drinkFrac={0.5} className="h-full w-full" />
        <div className="absolute inset-0 flex flex-col items-center justify-center">
          <span className="text-4xl font-black leading-none">2</span>
          <span className="mt-1 text-[10px] font-semibold text-ink-2">of 3 workouts</span>
        </div>
      </div>

      {/* workouts */}
      <div className="text-[11px] font-bold text-ink-2">This week&apos;s workouts</div>
      <div className="mt-2 flex gap-2.5 overflow-hidden">
        <WorkoutCard label="Day A" sub="Run + glute circuit" Icon={Footprints} accent="teal" />
        <WorkoutCard label="Day B" sub="Full-body weights" Icon={Dumbbell} accent="amber" done />
        <WorkoutCard label="Day C" sub="Long run or circuit" Icon={Activity} accent="teal" />
      </div>

      {/* drink strip */}
      <div className="mt-auto rounded-xl border border-border bg-surface p-3">
        <div className="flex items-center gap-3">
          <Beer className="h-5 w-5 text-ink-2" />
          <div className="flex-1">
            <div className="text-[13px] font-bold">4 pints this week</div>
            <div className="text-[10px] text-ink-2">8 pints budget</div>
          </div>
          <button className="flex h-8 w-8 items-center justify-center rounded-full bg-surface-high">
            <Minus className="h-4 w-4" strokeWidth={3} />
          </button>
          <button className="flex h-8 w-8 items-center justify-center rounded-full bg-surface-high">
            <Plus className="h-4 w-4" strokeWidth={3} />
          </button>
        </div>
        <div className="mt-2.5 flex items-center gap-1.5">
          {dots.map((d, i) => (
            <span key={i} className={`h-2 w-2 rounded-full ${dotClass[d]}`} />
          ))}
          <span className="ml-auto text-[10px] font-bold text-teal">3 dry days</span>
        </div>
      </div>
    </div>
  );
}
