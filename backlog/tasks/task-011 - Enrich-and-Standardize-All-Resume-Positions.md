---
id: TASK-011
title: Enrich and Standardize All Resume Positions
status: In Progress
assignee: []
created_date: '2026-04-02 11:59'
updated_date: '2026-04-02 12:01'
labels: []
dependencies: []
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Audit and refactor all resume position data to move from simple strings to a results-oriented rich format. Rewrite highlights to explicitly state business impact and leadership roles.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 All YAML files in _data/resume/positions/ use the {text, impact, leadership} format.
- [ ] #2 Each position has at least one highlight with an 'impact' or 'leadership' field.
- [ ] #3 Resume renders correctly in both standard and ATS views with the new data.
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->
