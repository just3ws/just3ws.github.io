---
id: TASK-240
title: Prepare archive reports for shared archive item state
status: Done
assignee:
  - codex
created_date: '2026-06-28 16:24'
updated_date: '2026-06-28 16:29'
labels: []
dependencies: []
documentation:
  - AGENTS.md
modified_files:
  - bin/generate_archive_status.rb
  - bin/generate_video_metadata_completeness.rb
  - bin/report_transcript_loops.rb
  - src/generators/archive_manager.rb
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Update the archive status, video metadata completeness, transcript loop report, and archive manager transcript auditing callers so they use a forthcoming shared `Generators::ArchiveState` module when it is available at `src/generators/archive_state.rb`. The callers should treat structured transcript turns as valid transcript content, normalize text consistently for reports, and surface YAML parse failures instead of silently counting invalid transcripts as complete. Do not create the shared module in this task.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Archive status counts transcript assets that have either scalar content or structured turns.
- [x] #2 Video metadata completeness marks transcript completeness true for structured turns with reasonable joined text length and false for invalid YAML.
- [x] #3 Transcript loop reporting analyzes normalized text from either scalar content or joined turns.
- [x] #4 Archive manager transcript auditing delegates transcript-content validity to `Generators::ArchiveState` without creating that module.
- [x] #5 Invalid YAML parse failures are visible in status/report output where feasible and are not counted as complete.
- [x] #6 Only the named generator/report files are edited unless a tiny targeted spec addition is necessary.
- [x] #7 Targeted scripts or specs are run when feasible and results are recorded.
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Read the named scripts, archive manager, current generated YAML outputs, nearby transcript examples, and the collaborator-provided `src/generators/archive_state.rb` API.
2. Patch only the named callers to require `src/generators/archive_state.rb` and use the state-object API: `Generators::ArchiveState.for_path`/`for_id`, `state.has_transcript?`, `state.text`, `state.invalid?`, and `state.load_error`.
3. Preserve existing report shapes while adding parse-error counts/details where feasible and ensuring invalid transcript YAML is not counted as complete.
4. Avoid regenerating `_data` or `tmp` reports; verify with syntax checks, read-only count probes, the archive auditor path, and the collaborator's focused ArchiveState spec.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Implemented the caller-side ArchiveState integration in the four requested files only. `src/generators/archive_state.rb` appeared during the turn as collaborator work; I read its public API and did not edit it. Verification included Ruby syntax checks for all four modified files, read-only state/count probes, a read-only `TranscriptAuditor` run, and `bundle exec rspec spec/src/generators/archive_state_spec.rb`.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Updated archive/report callers to consume the shared archive state API instead of directly inspecting `transcript['content']`.

Changed files:
- `bin/generate_archive_status.rb`: counts assets whose transcript state has text from either legacy content or structured turns; records transcript parse errors in the generated status payload.
- `bin/generate_video_metadata_completeness.rb`: rates transcript completeness from `ArchiveState` text, so structured turns can be complete when long enough; invalid transcript YAML becomes a partial transcript rating with an error field and summary count.
- `bin/report_transcript_loops.rb`: analyzes `ArchiveState` text for either content or joined turns and includes parse-error counts/details in JSON/Markdown reports.
- `src/generators/archive_manager.rb`: delegates missing-content detection to `ArchiveState` and uses invalid state errors for invalid transcript files.

No generated `_data` or `tmp` reports were regenerated. Verification: four `ruby -c` syntax checks passed; read-only probes found `assets_with_transcript_content=195`, `with_transcript_complete_probe=193`, `short_transcripts_probe=2`, `transcript_parse_errors=1`; archive auditor read-only run reported `missing_files=0 missing_content=0 invalid_files=1`; `bundle exec rspec spec/src/generators/archive_state_spec.rb` passed with 8 examples.
<!-- SECTION:FINAL_SUMMARY:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [x] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->
