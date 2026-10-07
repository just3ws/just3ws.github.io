#!/usr/bin/env python3
"""
Generate smooth, neutral warm virtual studio backdrops for webcam replacement.

Key Design Goals:
1. Zero Edge Tearing: Edge tearing happens when the virtual background has
   high-contrast patterns, sharp edges, or sudden luminance shifts that differ
   sharply from your actual lighting and room. By using ultra-smooth radial
   lighting vignettes with organic micro-grain (no high-frequency folds or slats),
   segmentation algorithms can cleanly resolve hair and silhouette edges.
2. Craftsman Theme Harmonization:
   - Warm Paper & Vellum: Natural studio wash harmonized with #faf8f5 (paper-canvas)
   - Slate Charcoal: Soft architectural dark studio wash harmonized with #1e232a (ink-main)
   - Craftsman Sage & Teal: Muted architectural backdrop harmonized with #0f766e
   - Amber Clay & Terracotta: Warm ambient dusk tone harmonized with #b45309
"""

import math
import os
from PIL import Image, ImageFilter
import numpy as np

W, H = 1920, 1080
OUT_DIR = os.path.join(os.path.dirname(__file__))

def create_studio_gradient(base_rgb, highlight_rgb, shadow_rgb,
                           light_center=(0.35, 0.40),
                           falloff_radius=0.85,
                           noise_intensity=0.015):
    """
    Creates an ultra-smooth photographic studio wall backdrop.
    Uses continuous 2D distance falloff with film micro-grain to prevent color banding.
    """
    # 2D coordinate grid normalized from 0 to 1
    x = np.linspace(0.0, 1.0, W, dtype=np.float32)
    y = np.linspace(0.0, 1.0, H, dtype=np.float32)
    gx, gy = np.meshgrid(x, y)

    # Key light position (slightly upper-left to match window light)
    lx, ly = light_center
    dist = np.sqrt(((gx - lx) * 1.1) ** 2 + ((gy - ly) * 0.9) ** 2)
    norm_dist = np.clip(dist / falloff_radius, 0.0, 1.0)

    # Smooth cosine falloff curve
    t = 0.5 * (1.0 + np.cos(norm_dist * math.pi)) # 1.0 at center, 0.0 at edge

    # 3-stop smooth interpolation: shadow -> base -> highlight
    # When t > 0.5: blend base to highlight
    # When t <= 0.5: blend shadow to base
    r = np.zeros((H, W), dtype=np.float32)
    g = np.zeros((H, W), dtype=np.float32)
    b = np.zeros((H, W), dtype=np.float32)

    high_mask = t >= 0.5
    u = (t[high_mask] - 0.5) * 2.0
    r[high_mask] = base_rgb[0] * (1.0 - u) + highlight_rgb[0] * u
    g[high_mask] = base_rgb[1] * (1.0 - u) + highlight_rgb[1] * u
    b[high_mask] = base_rgb[2] * (1.0 - u) + highlight_rgb[2] * u

    low_mask = ~high_mask
    v = t[low_mask] * 2.0
    r[low_mask] = shadow_rgb[0] * (1.0 - v) + base_rgb[0] * v
    g[low_mask] = shadow_rgb[1] * (1.0 - v) + base_rgb[1] * v
    b[low_mask] = shadow_rgb[2] * (1.0 - v) + base_rgb[2] * v

    # Add Gaussian film micro-grain to eliminate digital banding
    np.random.seed(42)
    grain = np.random.normal(0, noise_intensity * 255.0, (H, W))
    r = np.clip(r + grain, 0, 255).astype(np.uint8)
    g = np.clip(g + grain, 0, 255).astype(np.uint8)
    b = np.clip(b + grain, 0, 255).astype(np.uint8)

    img_array = np.stack([r, g, b], axis=2)
    img = Image.fromarray(img_array, mode="RGB")
    # Slight box blur to ensure buttery smoothness
    return img.filter(ImageFilter.GaussianBlur(radius=1.5))

def main():
    variants = [
        {
            "filename": "smooth-warm-vellum.jpg",
            "name": "Smooth Warm Vellum (Paper Canvas)",
            # Calibrated around #faf8f5 (250, 248, 245)
            "base": (238, 234, 226),
            "highlight": (252, 250, 247),
            "shadow": (214, 208, 198),
            "center": (0.35, 0.40)
        },
        {
            "filename": "smooth-craftsman-slate.jpg",
            "name": "Smooth Craftsman Slate (Dark Ink Studio)",
            # Calibrated around #1e232a (30, 35, 42)
            "base": (36, 42, 50),
            "highlight": (54, 62, 73),
            "shadow": (22, 26, 32),
            "center": (0.35, 0.40)
        },
        {
            "filename": "smooth-sage-teal.jpg",
            "name": "Smooth Craftsman Sage & Teal",
            # Calibrated around #0f766e (15, 118, 110) in a soft muted studio tone
            "base": (68, 86, 84),
            "highlight": (92, 114, 111),
            "shadow": (45, 58, 56),
            "center": (0.35, 0.40)
        },
        {
            "filename": "smooth-amber-studio.jpg",
            "name": "Smooth Amber Clay & Walnut",
            # Calibrated around warm amber/leather (#b45309) in a muted studio tone
            "base": (120, 92, 72),
            "highlight": (155, 122, 98),
            "shadow": (82, 60, 46),
            "center": (0.35, 0.40)
        }
    ]

    for v in variants:
        out_path = os.path.join(OUT_DIR, v["filename"])
        img = create_studio_gradient(
            base_rgb=v["base"],
            highlight_rgb=v["highlight"],
            shadow_rgb=v["shadow"],
            light_center=v["center"]
        )
        img.save(out_path, quality=95, optimize=True)
        print(f"Generated {v['name']} -> {out_path} ({os.path.getsize(out_path) // 1024} KB)")

if __name__ == "__main__":
    main()
