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
