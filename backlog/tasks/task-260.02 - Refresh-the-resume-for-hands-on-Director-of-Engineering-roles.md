---
id: TASK-260.02
title: Refresh the resume for hands-on Director of Engineering roles
status: In Progress
assignee:
  - '@Codex'
created_date: '2026-08-10 17:11'
updated_date: '2026-08-10 17:21'
labels:
  - site-refresh
  - panoramic-view
dependencies:
  - TASK-260.01
modified_files:
  - index.html
  - resume.html
  - _data/resume/profile.yml
  - _data/resume/summary.yml
  - _data/resume/ats.yml
  - _data/resume/skills.yml
  - _data/resume/timeline.yml
  - _data/resume/earlier_experience.yml
  - _data/resume/positions/emr-bear.yml
  - _data/resume/positions/onemain.yml
  - _data/resume/positions/sk-holdings.yml
  - _data/resume/positions/phalanx-duel.yml
  - resume/positions/emr-bear/index.html
  - _includes/json-ld.html
  - _includes/schema-factory.html
  - bin/validate_exports.rb
  - tests/layout.spec.js
parent_task_id: TASK-260
priority: high
type: enhancement
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Rewrite the site's resume around Mike Hall's current hands-on Director of Engineering identity. Lead with recent, relevant systems and organizational leadership; present the short recent role accurately and without grievance; compress earlier history while keeping the full record accessible.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 The resume leads with a concise current positioning statement and role-relevant capabilities rather than a generic full-stack label.
- [ ] #2 Recent experience uses evidence-backed achievement bullets and presents the short direct-hire role as occurring during a founder transition whose leadership responsibility was later consolidated.
- [ ] #3 The 52-working-day period is used only where it demonstrates bounded velocity and does not imply unverified durability.
- [ ] #4 Earlier experience is compressed into a readable selected-history layer with access to the complete chronology.
- [ ] #5 The resume page renders accessibly at desktop and mobile sizes and relevant build and browser checks pass.
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Add the recent Development Manager role to canonical resume data and the full timeline using the established hyphenated position-id and detail-page patterns.
2. Rewrite profile, summary, recent enterprise role, current capabilities, and selected-history layering from the approved publication brief; keep exact 52-day language out of the main resume and reserve it for the later case study.
3. Reduce the ATS surface to three detailed recent roles and one current technical project; retain every earlier employer on `/history/`.
4. Update root and `/resume.html` metadata, structured knowledge terms, generated-export validation, and rendered test expectations.
5. Build and review desktop/mobile output; correct only regressions introduced by the bounded resume slice and record the known pre-existing mobile navigation issue for the later navigation task.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Resume Refresh Brief
1. Surface and job: root `/` and `/resume.html` are the primary hiring-decision and ATS surfaces for CTOs, VPs, hiring managers, recruiters, technical peers, and machine evaluators.
2. Design read: Reading this as a concise executive-technical resume for hands-on Director of Engineering evaluation, with a sober evidence-led editorial language, preserving machine readability, printability, exports, structured data, and the complete-history escape hatch.
3. Mode and dials: targeted evolution. VARIANCE 2→3 by adding a clearer current identity and stronger recent-to-earlier layering; MOTION 1→1 because a resume needs no narrative animation; DENSITY 7→6 by limiting detailed roles to the three most recent, one current project, and compressed selected history.
4. Evidence: current profile and metadata say Staff Software Engineer; detailed experience ends in February 2026; the recent Development Manager role is absent; older experience and two large project blocks dilute the current leadership signal; root, exports, position routes, JSON-LD, and `/history/` already provide strong reusable structure.
5. Preserve: root and `/resume.html` routes, contact header, export/download paths, semantic heading order, experience anchor, position-detail pattern, print path, JSON-LD, complete timeline, current themes, and GoatCounter link semantics.
6. Retire: Staff-only identity, unsupported absolute outcome language, detailed BenchPrep placement, the second selected-project block, and earlier-history wording that competes with current leadership.
7. Introduce: hands-on Director identity, evidence-backed Panoramic View summary, a factual recent direct-hire transition entry, U.S.–Mexico distributed-team leadership, bounded safety judgment, current skills taxonomy, and stronger progressive disclosure to the full timeline.
8. Responsive and motion: no new motion. Long role and method language must wrap without horizontal overflow; desktop and 375px screenshots required. Existing global mobile-nav clipping is tracked separately and is not introduced by this slice.
9. Authorized files: resume entry pages and metadata, canonical `_data/resume/` files, one new position-detail route, resume JSON-LD knowledge terms, export validator, and layout smoke expectations. Exclusions: global navigation, home page, Panoramic View public pages, shared visual theme, private evidence, generated `_site/`, and generated export sources.
10. Verification: inspect rendered root and position detail; validate generated TXT/JSON exports; run Jekyll build, focused Playwright layout tests with desktop and 375px screenshots, then the full CI pipeline because canonical data and metadata change.
<!-- SECTION:NOTES:END -->
