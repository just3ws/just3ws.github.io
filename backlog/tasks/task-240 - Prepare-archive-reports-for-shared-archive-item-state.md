---
id: TASK-240
title: Prepare archive reports for shared archive item state
status: In Progress
assignee:
  - codex
created_date: '2026-06-28 16:24'
updated_date: '2026-06-28 16:24'
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
- [ ] #1 Archive status counts transcript assets that have either scalar content or structured turns.
- [ ] #2 Video metadata completeness marks transcript completeness true for structured turns with reasonable joined text length and false for invalid YAML.
- [ ] #3 Transcript loop reporting analyzes normalized text from either scalar content or joined turns.
- [ ] #4 Archive manager transcript auditing delegates transcript-content validity to `Generators::ArchiveState` without creating that module.
- [ ] #5 Invalid YAML parse failures are visible in status/report output where feasible and are not counted as complete.
- [ ] #6 Only the named generator/report files are edited unless a tiny targeted spec addition is necessary.
- [ ] #7 Targeted scripts or specs are run when feasible and results are recorded.
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Read the named scripts, archive manager, current generated YAML outputs, and nearby specs/helpers to identify current transcript-content and YAML-error handling patterns.
2. Patch only the named callers to require the forthcoming `src/generators/archive_state.rb` and call `Generators::ArchiveState` for transcript content checks/normalization/status where the caller needs shared state semantics.
3. Preserve script output shapes as much as possible while surfacing parse errors where feasible and ensuring invalid YAML is not counted as transcript-complete.
4. Run targeted scripts/specs that do not require regenerating large data, or run the scripts in a constrained way if feasible, then record results and any module assumptions.
<!-- SECTION:PLAN:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->
