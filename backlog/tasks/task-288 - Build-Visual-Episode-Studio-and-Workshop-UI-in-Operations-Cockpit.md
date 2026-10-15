---
id: TASK-288
title: Build Visual Episode Studio and Workshop UI in Operations Cockpit
status: In Progress
assignee:
  - '@antigravity'
created_date: '2026-10-15 01:45'
updated_date: '2026-10-15 01:51'
labels: []
dependencies:
  - TASK-287
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
While headless scripts manage file data, creators need an intuitive visual studio to workshop episode narrative arcs, preview script copy, edit host recollections, and attach research links without manually editing raw YAML files.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Embed interactive Episode Workshop tab into youtube/dashboard.html with split-screen editor and script previewer
- [ ] #2 Provide dedicated input sections for plot, theme, tone, key concepts, human story marginalia, and research attachments
- [ ] #3 Provide live copy preview of the compiled 6-act teleprompter script and YouTube description
- [ ] #4 Support direct export of modified episode dossier to local files and clipboard
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Include episode dossiers in telemetry payload via bin/youtube_pipeline.rb.
2. Build interactive Episode Workshop and Studio split-screen editor in youtube/dashboard.html.
3. Provide live copy preview for 6-act teleprompter scripts, YouTube description, and copy-to-clipboard actions.
4. Add RSpec tests in spec/youtube/youtube_pipeline_spec.rb covering the workshop studio.
5. Verify 100% em-dash cleanliness and run all validation gates.
<!-- SECTION:PLAN:END -->
