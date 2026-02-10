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
- Validation:
  - `bin/pipeline ci` (CI core pipeline)
  - `bin/pipeline smoke` (browser smoke checks)
  - `bin/cibuild` (compatibility wrapper)

## Contact

- [mike@just3ws.com](mailto:mike@just3ws.com)
- [(847) 877-3825](tel:+18478773825)

## Social

- [LinkedIn](https://www.linkedin.com/in/just3ws)
- [GitHub](https://www.github.com/just3ws)

## Community

### Past Community Involvement

- [Chicago Code Camp (2010-2012)](https://web.archive.org/web/20121228074319/https://chicagocodecamp.com:80/)

## Development

```bash
# Install dependencies
bundle install

# Run local server
./bin/server

# Build and validate
./bin/pipeline ci

# Run smoke tests against built output
./bin/pipeline smoke
```

Pipeline grammar reference: `/docs/pipeline-grammar/`
