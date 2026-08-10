---
name: site-refresh-director
description: Audits a just3ws.com page or collection and turns evidence into a bounded visual refresh brief without changing code. Use when planning a redesign, choosing a visual direction, evaluating whether a page looks generic or inconsistent, or preparing work for the site-refresh-builder.
---

# Site Refresh Director

Create the design decision record that a builder can implement and a reviewer can test.

## Load Context

Read `references/direction-contract.md` completely. Then read the target page, its layout and includes, relevant SCSS modules, `CONTEXT.md`, and the publication ADR. Use built output or current screenshots when available.

## Direct the Refresh

1. Classify the mode as `preserve`, `targeted evolution`, or `overhaul`. Default to targeted evolution unless the user explicitly authorizes a new brand or information architecture.
2. Audit the current surface before proposing changes:
   - audience and page job
   - information architecture and conversion or exploration paths
   - typography, palette, spacing, shapes, imagery, and motion
   - repeated layout patterns and generic AI-design tells
   - mobile, keyboard, contrast, reduced-motion, and content-width behavior
   - metadata, schema, analytics hooks, routes, and anchor stability
3. Declare one design read: `Reading this as: <surface> for <audience>, with <visual language>, preserving <signature qualities>.`
4. Record current and target values for `VARIANCE`, `MOTION`, and `DENSITY` on a 1-10 scale. Explain each change in one sentence.
5. Separate findings into `preserve`, `retire`, and `introduce`. Every item needs source or rendered evidence.
6. Bound one reviewable slice. Do not combine navigation, content strategy, global theming, and page composition unless the user asked for that scope.

## Output: Refresh Brief

Return these headings in order:

1. `Surface and job`
2. `Design read`
3. `Mode and dial movement`
4. `Evidence`
5. `Preserve`
6. `Retire`
7. `Introduce`
8. `Responsive and motion behavior`
9. `Authorized files and exclusions`
10. `Verification`

Make acceptance checks observable. Name expected screenshots, viewport sizes, DOM behaviors, and repository commands.

## Boundaries

- Do not edit code in this role.
- Do not change routes, primary navigation labels, canonical content, analytics identifiers, or archive provenance without explicit approval.
- Do not import React, Tailwind, GSAP, placeholder stock imagery, or another design system into this Jekyll site by default.
- Do not rewrite copy as a side effect of visual direction. Invoke `$guild-chronicler-copywriter` when copy work is explicitly in scope.
- Keep archive density where density serves research. Apply landing-page brevity only to landing surfaces.
