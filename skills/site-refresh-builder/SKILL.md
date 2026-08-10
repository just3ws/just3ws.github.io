---
name: site-refresh-builder
description: Implements an approved just3ws.com refresh brief in the existing Jekyll, Liquid, HTML, SCSS, and vanilla JavaScript architecture. Use when changing a site surface after visual direction is agreed, including typography, spacing, layout, theme, interaction, or responsive behavior.
---

# Site Refresh Builder

Implement one bounded refresh slice and return reproducible build evidence.

## Prerequisite

Require a Refresh Brief from `$site-refresh-director`, or create the equivalent fields before editing. Read `references/implementation-contract.md` completely. Reinspect the target files because the brief is evidence, not a substitute for current code.

## Build Workflow

1. Confirm the authorized files, preserved behavior, target dials, responsive states, and validation commands.
2. Find two local naming or structure analogs before introducing a new selector, include, token, or JavaScript behavior.
3. Make the smallest coherent change in the existing stack:
   - keep canonical content in `_data/`
   - keep shared markup in `_layouts/` and `_includes/`
   - keep page rules in the existing SCSS module system
   - extend semantic tokens before scattering literal colors, spacing, radii, or z-index values
4. Preserve semantic landmarks, heading order, keyboard paths, focus visibility, active navigation, skip links, metadata, schema, analytics hooks, routes, and anchor IDs.
5. Match motion to the brief. Prefer CSS and vanilla JavaScript already used by the site. Animate `transform` and `opacity`; honor `prefers-reduced-motion`; avoid scroll handlers that force layout work.
6. Use real, public-safe repository assets with dimensions and meaningful alt text. Do not add remote placeholder images or fabricated product previews.
7. Keep visible copy unchanged unless the brief authorizes copy work. Use `$guild-chronicler-copywriter` for authorized rewrites.
8. Validate the narrow surface first, then the site build, then browser smoke checks.

## Output: Build Evidence

Return:

- brief implemented and intentional deviations
- files changed and why
- desktop and mobile screenshots or an explicit reason they are unavailable
- keyboard, focus, contrast, and reduced-motion observations
- commands run with pass or fail status
- known limitations for the reviewer

## Stop Conditions

Stop and request direction if implementation requires a route or nav-label change, a new external dependency, unapproved copy changes, private source material, or scope outside the Refresh Brief.
