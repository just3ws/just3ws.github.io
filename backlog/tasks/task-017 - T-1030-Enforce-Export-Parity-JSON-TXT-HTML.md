---
id: TASK-017
title: 'T-1030: Enforce Export Parity (JSON/TXT/HTML)'
status: In Progress
assignee: []
created_date: '2026-04-07 13:39'
updated_date: '2026-04-07 16:45'
labels: []
milestone: System Transformation Phase 2
dependencies: []
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Ensure perfect parity between the HTML resume, JSON export, and plain text version by centralizing the export logic around the normalized YAML schema.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 resume.json export is perfectly idempotent with _data/resume source of truth
- [ ] #2 resume.txt export matches normalized content without custom override drift
- [ ] #3 Build fails if exports diverge from source data structures
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->
