---
id: TASK-003
title: Upgrade to Jekyll 4.x
status: Done
assignee: []
created_date: '2026-04-01 15:29'
updated_date: '2026-04-01 17:04'
labels: []
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The project is currently using Jekyll 3.10.0. Upgrading to Jekyll 4.x provides substantial performance gains and better collection support.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Update `Gemfile` to use Jekyll 4.x.
- [ ] #2 Run `bundle update` and resolve dependency conflicts.
- [ ] #3 Verify existing custom plugins and templates are compatible with Jekyll 4.
- [ ] #4 Verify site builds correctly and matches Jekyll 3 output.
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Upgraded Jekyll from 3.10.0 to 4.3.4.
- Updated Gemfile to use Jekyll ~> 4.3.4 and jekyll-sass-converter ~> 3.0.
- Fixed Liquid 4 syntax errors in bin/generate_interview_pages.rb by simplifying logic and standardizing spacing.
- Verified build is successful and clean.
- Environment currently remains on Ruby 3.4.8 as Ruby 4.0.0 was not available in the shell path.
<!-- SECTION:FINAL_SUMMARY:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->
