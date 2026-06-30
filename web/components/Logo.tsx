import { site } from "@/lib/site";

/**
 * The Streakline twin-streak mark, rebuilt as vector art from the same
 * bezier geometry as the iOS app icon (teal lead line, amber trail, spark).
 */
export function LogoMark({
  className,
  title,
}: {
  className?: string;
  title?: string;
}) {
  return (
    <svg
      viewBox="0 0 1024 1024"
      className={className}
      role={title ? "img" : "presentation"}
      aria-label={title}
      aria-hidden={title ? undefined : true}
    >
      {/* amber trail */}
      <path
        d="M244.7 807.2 C424.7 828.8 509.66 596.96 663.16 468.8"
        fill="none"
        stroke="#f5a623"
        strokeWidth={52}
        strokeLinecap="round"
      />
      {/* teal lead */}
      <path
        d="M235.7 726.2 C460.7 753.2 537.2 384.2 784.7 316.7"
        fill="none"
        stroke="#00e5c3"
        strokeWidth={84}
        strokeLinecap="round"
      />
      {/* lead spark */}
      <circle cx="784.7" cy="316.7" r="40" fill="#ebfffa" />
    </svg>
  );
}

/** Mark + wordmark, used in the header, footer and hero. */
export function Logo({
  className,
  markClassName = "h-7 w-7",
  withGlow = false,
}: {
  className?: string;
  markClassName?: string;
  withGlow?: boolean;
}) {
  return (
    <span className={`inline-flex items-center gap-2 ${className ?? ""}`}>
      <LogoMark
        title={`${site.name} logo`}
        className={`${markClassName} ${
          withGlow ? "[filter:drop-shadow(0_0_10px_#00e5c355)]" : ""
        }`}
      />
      <span className="text-xl font-extrabold tracking-tight">
        Streak<span className="text-teal">line</span>
      </span>
    </span>
  );
}
