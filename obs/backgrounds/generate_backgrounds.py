#!/usr/bin/env python3
"""
Generate two linen-curtain virtual backgrounds for The Sound Above OBS setup.
  bg-neutral-day.jpg  — flat diffuse warm-white curtain, no sun
  bg-morning-sun.jpg  — same curtain with warm upper-left sunbeam glow

Target: 1920x1080 JPEG for macOS native camera background replacement.
Designed to blend with the Camera Background HTML dark-slate OBS layer.
"""

import math
import random
import struct
import zlib
import os

# We only need stdlib + Pillow
from PIL import Image, ImageDraw, ImageFilter, ImageChops
import numpy as np

W, H = 1920, 1080
OUT = os.path.join(os.path.dirname(__file__), "obs", "backgrounds")
os.makedirs(OUT, exist_ok=True)

rng = random.Random(42)

# ── Palette ──────────────────────────────────────────────────────────────────
# Sampled directly from room photos: warm off-white linen drape
LINEN_BASE   = (212, 208, 200)   # warm natural linen
LINEN_SHADOW = (185, 180, 172)   # gentle fold shadow
LINEN_LIGHT  = (232, 228, 222)   # soft highlight
WARM_GOLD    = (250, 242, 225)   # subtle morning window diffuse light
WARM_GLOW    = (255, 248, 235)   # morning window glow halo


def make_noise_layer(w, h, scale=4, seed=0):
    """Low-frequency coherent noise via simple sinusoidal summation."""
    rng2 = random.Random(seed)
    arr = np.zeros((h, w), dtype=np.float32)
    for _ in range(8):
        freq_x = rng2.uniform(0.5, 3.0) * scale
        freq_y = rng2.uniform(0.5, 3.0) * scale
        phase_x = rng2.uniform(0, 2 * math.pi)
        phase_y = rng2.uniform(0, 2 * math.pi)
        amp = rng2.uniform(0.3, 1.0)
        xs = np.linspace(0, freq_x * math.pi, w)
        ys = np.linspace(0, freq_y * math.pi, h)
        gx, gy = np.meshgrid(xs, ys)
        arr += amp * np.sin(gx + phase_x) * np.cos(gy + phase_y)
    # Normalise to [0,1]
    arr = (arr - arr.min()) / (arr.max() - arr.min() + 1e-9)
    return arr


def linen_texture(w, h):
    """
    Simulate a woven linen curtain:
    - Coarse vertical folds (the primary drape)
    - Fine horizontal weave lines
    - Subtle noise for fabric irregularity
    """
    arr = np.zeros((h, w), dtype=np.float32)

    # Vertical drape folds — wide, soft
    xs = np.linspace(0, 1, w)
    fold_freq = 7   # number of folds across width
    fold = 0.5 + 0.5 * np.sin(xs * fold_freq * 2 * math.pi + 0.3)
    fold_smooth = np.clip(fold ** 1.6, 0, 1)
    arr += np.tile(fold_smooth, (h, 1)) * 0.45

    # Fine horizontal weave threads
    ys = np.linspace(0, 1, h)
    weave = 0.5 + 0.5 * np.sin(ys * H * 0.9 * math.pi)
    weave_smooth = np.clip(weave ** 3, 0, 1)
    arr += np.tile(weave_smooth.reshape(-1, 1), (1, w)) * 0.12

    # Fabric noise
    noise = make_noise_layer(w, h, scale=2, seed=7)
    arr += noise * 0.25

    # Normalise
    arr = (arr - arr.min()) / (arr.max() - arr.min() + 1e-9)
    return arr


def apply_linen_colour(texture, base, shadow, light):
    """Map [0,1] texture float to RGB between shadow and light colours."""
    r = base[0] + (light[0] - shadow[0]) * (texture - 0.5)
    g = base[1] + (light[1] - shadow[1]) * (texture - 0.5)
    b = base[2] + (light[2] - shadow[2]) * (texture - 0.5)
    r = np.clip(r, 0, 255).astype(np.uint8)
    g = np.clip(g, 0, 255).astype(np.uint8)
    b = np.clip(b, 0, 255).astype(np.uint8)
    return np.stack([r, g, b], axis=2)


def centre_glow(w, h, strength=0.15):
    """Slightly brighter centre, natural camera falloff at edges."""
    xs = np.linspace(-1, 1, w)
    ys = np.linspace(-1, 1, h)
    gx, gy = np.meshgrid(xs, ys)
    dist = np.sqrt(gx**2 + (gy * 0.6)**2)
    glow = np.clip(1.0 - dist * strength * 3, 0, 1)
    return glow


