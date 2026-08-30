---
id: TASK-267
title: IronLanguages podcast (2010) retrospective and digital archive integration
status: Todo
assignee: []
created_date: '2026-08-30 17:52'
updated_date: '2026-08-30 17:52'
labels:
  - archive
  - podcast
  - ironlanguages
  - history
milestone: Editorial Content Studio
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Preserve, structure, and highlight the historical 2010 IronLanguages Podcast archive (ironlanguages.net). Predating UGtastic and SCMC video recordings, this series documented the bleeding-edge era of dynamic languages on the CLR/DLR (IronRuby, IronPython, DLR, and open source .NET tooling). Key episodes include Shay "IronShay" Friedman (IronRuby Unleashed), Brian Hogan (Mentoring, Rumbling, Bridging), Rob Reynolds and Dru Sellers on the Nu Project (the genesis of Chocolatey), and Jeff Hardy (IronPython MVP).

### Forensic Artifact Discovery (`/Volumes/Dock_1TB`):
* **Local Ingestion Scripts:**
  - `bin/import_ironlanguages_local_snapshots.rb`
  - `bin/import_wayback_ironlanguages_posts.rb`
* **Historical Machine Backups & Google Buzz Archives:**
  - `/Volumes/Dock_1TB/mike/MBP 2010/Downloads/Just3Ws@gmail.com-backup/buzz/RT @ironlanguages- Episode 3- Interview with Brian.html`
  - `/Volumes/Dock_1TB/MBP 2010/Downloads/Just3Ws@gmail.com-backup/buzz/RT @ironlanguages- Episode 3- Interview with Brian.html`
  - `/Volumes/Dock_1TB/GAYLORD_BOX/BOX/MBP 2010/Downloads/Just3Ws@gmail.com-backup/buzz/RT @ironlanguages- Episode 3- Interview with Brian.html`
* **Wayback CDX & Snapshot Targets:**
  - `tmp/wayback-cdx/http___ironlanguages.net__.json`
  - `docs/wayback/targets-personal-ironlanguages-posts-local.txt`
  - `docs/wayback/targets-personal-ironlanguages-posts.txt`
  - `docs/wayback/targets-personal-ironlanguages.txt`
  - `docs/wayback/pending-ironlanguages-net.txt`
* **Republished Canonical Posts:**
  - `_posts/2010-06-28-minor-updates-itunes-and-ironlanguages-net.html`
  - `_posts/2010-06-24-episode-i-we-have-lift-off.html`
  - `_posts/2010-07-18-episode-2-chat-with-shay-ironshay-friedman.html`
  - `_posts/2010-08-09-upcoming-iron-languages-podcast-episodes.html`
  - `_posts/2010-08-28-episode-3-interview-with-brian-hogan.html`
  - `_posts/2010-09-30-interview-with-jeff-hardy.html`
  - `_posts/2010-09-30-the-lost-episode.html`
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Audit and index all IronLanguages podcast episodes, republished posts, and audio assets in `_data/interviews.yml` and career datalake.
- [ ] #2 Create a dedicated archival retrospective page (`/podcasts/ironlanguages/`) connecting the 2010 posts, audio streams, and historical context.
- [ ] #3 Document the bridge from .NET/IronRuby dynamic language exploration to the Chicago software craftsmanship movement.
- [ ] #4 Enforce strict zero em dashes and plain language prose across all written retrospective copy.
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 IronLanguages episodes are integrated into site navigation and search catalog.
- [ ] #2 `bundle exec rspec` and `bundle exec jekyll build` compile cleanly with 0 errors.
<!-- DOD:END -->
