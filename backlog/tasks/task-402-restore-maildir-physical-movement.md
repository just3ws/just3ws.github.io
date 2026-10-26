---
id: TASK-402
title: "Restore Ingress Maildir Physical File Movement and Companion Error Logging"
status: Completed
category: media
created_date: '2026-10-26 02:41'
type: feature
priority: high
tags:
  - media-pipeline
  - maildir-queue
  - physical-movement
  - error-quarantine
---

## Description
<!-- SECTION:DESCRIPTION:BEGIN -->
Closes Gap 1 by restoring 1:1 physical Maildir filesystem synchronization to the Rails 8 media-pipeline microservice:

1. **Physical Processing Lock**:
   - When `ProcessMediaAssetJob` acquires the job lock and starts processing, move the original video from `pending/` to `processing/` on disk.
   - Update `asset.file_path` to reflect the active `processing/` path.

2. **Physical Error Quarantine & Companion Log**:
   - On unhandled exception during audio extraction, transcription, or upload, move the video file from `processing/` to `failed/`.
   - Write `<filename>.error.log` alongside the video with complete error message, backtrace, and triage diagnostics.

3. **Physical Quota Cooldown Quarantine**:
   - When upstream YouTube API quota is exceeded (403 quotaExceeded), move the video to `blocked/`.
   - Write `<filename>.blocked.json` detailing the cooldown reset timestamp (2:00 AM CT / 00:00 PT).

4. **Requeue Filesystem Restoration**:
   - When an operator clicks Re-queue or calls `OperationsController#requeue`, relocate the quarantined file from `failed/` or `blocked/` back to `pending/`.
   - Purge companion `.error.log` and `.blocked.json` files.
<!-- SECTION:DESCRIPTION:END -->

## Execution Plan
<!-- SECTION:PLAN:BEGIN -->
- [x] Step 1: Implement physical Maildir directory helpers (`target_dir_for`, `move_file_safely`) in `ProcessMediaAssetJob`.
- [x] Step 2: Move video to `processing/` upon processing start and update `asset.file_path`.
- [x] Step 3: Move video to `failed/` on rescue and write companion `<filename>.error.log`.
- [x] Step 4: Move video to `blocked/` on quota block and write companion `<filename>.blocked.json`.
- [x] Step 5: Update `OperationsController#requeue` and `requeue_all_failed` to relocate files from `failed/` back to `pending/`.
- [x] Step 6: Write unit and request specs in `media-pipeline` verifying physical file movement and error log generation.
<!-- SECTION:PLAN:END -->
