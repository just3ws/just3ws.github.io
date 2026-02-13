---
name: transcript-import-batch
description: Batch transcript ingestion workflow for /Volumes outbox sources into canonical _data/transcripts/*.yml, including dry-run mapping reports, confidence thresholds, apply mode, and validation.
---

# Transcript Import Batch

## Purpose
Run a repeatable, low-risk transcript ingestion batch.

## Use When
- New transcript files arrive in `/Volumes/Dock_1TB/vimeo/outbox`.
- You need to ingest many files quickly and safely.

## Inputs
- Source transcript directory (`.txt`, `.md`, `.srt`, `.vtt`)
- `_data/video_assets.yml`
- Existing `_data/transcripts/*.yml`

## Commands
1. Dry-run mapping report:
   - `./bin/transcripts dry-run --source-dir /Volumes/Dock_1TB/vimeo/outbox --min-confidence 0.9`
2. Apply high-confidence mappings:
   - `./bin/transcripts ingest --source-dir /Volumes/Dock_1TB/vimeo/outbox --min-confidence 0.9`
3. Optional auto-commit:
   - `./bin/transcripts ingest --source-dir /Volumes/Dock_1TB/vimeo/outbox --auto-commit`

## Safety Rules
- Dry-run first unless explicitly told otherwise.
- Do not overwrite existing transcript files unless `--force` is requested.
- Do not commit `tmp/` reports.

## Expected Artifacts
- `tmp/transcript-import-report.json`
- `tmp/transcript-import-report.md`
