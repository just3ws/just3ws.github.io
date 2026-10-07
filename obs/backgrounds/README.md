# obs/backgrounds/

Virtual camera background images for The Sound Above and Errata streaming setup.

## Purpose

These are **native macOS camera replacement backgrounds** used in
**macOS Video Effects -> Background Replacement** (Control Center camera menu),
not as OBS browser sources. This provides a two-layer privacy stack:

```
Real room
  └─ macOS camera replaces background with craftsman virtual background
       └─ OBS receives the already-composited clean signal
            └─ Camera Background HTML overlay adds craftsmanship branding
```

## Available Background Variants

### Smooth Studio Gradients (Zero Edge Tearing & Highest Segmentation Cleanliness)
Specifically calibrated to prevent profile edge tearing, hair bleeding, and green-screen-style halo fringes. These use continuous photographic radial vignettes with film micro-grain to match the lighting curve of your webcam.

| File | Palette Tone | Harmonized CSS Token | Key Characteristic |
|---|---|---|---|
| `smooth-warm-vellum.jpg` | Warm Paper & Vellum | `--paper-canvas` (`#faf8f5`) | Matches warm cream room light; completely eliminates edge bleeding against light clothing or hair |
| `smooth-craftsman-slate.jpg` | Dark Sumi Ink Slate | `--ink-main` (`#1e232a`) | Dramatic dark studio look; matches the OBS background palette seamlessly |
| `smooth-sage-teal.jpg` | Muted Craftsman Teal | `--teal-craftsman` (`#0f766e`) | Subtle architectural studio wash; complements warm skin tones and blue office chair |
| `smooth-amber-studio.jpg` | Warm Amber & Clay | `--amber-accent` (`#b45309`) | Muted leather/terracotta tone; soft warm dusk ambience |

### Architectural Workshop & Library Backdrops

| File | Theme & Aesthetic | When to Use |
|---|---|---|
| `craftsman-study-bookshelf.jpg` | Quartersawn oak library study, vintage books, gentle f/2.2 bokeh | Archetype 1 rewatches, historical commentary, deep research |
| `linen-morning-window.jpg` | Tailored warm cream linen drape, soft morning diffuse daylight | Minimalist clean presentation, daylight sessions |
| `midcentury-workshop-wood.jpg` | Horizontal oiled walnut acoustic slat paneling, monstera plant | Archetype 2 Errata, live coding workbench, terminal demos |
| `chicago-loft-brick.jpg` | Historic Chicago common brick, dark bronze window mullions | Chicago craftsmanship episodes, community roundtable dialogues |
| `bg-neutral-day.jpg` | Flat diffuse light, neutral beige linen curtain | Minimalist baseline fallback |
| `bg-morning-sun.jpg` | Morning sunbeam glow on warm linen curtain | Early morning recordings matching window light |

## How to Load in macOS (Golden Gate)

1. Open any camera-active application (OBS Studio, FaceTime, or Photo Booth).
2. Click the green Video Effects icon in the macOS menu bar / Control Center.
3. Under **Background**, click **+** -> select any of the `.jpg` files from `obs/backgrounds/`.
4. macOS remembers your selected background across OBS Studio sessions.

## OBS Integration & Scene 05 (Workbench) Optimization

The camera source (`Host Camera`, Scenes 02 to 05) picks up the composited signal.

In **Scene 05 (Workbench - Code & Terminal)**:
- Terminal is maximized (1920x1080) for 100% readability.
- Host camera is positioned in the lower-right corner (440x300).
- Lower Third card automatically dismisses after 10 seconds (`--autohide 10`), or can be rendered as a minimal top HUD status bar (`--layout minimal`), preventing any obstruction of the shell prompt and cursor.

## Privacy Guarantee

By replacing your personal background with one of the craftsman workshop or library backdrops, your physical workspace remains completely private. Natural f/2.2 to f/2.8 optical depth-of-field prevents any uncanny artificial rendering.
