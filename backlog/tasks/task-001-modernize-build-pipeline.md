---
id: TASK-001
title: Modernize Build Pipeline
status: To Do
assignee: []
created_date: '2026-04-01 15:29'
labels: []
dependencies: []
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The current build pipeline relies on manual execution of shell scripts and committing generated artifacts (`_site/`, `interviews/`, `videos/`) to Git. This causes repository bloat and potential merge conflicts.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Create a GitHub Actions workflow for building and deploying to GitHub Pages.
- [ ] #2 Configure the build to run on push to `main` or as a pull request check.
- [ ] #3 Add `_site/`, `interviews/` (excluding `index.html`), and `videos/` (excluding `index.html`) to `.gitignore`.
- [ ] #4 Verify that the built site matches the previous manually generated output.
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

## Technical Notes
- Use the official Jekyll deployment action if possible.
- Ensure all custom generator scripts in `bin/` are executed during the CI build before the Jekyll step.
