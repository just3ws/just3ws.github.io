---
id: TASK-410
title: Recover and publish reviewed local site work
status: In Progress
assignee: []
created_date: '2026-11-21T00:08:00Z'
updated_date: '2026-11-21T00:09:00Z'
labels: []
dependencies: []
documentation:
  - CONTEXT.md
  - docs/persona-review-council.md
type: chore
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Substantial site work remained uncommitted while master also diverged from origin. Recover both histories without losing released episodes and verify the public site before pushing.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Reviewed local work and upstream commits are preserved together.
- [ ] #2 Public boundary, generated output and installed HTTPS routes pass applicable checks.
- [ ] #3 Reviewed commits reach origin/master and the Pages deployment is verified.
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Inventory and preserve the dirty checkout and local-only commit; reconcile three upstream commits without dropping released episode records.
2. Run council review of public provenance, authorship, quarantine, and generated surfaces; fix concrete findings using existing contracts.
3. Regenerate, run full CI/public boundary checks, install localhost and smoke test affected HTTPS routes.
4. Commit exact reviewed paths, push master, monitor Pages deployment and verify production routes.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Initial remote fetch shows master diverged: three upstream commits and one local commit. Upstream includes episode infrastructure and Dashboard That Couldn't Hear; local untracked files overlap those paths. Preserve a local checkpoint before merging. Council found synthetic narrator misattribution and unsupported historical claims requiring correction.
<!-- SECTION:NOTES:END -->
