---
id: TASK-265.03
title: Verify editorial prose and claim attribution across promoted content
status: To Do
assignee: []
created_date: '2026-09-06 16:58'
updated_date: '2026-09-06 16:58'
labels:
  - editorial
  - quality
  - audit
  - validation
dependencies: []
documentation:
  - docs/sme-delegation-and-multi-archive-playbook.md
  - docs/style-guide-and-canonical-naming.md
  - .agents/skills/no-em-dashes/SKILL.md
modified_files:
  - _posts/
  - conferences/
parent_task_id: TASK-265
priority: medium
type: task
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Execute strict editorial quality and claim attribution gating across all published retrospective essays and conference playlists. Enforce the 6-level claim attribution matrix, verify zero em dashes, and assert plain-language neuroinclusive readability.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Verify all historical assertions against the multi-archive primary source index (Level 1 contemporaneous evidence or Level 2 corroborated records).
- [ ] #2 Validate zero em dashes across all newly authored articles and playlists using `bundle exec rake validate:fast`.
- [ ] #3 Run `bundle exec rake test` to assert 0 broken internal links and valid markup structure.
- [ ] #4 Review via Persona Review Council editorial standards before setting publication status to live.
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 All promoted content artifacts pass validation with 0 failures, 0 broken links, and 0 em dashes.
<!-- DOD:END -->
