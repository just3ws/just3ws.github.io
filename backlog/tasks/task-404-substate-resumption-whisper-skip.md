---
id: TASK-404
title: "Implement Substate Resumption and Skip for Whisper STT and Audio DSP on Requeue"
status: Pending
category: media
created_date: '2026-10-26 02:41'
type: performance
priority: high
tags:
  - media-pipeline
  - substate-resumption
  - whisper-stt
  - gpu-conservation
---

## Description
<!-- SECTION:DESCRIPTION:BEGIN -->
Closes Gap 3 by restoring granular substate resumption in `ProcessMediaAssetJob`:

1. **Root Cause**:
   - When a job fails at step 6 (`youtube_upload`) or step 7 (`playlist_assignment`) due to network glitch or quota exhaustion, requeuing re-extracts audio with FFmpeg and re-invokes `ztranscribe` Whisper Metal GPU inference from scratch.
   - Wastes 10 to 15 minutes of Apple Silicon GPU compute and thermal capacity re-transcribing text that already exists in the database.

2. **Resolution Algorithm**:
   - Check if `asset.transcript_text.present?` and `asset.transcript_vtt.present?`.
   - If present, skip both FFmpeg audio extraction and `ztranscribe` GPU execution, jumping straight to metadata resolution and YouTube upload.
   - If scratch WAV already exists on disk, reuse it rather than re-extracting from the master video.
<!-- SECTION:DESCRIPTION:END -->

## Execution Plan
<!-- SECTION:PLAN:BEGIN -->
- [ ] Step 1: Add substate resumption guards in `ProcessMediaAssetJob#perform` checking `asset.transcript_text.present?`.
- [ ] Step 2: Reuse existing scratch WAV if already extracted.
- [ ] Step 3: Record `transcription_reused` event in asset lifecycle history.
- [ ] Step 4: Write unit specs verifying Whisper STT is skipped when transcripts exist.
- [ ] Step 5: Verify test suite and fast validation pass cleanly.
<!-- SECTION:PLAN:END -->
