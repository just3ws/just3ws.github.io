---
id: TASK-281
title: Add local public-surface review queue
status: In Progress
assignee: []
created_date: '2026-09-03 01:18'
updated_date: '2026-09-03 01:18'
labels:
  - security
  - editorial
  - privacy
dependencies: []
documentation:
  - bin/audit_public_surface.rb
  - docs/public-artifact-curation-policy.md
  - .gitignore
priority: high
type: feature
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Provide a local-only, redacted review queue for public-surface audit findings. The queue must let the author inspect evidence, preserve source links, and record a deliberate decision without placing private review material in the public site or git history. Strict publication checks must be able to distinguish unresolved findings from decisions that have been recorded.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 A local ignored report is generated in tmp and includes stable finding IDs, category, risk, confidence, source file and line, redacted excerpt, and decision state.
- [ ] #2 The report separates ordinary findings, author recollection quarantine, and source-backed recorded uncertainty.
- [ ] #3 The queue supports recording one of pending, verify, rewrite, generalize, recorded, or hold without storing raw sensitive values.
- [ ] #4 The strict gate fails for unresolved high-risk or quarantined findings and passes only when each such item has an allowed recorded decision.
- [ ] #5 The report contains actionable source links or file and line references for each item.
- [ ] #6 Regression tests cover report generation, stable IDs, redaction, and decision filtering.
- [ ] #7 Documentation explains where review occurs and confirms that the queue is local-only and excluded from publication.
- [ ] #8 Focused tests, lint, and the audit pass.
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Extend the auditor with a local report directory under tmp/public-surface-audit and write redacted JSON plus human Markdown output by default, while retaining stdout summaries.
2. Generate stable IDs from relative path, line, detector, and redacted evidence, without embedding raw sensitive values.
3. Add a small decision command or subcommand that validates IDs and allowed decisions, then stores only decision metadata in the ignored local report state.
4. Load decisions during strict evaluation. Treat high-risk and quarantined items as blocking until they have an explicit allowed decision; recorded transcript uncertainty remains informational.
5. Add source file and line references to the local report, plus clear local-only warnings.
6. Add RSpec coverage using temporary roots and report directories for generation, redaction, ID stability, and decision filtering.
7. Document the review workflow and run focused tests, Markdown lint, diff checks, normal audit, and strict behavior.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Task entered In Progress. Current CLI output is not a sufficient judgment surface. This task adds a local-only queue without publishing review findings.
<!-- SECTION:NOTES:END -->
