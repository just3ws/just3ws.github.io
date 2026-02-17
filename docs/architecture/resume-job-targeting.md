---
layout: minimal
title: Resume Job Targeting
description: Strategy for job-specific resume permalinks using overlays on canonical timeline data.
breadcrumb: Resume Job Targeting
breadcrumb_parent_name: Docs
breadcrumb_parent_url: /docs/
---

{% include breadcrumbs.html %}

# Resume Job Targeting

Status: strategy documented for future implementation. Not currently implemented.

## Goal

Support shareable, print-friendly, job-specific resume links (for a specific role at a specific company) without forking or duplicating canonical resume data.

Examples:

- `/resume/jobs/staff-platform-acme-2026/`
- `/resume/jobs/principal-backend-contoso-2026/`

## Core Decision

1. Keep canonical resume data as the source of truth:
   - `_data/resume/timeline.yml`
   - `_data/resume/summary.yml`
   - `_data/resume/positions/*.yml`
2. Define job targets as overlays that selectively override canonical fields at render time.
3. Never clone full position records into job-specific files.

## Proposed Data Model

Store one file per target:

- `_data/resume/jobs/<job_slug>.yml`

Suggested shape (field-level replace/override only):

```yaml
id: staff-platform-acme-2026
title: Staff Platform Engineer - Acme
company: Acme
role: Staff Platform Engineer
created_at: 2026-02-17
sitemap: false
robots: noindex,follow

summary:
  text: >-
    Tailored summary for this role.

timeline:
  include:
    - onemain
    - sk-holdings
    - activecampaign
  exclude:
    - coderwall

positions:
  onemain:
    description: >-
      Override role summary for this target.
    achievements:
      highlights:
        - Tailored highlight one.
        - Tailored highlight two.
    skills:
      - OpenTelemetry
      - Incident Leadership
```

## Route and Rendering Strategy

1. Generate a static page per job target:
   - `/resume/jobs/<job_slug>/`
2. Render with the existing resume layout and include stack.
3. Build a merged view model:
   - start with canonical data
   - apply target overlay
   - render result
4. Printing should use the same page (`window.print`) as other resume pages.

## Canonical and Indexing Policy

Default policy for company/job-targeted resumes:

1. `robots: noindex,follow`
2. `sitemap: false`
3. Canonical can be self-referential or root; choose one policy and enforce it in validators.

Recommendation:

1. Use self-canonical for each job target page.
2. Keep noindex + sitemap false to avoid search indexing and stale public discovery.

## Guardrails

1. Root route semantics stay unchanged:
   - `/` remains the canonical default resume.
   - `/home/` remains the homepage surface.
2. Job overlays can only override approved display fields.
3. Unknown position IDs in overlays must fail validation.
4. Empty/invalid target outputs must fail generation.
5. Keep active targets small and intentional to avoid maintenance sprawl.

## Operational Workflow

1. Create `_data/resume/jobs/<job_slug>.yml`.
2. Run generation for job target pages.
3. Run `./bin/pipeline validate`.
4. Run `./bin/pipeline smoke` for resume and target routes.
5. Share `/resume/jobs/<job_slug>/` for that application.
6. Retire or archive old target files when no longer needed.

## Known Tradeoffs

1. More targeted pages increase editorial overhead.
2. Highlight-level edits are easiest when replacing full `highlights` arrays.
3. This is intentionally optimized for accuracy and maintainability, not unlimited variants.

