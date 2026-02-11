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

5. Blog posts (`/YYYY/...`)
- must expose `Article` with `headline`, `datePublished`, `dateModified`, and `mainEntityOfPage.@id`.

## Validation and Artifacts

- Semantic contract validator: `bin/validate_semantic_output.rb`
- Coverage report: `tmp/schema-coverage-report.json`
- Graph artifact generator: `bin/visualize_semantic_graph.rb`
- Graph outputs:
  - `tmp/schema-graph.dot`
  - `tmp/schema-graph-summary.json`
