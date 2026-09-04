---
id: TASK-285
title: Publish UGtastic archive artifacts and operating loops
status: Done
assignee:
  - '@agent-just3ws'
created_date: '2026-09-04 16:02'
updated_date: '2026-09-04 16:38'
labels:
  - archive
  - public-surface
  - provenance
dependencies: []
references:
  - docs/public-artifact-curation-policy.md
  - docs/archive/oral-history-inventory-and-provenance.md
documentation:
  - docs/style-guide-and-canonical-naming.md
modified_files:
  - ugtastic/index.html
  - archive-atlas/index.html
  - assets/images/ugtastic-branding/ugtastic-760x333.png
  - assets/images/ugtastic-branding/header-logo.png
  - assets/images/ugtastic-branding/ugtastic-github-avatar.png
  - assets/images/ugtastic-branding/user-group-avatar-fallback.png
  - assets/images/ugtastic-branding/ugtastic-favicon.png
  - assets/images/ugtastic-branding/logo-small.png
  - assets/images/ugtastic-branding/ugtastic-outro-slate.png
  - assets/audio/ugtastic/life-of-riley.mp3
type: feature
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Create a public UGtastic archive artifacts page that presents recovered branding assets, badges, avatars, screenshots, audio, and public archive links. Keep the modernization process, Mike-authored quotes, formulas, and gates on the broader profile and case-study surfaces instead of the UGtastic exhibit.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Dedicated public UGtastic artifacts route is discoverable from an existing archive surface
- [x] #2 Recovered logos badges avatars screenshots and audio are presented with source-aware labels
- [x] #3 The UGtastic page stays focused on archive artifacts and links, without unrelated modernization methodology content
- [x] #4 Modernization quotes formulas diagrams and gates remain available on the broader profile and case-study surfaces
- [x] #5 Public surface contains no private contact data workplace secrets PHI or unnecessary personal detail
- [x] #6 Installed localhost route is verified after build
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [x] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Implemented /ugtastic/ as a focused public archive exhibit. The page features recovered UGtastic logos, identity marks, avatars, a user-group badge mark, dated screenshots, a local Life of Riley audio player, SoundCloud search, WHOIS Tech Community, GitHub, interview, timeline, and Archive Atlas links. Modernization quotes, formulas, diagrams, and gates remain on the profile and case-study surfaces. Source assets were selected from /Volumes/Dock_1TB/WITC and copied into the public repository only after filename and media inspection.

Confirmed direct SoundCloud provenance from Mike: https://soundcloud.com/ugtastic. Updated the exhibit's SoundCloud link from a search URL to the direct UGtastic profile.

Follow-up correction and enrichment: removed Creative Studios lockups from the public asset set; added direct SoundCloud widget and recovered UGtastic Outro slate. Added production evidence section based on Final Cut references to Life of Riley - reverse stereo, UGtastic Outro v2..11, named intro overlays, and 105 recovered interview MP3 exports.

Added an archive observatory to `/ugtastic/`: Liquid-driven interview-era count bars from `_data/timeline_archive.json`, four evidence-backed intersection cards, and a four-clock production-language map covering recording, production, preservation, and curation. Linked to `/timeline/` and `/archive-atlas/`. Rebuilt and reran semantic, SEO, TMI, and graphify checks.

Tooled `bin/analyze_ugtastic_audio.rb` to inspect the recovered 105-file MP3 export without transcription. Generated `_data/ugtastic_audio_inventory.json` with ffprobe metadata and conservative ffmpeg boundary candidates. Current aggregate: 105 stereo files, 20.28 hours, 100 at 44.1 kHz, 4 at 16 kHz, 1 at 48 kHz, 27 leading candidates, 4 trailing candidates. Integrated measured inventory and formula into `/ugtastic/`, with uncertainty boundaries stated explicitly. Rebuilt, reran semantic and SEO checks, reran TMI with 864 passes, refreshed graphify, and reinstalled localhost output.

Added `bin/analyze_ugtastic_production.rb` and `_data/ugtastic_production_analysis.json`. Compared 105 audio exports with 91 finished videos: 89 normalized filename joins, all 91 finished videos contain audio, and 20 Final Cut event files were inspected. Named Life of Riley and UGtastic Outro references appear in the event records; four event files contain intro overlay references. Page now labels confidence and keeps exact placement as an open waveform or spectral matching step.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Published a focused UGtastic archive exhibit with recovered branding assets, avatars, badge mark, screenshots, local audio player for Life of Riley, SoundCloud search, and archive links. Kept modernization quotes, formulas, diagrams, and gates on the profile and case-study surfaces. Verified build, installed localhost output, semantic validation, SEO validation, TMI audit, and source separation.
<!-- SECTION:FINAL_SUMMARY:END -->