def vignette(w, h, strength=0.18):
    """Darken edges as a real lens does."""
    xs = np.linspace(-1, 1, w)
    ys = np.linspace(-1, 1, h)
    gx, gy = np.meshgrid(xs, ys)
    dist = np.sqrt(gx**2 + gy**2)
    vig = np.clip(1.0 - dist * strength * 1.8, 0.72, 1.0)
    return vig


def morning_sun_layer(w, h):
    """
    Warm sunbeam coming through upper-left of frame.
    Returns an RGBA image to composite over the base.
    """
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Primary halo — large soft ellipse upper-left
    draw.ellipse([-120, -200, 680, 560], fill=(*WARM_GLOW, 60))

    # Core bright patch
    draw.ellipse([40, -80, 420, 360], fill=(*WARM_GOLD, 55))

    # Two diagonal ray streaks
    for angle_offset, width, alpha in [(-12, 120, 30), (8, 80, 22), (-28, 60, 18)]:
        # Ray from upper-left extending diagonally
        cx, cy = 180, -60
        length = 1400
        rad = math.radians(55 + angle_offset)
        ex = cx + length * math.cos(rad)
        ey = cy + length * math.sin(rad)

        ray = Image.new("RGBA", (w, h), (0, 0, 0, 0))
        rdraw = ImageDraw.Draw(ray)
        rdraw.line([(cx, cy), (ex, ey)], fill=(*WARM_GOLD, alpha), width=width)
        ray_blur = ray.filter(ImageFilter.GaussianBlur(radius=width // 2))
        img = Image.alpha_composite(img, ray_blur)

    # Final soft blur on whole layer
    img = img.filter(ImageFilter.GaussianBlur(radius=40))
    return img


# ── Build base texture ────────────────────────────────────────────────────────
print("Building linen texture…")
tex = linen_texture(W, H)
rgb = apply_linen_colour(tex, LINEN_BASE, LINEN_SHADOW, LINEN_LIGHT)
base_img = Image.fromarray(rgb, "RGB")

# Apply centre glow and vignette
glow_arr = centre_glow(W, H, strength=0.15)
vig_arr  = vignette(W, H, strength=0.15)
combined = glow_arr * vig_arr
combined = (combined - combined.min()) / (combined.max() - combined.min() + 1e-9)
# Remap to [0.88, 1.0] brightness multiplier
brightness = 0.88 + combined * 0.12

rgb_f = rgb.astype(np.float32) * brightness[:, :, np.newaxis]
rgb_f = np.clip(rgb_f, 0, 255).astype(np.uint8)
base_img = Image.fromarray(rgb_f, "RGB")

# Soft blur — depth-of-field feel (background slightly soft)
base_img = base_img.filter(ImageFilter.GaussianBlur(radius=1.8))

# ── Image 1: Neutral Day ──────────────────────────────────────────────────────
print("Saving bg-neutral-day.jpg…")
neutral = base_img.copy()
neutral_path = os.path.join(OUT, "bg-neutral-day.jpg")
neutral.save(neutral_path, "JPEG", quality=95, optimize=True)
print(f"  → {neutral_path}")

# ── Image 2: Morning Sun ──────────────────────────────────────────────────────
print("Building morning sun layer…")
sun_layer = morning_sun_layer(W, H)

base_rgba = base_img.convert("RGBA")
morning = Image.alpha_composite(base_rgba, sun_layer).convert("RGB")

# Warm colour grade — slight yellow-orange push
morning_arr = np.array(morning, dtype=np.float32)
morning_arr[:, :, 0] = np.clip(morning_arr[:, :, 0] * 1.06, 0, 255)  # R up
morning_arr[:, :, 2] = np.clip(morning_arr[:, :, 2] * 0.94, 0, 255)  # B down
morning = Image.fromarray(morning_arr.astype(np.uint8), "RGB")

print("Saving bg-morning-sun.jpg…")
morning_path = os.path.join(OUT, "bg-morning-sun.jpg")
morning.save(morning_path, "JPEG", quality=95, optimize=True)
print(f"  → {morning_path}")

print("\nDone. Both backgrounds saved.")
print(f"  Neutral day : {neutral_path}")
print(f"  Morning sun : {morning_path}")
