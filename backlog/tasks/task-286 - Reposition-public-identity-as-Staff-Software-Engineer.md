---
id: TASK-286
title: Reposition public identity as Staff Software Engineer
status: In Progress
assignee:
  - agent-just3ws
created_date: '2026-09-04 19:48'
updated_date: '2026-09-04 19:51'
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
- [x] #1 Canonical professional positioning names Staff Software Engineer as the identity and Software Engineer as the underlying profession
- [x] #2 Positioning explains that Mike works across code, runtime systems, business boundaries, and teams of individual contributors
- [x] #3 Positioning states that Mike helps IC teams accomplish business objectives through technical clarity, hands-on engineering, and durable ownership
- [x] #4 Principal remains a scale-dependent target calibration rather than the default public identity
- [x] #5 Historical employer titles and factual career evidence remain unchanged
- [x] #6 Canonical profile and summary metadata, voice guidance, public curation guidance, career strategy, and relevant positioning brief agree with the new identity
- [x] #7 Changed prose contains no em dashes and generated outputs are not hand-edited
- [x] #8 Relevant validation is run and unrelated working-tree changes are preserved
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [x] #1 AC criteria is completed and the change has been verified
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

Positioning refinement: distinguish levels of software engineering abstraction from collaboration models. Do not describe teams of ICs as a system layer. State that Mike works from code and runtime behavior through business and organizational boundaries, and collaborates with IC teams to accomplish business objectives.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Repositioned the canonical public identity as Staff Software Engineer, explicitly rooted in hands-on software engineering. Updated the profile, summary, voice guide, resume contract, career strategy, public curation policy, topology plan, and Panoramic View positioning to describe work across code, runtime systems, business boundaries, and teams of individual contributors. Principal is now documented as a scale-dependent target calibration rather than the default identity. Updated the resume quality validator to enforce the new canonical title. Historical position titles and evidence were not changed. Verification: bundle exec rake validate:resume_quality passed; bundle exec jekyll build passed across 935 pages; rendered homepage and resume metadata, Schema.org jobTitle, and visible heading show Staff Software Engineer; prose audit passed with 0 errors and 0 AI-jargon matches; git diff --check passed. The strict public-surface audit reports existing pending archive-wide findings unrelated to this positioning change. The full pipeline build remains blocked only at the PDF exporter because the sandbox cannot bind its local listener.
<!-- SECTION:FINAL_SUMMARY:END -->
