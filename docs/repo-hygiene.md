---
layout: minimal
title: Repository Hygiene
description: Policy for pruning stale files, controlling legacy content, and preventing repository drift.
breadcrumb: Repository Hygiene
breadcrumb_parent_name: Docs
breadcrumb_parent_url: /docs/
---

{% include breadcrumbs.html %}

# Repository Hygiene

This policy keeps technical debt from accumulating in the repository by making file ownership, retention, and pruning rules explicit.

## File Classes

- `canonical`: source files required to generate public site output.
- `generated`: repo-tracked generated artifacts required by the site (`interviews/`, `videos/`, selected `_data` outputs).
- `reference`: implementation documentation required for maintainers.
- `ephemeral`: local reports and build outputs (`tmp/`, `_site/`) that are never canonical.
- `legacy`: historical context files kept for migration support, not as active source of truth.

## Retention Rules

1. Keep `canonical`, `generated`, and `reference` files in version control.
2. Exclude `ephemeral` files from commits unless explicitly required by policy.
3. Mark `legacy` directories in `_data/repo_hygiene.yml` and require an explicit retention decision.
4. Any new top-level file or directory must be declared in `_data/repo_hygiene.yml`.

## Pruning Workflow

1. Detect candidates with `ruby ./bin/validate_repo_hygiene.rb`.
2. Confirm that a candidate is not referenced by build scripts, templates, docs, or validators.
3. If uncertain, quarantine under an archive path before deletion.
4. Remove references and update `_data/repo_hygiene.yml` in the same commit.
5. Run `./bin/pipeline validate`.

## Current Decisions

- `career_history.md` is deprecated and must not be reintroduced.
- `context/interviews-history/` is legacy reference data and must stay explicitly marked as `review_required` until archival policy is finalized.

## CI Enforcement

`bin/validate_repo_hygiene.rb` is part of `./bin/pipeline validate` and enforces:

- top-level allowlist compliance
- deprecated-path blocking
- docs-link style consistency checks for `/docs/*` routes
