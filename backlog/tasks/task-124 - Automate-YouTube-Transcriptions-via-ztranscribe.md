---
id: TASK-124
title: Automate YouTube Transcriptions via ztranscribe
status: To Do
assignee: []
created_date: '2026-05-14 17:26'
labels: []
dependencies: []
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
A large number of interviews are still pending transcription. We will use the local system's `ztranscribe` capability (alias for `~/.config/zsh/recipes/yt-transcribe`) to download and transcribe these videos directly from YouTube.

### Plan
1. **Discovery:** Find all `video_assets` missing a `transcript_id` that have a valid `youtube` platform ID.
2. **Transcription:** For each video, run the local `yt-transcribe` pipeline: `~/.config/zsh/recipes/yt-transcribe https://www.youtube.com/watch?v=<id>`.
3. **Ingestion:** Move the resulting `.txt` transcripts from `~/Downloads/transcripts/` into a staging area and use the project's `./bin/transcripts` pipeline to ingest them into `_data/transcripts/`.
4. **Audit:** Run the `transcript-conversational-audit` skill (using `rake audit:prepare[slug]` and `rake audit:ingest[slug]`) to clean the transcript, separate speakers, and generate the durable insights and SEO metadata.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Identify all pending video_assets with a youtube platform id
- [ ] #2 Use yt-transcribe to download and transcribe the audio
- [ ] #3 Import the resulting transcripts into the project using the transcript pipeline
- [ ] #4 Run transcript-conversational-audit on the new transcripts to generate insights and metadata
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->
