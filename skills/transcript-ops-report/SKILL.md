---
name: transcript-ops-report
description: Operational reporting for transcript ingestion batches, tracking intake volume, mapping confidence, skips, and corpus growth over time.
---

# Transcript Ops Report

## Purpose
Track transcript ingestion progress across days/weeks.

## Use When
- Monitoring backlog reduction and mapping quality.
- Creating weekly status updates.

## Data Source
- `tmp/transcript-import-report.json`
- `tmp/transcript-import-report.md`
- `_data/video_assets.yml`
- `_data/transcripts/*.yml`

## Report Outputs
- Batch totals:
  - discovered files
  - mapped files
  - low-confidence files
  - skipped existing
  - newly written transcripts
- Corpus totals:
  - assets with transcript IDs
  - transcript files on disk
- Drift signals:
  - orphan files
  - duplicate transcript reuse

## Commands
- `./bin/transcripts dry-run --source-dir /Volumes/Dock_1TB/vimeo/outbox`
- `./bin/transcripts audit`
