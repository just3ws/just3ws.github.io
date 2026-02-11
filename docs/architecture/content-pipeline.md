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
- last-modified parity checks
- SEO/canonical and semantic/schema validators
- metadata reporting + HTMLProofer
