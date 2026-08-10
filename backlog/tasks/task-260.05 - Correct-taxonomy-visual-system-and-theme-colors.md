---
id: TASK-260.05
title: Correct taxonomy visual system and theme colors
status: Done
assignee:
  - Codex
created_date: '2026-08-10 18:34'
updated_date: '2026-08-10 19:50'
labels:
  - site-refresh
  - taxonomy
  - visual-regression
dependencies: []
references:
  - 'https://just3ws.localhost/taxonomy/'
documentation:
  - CONTEXT.md
  - docs/adr/0001-public-archive-publication-contract.md
modified_files:
  - taxonomy/index.html
  - _sass/_p_taxonomy.scss
  - _sass/_p_theme_kanagawa.scss
  - assets/css/site.scss
  - _includes/head/base.html
  - tests/layout.spec.js
parent_task_id: TASK-260
priority: high
type: bug
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Bring the public `/taxonomy/` knowledge-graph page into the refreshed just3ws visual system. The page currently presents a disconnected hard-coded palette and inconsistent light/Kanagawa theme behavior, making the broader site refresh appear incomplete.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 The taxonomy page uses a coherent palette consistent with the refreshed professional site in the default theme.
- [x] #2 The taxonomy page remains coherent and readable in the Kanagawa theme, including hero, metrics, controls, graph, inspector, legend, table, badges, links, and buttons.
- [x] #3 Text, controls, and graph labels preserve accessible contrast and visible focus states.
- [x] #4 Graph interaction, entity filtering, taxonomy search, and entity links continue to work.
- [x] #5 Desktop and 375px mobile browser checks cover layout bounds and the two theme states.
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [x] #1 AC criteria is completed and the change has been verified
<!-- DOD:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Refresh type: targeted evolution, limited to /taxonomy/.

Design read: Treat the taxonomy as a living technical field map for archive explorers and hiring evaluators—warm, editorial, and cartographic—while preserving its research density and interactive graph utility.

Direction dials:
- VARIANCE 2 → 6: replace centered hero/equal dashboard cards with an offset editorial composition and ledger-like information structure.
- MOTION 2 → 3: retain meaningful hover, focus, filtering, and graph feedback; add no decorative spectacle.
- DENSITY 4 → 7: reduce dead space and expose more of the archive's real human record without crowding controls.

Preserve:
- /taxonomy/ route, title metadata, global navigation, all graph/filter/search/table behavior, entity links, categorical distinction, both themes, visible focus, responsive containment, public-safe data.
- Existing real archive counts and human-verifiable proof only.

Retire:
- Generic dark product-card hero, four equal SaaS metric cards, excessive rounded/shadowed panel chrome, large dead zones, and machine-first labels that foreground nodes/edges over people and conversations.

Introduce:
- Warm paper-and-ink default presentation with restrained CSS texture; Kanagawa remains a coherent dark editorial variant.
- Human-first hero: “Follow the people. Trace the ideas.” plus a field note explaining this is a navigable record, not a leaderboard or social graph.
- Ruled archive ledger for recorded voices, 200+ conversations, communities/gatherings, and open-source threads; node/connection totals remain secondary provenance.
- Editorial graph and index sections: “Start with a person, place, project, or practice” and “Prefer names to constellations?”
- Minimal radii, strong rules, compact margins, integrated graph/inspector composition, and register-like table styling.

Authorized files:
- taxonomy/index.html
- _sass/_p_taxonomy.scss
- _sass/_p_theme_kanagawa.scss
- tests/layout.spec.js

Explicit exclusions:
- No route, global navigation, source-data, graph-algorithm, global token, cache-busting, dependency, or unrelated page changes.
- No new image asset; restrained CSS texture is more truthful than decorative stock imagery.

Execution:
1. Revise taxonomy markup and public copy within the existing data/interaction contract.
2. Rework scoped taxonomy styles and focused Kanagawa overrides.
3. Extend Playwright assertions for the new human-first copy and preserve existing interaction/theme/mobile checks.
4. Build and run focused tests; capture desktop and 375px screenshots in both themes.
5. Run the repository validation suite.
6. Submit the finished slice to the required independent site-refresh reviewer; address any changes requested and re-review before finalizing.

Reviewer corrections before final gate:
7. Remove aria-label overrides from the graph filter and index search so each accessible name exactly contains its visible label; update Playwright locators.
8. Make the entity name itself the destination link, remove the redundant Action column, and fit the four-column ledger within the desktop content width while retaining internal scrolling on mobile; assert desktop table containment and visible links.
9. Reset scroll position before the Kanagawa full-page capture, rerun build/browser checks, and return the same slice to the independent reviewer.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
L1 context-hunter micro-brief: closest analogs are `_sass/_p_home_refresh.scss` and `_sass/_p_panoramic_view.scss`, which scope page tokens locally and defer Kanagawa overrides to `_sass/_p_theme_kanagawa.scss`. The taxonomy page instead embeds a separate slate/blue/pink CSS block and repeats those colors in graph JavaScript. Main risks are the broad Kanagawa `!important` selectors, keeping categorical graph colors distinguishable, and preserving table/graph behavior while consolidating presentation.

Diagnosis reproduced from the user URL: the default-theme taxonomy title renders dark on a dark hero, the graph/legend/badges use unrelated saturated colors, and the table is visually cramped. Separately, `https://just3ws.localhost/` serves an August 9 static build; `/home/` still contains `Architect & Creator`, so the completed refresh is not visible there.

