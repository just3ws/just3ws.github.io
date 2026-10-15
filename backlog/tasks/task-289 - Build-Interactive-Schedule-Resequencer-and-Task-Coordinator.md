---
id: TASK-289
title: Build Interactive Schedule Resequencer and Task Coordinator
status: Done
assignee:
  - '@antigravity'
created_date: '2026-10-15 01:45'
updated_date: '2026-10-15 02:04'
labels: []
dependencies:
  - TASK-287
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Managing a multi-week serialized release requires flexible calendar resequencing and explicit boundaries between automated background jobs and human creator actions. Creators need to easily reorder episodes, adjust dates, and track the status of both human and autonomous tasks.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Enhance publication schedule schema to classify each milestone as human-performed or autonomous
- [x] #2 Add resequence command to bin/youtube_pipeline.rb to safely shift and swap episode broadcast dates
- [x] #3 Add visual calendar resequencing controls in youtube/dashboard.html with status indicators
- [x] #4 Ensure validation passes and all dates remain consistent across publication_schedule.yml and episode dossiers
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [x] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Enhance publication_schedule.yml with executor classification (human vs autonomous).
2. Add resequence command to bin/youtube_pipeline.rb supporting swap and date shift.
3. Add visual executor badges and resequencing controls to youtube/dashboard.html.
4. Write RSpec unit and contract tests for schedule resequencing.
5. Verify 100% em-dash cleanliness and pass all validation gates.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Added executor classification to publication_schedule.yml, built resequence command in bin/youtube_pipeline.rb, and added visual indicators and shift buttons in youtube/dashboard.html. Verified with 21 RSpec tests.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Implemented schedule resequencing and executor classification. Verified with RSpec and 100% em-dash cleanliness.
<!-- SECTION:FINAL_SUMMARY:END -->
