/**
 * Dual-arc progress ring matching the app's ProgressRingView:
 * teal outer arc = workout progress, amber (or red) inner arc = drink budget.
 */
export function Ring({
  workoutFrac,
  drinkFrac,
  overBudget = false,
  className,
}: {
  workoutFrac: number;
  drinkFrac: number;
  overBudget?: boolean;
  className?: string;
}) {
  const outerR = 52;
  const innerR = 36;
  const outerC = 2 * Math.PI * outerR;
  const innerC = 2 * Math.PI * innerR;
  const track = "var(--color-surface-high)";

  return (
    <svg viewBox="0 0 120 120" className={className} aria-hidden="true">
      <g transform="rotate(-90 60 60)">
        <circle cx="60" cy="60" r={outerR} fill="none" stroke={track} strokeWidth="10" />
        <circle
          cx="60"
          cy="60"
          r={outerR}
          fill="none"
          stroke="var(--color-teal)"
          strokeWidth="10"
          strokeLinecap="round"
          strokeDasharray={outerC}
          strokeDashoffset={outerC * (1 - Math.min(1, workoutFrac))}
          style={{ filter: "drop-shadow(0 0 4px #00e5c399)" }}
        />
        <circle cx="60" cy="60" r={innerR} fill="none" stroke={track} strokeWidth="7" />
        <circle
          cx="60"
          cy="60"
          r={innerR}
          fill="none"
          stroke={overBudget ? "var(--color-red)" : "var(--color-amber)"}
          strokeWidth="7"
          strokeLinecap="round"
          strokeDasharray={innerC}
          strokeDashoffset={innerC * (1 - Math.min(1, drinkFrac))}
        />
      </g>
    </svg>
  );
}
