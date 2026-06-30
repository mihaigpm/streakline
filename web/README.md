# Streakline — Landing page

Marketing site for the Streakline iPhone app, at **[streakline.fit](https://streakline.fit)**.

Built with **Next.js 16 (App Router)** and **Tailwind CSS v4**, exported as a
fully **static site** (`output: "export"`) so it can be served by any web
server — no Node.js runtime needed at deploy time. Perfect for a bare $5
DigitalOcean droplet running nginx.

The design mirrors the app's `DesignSystem.swift` (same dark palette, teal +
amber brand colours, rounded display type) so the site and product read as one.

## Stack

- Next.js 16 App Router, static export (`out/`)
- Tailwind CSS v4 (CSS-first theme in `app/globals.css`)
- `lucide-react` for icons
- `next/font` (Nunito — the closest free web face to the app's SF Pro Rounded)
- Zero client JS beyond a tiny scroll-reveal enhancer and the mobile menu

## Project layout

```
app/
  layout.tsx          Root layout, fonts, metadata, scroll-reveal script
  page.tsx            The landing page (hero, features, FAQ, CTA…)
  privacy/page.tsx    Privacy policy   (App Store required URL)
  support/page.tsx    Support          (App Store required URL)
  sitemap.ts          /sitemap.xml
  robots.ts           /robots.txt
  icon.png            favicon / PWA icon   (generated)
  apple-icon.png      apple-touch-icon     (generated)
  opengraph-image.png social card 1200x630 (generated)
components/           Logo, header, footer, CTAs, phone mockups
lib/site.ts           Single source of truth for URLs, contact, copy
scripts/              Brand-asset generator (Python + Pillow)
deploy/               nginx config + deploy script for the droplet
```

## Configure before launch

Edit `lib/site.ts`:

- `appStoreUrl` — leave empty until the public App Store listing exists (the UI
  falls back to a "Coming soon" badge + the TestFlight CTA). Fill it in to flip
  the badge to a live "Download on the App Store" link.
- `testFlightUrl` — your public TestFlight beta link.
- `email` / `supportEmail` / `privacyEmail` — real inboxes on the domain.

## Develop

```bash
npm install
npm run dev          # http://localhost:3000
```

## Build (static export)

```bash
npm run build        # outputs static site to ./out
```

## Regenerate brand assets

The favicon, app icons and OG image are generated from the real app glyph and
the app's SF Pro Rounded typeface:

```bash
python3 scripts/generate_web_assets.py
```

(Requires Pillow: `pip3 install pillow`. Run on macOS — it reads the system
`SFNSRounded.ttf`.)

## Deploy — Option A: DigitalOcean App Platform (free, recommended)

App Platform's **free tier hosts up to 3 static sites** with automatic HTTPS, a
global CDN, custom domains, and auto-deploy on every push. DigitalOcean builds
the site on their infrastructure, so there's no droplet to manage and no build
memory limit to worry about.

A ready-made spec lives at [`../.do/app.yaml`](../.do/app.yaml) (source dir
`web`, build `npm run build`, output `out`). Deploy it:

```bash
doctl apps create --spec .do/app.yaml          # from the repo root
# later updates:
doctl apps update <APP_ID> --spec .do/app.yaml
```

Or in the dashboard: **Create → Apps**, pick the GitHub repo, and it detects the
spec. Add the `streakline.fit` DNS records it shows you (or delegate the domain
to DO's nameservers) and TLS is issued automatically.

## Deploy — Option B: DigitalOcean droplet (nginx)

Because a 512 MB droplet can run out of memory during a Next.js build, the
recommended flow is **build locally (or in CI), then copy the static `out/`
folder to the droplet**. The droplet only ever serves files — it never needs
Node.js.

### One-time droplet setup

```bash
# on the droplet
apt update && apt install -y nginx
mkdir -p /var/www/streakline
# copy deploy/nginx.conf to /etc/nginx/sites-available/streakline, then:
ln -s /etc/nginx/sites-available/streakline /etc/nginx/sites-enabled/streakline
rm -f /etc/nginx/sites-enabled/default
nginx -t && systemctl reload nginx

# HTTPS (free, auto-renewing)
apt install -y certbot python3-certbot-nginx
certbot --nginx -d streakline.fit -d www.streakline.fit
```

Point the `streakline.fit` DNS A record at the droplet's IP first.

### Every deploy

```bash
# from this web/ directory, on your machine
DROPLET=root@streakline.fit ./deploy/deploy.sh
```

This builds and `rsync`s `out/` to the droplet. See `deploy/deploy.sh`.

### Alternative: build on the droplet

If you'd rather build on the droplet, give it swap first so the build doesn't
get OOM-killed:

```bash
fallocate -l 2G /swapfile && chmod 600 /swapfile && mkswap /swapfile && swapon /swapfile
```

Then `git pull`, `npm ci`, `npm run build`, and serve `out/` with the same nginx config.
