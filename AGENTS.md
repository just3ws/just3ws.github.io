# Project Agent Instructions

## Registered Skills
Use these skills by default for this repository:

1. `gh-fix-ci` - Diagnose and fix failing GitHub Actions checks.
2. `gh-address-comments` - Process and resolve PR review comments.
3. `playwright` - Run browser-based smoke checks and regression checks.
4. `screenshot` - Capture visual evidence for UI regressions.
5. `security-best-practices` - Run focused security reviews (JS/TS/Ruby-adjacent patterns).
6. `security-threat-model` - Produce threat models for pipeline/content flows.
7. `transcript-import-batch` - Batch ingest transcript files from outbox with dry-run/apply + validation workflow.
8. `transcript-review-gate` - Review low-confidence transcript mappings before apply.
9. `transcript-quality-check` - Audit transcript integrity and content quality in canonical data.
10. `transcript-ops-report` - Summarize transcript ingestion throughput and corpus growth.

## GitHub Pages / Pipeline Focus
For this site, prioritize:

1. CI reliability and reproducibility (Ruby/Bundler parity).
2. Jekyll build + internal link validation as required checks.
3. Smoke testing key pages via Playwright before merge.

## SEO + HTML Standards Guidance
There is no dedicated curated skill currently installed for HTML standards or SEO architecture.
Use this stack instead:

1. `playwright` for navigation/indexability smoke tests.
2. Jekyll plugins and templates (`jekyll-seo-tag`, sitemap, metadata includes) for structured SEO output.
3. CI checks (`html-proofer` + targeted assertions) for broken links and markup regressions.
