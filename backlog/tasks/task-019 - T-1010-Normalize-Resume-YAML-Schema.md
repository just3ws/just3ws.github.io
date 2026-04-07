---
id: TASK-019
title: 'T-1010: Normalize Resume YAML Schema'
status: In Progress
assignee: []
created_date: '2026-04-07 13:39'
updated_date: '2026-04-07 13:39'
labels: []
milestone: System Transformation Phase 2
dependencies: []
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Harden the resume data model by enforcing a strict context-action-impact schema across all professional positions.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 All files in _data/resume/positions/ contain 'context', 'action', and 'impact' fields
- [ ] #2 Update Liquid templates (ats-content.html, etc.) to render these new fields correctly
- [ ] #3 Validation script (or manual check) confirms no raw strings remain in legacy summary fields without structure
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->
