# just3ws Direction Contract

## Lineage

This contract adapts the audit-first redesign protocol, three design dials, anti-repetition discipline, and pre-flight mindset from [Leonxlnx/taste-skill](https://github.com/Leonxlnx/taste-skill), then narrows them to this repository's Jekyll architecture and public archive obligations.

## Durable Context

- just3ws.com is a personal brand site, Staff-level engineering record, and public technical archive.
- Public material must satisfy `CONTEXT.md` and `docs/adr/0001-public-archive-publication-contract.md`.
- The site is Jekyll with Liquid, semantic HTML, modular SCSS, vanilla JavaScript, canonical YAML data, and Playwright smoke tests.
- The established voice is calm, technically literate, systems-aware, builder-respectful, and hype-free.
- Existing visual language includes Nord-derived light tokens plus the Kanagawa Wave dark theme, a compact persistent navigation, dense archive surfaces, and image evidence from the historical corpus.

## Taste Dials

Score each target surface independently.

| Dial | 1-3 | 4-7 | 8-10 |
| --- | --- | --- | --- |
| `VARIANCE` | symmetric and predictable | offset compositions and varied ratios | experimental asymmetry and overlap |
| `MOTION` | static with interaction feedback | restrained transitions and reveals | scroll choreography or spatial motion |
| `DENSITY` | sparse landing page | editorial reading surface | research index or metadata cockpit |

Do not force one value across the site. A home hero and a transcript index have different jobs.

## Derived Taste Principles

- Read the audience, page kind, assets, and quiet constraints before choosing an aesthetic.
- Audit before changing an existing project. Preserve brand, information architecture, accessibility wins, analytics hooks, and SEO unless scope says otherwise.
- Prefer targeted evolution. Typography, spacing, palette calibration, and interaction feedback usually provide the safest leverage.
- Use cards only when grouping or elevation carries meaning. Use space, rules, or list structure for archive material.
- Vary section composition when repetition makes a page feel templated, but keep mobile collapse explicit.
- Keep one palette logic and one shape logic per surface. Document exceptions instead of drifting.
- Keep body text readable, headings intentional, CTAs unambiguous, and focus states visible.
- Motivate motion with hierarchy, feedback, or storytelling. Provide a reduced-motion path.
- Use real public-safe assets. Generated or stock imagery must be explicitly authorized and must not imply false provenance.
- Make final review mechanical where possible: contrast, link state, viewport behavior, asset dimensions, page build, and smoke tests.

## Upstream Ideas Not Adopted as Defaults

- React, Next.js, Tailwind, Motion, GSAP, and third-party component systems
- randomized art direction
- mandatory AIDA structure
- mandatory dark mode or mandatory imagery on every surface
- stock placeholder services
- forced animation, asymmetry, bento grids, or cinematic spacing
- global bans that conflict with Mike's established voice or archive content

These can be proposed only when the target brief and current architecture justify them.

## Evidence Sources

Read the smallest relevant set:

- `_sass/_p_variables.scss` for foundational tokens
- `_sass/_p_theme_modern.scss` and `_sass/_p_theme_kanagawa.scss` for themes
- `_sass/_p_base_layout.scss` and `_sass/_p_main.scss` for shared and page patterns
- `_layouts/base.html` and `_includes/header.html` for global behavior
- `_data/navigation.yml` for canonical navigation
- `tests/layout.spec.js` for rendered expectations and screenshot paths
- `skills/guild-chronicler-copywriter/` for authorized copy changes
