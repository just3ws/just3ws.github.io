---
id: TASK-260.04
title: Refresh homepage navigation and visual system for hiring evaluation
status: Done
assignee:
  - '@Codex'
created_date: '2026-08-10 17:11'
updated_date: '2026-08-15 18:47'
labels:
  - site-refresh
  - panoramic-view
dependencies:
  - TASK-260.02
  - TASK-260.03
modified_files:
  - .agents/product-marketing-context.md
  - _config.yml
  - _data/home.yml
  - _data/navigation.yml
  - _includes/head/base.html
  - _sass/_p_home_refresh.scss
  - _sass/_p_theme_kanagawa.scss
  - _sass/_p_theme_modern.scss
  - about/index.html
  - assets/css/site.scss
  - bin/smoke_playwright.sh
  - docs/site-refresh/panoramic-view-positioning.md
  - home/index.html
  - resume.html
  - tests/layout.spec.js
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
- [x] #1 The homepage communicates the exact `Principal Software Engineer` identity and a plain-language technical IC value proposition above the fold
- [x] #2 Visitors have clear paths to the résumé, selected work, complete history, contact, and the public archive; the unpublished Panoramic View route is not linked
- [x] #3 Desktop and mobile heading scales are readable, small text and primary actions meet AA contrast, and the visual system retains its editorial character
- [x] #4 Primary navigation and homepage content work without clipping or horizontal overflow at supported mobile widths
- [x] #5 Existing public routes remain available and the Jekyll build, scoped internal-link validation, accessibility checks, and Playwright smoke checks pass
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [x] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Replace the existing `/home/` composition with a hiring-evaluator landing page driven by canonical professional-home data: current identity, operating promise, Panoramic View differentiation, evidence at multiple scales, selected work, complete history, and contact.
2. Simplify the primary navigation to Resume, Panoramic View, Work, Archive, and Contact while preserving every existing archive/intelligence route inside the appropriate dropdown.
3. Add a dedicated responsive home visual layer and revise the shared mobile navigation into a bounded grid with viewport-contained dropdowns.
4. Update stale site-level Staff Engineer metadata and add Playwright assertions for evaluator paths, mobile bounds, dropdown operation, reduced-motion-safe behavior, and archive route availability.
5. Run visual review, privacy/content review, Jekyll and full repository validation, link/accessibility checks, and browser smoke tests.

Follow-up refinement requested 2026-08-15: replace the superseded Director-role homepage copy with the settled Principal Software Engineer identity, rewrite the landing page in plain human language, reduce poster-scale display typography, remove the link to the explicitly unpublished `/panoramic-view/` page, and update active positioning context so the old management target cannot drift back in.
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

The final conceptual refinement makes the value proposition explicit: Panoramic View maps the perspective of the business to actual system operation. Its governing questions are what the business believes the system does, what evidence shows it actually does, and where vision and reality align, diverge, or remain unknown. The model may extend from supply chain through archival cold storage only as time and mandate permit.

Verification: homepage and navigation YAML parsed; a route-preservation assertion confirmed all 19 required professional, work, archive, and intelligence routes remain present; public-safety scans found no implementation employers, people, private paths, proprietary counts, customers, or internal politics in homepage or methodology surfaces.

Browser and visual verification: all eight Playwright tests passed across refreshed home, resume, Panoramic View, current-role detail, desktop, 375px mobile, viewport-contained archive dropdown, accessible method diagram, and the Kanagawa alternative theme. Default, mobile, menu-open, methodology, resume, and Kanagawa screenshots were reviewed.

Full validation: after cleaning the generated site, Jekyll built 1,038 pages with zero accessibility warnings and `bundle exec rake validate` passed data, archive, generated freshness, repository hygiene, SEO/indexability, semantics, exports, SEO budgets, and HTML-Proofer checks over 1,018 files and 832 internal links. Existing generated-export destination-collision warnings remain unchanged.

Reviewer verdict: PASS. The homepage now provides one evaluator path from current identity to operating method, multi-scale practical evidence, selected work, complete history, and contact. Repeated generic cards were replaced by editorial rows and system-map motifs; no new scripted motion was added; reduced-motion and both themes are supported; mobile clipping is resolved.

The earlier implementation-note phrase `Hands-on Director of Engineering` is superseded. The permanent public identity is exactly `Principal Software Engineer`; OneMain's historical title remains `Associate Director, Staff Engineer` in that position's source data.

Independent site-refresh review verdict: PASS. Its only minor observation was a mismatch between the stated mobile H1 cap and the test location. The home breakpoint is now 1.85rem and the ≤34px assertion runs in the 375px `/home/` test; the installed-localhost desktop/mobile smoke pair passes 2/2.

Critical-surface A11y, ATS, and search audit completed for `/home/`, `/`, `/portfolio/`, `/history/`, the OneMain role page, `/contact/`, exports, and the print PDF. Resume surfaces are structurally strong. Portfolio slideshow controls, keyboard modal behavior, repeated image alternatives, and proof-oriented positioning remain a separate follow-up rather than an expansion of this homepage slice.
<!-- SECTION:NOTES:END -->

## Comments

<!-- COMMENTS:BEGIN -->
created: 2026-08-15 18:27
---
User review: `/home/` is materially improved but its header type renders too large and its copy reads unnaturally. Reopened this bounded homepage slice for a typography and voice correction; the previously approved structure, routes, evidence boundaries, and theme behavior remain the baseline.
---
<!-- COMMENTS:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Reframed `/home/` around the exact Principal Software Engineer identity with concise first-person technical-IC copy and restrained editorial typography. Preserved core evaluator and archive routes, removed the link to the unpublished Panoramic View page, aligned active marketing/site metadata, and kept the legacy `/resume.html` alias available but out of search indexing. Updated responsive styling and regression coverage, including a verified ≤34px mobile hero heading. Jekyll built 1,040 pages with zero markup accessibility warnings; scoped metadata, SEO, indexability, semantic, export, link, and Playwright checks passed; independent visual review returned PASS.
<!-- SECTION:FINAL_SUMMARY:END -->
