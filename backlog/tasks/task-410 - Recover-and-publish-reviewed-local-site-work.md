---
id: TASK-410
title: Recover and publish reviewed local site work
status: In Progress
assignee: []
created_date: '2026-11-21T00:08:00Z'
updated_date: '2026-11-21T00:28:00Z'
labels: []
dependencies: []
documentation:
  - CONTEXT.md
  - docs/persona-review-council.md
modified_files:
  - _data/ramblin_aimblin_episodes.yml
  - >-
    _data/transcripts/ramblin-aimblin-hall-pass-to-roam-the-ghost-of-cardboard-cutouts.yml
  - _data/transcripts/ramblin-aimblin-the-dashboard-that-couldnt-hear.yml
  - _plugins/generate_video_assets.rb
  - spec/plugins/video_asset_generator_spec.rb
  - ai/series/ramblin-aimblin/the-67-year-obituary-of-the-programmer.md
  - series/ramblin-aimblin/index.html
  - _data/video_assets.yml
  - series/studio-workbench/ship-of-theseus.html
  - spec/pipeline/namespacing_and_ponytail_spec.rb
  - docs/studio-workbench-coderwall-briefing.md
  - obs/bookmarks/the-sound-above-rewatch.html
  - _includes/studio_workbench/coderwall_content.html
  - _data/panoramic_view.yml
type: chore
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Substantial site work remained uncommitted while master also diverged from origin. Recover both histories without losing released episodes and verify the public site before pushing.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Reviewed local work and upstream commits are preserved together.
- [ ] #2 Public boundary, generated output and installed HTTPS routes pass applicable checks.
- [ ] #3 Reviewed commits reach origin/master and the Pages deployment is verified.
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Inventory and preserve the dirty checkout and local-only commit; reconcile three upstream commits without dropping released episode records.
2. Run council review of public provenance, authorship, quarantine, and generated surfaces; fix concrete findings using existing contracts.
3. Regenerate, run full CI/public boundary checks, install localhost and smoke test affected HTTPS routes.
4. Commit exact reviewed paths, push master, monitor Pages deployment and verify production routes.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Initial remote fetch shows master diverged: three upstream commits and one local commit. Upstream includes episode infrastructure and Dashboard That Couldn't Hear; local untracked files overlap those paths. Preserve a local checkpoint before merging. Council found synthetic narrator misattribution and unsupported historical claims requiring correction.

Merged origin/master preserving both histories. Stash backup retained; all overlapping episode files matched upstream byte-for-byte except registry. Combined registry retains Hall Pass, upstream Dashboard recut, and local Programmer Obituary. Original tracked/untracked work backed up under /private/tmp before merge.

Full RSpec passed 307 examples. Corrected indentation introduced while combining episode registry; rebuilding. Focused generator/quarantine/stdin audit specs passed 22 examples.

Council corrections: label two synthetic narration transcripts and video asset records accurately; remove unsupported 1959 disappearance claim and unverified extended quotations from Programmer Obituary; cite primary NVIDIA, CFR, Salesforce earnings, Diamandis, GitHub keynote and original JRE records; distinguish code-writing forecasts, capability forecasts and hiring plans. Restore human role context for Amodei and Garman. Align current series guide with configured human editorial approval and no generated depictions of real people. Standard historical episode disclosure retained for reciprocal release contracts. YAML parse and git diff --check passed.

Installed HTTPS Chrome smoke passed 11 routes plus desktop/mobile screenshots. Production build passed 1186 pages. Read-only catalog privacy verification of all 20 newly added video IDs found 3 private records (BFA6MAwSgjY, 1cPmiLCkDrc, ffh3Gw7r4DA); retract those public artifacts and preserve local copies before release. Broad strict audit has preexisting unresolved findings; ordinary publication boundary scan reports zero critical findings.

Extended metadata-only verification to all catalog-matched site videos: 57 are private. Backed up affected public manifests/transcripts under /private/tmp/just3ws-private-retractions, then ran the existing SiteSyncService retraction workflow. Regenerate all dependent exports. SEO budget failure was a preexisting duplicate title for Studio Workbench Episode 01 and Ship of Theseus; shorten the latter title without altering the page body.

Final tests exposed a preexisting SwiftBar expectation missing its live rocket status; allow that supported status. Source patterns are the two identical router smoke assertions; no runtime behavior change. Re-run validation against a stable production build after localhost install is complete.
<!-- SECTION:NOTES:END -->
