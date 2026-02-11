---
layout: minimal
title: Domain Migration
description: Legacy domain migration and redirect-log workflow.
breadcrumb: Domain Migration
breadcrumb_parent_name: Docs
breadcrumb_parent_url: /docs/
---

{% include breadcrumbs.html %}

# Domain Migration

This workflow supports legacy-domain migration while preserving visibility into inbound traffic patterns before final redirect policy is locked.

## Primary Policy

- Canonical production domain: `https://www.just3ws.com`
- Legacy domains should be fronted by Cloudflare and redirected with `301` to the canonical domain.
- Redirects must preserve path and query string.

## Configuration Source

- Migration config file: `_data/domain_migration.yml`
- Key fields:
  - `primary_domain`
  - `legacy_domains[].domain`
  - `legacy_domains[].status` (`observe_only` or `redirect_enforced`)
  - `legacy_domains[].preserve_path_query`

## Cloudflare Rule Shape

For each legacy domain:

1. Enable proxying through Cloudflare.
2. Create a redirect rule matching host.
3. Target URL expression:
   - `https://www.just3ws.com${uri}`
4. Status code: `301`.
5. Preserve query string.

## Log Capture

Export logs with at least:

- `ClientRequestHost`
- `ClientRequestPath`
- `ClientRequestQuery`
- `EdgeResponseStatus`
- `ClientCountry`
- `UserAgent`

Then summarize with:

```sh
ruby ./bin/report_legacy_domain_logs.rb path/to/cloudflare-export.csv
```

## Output Use

- Identify high-volume legacy routes.
- Identify paths that should get dedicated redirects.
- Monitor migration progress by host/path/request volume over time.
