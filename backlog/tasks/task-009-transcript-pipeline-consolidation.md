---
id: task-009
title: Consolidate Transcript Pipeline
status: To Do
assignee: []
created_date: '2026-04-01 15:29'
labels: []
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The transcript pipeline is currently fragmented across multiple scripts in `bin/` (audit, normalize, import, report). This makes transcript management difficult and error-prone.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Implement a cohesive "Archive Manager" for all transcript-related tasks.
- [ ] #2 Consolidation of scripts like `audit_transcripts.rb` and `normalize_transcripts.rb`.
- [ ] #3 Standardized logging and error reporting for transcript processing.
- [ ] #4 Integration with the new Rakefile/CLI tool for unified execution.
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->
