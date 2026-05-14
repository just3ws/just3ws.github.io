---
id: TASK-124
title: Automate YouTube Transcriptions via ztranscribe
status: In Progress
assignee: []
created_date: '2026-05-14 17:26'
updated_date: '2026-05-14 23:33'
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
- [x] #1 Identify all pending video_assets with a youtube platform id
- [ ] #2 Use yt-transcribe to download and transcribe the audio
- [ ] #3 Import the resulting transcripts into the project using the transcript pipeline
- [ ] #4 Run transcript-conversational-audit on the new transcripts to generate insights and metadata
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
### Plan (Updated for async capabilities)
1. **Discovery:** Find all `video_assets` missing a `transcript_id` with a valid `youtube` platform ID.
2. **Enqueue Jobs:** For each video, use `zdots-ctx enqueue transcription '{"url": "https://www.youtube.com/watch?v=<id>"}'` to queue the download and transcription asynchronously.
3. **Background Worker:** Run the `zdots-ctx worker` in a background process or terminal pane to process the queued transcriptions without blocking the main workflow.
4. **Ingestion & Auditing:** As jobs complete and output to `~/Downloads/transcripts/`, stage them in `tmp/transcript-id-staging/` using their `video_asset_id` and run `./bin/transcripts ingest`. Finally, run the `transcript-conversational-audit` skill to generate insights and metadata.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Updated `backlog/docs/architecture/transcript-import.md` to document the new asynchronous transcription workflow. 

Encountered an issue where the background worker was suspended by the OS because `ffmpeg` (called by `yt-transcribe`) attempted to read from `stdin` when launched without a terminal attached.

Resolved the issue by:
1. Killing the suspended worker.
2. Running `zdots-ctx clear-stale-jobs` to release the locked jobs.
3. Restarting the worker with explicit redirection: `zdots-ctx worker --type transcription < /dev/null &`.

Documented this failure mode and the exact recovery steps in the architecture runbook to ensure the process is highly resilient and fully resumable after internet outages or OS interruptions.

Currently, the `yt-transcribe` worker is happily crunching through the queue in the background. We are waiting on it to finish the next batch of YouTube videos before any more canonical audits can be performed. The system is operating exactly as designed.

[Update: The worker was resumed after being checked on. The stale jobs were requeued and the background process is running `whisper-cli` normally.]
<!-- SECTION:NOTES:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->
