---
id: task-005
title: Separate Templates from Generator Logic
status: To Do
assignee: []
created_date: '2026-04-01 15:29'
labels: []
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Current Ruby scripts (e.g., `generate_interview_pages.rb`) have large blocks of hard-coded HTML/Liquid. This makes it hard to change styling or maintain clean code.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Move hard-coded HTML templates out of Ruby scripts.
- [ ] #2 Use Jekyll `_layouts` and `_includes` for all markup generation.
- [ ] #3 Ruby scripts/plugins should only handle data preparation and front matter assignment.
- [ ] #4 Ensure that existing styles are maintained.
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->
