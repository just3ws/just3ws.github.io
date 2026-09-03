---
id: TASK-280
title: Quarantine uncertain public recollections
status: Done
assignee: []
created_date: '2026-09-03 01:06'
updated_date: '2026-09-03 01:08'
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
- [x] #1 Uncertainty and recollection findings are emitted in a distinct quarantine collection separate from privacy and operational findings.
- [x] #2 Text and JSON reports identify quarantined material as requiring evidence review before publication.
- [x] #3 Quarantine output contains redacted snippets and file and line references, never raw secrets or unredacted personal data.
- [x] #4 The audit remains non-failing for uncertainty alone while credential-shaped findings retain the critical failure behavior.
- [x] #5 Regression coverage proves safe uncertain historical language is quarantined and not classified as a credential or privacy breach.
- [x] #6 The curation policy documents the quarantine meaning and the human decision required to promote or rewrite a recollection.
- [x] #7 Focused tests, lint, and the live repository audit pass.
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [x] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Add a first-class classification for claim-boundary findings so uncertainty is returned as quarantine data rather than mixed into ordinary risk findings.
2. Extend JSON output with a quarantine collection and text output with a clearly labeled quarantine section, retaining redacted file, line, and snippet evidence.
3. Keep exit behavior unchanged: uncertainty does not fail the audit, while critical credential findings do.
4. Add synthetic regression coverage for an uncertain historical sentence and confirm it is quarantined without being treated as a privacy breach.
5. Document the quarantine workflow in the public curation policy: verify against source, rewrite as recollection, or hold from publication.
6. Run focused RSpec, Markdown lint, diff checks, and the repository audit.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Task entered In Progress. This is a focused continuation of TASK-279 and keeps uncertain recollections distinct from direct privacy exposure.

Added first-class quarantine classification for uncertainty and recollection findings. JSON now separates findings from quarantine; text output labels quarantine and explains the three human outcomes.

Added --strict and rake audit:public_surface_strict. Normal audit exits successfully when only review candidates exist; strict publication gate fails while high-risk findings or quarantine remain.

Added policy guidance for authenticity without transgression and for safe, slow, soft review. The review process explicitly follows 'Slow is smooth. Smooth is fast.'

Verification: 5 focused RSpec examples pass, Markdown lint passes across 449 files, syntax and diff checks pass. Current built-surface scan covers 2,670 files, reports 1,188 non-quarantine findings, 5,553 quarantined passages, and 0 critical findings. Normal audit exits 0; strict gate exits 1 as intended because unresolved review and quarantine material remains.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Separated uncertain recollections from ordinary public-surface findings by adding a redacted quarantine stream to the audit's text and JSON outputs. Added a strict publication gate that fails on unresolved high-risk findings or quarantine while preserving non-failing diagnostic mode for ordinary review. Expanded the curation policy with authenticity without transgression and a safe, slow, soft review model grounded in the zdots PHI boundary principle. Synthetic regression coverage, Markdown lint, syntax checks, and the live built-surface audit pass. The strict gate remains intentionally red because the current archive still contains unresolved human review candidates.
<!-- SECTION:FINAL_SUMMARY:END -->
