# Mike Hall

Personal resume site at [just3ws.com](https://www.just3ws.com)

## Resume Formats

- [HTML](https://www.just3ws.com) - Primary resume
- [Full History](https://www.just3ws.com/history) - Complete career timeline
- [Plain Text](https://www.just3ws.com/resume.txt)
- [Markdown](https://www.just3ws.com/resume.md)

## Archives & Media

- [Home](https://www.just3ws.com/home/) - Navigation hub and context
- [Writing](https://www.just3ws.com/writing) - Technical posts
- [Interviews](https://www.just3ws.com/interviews/) - Interview archive
- [One-off Videos](https://www.just3ws.com/oneoffs/) - One-off talks and recordings
- [SCMC Videos](https://www.just3ws.com/scmc/) - Software Craftsmanship McHenry County archive

## Data & Automation

- Canonical interview timeline lives in `_data/interviews.yml`
- Canonical video assets live in `_data/video_assets.yml`
- Interview conference metadata lives in `_data/interview_conferences.yml`
- Interview community metadata lives in `_data/interview_communities.yml`
- One-off metadata lives in `_data/oneoff_videos.yml`
- SCMC metadata lives in `_data/scmc_videos.yml`
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

## Development

```bash
# Install dependencies
bundle install

# Run local server
./bin/server

# Build and validate
./bin/pipeline ci

# Run unit tests for generator/template logic
bundle exec rspec

# Run smoke tests against built output
./bin/pipeline smoke

# Generate semantic graph artifacts from rendered pages
./bin/pipeline semantic-graph

# Print sitemap coverage summary
./bin/pipeline sitemap
```

Pipeline grammar reference: `/docs/pipeline-grammar/`

## Analytics Events (GoatCounter)

GoatCounter page analytics are loaded globally in the `minimal` layout. Custom events are tracked via `assets/js/goatcounter-events.js` for:

- `mailto:` link clicks
- `tel:` link clicks
- Resume/file download-style links
- Outbound link clicks (including video hosts like YouTube/Vimeo)

Missed path tracking is captured in `404.html` as an event:

- `path`: `/event/missed-path`
- `title`: requested URL path + query string
