---
id: TASK-260.04
title: Refresh homepage navigation and visual system for hiring evaluation
status: In Progress
assignee:
  - '@Codex'
created_date: '2026-08-10 17:11'
updated_date: '2026-08-10 18:09'
labels:
  - site-refresh
  - panoramic-view
dependencies:
  - TASK-260.02
  - TASK-260.03
parent_task_id: TASK-260
priority: high
type: enhancement
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Recompose the homepage and shared presentation so a human or AI evaluator quickly understands Mike Hall's current professional identity, differentiating method, proof, and next action while the public archive remains discoverable. Resolve the existing mobile navigation clipping and evolve the visual language from the approved resume and Panoramic View direction.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 The homepage communicates the hands-on Director of Engineering positioning and core operating promise above the fold.
- [ ] #2 Visitors have clear paths to the resume, Panoramic View methodology, selected evidence, complete history, and contact action.
- [ ] #3 The visual system uses the approved Panoramic View direction without generic card repetition or inaccessible motion.
- [ ] #4 Primary navigation works without clipping or overflow at supported mobile widths.
- [ ] #5 Existing archive routes remain available and the Jekyll build, internal-link validation, accessibility checks, and Playwright smoke checks pass.
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Replace the existing `/home/` composition with a hiring-evaluator landing page driven by canonical professional-home data: current identity, operating promise, Panoramic View differentiation, evidence at multiple scales, selected work, complete history, and contact.
2. Simplify the primary navigation to Resume, Panoramic View, Work, Archive, and Contact while preserving every existing archive/intelligence route inside the appropriate dropdown.
3. Add a dedicated responsive home visual layer and revise the shared mobile navigation into a bounded grid with viewport-contained dropdowns.
4. Update stale site-level Staff Engineer metadata and add Playwright assertions for evaluator paths, mobile bounds, dropdown operation, reduced-motion-safe behavior, and archive route availability.
5. Run visual review, privacy/content review, Jekyll and full repository validation, link/accessibility checks, and browser smoke tests.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Homepage and Navigation Refresh Brief
1. Surface and job: `/home/` becomes the primary human landing page; `/` remains the canonical résumé and ATS surface. The first viewport must answer who Mike is now, what problem he solves, how he works, where to inspect proof, and how to contact him.
2. Design read: an executive-technical editorial page with one strong through-line—Stabilize, Understand, Innovate—rather than a project gallery or personal miscellany page.
3. Context-hunter classification: L2 targeted evolution spanning one canonical data file, one page, one page-specific SCSS partial, navigation data, shared responsive navigation rules, site metadata, and focused tests. Reuse the existing Jekyll data/render split, minimal layout, header include, theme variables, and Playwright suite.
4. Dials: VARIANCE 4, MOTION 1, DENSITY 5. Use typographic hierarchy, editorial rows, rules, and one systems-map motif; avoid repeated generic cards and new scripted animation.
5. Preserve: `/home/`, `/`, `/portfolio/`, `/writing/`, `/interviews/`, `/intelligence/`, `/history/`, all archive children, theme toggle, avatar brand, contact route, breadcrumb conventions, semantic headings, and archive discoverability.
6. Retire: Architect & Creator as the primary label, game-first hero placement, biography-first framing, six competing top-level navigation categories, emoji-heavy dropdown labels, and mobile flex behavior that compresses links beyond the viewport.
7. Introduce: Hands-on Director of Engineering, the approved operating promise, Panoramic View as the primary differentiator, anonymized practical proof across enterprise and small-company contexts, a current hands-on builder signal, a clear complete-history escape hatch, and a professional contact action.
8. Navigation architecture: top-level Resume, Panoramic View, Work, Archive, Contact, plus theme toggle. Work contains Portfolio, Writing, Now, and Complete History. Archive retains conversations, timeline, speakers, Ask, Studio, Web, Curiosities, Books, Intelligence Dashboard, Knowledge Graph, Archive Status, and Exports.
9. Responsive contract: at 375px, the primary links form a three-column bounded grid; no link or dropdown exceeds the viewport; dropdown contents remain keyboard/click reachable; homepage content and decorative systems motif do not create horizontal overflow.
10. Authorized files: `_data/home.yml`, `home/index.html`, `_data/navigation.yml`, `_sass/_p_home_refresh.scss`, `_sass/_p_theme_modern.scss`, `assets/css/site.scss`, `_config.yml`, `_includes/head/base.html`, and `tests/layout.spec.js`.
<!-- SECTION:NOTES:END -->
