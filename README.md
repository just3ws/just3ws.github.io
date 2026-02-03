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
- [UGtastic](https://www.just3ws.com/ugtastic/) - Vimeo original interview archive
- [UGtastic Conferences](https://www.just3ws.com/ugtastic/conferences/) - Grouped by event
- [UGtastic Communities](https://www.just3ws.com/ugtastic/communities/) - Grouped by meetup or group
- [Vimeo Videos](https://www.just3ws.com/vimeo/) - One-off talks and recordings
- [SCMC Videos](https://www.just3ws.com/vimeo/scmc/) - Software Craftsmanship McHenry County archive

## Data & Automation

- UGtastic canonical data lives in `_data/ugtastic.yml`
- UGtastic community metadata lives in `_data/ugtastic_communities.yml`
- Vimeo one-off metadata lives in `_data/vimeo_videos.yml`
- Generated pages:
  - `bin/generate_ugtastic_pages.rb`
  - `bin/generate_ugtastic_community_pages.rb`
  - `bin/generate_vimeo_pages.rb`
- Validation:
  - `bin/validate_ugtastic.rb` (runs in CI)

## Contact

- [mike@just3ws.com](mailto:mike@just3ws.com)
- [(847) 877-3825](tel:+18478773825)

## Social

- [LinkedIn](https://www.linkedin.com/in/just3ws)
- [GitHub](https://www.github.com/just3ws)

## Community

### Presentations

- [Teach Yourself Beginning Community in 24 Months](https://www.pechakucha.org/presentations/teach-yourself-beginning-community-in-24-months-2)

### Past Community Involvement

- [Chicago Code Camp (2010-2012)](https://web.archive.org/web/20121228074319/https://chicagocodecamp.com:80/)

## Development

```bash
# Install dependencies
bundle install

# Run local server
./bin/server

# Build and validate
./bin/cibuild
```
