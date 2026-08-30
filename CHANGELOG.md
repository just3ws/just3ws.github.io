# Changelog

All notable changes to the Mike Hall Technical Architecture & CareerOS platform (`just3ws.github.io`) are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [2.4.0] - 2026-08-30

### Added
- **100% YouTube Corpus Parity:** Migrated final 4 master MP4 videos directly from Vimeo to YouTube (`Igor Polevoy`, `Ralph Iden`, `Peter Krawczyk & Larry Ullman`, `Andy Maleh`), bringing all 212 historical recordings to 100% active YouTube video playback.
- **Accidental Deletion Recovery:** Restored Greg Baugues' RailsConf 2014 mental health interview (`d8c9ZQ7lAtY`), synchronized 421 timed caption cues, and attached the video to the channel's *RailsConf 2014 Interviews* playlist.
- **Dedicated SCMC YouTube Playlist:** Launched public playlist `PLC2qBbsulKdk` (*Software Craftsmanship McHenry County Archive*) preserving all 12 canonical meeting presentations.
- **IronLanguages Retrospective Hub (`/podcasts/ironlanguages/`):** Documented the 2010 podcast archive (`ironlanguages.net`) exploring dynamic languages on the CLR/DLR (IronRuby, IronPython) and the genesis of Chocolatey package management.
- **Podcast RSS 2.0 Feed (`/podcast.xml`):** Generated standards-compliant podcast feed with iTunes namespaces allowing developers to subscribe to the complete UGtastic oral history archive on any modern podcast app.
- **Backlog Milestones:** Created and persisted `TASK-267` (IronLanguages), `TASK-268` (Groupon HQ era), `TASK-269` (UGtastic lore shorts), and `TASK-270` (podcast feed).

### Changed
- Refined `/interviews/` and `/scmc/` navigation with links to the official YouTube playlist, IronLanguages hub, and podcast feed.
- Updated `bin/validate_last_modified_output.rb` to resolve category-nested Jekyll permalinks.
- Audited and verified 100% data parity: 191 unique speakers, 212 transcripts, 1,122 generated pages.

---

## [2.3.0] - 2026-08-29

### Added
- **4D System Cartography Framework:** Published architectural modernization methodology at `/panoramic-view/` and `/case-studies/`.
- **Career Datalake & MCP Server:** Released `career_datalake_mcp_server.rb` exposing 20+ years of career history, skills, and oral history via MCP tools.
- **Automated Resume Quality & ATS Suite:** Added `bin/validate_resume_quality.rb` and `bin/benchmark_ats_keywords.rb` asserting >=85% composite score across 5 Staff+/Principal archetypes.
- **Wayfinder Executive Brief Generator:** Built `bin/generate_executive_brief.rb` with vector PDF compilation for tailored 1-page recruiter packages.

---

## [2.2.0] - 2026-08-20

### Added
- **Chicago Craftsmanship Monograph:** Published `/chicago-craftsmanship/` documenting the regional tech uprising that sparked SCNA and the $10B+ Midwest tech surge.
- **Closed Caption WebVTT Pipeline:** Synchronized 211 WebVTT caption files with YouTube closed captions.

---

## [2.1.0] - 2026-08-10

### Added
- **Tailored Role Archetypes:** Data-driven generator producing 5 bespoke resume tiers (Principal Architect, Staff Platform, Observability Specialist, Founding Staff AI, Senior Rails).
- **Strict Prose Enforcement:** Integrated `no-em-dashes` validation rule across all resume, brief, and documentation files.

---

## [2.0.0] - 2026-07-01

### Added
- Complete rebuild on Jekyll 4.x with data-driven YAML architecture.
- Schema.org `Person` JSON-LD linked data integration.
- Full mobile-responsive accessibility and syntax-highlighted dark theme.
