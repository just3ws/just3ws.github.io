---
id: TASK-266.02
title: Implement interactive outreach drawer and interview calibration scripts
status: To Do
assignee: []
created_date: '2026-09-06 16:58'
updated_date: '2026-09-06 16:58'
labels:
  - outreach
  - wayfinder
  - ux
  - briefs
dependencies: []
documentation:
  - docs/direct-hiring-manager-outreach-playbook.md
  - docs/career-strategy-audhd-principal-engineering.md
modified_files:
  - _layouts/brief.html
  - _sass/_brief.scss
parent_task_id: TASK-266
priority: high
type: enhancement
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Enhance `_layouts/brief.html` with an accessible, low-friction interactive outreach drawer and 30-second interview calibration scripts. Give hiring managers and technical leaders instant copy-paste access to peer-to-peer diagnostic outreach notes and structured interview positioning scripts directly on the rendered brief page.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Add a keyboard-operable slide-over drawer in `_layouts/brief.html` displaying direct outreach copy tailored to the company profile.
- [ ] #2 Render 30-second interview calibration scripts answering "tell me about yourself" and "why this role" calibrated to the target mandate.
- [ ] #3 Provide 1-click clipboard copy buttons with visual confirmation feedback.
- [ ] #4 Maintain strict accessibility: ARIA attributes, keyboard focus trapping when open, and Escape key dismissal.
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 Interactive outreach drawer is tested and functional across desktop and mobile viewports with zero layout regressions.
<!-- DOD:END -->
