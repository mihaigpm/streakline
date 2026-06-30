#!/usr/bin/env python3
"""Generate web brand assets for the Streakline landing page.

Reuses the real app glyph (transparent launch logo) and the exact SF Pro
Rounded typeface the app ships with, so the site matches the app 1:1.

Outputs (committed, so the droplet only ever serves static files):
  app/icon.png            512x512  -> favicon / PWA icon
  app/apple-icon.png      180x180  -> apple-touch-icon
  app/favicon.ico         multi    -> legacy favicon
  app/opengraph-image.png 1200x630 -> social share card
  app/twitter-image.png   1200x630 -> twitter card (copy of OG)
"""
import os
from PIL import Image, ImageDraw, ImageFont, ImageFilter

HERE = os.path.dirname(os.path.abspath(__file__))
WEB = os.path.dirname(HERE)
APP = os.path.join(WEB, "app")
ASSETS = os.path.join(WEB, "..", "Streakline", "Streakline", "Assets.xcassets")
ICON_SRC = os.path.join(ASSETS, "AppIcon.appiconset", "icon_light.png")
GLYPH_SRC = os.path.join(ASSETS, "LaunchLogo.imageset", "launch_logo@3x.png")
FONT_PATH = "/System/Library/Fonts/SFNSRounded.ttf"

TEAL = (0, 229, 195)
AMBER = (245, 166, 35)
BG = (10, 10, 15)
WHITE = (255, 255, 255)
GRAY = (136, 136, 160)


def rounded_font(size, weight="Heavy"):
    f = ImageFont.truetype(FONT_PATH, size)
    for name in (weight, "Black", "Bold"):
        try:
            f.set_variation_by_name(name)
            break
        except Exception:
            continue
    return f


def radial_glow(size, center, radius, color, max_alpha):
    """Soft radial gradient, built small then upscaled for smoothness."""
    small = 200
    g = Image.new("L", (small, small), 0)
    px = g.load()
    w, h = size
    cx, cy = center[0] / w * small, center[1] / h * small
    rr = radius / max(w, h) * small
    for yy in range(small):
        for xx in range(small):
            d = ((xx - cx) ** 2 + (yy - cy) ** 2) ** 0.5 / rr
            v = max(0.0, 1.0 - d)
            px[xx, yy] = int((v ** 1.8) * max_alpha)
    g = g.resize(size, Image.BICUBIC)
    layer = Image.new("RGBA", size, color + (0,))
    layer.putalpha(g)
    return layer


def build_icons():
    src = Image.open(ICON_SRC).convert("RGBA")
    src.resize((512, 512), Image.LANCZOS).save(os.path.join(APP, "icon.png"))
    # Apple touch icon: opaque, no transparency (iOS adds the mask).
    apple = Image.new("RGBA", (180, 180), BG + (255,))
    apple.alpha_composite(src.resize((180, 180), Image.LANCZOS))
    apple.convert("RGB").save(os.path.join(APP, "apple-icon.png"))
    src.resize((48, 48), Image.LANCZOS).save(
        os.path.join(APP, "favicon.ico"),
        sizes=[(16, 16), (32, 32), (48, 48)],
    )
    print("wrote icon.png, apple-icon.png, favicon.ico")


def build_og():
    W, H = 1200, 630
    img = Image.new("RGBA", (W, H), BG + (255,))
    img.alpha_composite(radial_glow((W, H), (W * 0.72, H * 0.28), W * 0.6, TEAL, 70))
    img.alpha_composite(radial_glow((W, H), (W * 0.18, H * 0.9), W * 0.5, AMBER, 32))

    # Hairline frame for a crisp card edge.
    d = ImageDraw.Draw(img)
    d.rounded_rectangle([16, 16, W - 16, H - 16], radius=28, outline=(42, 42, 56, 255), width=2)

    # Brand glyph, top-left.
    glyph = Image.open(GLYPH_SRC).convert("RGBA")
    gsize = 250
    img.alpha_composite(glyph.resize((gsize, gsize), Image.LANCZOS), (96, 92))

    # Wordmark: "Streak" white + "line" teal.
    wm = rounded_font(132)
    x, y = 360, 150
    d.text((x, y), "Streak", font=wm, fill=WHITE)
    x += int(d.textlength("Streak", font=wm))
    d.text((x, y), "line", font=wm, fill=TEAL)

    # Tagline.
    tag = rounded_font(46, weight="Bold")
    d.text((362, 320), "Drink less. Move more.", font=tag, fill=GRAY)
    d.text((362, 378), "Keep the streak.", font=tag, fill=GRAY)

    # Footer line: accent dash + domain.
    d.rounded_rectangle([98, 520, 158, 532], radius=6, fill=TEAL)
    dom = rounded_font(34, weight="Bold")
    d.text((98, 548), "streakline.fit", font=dom, fill=(180, 180, 200))
    # Availability pill, right side.
    pill = rounded_font(30, weight="Bold")
    label = "for iPhone"
    pw = d.textlength(label, font=pill)
    d.rounded_rectangle([W - 96 - pw - 56, 540, W - 96, 596], radius=28,
                        fill=(28, 28, 38, 255), outline=(42, 42, 56, 255), width=2)
    d.text((W - 96 - pw - 28, 550), label, font=pill, fill=(200, 200, 215))

    out = img.convert("RGB")
    out.save(os.path.join(APP, "opengraph-image.png"))
    out.save(os.path.join(APP, "twitter-image.png"))
    print("wrote opengraph-image.png, twitter-image.png")


if __name__ == "__main__":
    os.makedirs(APP, exist_ok=True)
    build_icons()
    build_og()
    print("done ->", APP)
