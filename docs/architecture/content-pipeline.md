---
layout: minimal
title: Content Pipeline
description: How canonical data becomes generated pages and validated output.
breadcrumb: Content Pipeline
breadcrumb_parent_name: Docs
breadcrumb_parent_url: /docs/
---

{% include breadcrumbs.html %}

# Content Pipeline

## Inputs

- `_data/interviews.yml`
- `_data/video_assets.yml`
- `_data/interview_conferences.yml`
- `_data/interview_communities.yml`
- `_data/resources.yml`
- `_data/transcripts/*.yml`

## Generation Steps

1. link alignment: `bin/sync_interview_asset_links.rb`
2. summary derivation: `bin/generate_context_summaries.rb`
3. page generation:
   - `bin/generate_interview_pages.rb`
   - `bin/generate_video_asset_pages.rb`
   - `bin/generate_interview_taxonomy_pages.rb`

## Template Sources

- Generated taxonomy pages now render through:
  - `_templates/generated/interview-taxonomy-index.erb`
  - `_templates/generated/interview-taxonomy-detail.erb`

## Validation

`./bin/pipeline validate` runs:

- data uniqueness/integrity checks
- transcript integrity checks (`bin/audit_transcripts.rb`)
- resources registry validation
- last-modified parity checks
- SEO/canonical and semantic/schema validators
- metadata reporting + HTMLProofer

## Transcript Import Workflow

Use `bin/import_transcripts_from_outbox.rb` to onboard transcript files from an external directory.

1. Run a dry run to generate mapping reports:
   - `ruby ./bin/import_transcripts_from_outbox.rb --source-dir /Volumes/Dock_1TB/vimeo/outbox`
2. Review:
   - `tmp/transcript-import-report.json`
   - `tmp/transcript-import-report.md`
3. Apply high-confidence mappings:
   - `ruby ./bin/import_transcripts_from_outbox.rb --source-dir /Volumes/Dock_1TB/vimeo/outbox --apply`
4. Re-run validation:
   - `./bin/pipeline validate`

Shortcut wrapper:

- `./bin/transcripts dry-run --source-dir /Volumes/Dock_1TB/vimeo/outbox`
- `./bin/transcripts ingest --source-dir /Volumes/Dock_1TB/vimeo/outbox --auto-commit`
