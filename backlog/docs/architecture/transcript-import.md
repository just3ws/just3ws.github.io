---
layout: minimal
title: Transcript Import
description: Runbook for importing transcript files and mapping them to canonical
  video assets.
breadcrumb: Transcript Import
breadcrumb_parent_name: Docs
breadcrumb_parent_url: "/backlog/docs/"
id: doc-008
---

{% include breadcrumbs.html %}

# Transcript Import

## Automated YouTube Transcription (Async)

For missing transcripts of videos hosted on YouTube, we use a local asynchronous pipeline powered by `zdots-ctx` and `whisper.cpp`.

1. **Enqueue Pending Videos:**
   Identify all pending `video_assets` with a YouTube ID and enqueue them to the local `zdots-ctx` worker.
   ```bash
   ./bin/batch_ztranscribe.rb
   ```
2. **Start the Background Worker:**
   Ensure the worker is running to process the queue asynchronously.
   ```bash
   zdots-ctx worker --type transcription
   ```
3. **Stage Completed Transcripts:**
   As the worker finishes downloading and transcribing to `~/Downloads/transcripts/`, map them back to their canonical `video_asset_id` and stage them for ingestion.
   ```bash
   ./bin/stage_completed_transcripts.rb
   ```
4. **Ingest Staged Transcripts:**
   Use the standard pipeline to ingest the staged files into `_data/transcripts/`.
   ```bash
   ./bin/transcripts ingest --source-dir tmp/transcript-id-staging --min-confidence 0.9 --auto-commit
   ```

## Canonical Model

- Transcript files live in `_data/transcripts/*.yml`.
- Video assets reference transcripts via `_data/video_assets.yml` `transcript_id`.
- `_data/transcripts.yml` is legacy and not used for active content.

## Commands

1. Audit current repository transcript integrity:
   - `./bin/transcripts audit`
2. Build ID-suffixed staging files (recommended for ambiguous filenames):
   - `./bin/transcripts prepare --source-dir /Volumes/Dock_1TB/vimeo/outbox --output-dir tmp/transcript-id-staging --min-confidence 0.8 --clean-output`
3. Run import in dry-run mode:
   - `./bin/transcripts dry-run --source-dir tmp/transcript-id-staging --min-confidence 0.9`
4. Review output reports:
   - `tmp/transcript-import-report.json`
   - `tmp/transcript-import-report.md`
5. Apply high-confidence mappings:
   - `./bin/transcripts ingest --source-dir tmp/transcript-id-staging --min-confidence 0.9`

## Direct Import Mode

If filenames already include explicit IDs and do not need staging:

- `./bin/transcripts dry-run --source-dir /Volumes/Dock_1TB/vimeo/outbox --min-confidence 0.9`
- `./bin/transcripts ingest --source-dir /Volumes/Dock_1TB/vimeo/outbox --min-confidence 0.9`

## Report Files

- Mapping report: `tmp/transcript-import-report.json`
- Human-readable summary: `tmp/transcript-import-report.md`

## Legacy sequence (kept for reference)

1. Run import in dry-run mode:
   - `./bin/transcripts dry-run --source-dir /Volumes/Dock_1TB/vimeo/outbox --min-confidence 0.9`
2. Review output reports:
   - `tmp/transcript-import-report.json`
   - `tmp/transcript-import-report.md`
3. Apply high-confidence mappings:
   - `./bin/transcripts ingest --source-dir /Volumes/Dock_1TB/vimeo/outbox --min-confidence 0.9`
4. Re-run pipeline validation:
   - `./bin/transcripts validate`

## One-Command Batch Mode

- Ingest + audit + validate + commit:
  - `./bin/transcripts ingest --source-dir /Volumes/Dock_1TB/vimeo/outbox --auto-commit`
- Ingest + audit + validate + commit + push:
  - `./bin/transcripts ingest --source-dir /Volumes/Dock_1TB/vimeo/outbox --auto-commit --auto-push`

## Notes

- Supported source file formats: `.txt`, `.md`, `.srt`, `.vtt`.
- Existing transcript files are not overwritten unless `--force` is supplied.
- Low-confidence mappings are never auto-applied; review those in the report first.
