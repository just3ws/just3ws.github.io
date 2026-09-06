---
id: TASK-266
title: Execute low-cognitive-load outreach for target Staff and Principal leads
status: To Do
assignee: []
created_date: '2026-08-30 09:15'
updated_date: '2026-09-06 16:58'
labels:
  - outreach
  - strategy
  - wayfinder
  - career-os
milestone: Career Intelligence & Market Activation
dependencies:
  - TASK-261
subtasks:
  - TASK-266.01
  - TASK-266.02
  - TASK-266.03
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Leverage the Direct Hiring Manager Outreach Playbook (`docs/direct-hiring-manager-outreach-playbook.md`) and the Wayfinder Executive Pitch Brief generator (`bin/generate_executive_brief.rb`) to generate custom 1-page executive pitch briefs and 65-word diagnostic outreach notes for high-conviction Principal/Staff leads from `wwworkremote.localhost` (e.g., Huntress, Coder, NextPatient, and enterprise telemetry targets).

Staged for active execution at a later date when market activation is prioritized. Tasked out into three concrete execution phases:
- `TASK-266.01`: Generate tailored executive briefs and vector PDFs for priority target leads
- `TASK-266.02`: Implement interactive outreach drawer and interview calibration scripts
- `TASK-266.03`: Wire cross-repo job-lead messaging and pipeline peer mutex
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Generate tailored executive briefs and vector PDFs for target leads (`ruby bin/generate_executive_brief.rb --company ...`).
- [ ] #2 Render interactive outreach drawers and 30-second interview calibration scripts in `_layouts/brief.html`.
- [ ] #3 Connect cross-repo job-lead messaging via the zdots message bus (`job-leads` channel) with `agent-wwworkremote`.
- [ ] #4 Track outreach pipeline status in `CareerOS::PeerMutex` and `docs/direct-hiring-manager-outreach-playbook.md`.
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 All target brief surfaces render cleanly on `just3ws.localhost/exports/briefs/`.
- [ ] #2 ATS match score and claim verification remain >= 85.0% and 0 em dashes.
<!-- DOD:END -->
