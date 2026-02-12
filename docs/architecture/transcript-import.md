---
layout: minimal
title: Transcript Import
description: Runbook for importing transcript files and mapping them to canonical video assets.
breadcrumb: Transcript Import
breadcrumb_parent_name: Docs
breadcrumb_parent_url: /docs/
---

{% include breadcrumbs.html %}

# Transcript Import

## Canonical Model

- Transcript files live in `_data/transcripts/*.yml`.
- Video assets reference transcripts via `_data/video_assets.yml` `transcript_id`.
- `_data/transcripts.yml` is legacy and not used for active content.

## Commands

1. Audit current repository transcript integrity:
   - `ruby ./bin/audit_transcripts.rb`
2. Run import in dry-run mode:
   - `ruby ./bin/import_transcripts_from_outbox.rb --source-dir /Volumes/Dock_1TB/vimeo/outbox`
3. Review output reports:
   - `tmp/transcript-import-report.json`
   - `tmp/transcript-import-report.md`
4. Apply high-confidence mappings:
   - `ruby ./bin/import_transcripts_from_outbox.rb --source-dir /Volumes/Dock_1TB/vimeo/outbox --apply`
5. Re-run pipeline validation:
   - `./bin/pipeline validate`

## Notes

- Supported source file formats: `.txt`, `.md`, `.srt`, `.vtt`.
- Existing transcript files are not overwritten unless `--force` is supplied.
- Low-confidence mappings are never auto-applied; review those in the report first.
