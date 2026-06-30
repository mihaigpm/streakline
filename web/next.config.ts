import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // Static HTML/CSS/JS export — no Node server needed at runtime.
  // The $5 droplet only serves the contents of `out/` via nginx.
  output: "export",

  // Emit `/privacy/index.html` etc. so static hosting needs no rewrites.
  trailingSlash: true,

  // Static export can't use the optimizing image server; we ship plain assets.
  images: { unoptimized: true },
};

export default nextConfig;
