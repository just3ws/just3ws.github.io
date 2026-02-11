---
layout: minimal
title: Architecture Overview
description: Repository structure and ownership boundaries for resume, archive, and generation workflows.
breadcrumb: Architecture Overview
breadcrumb_parent_name: Docs
breadcrumb_parent_url: /docs/
---

{% include breadcrumbs.html %}

# Architecture Overview

This repository has two primary product surfaces:

1. Resume surface (`/`, `/history/`, `/resume.txt`, `/resume.md`) optimized for stability.
2. Archive/site surface (`/home/`, `/interviews/`, `/videos/`, docs, taxonomy pages) optimized for ongoing iteration.

## Core Layout Boundaries

- `layout: resume` pages use the resume theme and avoid archive navigation chrome.
- `layout: minimal` pages use the site theme and include global site navigation.
- Shared head/meta logic lives in `_includes/head/base.html`.

## Content Sources

- Canonical data: `_data/*.yml`
- Transcript corpus: `_data/transcripts/*.yml`
- Derived/generated metadata: `_data/index_summaries.yml`, `_data/last_modified.yml`

## Generation Pipeline

`./bin/pipeline generate` orchestrates:

1. data synchronization (`sync_interview_asset_links.rb`)
2. context summary generation (`generate_context_summaries.rb`)
3. interview/video page generation
4. taxonomy page generation

## Ruby Generator Modules

Shared generator helpers now live under:

- `src/generators/core/meta.rb`
- `src/generators/core/text.rb`
- `src/generators/core/yaml_io.rb`

This keeps `bin/*` scripts as orchestration entrypoints and reduces repeated helper logic.
