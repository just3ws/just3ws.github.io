# Task-001: Modernize Build Pipeline

**Status:** To Do
**Priority:** High

## Description
The current build pipeline relies on manual execution of shell scripts and committing generated artifacts (`_site/`, `interviews/`, `videos/`) to Git. This causes repository bloat and potential merge conflicts.

## Acceptance Criteria
- [ ] Create a GitHub Actions workflow for building and deploying to GitHub Pages.
- [ ] Configure the build to run on push to `main` or as a pull request check.
- [ ] Add `_site/`, `interviews/` (excluding `index.html`), and `videos/` (excluding `index.html`) to `.gitignore`.
- [ ] Verify that the built site matches the previous manually generated output.

## Technical Notes
- Use the official Jekyll deployment action if possible.
- Ensure all custom generator scripts in `bin/` are executed during the CI build before the Jekyll step.
