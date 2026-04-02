---
id: TASK-009
title: Consolidate Transcript Pipeline
status: Done
assignee: []
created_date: '2026-04-01 15:29'
updated_date: '2026-04-02 01:23'
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

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Consolidated the fragmented transcript management scripts into a unified system.
- Created `src/generators/archive_manager.rb` which encapsulates text normalization rules and a robust `TranscriptAuditor` class.
- Replaced `bin/audit_transcripts.rb` and `bin/normalize_transcripts.rb` with integrated Rake tasks: `rake transcript:audit` and `rake transcript:normalize`.
- Standardized logging and error reporting for transcript audits.
- Verified that the new system correctly identifies missing files, orphan files, and duplicate transcript usage.
- The pipeline now supports a dry-run mode by default and an apply mode via the `APPLY=true` environment variable.
- This fulfills all acceptance criteria for TASK-009.
<!-- SECTION:FINAL_SUMMARY:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->
