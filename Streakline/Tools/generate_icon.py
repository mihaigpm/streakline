#!/usr/bin/env python3
"""Generate the Streakline app icon (light / dark / tinted) at 1024px."""
import math
from PIL import Image, ImageDraw, ImageFilter

SS = 4                      # supersample factor
S = 1024 * SS               # working canvas size
OUT = 1024

TEAL = (0, 229, 195)
AMBER = (245, 166, 35)
BG = (10, 10, 15)


def lerp(a, b, t):
    return a + (b - a) * t


def cubic_bezier(p0, p1, p2, p3, n=900):
    pts = []
    for i in range(n + 1):
        t = i / n
        mt = 1 - t
        x = mt**3 * p0[0] + 3 * mt**2 * t * p1[0] + 3 * mt * t**2 * p2[0] + t**3 * p3[0]
        y = mt**3 * p0[1] + 3 * mt**2 * t * p1[1] + 3 * mt * t**2 * p2[1] + t**3 * p3[1]
        pts.append((x, y, t))
    return pts


def stroke(draw, pts, w0, w1, color):
    """Stamp circles along a path with a tapering width and round caps."""
    for (x, y, t) in pts:
        r = lerp(w0, w1, t) / 2
        draw.ellipse([x - r, y - r, x + r, y + r], fill=color)


def radial_glow(size, center, radius, color, max_alpha):
    """Soft radial gradient built at low-res then upscaled for speed + smoothness."""
    small = 256
    g = Image.new("L", (small, small), 0)
    px = g.load()
    cx, cy = center[0] / size * small, center[1] / size * small
    rr = radius / size * small
    for yy in range(small):
        for xx in range(small):
            d = math.hypot(xx - cx, yy - cy) / rr
            v = max(0.0, 1.0 - d)
            px[xx, yy] = int((v ** 1.8) * max_alpha)
    g = g.resize((size, size), Image.BICUBIC)
    layer = Image.new("RGBA", (size, size), color + (0,))
    layer.putalpha(g)
    return layer


# Streak geometry (in working-canvas space)
def scale_center(pts, k=0.9, c=S / 2):
    return [((x - c) * k + c, (y - c) * k + c, t) for (x, y, t) in pts]


_teal = cubic_bezier((820, 3000), (1820, 3120), (2160, 1480), (3260, 1180))
# Amber trails the teal line: same shape, nudged down, ending before the lead tip.
_amber_full = [(x + 40, y + 360, t) for (x, y, t) in _teal]
_amber = [(x, y, t / 0.80) for (x, y, t) in _amber_full if t <= 0.80]

TEAL_BEZIER = scale_center(_teal)
AMBER_BEZIER = scale_center(_amber)
TEAL_TIP = TEAL_BEZIER[-1]
TEAL_W0, TEAL_W1 = 360, 286
AMBER_W0, AMBER_W1 = 236, 188


def draw_glyph(base):
    """Draw the two streaks + glows + lead spark onto an RGBA base image."""
    # Glow layers (blurred, behind strokes).
    glow = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    gd = ImageDraw.Draw(glow)
    stroke(gd, AMBER_BEZIER, AMBER_W0 + 120, AMBER_W1 + 120, AMBER + (90,))
    stroke(gd, TEAL_BEZIER, TEAL_W0 + 150, TEAL_W1 + 150, TEAL + (120,))
    glow = glow.filter(ImageFilter.GaussianBlur(70 * SS // 4))
    base.alpha_composite(glow)

    # Solid strokes (amber behind, teal in front).
    fg = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    fd = ImageDraw.Draw(fg)
    stroke(fd, AMBER_BEZIER, AMBER_W0, AMBER_W1, AMBER + (255,))
    stroke(fd, TEAL_BEZIER, TEAL_W0, TEAL_W1, TEAL + (255,))
    base.alpha_composite(fg)

    # Bright lead spark at the teal tip.
    spark = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    sd = ImageDraw.Draw(spark)
    tx, ty, _ = TEAL_TIP
    sd.ellipse([tx - 230, ty - 230, tx + 230, ty + 230], fill=TEAL + (140,))
    spark = spark.filter(ImageFilter.GaussianBlur(40 * SS // 4))
    base.alpha_composite(spark)
    core = ImageDraw.Draw(base)
    core.ellipse([tx - 96, ty - 96, tx + 96, ty + 96], fill=(235, 255, 250, 255))


def draw_glyph_mono(base, light=235, mid=150):
    """Monochrome glyph for the tinted variant (luminance drives the system tint)."""
    fg = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    fd = ImageDraw.Draw(fg)
    stroke(fd, AMBER_BEZIER, AMBER_W0, AMBER_W1, (mid, mid, mid, 255))
    stroke(fd, TEAL_BEZIER, TEAL_W0, TEAL_W1, (light, light, light, 255))
    base.alpha_composite(fg)
    tx, ty, _ = TEAL_TIP
    ImageDraw.Draw(base).ellipse([tx - 96, ty - 96, tx + 96, ty + 96], fill=(255, 255, 255, 255))


def build_light():
    img = Image.new("RGBA", (S, S), BG + (255,))
    # Subtle vertical lift + teal radial glow for depth.
    img.alpha_composite(radial_glow(S, (S * 0.52, S * 0.42), S * 0.72, TEAL, 60))
    img.alpha_composite(radial_glow(S, (S * 0.30, S * 0.80), S * 0.55, AMBER, 26))
    draw_glyph(img)
    return img


def build_dark():
    img = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    img.alpha_composite(radial_glow(S, (S * 0.52, S * 0.42), S * 0.72, TEAL, 40))
    draw_glyph(img)
    return img


def build_tinted():
    img = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    draw_glyph_mono(img)
    return img


def build_logo():
    """Transparent twin-streak glyph for the launch screen (no canvas-wide glow)."""
    img = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    draw_glyph(img)
    return img


def save(img, name):
    img.convert("RGBA").resize((OUT, OUT), Image.LANCZOS).save(name)
    print("wrote", name)


import os

HERE = os.path.dirname(os.path.abspath(__file__))
ASSETS = os.path.join(HERE, "..", "Streakline", "Assets.xcassets")
DEST = os.path.join(ASSETS, "AppIcon.appiconset")
save(build_light(), os.path.join(DEST, "icon_light.png"))
save(build_dark(), os.path.join(DEST, "icon_dark.png"))
save(build_tinted(), os.path.join(DEST, "icon_tinted.png"))

# Launch logo (centered glyph on transparent), rendered at @1x / @2x / @3x.
LAUNCH = os.path.join(ASSETS, "LaunchLogo.imageset")
os.makedirs(LAUNCH, exist_ok=True)
logo = build_logo().convert("RGBA")
for scale, suffix in [(1, ""), (2, "@2x"), (3, "@3x")]:
    px = 240 * scale
    out = os.path.join(LAUNCH, f"launch_logo{suffix}.png")
    logo.resize((px, px), Image.LANCZOS).save(out)
    print("wrote", out)
