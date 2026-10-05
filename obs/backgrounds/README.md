# obs/backgrounds/

Virtual camera background images for The Sound Above streaming setup.

## Purpose

These are **native macOS camera replacement backgrounds** — used in
**System Settings → Video Effects → Background** (or equivalent), not as
OBS browser sources. This gives a two-layer privacy stack:

```
Real room
  └─ macOS camera replaces background with bg-*.jpg
       └─ OBS receives the already-composited signal
            └─ Camera Background HTML overlay adds craftsmanship branding
```

## Files

| File | When to use |
|---|---|
| `bg-neutral-day.jpg` | Default — flat diffuse light, neutral beige/linen curtain |
| `bg-morning-sun.jpg` | Morning sessions — warm upper-left sunbeam glow, matches actual window light |

## How to load in macOS

1. Open FaceTime, Photo Booth, or any camera-active app
2. Click the video effects button (top-left of camera preview) → **Backgrounds**
3. Click **+** → **Choose** → select the bg-*.jpg from this folder
4. Switch between them to match current lighting

## OBS integration

The camera source (`Host Camera`, Scene 02) picks up the already-replaced
video signal. The `Camera Background` browser source sits below it in the
scene stack as a branded stage — together they form a three-layer composite:

```
Layer 3 (top)  — Overlay: Lower Third (HTML)
Layer 2        — Host Camera (macOS already replaced bg with bg-*.jpg)
Layer 1        — Camera Background (HTML craftsmanship stage)
```

## Privacy guarantee

Even if macOS background replacement has edge artefacts, OBS's `Camera Background`
HTML layer catches them — the linen palette of bg-*.jpg was chosen to blend
with the dark slate OBS background at the edges, minimising halo fringing.
