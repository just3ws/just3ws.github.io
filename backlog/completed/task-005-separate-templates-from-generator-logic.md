---
id: TASK-005
title: Separate Templates from Generator Logic
status: Done
assignee: []
created_date: '2026-04-01 15:29'
updated_date: '2026-04-01 19:59'
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

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Separated hard-coded templates from generator logic by moving them to dedicated Jekyll layouts.
- Created `_layouts/interview.html` for interview detail pages.
- Created `_layouts/video_asset.html` for video detail pages.
- Created `_layouts/taxonomy_index.html` and `_layouts/taxonomy_detail.html` for conference and community groupings.
- Updated Jekyll Generator plugins to use these new layouts, passing data via frontmatter.
- Removed large blocks of hard-coded HTML from Ruby scripts, significantly improving maintainability.
- Verified that styling and structure of generated pages are maintained.
- This fulfills all acceptance criteria for TASK-005.
<!-- SECTION:FINAL_SUMMARY:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->
