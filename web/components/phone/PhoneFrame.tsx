import { Signal, Wifi, BatteryFull } from "lucide-react";

/** A lightweight iPhone shell: titanium bezel, dynamic island, status bar. */
export function PhoneFrame({
  children,
  className,
  glow = true,
}: {
  children: React.ReactNode;
  className?: string;
  glow?: boolean;
}) {
  return (
    <div
      className={`relative aspect-[9/19.5] w-full rounded-[2.6rem] border border-white/10 bg-[#1a1a22] p-[3px] shadow-2xl ${
        glow ? "shadow-[0_30px_120px_-30px_#00e5c355]" : ""
      } ${className ?? ""}`}
    >
      <div className="relative h-full w-full overflow-hidden rounded-[2.35rem] bg-bg">
        {/* dynamic island */}
        <div className="absolute left-1/2 top-2 z-20 h-[18px] w-[78px] -translate-x-1/2 rounded-full bg-black" />
        {/* status bar */}
        <div className="flex items-center justify-between px-5 pt-2.5 text-[10px] font-bold text-ink">
          <span>9:41</span>
          <span className="flex items-center gap-1">
            <Signal className="h-3 w-3" />
            <Wifi className="h-3 w-3" />
            <BatteryFull className="h-3.5 w-3.5" />
          </span>
        </div>
        <div className="h-[calc(100%-1.75rem)] overflow-hidden">{children}</div>
      </div>
    </div>
  );
}
