---
id: TASK-001
title: Modernize Build Pipeline
status: Done
assignee: []
created_date: '2026-04-01 15:29'
updated_date: '2026-04-01 19:07'
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

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Modernized the build pipeline to eliminate the need for committing built artifacts.
- Updated `.github/workflows/validate.yml` to build the site from scratch using `./bin/pipeline build`.
- Updated `.github/workflows/deploy.yml` to build the site from scratch before deploying to GitHub Pages.
- Refined `.gitignore` to exclude generated content in `interviews/` and `videos/` while preserving root `index.html` files.
- Re-added root `index.html` files to git tracking.
- Verified that the build is clean and successful with Jekyll 4.3.4 and Ruby 3.4.8.
<!-- SECTION:FINAL_SUMMARY:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->
