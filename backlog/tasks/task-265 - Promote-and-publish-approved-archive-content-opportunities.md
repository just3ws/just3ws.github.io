---
id: TASK-265
title: Promote and publish approved archive content opportunities
status: In Progress
assignee: []
created_date: '2026-08-30 09:15'
updated_date: '2026-09-06 16:58'
labels:
  - content
  - editorial
  - backlog
milestone: Editorial Content Studio
dependencies:
  - TASK-257
subtasks:
  - TASK-265.01
  - TASK-265.02
  - TASK-265.03
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Review the 80 content candidates generated in `_data/content_opportunities.yml` and accessible via `https://just3ws.localhost/reports/content-opportunities/`. Promote approved candidates (derived historical essays, YouTube Shorts scripts, conference playlists, and LinkedIn durable wisdom posts) into active publication tasks using `bin/promote_content_opportunities.rb`.

Staged for active writing and release at a later date. The promotion engine generated 10 initial candidate tasks (`task-candidate-*.md`), now organized into three structured implementation subtasks:
- `TASK-265.01`: Format promoted retrospective essays for posts publication
- `TASK-265.02`: Package promoted conference playlists into curated exhibits
- `TASK-265.03`: Verify editorial prose and claim attribution across promoted content
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Review and approve high-signal candidates in `_data/content_opportunities.yml` (4 core retrospective essays and 6 conference playlists approved).
- [x] #2 Execute `ruby bin/promote_content_opportunities.rb` to generate publication artifacts and tracking items (10 tasks generated).
- [ ] #3 Format promoted long-form essays into `_posts/` with Charter/Iowan Editorial Serif styling.
- [ ] #4 Verify all promoted artifacts pass the `no-em-dashes` validation suite and citation verification.
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 Approved content pieces are generated and indexed in site collections.
- [ ] #2 `bundle exec rake build` compiles without broken links or missing frontmatter.
<!-- DOD:END -->
