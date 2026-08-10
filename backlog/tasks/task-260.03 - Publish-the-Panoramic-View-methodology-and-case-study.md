---
id: TASK-260.03
title: Publish the Panoramic View methodology and case study
status: In Progress
assignee:
  - '@Codex'
created_date: '2026-08-10 17:11'
updated_date: '2026-08-10 18:23'
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
1. Extend canonical Panoramic View data with an actor definition, three-model reconciliation structure, explicit delta, and public-safe Rails proving-ground statement.
2. Update the methodology and homepage method block so human and agentic actors are treated consistently and the domain model is visible between business understanding and runtime behavior.
3. Refine the publication brief and product-marketing context with the same terminology and scope qualifications.
4. Update focused browser assertions, rebuild, inspect desktop/mobile renderings, run privacy and link/accessibility validation, and complete an independent review pass.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Follow-up L1 micro-brief
- Closest analogs: `_data/panoramic_view.yml` remains canonical; `panoramic-view/index.html` and `home/index.html` already iterate its public definition and governing questions; tests assert the same vocabulary.
- Chosen model: three realities—interested-party understanding, implemented domain model, and observed runtime behavior—with an explicit delta. Actor means any participant pursuing a goal through an interface, including a human or agentic AI system.
- Flagship context: complex Rails platform systems are the primary proving ground; traversal continues with equal fidelity beyond Rails through interfaces, services, integrations, infrastructure, data, and return paths.
- Main risk: turning intended completeness into an absolute claim. Preserve provenance, contradictions, and unknowns; describe completeness relative to the defined decision scope and available evidence.
- Authorized files: `_data/panoramic_view.yml`, `panoramic-view/index.html`, `_sass/_p_panoramic_view.scss`, `home/index.html`, `_sass/_p_home_refresh.scss`, `.agents/product-marketing-context.md`, `docs/site-refresh/panoramic-view-positioning.md`, and `tests/layout.spec.js`. Preserve routes, nav, metadata, case-study discretion, both themes, and no-motion behavior.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Published a public-safe Panoramic View field guide with Mike's authorship and evidence boundaries, the horizontal journey and vertical browser-to-backend wave, the Simple Loop of Discovery, supporting concepts, tool distinctions, enterprise and small-organization scale lenses, a fully structured anonymized founder-transition case study, an accessible original diagram, explicit limitations, and future work. Added the newly supplied proof that enterprise documentation became independent institutional memory years after creation.

Refined the public definition around business-to-system reconciliation and made its three governing questions explicit.
<!-- SECTION:FINAL_SUMMARY:END -->
