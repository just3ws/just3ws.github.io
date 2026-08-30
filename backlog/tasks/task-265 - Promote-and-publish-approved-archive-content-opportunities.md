---
id: TASK-265
title: Promote and publish approved archive content opportunities
status: To Do
assignee: []
created_date: '2026-08-30 09:15'
updated_date: '2026-08-30 09:15'
labels:
  - content
  - editorial
  - backlog
milestone: Editorial Content Studio
dependencies:
  - TASK-257
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Review the 80 content candidates generated in `_data/content_opportunities.yml` and accessible via `https://just3ws.localhost/reports/content-opportunities/`. Promote approved candidates (derived historical essays, YouTube Shorts scripts, conference playlists, and LinkedIn durable wisdom posts) into active publication tasks using `bin/promote_content_opportunities.rb`.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Review and approve high-signal candidates in `_data/content_opportunities.yml` (e.g., Aaron Patterson ActiveRecord internals, Igor Polevoy JavaLite/ActiveJDBC history, Rob Reynolds Chocolatey/SCMC).
- [ ] #2 Execute `ruby bin/promote_content_opportunities.rb` to generate publication artifacts and tracking items.
- [ ] #3 Format promoted long-form essays into `_posts/` with Charter/Iowan Editorial Serif styling.
- [ ] #4 Verify all promoted artifacts pass the `no-em-dashes` validation suite and citation verification.
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 Approved content pieces are generated and indexed in site collections.
- [ ] #2 `bundle exec rake build` compiles without broken links or missing frontmatter.
<!-- DOD:END -->
