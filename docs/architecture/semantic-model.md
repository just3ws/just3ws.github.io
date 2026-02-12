---
layout: minimal
title: Semantic Model
description: Canonical JSON-LD entity model and route-level schema contracts for rendered pages.
breadcrumb: Semantic Model
breadcrumb_parent_name: Docs
breadcrumb_parent_url: /docs/
---

{% include breadcrumbs.html %}

# Semantic Model

This page defines the canonical JSON-LD object model for rendered pages in `_site`.

## Canonical Entity IDs

- Person: `https://www.just3ws.com/id/person/mike-hall`
- Interview: `https://www.just3ws.com/id/interview/<interview-id>`
- VideoObject: `https://www.just3ws.com/id/video/<video-asset-id>`

IDs are deterministic and stable across builds.

## Supporting Governance Data

- Navigation contract: `_data/navigation.yml`
- Taxonomy vocabulary and allowed patterns: `_data/taxonomy.yml`

## Route Contracts

1. `/`
- must expose `Person` JSON-LD.

2. `/home/`
- must not expose resume `Person` JSON-LD.

3. `/videos/<id>/`
- must expose `VideoObject` with `@id`, `name`, `description`, `url`, `uploadDate`.

4. `/interviews/<id>/`
- must expose `Interview` with `@id`, `name`, `url`, `datePublished`, `interviewer`, and `mainEntityOfPage`.
- should link to canonical `VideoObject` by `subjectOf.@id` when asset data exists.

5. Index routes (`/interviews/`, `/videos/`, `/oneoffs/`, `/scmc/`)
- must expose `CollectionPage` with `mainEntity` set to `ItemList`.
- each `ListItem` should reference canonical IDs for the underlying entity.

6. Pages with visual breadcrumbs
- must expose `BreadcrumbList` JSON-LD aligned with rendered breadcrumb links.

7. Blog posts (`/YYYY/...`)
- must expose `Article` with `headline`, `datePublished`, `dateModified`, and `mainEntityOfPage.@id`.

## Validation and Artifacts

- Semantic contract validator: `bin/validate_semantic_output.rb`
- Coverage report: `tmp/schema-coverage-report.json`
- Graph artifact generator: `bin/visualize_semantic_graph.rb`
- Graph outputs:
  - `tmp/schema-graph.dot`
  - `tmp/schema-graph-summary.json`
- Snapshot page generator: `bin/generate_semantic_snapshot_page.rb`
- Snapshot page output: `docs/architecture/semantic-graph.md`

## Visualization Workflow

1. Refresh build and semantic artifacts:
   - `./bin/pipeline ci`
2. Generate snapshot docs page:
   - `./bin/pipeline semantic-snapshot`
3. Review published snapshot:
   - `/docs/architecture/semantic-graph/`
