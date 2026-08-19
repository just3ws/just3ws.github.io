# Mike Hall

## Quick Command Reference

| Action | Command | Description |
| :--- | :--- | :--- |
| **Local Dev Server** | `./bin/server` | Clean build + serve at `http://127.0.0.1:4000/` with live-reload |
| **Simple Site Build** | `bundle exec jekyll build` | Compile Jekyll static site to `_site/` |
| **Full Build Pipeline** | `./bin/pipeline build` | Regenerate data pages + compile Jekyll site |
| **Run Full CI** | `./bin/pipeline ci` | Full build, unit tests, and validation checks |
| **Run Smoke Tests** | `./bin/pipeline smoke` | Browser-based Playwright end-to-end smoke checks |

## Resume Formats

- [HTML](https://www.just3ws.com) - Primary resume
- [Full History](https://www.just3ws.com/history) - Complete career timeline
- [Advisory & Engagements](https://www.just3ws.com/engagements/) - Fractional engineering, 30–90 day system cartography audits, & advisory retainers
- [Plain Text](https://www.just3ws.com/resume.txt)
- **Markdown Exports** - See [`/exports/`](https://www.just3ws.com/exports/) for auto-generated markdown versions
  - Resume (`resume.md`), Portfolio (`portfolio.md`), History (`history.md`)

## Archives & Media

- [Home](https://www.just3ws.com/home/) - Navigation hub and context
- [Start Here](https://www.just3ws.com/start-here/) - Time-boxed archive entry paths
- [Archive Status](https://www.just3ws.com/archive-status/) - Metadata and transcript quality snapshot
- [Writing](https://www.just3ws.com/writing) - Technical posts
- [Interviews](https://www.just3ws.com/interviews/) - Interview archive
- [One-off Videos](https://www.just3ws.com/oneoffs/) - One-off talks and recordings
- [SCMC Videos](https://www.just3ws.com/scmc/) - Software Craftsmanship McHenry County archive

## Data & Automation

- Canonical interview timeline lives in `_data/interviews.yml`
- Canonical video assets live in `_data/video_assets.yml`
- Interview conference metadata lives in `_data/interview_conferences.yml`
- Interview community metadata lives in `_data/interview_communities.yml`
- Trusted source registry lives in `_data/resources.yml`
- Advisory engagement offerings live in `_data/engagements.yml`
- One-off metadata lives in `_data/oneoff_videos.yml`
- SCMC metadata lives in `_data/scmc_videos.yml`
- Canonical taxonomy vocabulary lives in `_data/taxonomy.yml`
- Primary navigation model lives in `_data/navigation.yml`
- Generated pages:
  - `bin/sync_interview_asset_links.rb`
  - `bin/generate_video_asset_pages.rb`
  - `bin/generate_interview_pages.rb`
  - `bin/generate_interview_taxonomy_pages.rb`
  - `bin/generate_context_summaries.rb`
- Shared generator helpers:
  - `src/generators/core/meta.rb`
  - `src/generators/core/text.rb`
  - `src/generators/core/yaml_io.rb`
- Validation:
  - `bin/pipeline ci` (CI core pipeline)
  - `bin/pipeline smoke` (browser smoke checks)
  - `bin/validate_data_uniqueness.rb` + `bin/validate_data_integrity.rb`
  - `bin/validate_archive_surfaces.rb`
  - `bin/validate_repo_hygiene.rb`
  - `bin/validate_metadata_completeness_budget.rb`
  - `bin/validate_last_modified_output.rb`

## Contact

- [mike@just3ws.com](mailto:mike@just3ws.com)
- [(847) 877-3825](tel:+18478773825)

## Social

- [LinkedIn](https://www.linkedin.com/in/just3ws)
- [GitHub](https://www.github.com/just3ws)

## Community

### Past Community Involvement (WaybackMachine)

- [Chicago Code Camp (2010-2012)](https://web.archive.org/web/20121228074319/https://chicagocodecamp.com:80/)
- [UGtastic](https://web.archive.org/web/20120414040704/https://www.ugtastic.com/)
- [UGl.st](https://web.archive.org/web/20140111160057/http://ugl.st/)

## Contributing

For information on local development, build pipelines, and repository standards, please see [CONTRIBUTING.md](CONTRIBUTING.md).

Full system documentation, operator runbooks, and CLI tooling guides are available in [docs/tooling-user-guide.md](docs/tooling-user-guide.md) and the [Docs Index](/backlog/docs/).

## Development Overview

The project is built with **Jekyll 4.x** and uses a data-driven architecture.

- **Canonical Data**: Lives in `_data/` (YAML).
- **Core Pipeline**: `./bin/pipeline` (Rake-based).
- **Automation**: Specialized Ruby generators in `_plugins/`.

## Analytics Events (GoatCounter)

GoatCounter page analytics are loaded globally in the `minimal` layout. Custom events are tracked via `assets/js/goatcounter-events.js` for:

- `mailto:` link clicks
- `tel:` link clicks
- Resume/file download-style links
- Outbound link clicks (including video hosts like YouTube/Vimeo)

Missed path tracking is captured in `404.html` as an event:

- `path`: `/event/missed-path`
- `title`: requested URL path + query string
