# Task-005: Separate Templates from Generator Logic

**Status:** To Do
**Priority:** Medium

## Description
Current Ruby scripts (e.g., `generate_interview_pages.rb`) have large blocks of hard-coded HTML/Liquid. This makes it hard to change styling or maintain clean code.

## Acceptance Criteria
- [ ] Move hard-coded HTML templates out of Ruby scripts.
- [ ] Use Jekyll `_layouts` and `_includes` for all markup generation.
- [ ] Ruby scripts/plugins should only handle data preparation and front matter assignment.
- [ ] Ensure that existing styles are maintained.
