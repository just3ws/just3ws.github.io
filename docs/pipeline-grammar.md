---
layout: minimal
title: Pipeline Grammar
description: Command grammar and usage for the build, validation, and smoke pipeline.
permalink: /docs/pipeline-grammar/
breadcrumb: Pipeline Grammar
breadcrumb_parent_name: Docs
breadcrumb_parent_url: /docs/
---

{% include breadcrumbs.html %}

# Pipeline Grammar

Use the pipeline entrypoint for all build/validation workflow commands:

```bash
./bin/pipeline <command>
```

Grammar:

```ebnf
<command> ::= generate | build | validate | smoke | sitemap | ci | help
```

## Commands

- `generate`  
  Regenerates data-driven interview/video pages from canonical YAML in `_data/`.
- `build`  
  Runs runtime checks, regenerates pages, and builds `_site` via Jekyll.
- `validate`  
  Runs data integrity checks, SEO/canonical checks, semantic/schema checks, HTMLProofer, and resume/sitemap guardrails against `_site`.
- `smoke`  
  Runs Playwright smoke checks against built `_site`.
- `sitemap`  
  Prints a local sitemap coverage summary (counts by section + URL sample).
- `ci`  
  Full CI core pipeline (`build` + `validate`).
- `help`  
  Prints grammar and command help.

## Common Flows

```bash
# Full CI-equivalent local run
./bin/pipeline ci

# CI + browser smoke checks
./bin/pipeline ci
./bin/pipeline smoke

# Visualize sitemap coverage after a build
./bin/pipeline sitemap

# Build only (useful when iterating on templates/content)
./bin/pipeline build

# Validate existing _site output without rebuilding
./bin/pipeline validate
```

## Notes

- In CI, the workflow runs:
  - `./bin/pipeline ci`
  - `./bin/pipeline smoke`
- If your shell runtime does not match `.tool-versions`, pipeline commands fail fast with a version mismatch message.
- Build-time last-modified metadata:
  - `./bin/pipeline build` and `./bin/pipeline ci` generate git-based post last-modified values into `_data/last_modified.yml`.
  - Validation ensures each built article page exposes `dateModified` and matches generated values.

## Canonical Script Names

- Generators:
  - `bin/sync_interview_asset_links.rb`
  - `bin/generate_interview_pages.rb`
  - `bin/generate_video_asset_pages.rb`
  - `bin/generate_interview_taxonomy_pages.rb`
  - `bin/generate_last_modified.rb`
- Validators/reports:
  - `bin/validate_data_uniqueness.rb`
  - `bin/validate_data_integrity.rb`
  - `bin/validate_last_modified_output.rb`
  - `bin/validate_seo_output.rb`
  - `bin/validate_public_index_mode.rb`
  - `bin/validate_semantic_output.rb`
  - `bin/report_seo_metadata.rb`
  - `bin/visualize_sitemap.rb`
