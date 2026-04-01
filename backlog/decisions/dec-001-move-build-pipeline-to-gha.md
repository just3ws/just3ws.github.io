# DEC-001: Move Build Pipeline to GitHub Actions

**Status:** Accepted
**Date:** 2026-04-01

## Context
The project currently commits build artifacts (`_site/`) and generated pages (`interviews/`, `videos/`) to the repository. This leads to:
- Rapid growth of the Git repository size.
- Frequent merge conflicts on generated content.
- Manual dependency on the local developer environment for deployments.

## Decision
We will move the build and deployment process to GitHub Actions.
- `_site/` and generated HTML pages will be added to `.gitignore`.
- GitHub Actions will execute the generator scripts and Jekyll build on every push to the `main` branch.
- The build artifacts will be deployed directly to GitHub Pages from the CI environment.

## Consequences
- Clean repository with only source files and canonical data.
- Automated, deterministic builds.
- No more manual build/commit cycle before pushing.
- History of `_site/` will no longer be tracked in Git.