Correct hypothesis: taxonomy presentation was isolated in a page-local hard-coded CSS block, while graph node colors and generated badges repeated a second hard-coded palette in JavaScript. The default global heading color overrode the hero inheritance, producing dark text on a dark hero; broad Kanagawa `!important` rules created partial theme overrides.

Implemented a scoped taxonomy visual system using the refreshed Nord and Kanagawa tokens; added accessible labeled controls and focus states; unified legend, graph, dynamic badges, inspector, metrics, and table; made graph colors update when `data-theme` changes; added responsive graph/table containment.

Added a build-time version query to the shared stylesheet URL because nginx caches static CSS for seven days and the unversioned URL could make a freshly published build appear unchanged.

Verification completed in source/build: the regression test first failed with title color rgb(46, 52, 64) instead of rgb(236, 239, 244), then passed after the fix. Ten Playwright layout tests pass, including both taxonomy themes, search/filter, focus, graph canvas, and 375px bounds. Jekyll builds 1,039 pages with zero accessibility-hook warnings. Full `bundle exec rake validate` and HTML-Proofer pass over 1,019 files and 832 internal links. Published endpoint was captured successfully after the first sync.

Current external-state blocker: `/opt/homebrew/var/www/just3ws.github.io` contains the final validated build, but the system-domain nginx LaunchDaemon is loaded and not answering. `zsvc restart nginx` requires an interactive sudo password; non-sudo `launchctl kickstart` is denied. User must run `sudo launchctl kickstart -k system/homebrew.mxcl.nginx`, after which the endpoint can be reverified.

Direction evidence: the current published page is technically corrected but reads as a generic SaaS analytics dashboard—centered dark hero, four equal floating metrics, repeated rounded cards, extensive whitespace, and labels such as “Interactive Knowledge Graph Network” and “Taxonomy Entity Index.” Those choices obscure the archive's human and historical character. Closest useful analogs are the site's refreshed editorial/Panoramic View surfaces, but this page should avoid fake nostalgia: use real counts, restrained texture, and legible technical density. Main implementation risk is broad Kanagawa !important styling combined with graph/table interaction states.

Implemented the approved targeted evolution for /taxonomy/: human-first archive copy, asymmetrical editorial hero, field-note framing, ruled human-scale ledger, secondary graph provenance counts, editorial graph/index headings, integrated inspector, register-style table, restrained paper texture, and matching Kanagawa dark treatment. No routes, data sources, graph algorithms, dependencies, or other pages were changed in this pass.

Verification: Jekyll build succeeds across 1,039 pages with zero accessibility-hook warnings. Focused taxonomy Playwright checks pass; full tests/layout.spec.js passes 10/10. Evidence captured for default/Kanagawa desktop and 375px mobile, including layout bounds, focus, filtering, search, graph canvas, theme toggle, and table rendering. bundle exec rake validate passes data, resources, taxonomy, archive-surface, and last-modified checks, then stops on unrelated generated-resume freshness drift in OneMain/SK Holdings/Tandem caused by concurrent resume copy work; those out-of-scope files were preserved.

Independent reviewer verdict: Changes requested. Major findings were WCAG 2.5.3 label-in-name mismatches on the two controls and desktop clipping that hid the Action column/entity links. Minor evidence issue: Kanagawa screenshot captured the sticky header over the graph. Corrections are added to the plan before implementation.

Reviewer corrections verified: focused taxonomy checks pass 2/2, full layout suite passes 10/10, taxonomy validator passes, and git diff --check is clean for the scoped files. Independent re-review verdict: Pass with no blocker, major, or minor findings.

Published current _site via bin/install-localhost. https://just3ws.localhost/taxonomy/ returns HTTP 200; response Last-Modified is Mon, 10 Aug 2026 19:48:46 GMT.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Refreshed /taxonomy/ from a generic analytics dashboard into a human-first technical oral-history field map.

What changed:
- Reframed the hero, section language, and metadata around people, conversations, communities, projects, and the movement of ideas.
- Replaced floating KPI cards with a ruled archive ledger using evidence-backed counts; graph node/edge totals remain secondary provenance.
- Introduced a warm paper-and-ink default surface and coherent Kanagawa editorial variant with minimal card chrome, compact density, field-note framing, and register-style table treatment.
- Preserved graph palette/category behavior, filtering, search, inspection, theme switching, entity destinations, focus visibility, and mobile containment.
- Corrected independent-review findings by aligning accessible names with visible control labels, linking entity names directly, fitting the complete four-column register at desktop width, and recapturing dark-theme evidence from the page top.

Verification:
- Jekyll build: 1,039 pages; zero accessibility-hook warnings.
- Playwright: focused taxonomy 2/2; complete layout suite 10/10.
- Taxonomy output validator: pass.
- Desktop and 375px screenshots captured in default and Kanagawa themes.
- Independent site-refresh review: Pass, no blocker/major/minor findings.
- Published to the existing localhost webroot; https://just3ws.localhost/taxonomy/ returns HTTP 200 with the current build.
- Full repository validation reaches and passes taxonomy-related checks, then stops on unrelated concurrent generated-resume freshness drift in OneMain/SK Holdings/Tandem; those out-of-scope files were preserved.
<!-- SECTION:FINAL_SUMMARY:END -->
