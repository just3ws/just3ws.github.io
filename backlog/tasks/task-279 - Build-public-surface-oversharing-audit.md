---
id: TASK-279
title: Build public-surface oversharing audit
status: In Progress
assignee: []
created_date: '2026-09-03 01:00'
labels:
  - security
  - editorial
  - privacy
dependencies: []
documentation:
  - CONTEXT.md
  - docs/public-artifact-curation-policy.md
  - docs/style-guide-and-canonical-naming.md
  - docs/agents/domain.md
priority: high
type: feature
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Create a repeatable repository-local audit for the public website surface. It must inspect publishable Markdown, YAML, templates, source data, generated public artifacts where available, and public-facing URLs or metadata without reading secrets or PHI-shaped files. Findings must be evidence-backed, redact sensitive values, classify risk and confidence, and provide actionable file and line references so the author can curate candid historical material without accidentally publishing private, identifying, speculative, or unnecessarily exposing details.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 The audit scans the documented public-content surfaces while explicitly excluding secrets, environment files, credentials, private handoffs, dependency/vendor trees, and other non-public inputs.
- [ ] #2 Findings classify at least risk level, confidence, category, file location, and a safe explanation of why review is recommended.
- [ ] #3 The report redacts matched values and never prints full tokens, credentials, email addresses, phone numbers, private URLs, or other sensitive values.
- [ ] #4 The audit distinguishes likely sensitive exposure from contextual language that is merely candid, historical, uncertain, or editorially awkward.
- [ ] #5 The tool supports a machine-readable report and a human-readable summary suitable for CI and local editorial review.
- [ ] #6 The tool has regression coverage for representative secret, personal-data, speculative-claim, and safe historical-content cases.
- [ ] #7 Usage and curation guidance are documented, including the rule that the tool flags review candidates and does not make publication decisions.
- [ ] #8 The implementation passes the repository's relevant build, lint, test, and safety checks without modifying unrelated work.
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->
