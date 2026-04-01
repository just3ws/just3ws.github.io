# Task-009: Transcript Pipeline Consolidation

**Status:** To Do
**Priority:** Medium

## Description
The transcript pipeline is currently fragmented across multiple scripts in `bin/` (audit, normalize, import, report). This makes transcript management difficult and error-prone.

## Acceptance Criteria
- [ ] Implement a cohesive "Archive Manager" for all transcript-related tasks.
- [ ] Consolidation of scripts like `audit_transcripts.rb` and `normalize_transcripts.rb`.
- [ ] Standardized logging and error reporting for transcript processing.
- [ ] Integration with the new Rakefile/CLI tool for unified execution.
