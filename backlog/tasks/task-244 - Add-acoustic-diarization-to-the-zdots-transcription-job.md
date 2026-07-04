---
id: TASK-244
title: Add acoustic diarization to the zdots transcription job
status: To Do
assignee: []
created_date: '2026-07-04 03:23'
labels:
  - pipeline
  - transcription
milestone: Interview Archive Pipeline
dependencies:
  - TASK-242
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
whisper-cli produces no speaker labels on its own. Add a WhisperX/pyannote acoustic-diarization step to the zdots `transcription` job so its output carries real speaker turns with start/end timestamps. Define the diarized transcript schema (speaker segments + timestamps) and extend bin/validate_data + specs. These acoustic turns become the ground truth the audit skill's heuristic speaker_map is fused onto in the next task.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 The transcription job emits acoustic speaker segments with start/end timestamps
- [ ] #2 The diarized transcript schema is defined and validated (bin/validate_data + spec)
- [ ] #3 It runs inside the existing zdots worker on Apple Silicon and is resumable
- [ ] #4 Standard/Turbo profile guidance is updated per the archive-forensics loop notes
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->
