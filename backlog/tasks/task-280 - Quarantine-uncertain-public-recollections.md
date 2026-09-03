---
id: TASK-280
title: Quarantine uncertain public recollections
status: In Progress
assignee: []
created_date: '2026-09-03 01:06'
labels:
  - security
  - editorial
  - privacy
dependencies: []
documentation:
  - docs/public-artifact-curation-policy.md
  - bin/audit_public_surface.rb
priority: high
type: enhancement
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Extend the public-surface oversharing audit so uncertain recollections and claim-boundary language are separated into a quarantine stream for evidence review. The quarantine must preserve safe file and line references without presenting uncertain material as verified public fact, and must not expose sensitive values in its report.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Uncertainty and recollection findings are emitted in a distinct quarantine collection separate from privacy and operational findings.
- [ ] #2 Text and JSON reports identify quarantined material as requiring evidence review before publication.
- [ ] #3 Quarantine output contains redacted snippets and file and line references, never raw secrets or unredacted personal data.
- [ ] #4 The audit remains non-failing for uncertainty alone while credential-shaped findings retain the critical failure behavior.
- [ ] #5 Regression coverage proves safe uncertain historical language is quarantined and not classified as a credential or privacy breach.
- [ ] #6 The curation policy documents the quarantine meaning and the human decision required to promote or rewrite a recollection.
- [ ] #7 Focused tests, lint, and the live repository audit pass.
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->
