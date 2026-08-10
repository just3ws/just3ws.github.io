---
id: TASK-260.03
title: Publish the Panoramic View methodology and case study
status: Done
assignee:
  - '@Codex'
created_date: '2026-08-10 17:11'
updated_date: '2026-08-10 18:08'
labels:
  - site-refresh
  - panoramic-view
dependencies:
  - TASK-260.01
modified_files:
  - _data/panoramic_view.yml
  - panoramic-view/index.html
  - _sass/_p_panoramic_view.scss
  - assets/css/site.scss
  - _data/repo_hygiene.yml
  - tests/layout.spec.js
  - docs/site-refresh/panoramic-view-positioning.md
  - .agents/product-marketing-context.md
parent_task_id: TASK-260
priority: high
type: enhancement
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Create public-facing material that explains Panoramic View as Mike Hall's original general methodology and uses a later, anonymized application at an acquired healthcare software organization as supporting evidence. Teach the horizontal journey and vertical system-wave model, the discovery loop, instrumentation and governance concepts, current limitations, and future work.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 A methodology page defines Panoramic View clearly for non-specialists while retaining its technical depth and original metaphors.
- [x] #2 The page distinguishes the methodology from observability tools, architecture diagrams, customer-journey analytics, and static documentation.
- [x] #3 A sanitized case study follows problem, insight, method, tools, application, evidence, limitations, and future-work structure.
- [x] #4 A diagram or interactive artifact shows the left-to-right journey and top-to-bottom request-response wave without proprietary source material.
- [x] #5 Every material claim follows the approved public claim ledger and the pages pass relevant build, link, accessibility, and browser checks.
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [x] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Add a canonical public-safe Panoramic View data model containing the definition, discovery loop, distinctions, enterprise and small-organization applications, evidence boundaries, limitations, and future work.
2. Build `/panoramic-view/` as a non-specialist-first methodology narrative with technical depth, an accessible browser-to-backend-and-back diagram, and two anonymized scale lenses.
3. Add dedicated responsive SCSS through the existing Sass entry point, preserving the site's minimal layout, theme variables, semantic headings, and no-motion baseline.
4. Add focused Playwright assertions for route, content, discretion rules, diagram accessibility, and mobile overflow.
5. Run public-safety scans, YAML parsing, Jekyll/build/link/accessibility checks, browser tests, and an independent reviewer pass before finalization.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Panoramic View Refresh Brief
1. Surface and job: `/panoramic-view/` is the primary proof-of-method page for hiring leaders, recruiters, technical peers, and machine evaluators who need to understand what Mike originated, how it works, and where it applies.
2. Design read: a method field guide rather than a branded thought-leadership landing page; evidence-led, calm, visually legible, and useful to both non-specialists and engineers.
3. Context-hunter classification: L2 targeted feature. Reuse the minimal page/breadcrumb pattern from `work-through-conversations/index.html`, the data-driven card composition from `portfolio.html`, and the canonical-data/render split already used across the resume.
4. Dials: VARIANCE 3, MOTION 1, DENSITY 6. The new route may have a distinct systems-map visual language, but no animation or interaction is required to explain the model.
5. Preserve: minimal layout, CSS variable themes, semantic HTML, breadcrumb/include conventions, Jekyll SEO front matter, static/no-JavaScript operation, and mobile readability.
6. Evidence contract: name Mike as author of the general method; use `conceived circa 2021–2022; earliest timestamped exported evidence in 2023`; treat OpenTelemetry as a subordinate instrument; identify Simple Loop as Mike-originated; describe Fault Topography with careful authorship boundaries; publish only approved evidence and uncertainty.
7. Discretion contract: proof defaults to organization archetype + operating scale/constraints + situation/need + questions answered + artifacts/evidence + limitations. Do not name implementation organizations, coworkers, customers, internal repositories, platform labels, confidential counts, or politics.
8. Scale lenses: one regulated multi-team enterprise and one small acquired healthcare software organization. Their value is comparative applicability, not named-client prestige.
9. Responsive and accessibility: diagram has an explanatory caption and equivalent ordered text; all grids collapse to one column; no content overflow at 375px; reduced-motion needs no special handling because no motion is introduced.
10. Authorized files: `_data/panoramic_view.yml`, `panoramic-view/index.html`, `_sass/_p_panoramic_view.scss`, `assets/css/site.scss`, and focused layout tests. Global navigation and homepage remain TASK-260.04.

Added the user-attested enterprise durability signal in anonymized form: years after creation, colleagues unaware of Mike's authorship used documentation projected from the model to train him on two separate occasions. It is labeled as practical institutional-memory evidence, not converted into a business-impact metric.

Verification: Panoramic View YAML parsed with two scale applications and eight case-study sections; Jekyll built 1,038 pages with zero accessibility warnings; eight focused Playwright tests passed, including method content, implementation-name exclusions, accessible SVG naming, and 375px content-overflow checks; full `bundle exec rake validate` passed data, archive, generated freshness, repository hygiene, SEO/indexability, semantics, exports, SEO budgets, accessibility hooks, and HTML-Proofer link/script/image checks.

Reviewer findings: no blocker, major, or minor issues introduced. The public page names organization archetypes and operating constraints while omitting implementation employers, people, private paths, repositories, proprietary identifiers, topology counts, customers, and political narrative. Existing build warnings about generated export destination collisions and the pre-existing mobile global-nav clipping are outside this slice and remain assigned to TASK-260.04.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Published a public-safe Panoramic View field guide with Mike's authorship and evidence boundaries, the horizontal journey and vertical browser-to-backend wave, the Simple Loop of Discovery, supporting concepts, tool distinctions, enterprise and small-organization scale lenses, a fully structured anonymized founder-transition case study, an accessible original diagram, explicit limitations, and future work. Added the newly supplied proof that enterprise documentation became independent institutional memory years after creation.
<!-- SECTION:FINAL_SUMMARY:END -->
