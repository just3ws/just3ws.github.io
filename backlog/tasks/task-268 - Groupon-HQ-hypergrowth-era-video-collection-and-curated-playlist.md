---
id: TASK-268
title: Groupon HQ hypergrowth era (2011-2014) video collection and curated playlist
status: Todo
assignee: []
created_date: '2026-08-30 17:52'
updated_date: '2026-08-30 17:52'
labels:
  - archive
  - groupon
  - youtube
  - playlist
milestone: Editorial Content Studio
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Curate and publish the dedicated Groupon HQ Studio Collection preserving 35+ technical interviews recorded on-site at 600 W Chicago Ave during the peak of Chicago's hypergrowth era (2011-2014). Featured leaders include Brian Ray (ChiPy / Chia), Dave Hoover (Geekfest / Obtiva Apprenticeship), Trek Glowacki (Ember.js Core), Charles Oliver Nutter (JRuby Co-Lead), Aaron Bedra (Clojure security), Mike Busch, Sam Serpoosh, Michael Ficarra, Ryan Briones, and Ethan Gunderson.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Verify all 35+ Groupon HQ interviews are indexed with tags and transcripts in `_data/interviews.yml`.
- [ ] #2 Create and publish the public YouTube playlist 'Groupon HQ & Chicago Developer Culture (2011-2014)'.
- [ ] #3 Add a thematic filter and showcase section on `/interviews/` highlighting the Groupon studio archive.
- [ ] #4 Enforce strict zero em dashes and plain language prose across all playlist descriptions and page copy.
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 YouTube playlist is live and populated via `bin/lib/youtube_client.rb`.
- [ ] #2 Site build compiles cleanly with updated thematic navigation.
<!-- DOD:END -->
