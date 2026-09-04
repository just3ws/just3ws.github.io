---
id: TASK-286
title: Reposition public identity as Staff Software Engineer
status: In Progress
assignee:
  - agent-just3ws
created_date: '2026-09-04 19:48'
updated_date: '2026-09-04 19:49'
labels:
  - positioning
  - resume
  - public-surface
dependencies: []
documentation:
  - CONTEXT.md
  - CODEX.md
  - docs/career-strategy-audhd-principal-engineering.md
  - docs/style-guide-and-canonical-naming.md
  - docs/persona-review-council.md
modified_files:
  - _data/resume/profile.yml
  - _data/resume/summary.yml
  - CODEX.md
  - docs/career-strategy-audhd-principal-engineering.md
  - docs/voice-actor.md
  - docs/public-artifact-curation-policy.md
  - docs/professional-public-topology-plan.md
  - docs/site-refresh/panoramic-view-positioning.md
  - bin/validate_resume_quality.rb
priority: high
type: enhancement
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The current public system anchors Mike Hall as Software Engineer and treats Staff as only role scope, while the strongest recurring career pattern is Staff Software Engineering rooted in hands-on software engineering. The positioning should make team-of-ICs collaboration, business-objective delivery, system understanding, safer change, and durable ownership the central identity without implying people management or erasing historical titles.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Canonical professional positioning names Staff Software Engineer as the identity and Software Engineer as the underlying profession
- [ ] #2 Positioning explains that Mike works across code, runtime systems, business boundaries, and teams of individual contributors
- [ ] #3 Positioning states that Mike helps IC teams accomplish business objectives through technical clarity, hands-on engineering, and durable ownership
- [ ] #4 Principal remains a scale-dependent target calibration rather than the default public identity
- [ ] #5 Historical employer titles and factual career evidence remain unchanged
- [ ] #6 Canonical profile and summary metadata, voice guidance, public curation guidance, career strategy, and relevant positioning brief agree with the new identity
- [ ] #7 Changed prose contains no em dashes and generated outputs are not hand-edited
- [ ] #8 Relevant validation is run and unrelated working-tree changes are preserved
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Update canonical public profile and summary so the default identity is Staff Software Engineer, explicitly rooted in software engineering.
2. Update the resume and voice contracts to describe Staff work as hands-on technical leadership across systems, business objectives, and teams of individual contributors, with no people-management implication.
3. Update career strategy, public curation guidance, topology, and Panoramic View positioning so Staff is the default identity and Principal is a scale-dependent target calibration.
4. Preserve all historical position titles and evidence, including Associate Director, Staff Engineer, Principal Architect, CTO, and other exact records.
5. Run prose checks and targeted resume/data validation. Inspect the diff to ensure unrelated generated timestamp changes remain untouched.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Resume validator had a stale hardcoded Software Engineer identity expectation. Updated it to assert Staff Software Engineer and report hands-on IC scope, which is part of keeping the canonical positioning contract internally consistent.
<!-- SECTION:NOTES:END -->
