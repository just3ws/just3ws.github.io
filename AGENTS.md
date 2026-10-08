<!-- ═══════════════════════════════════════════════════════════════════════
     CURRENT FOCUS - last updated 2026-10-07
     Cold-start resume state, canonical for every agent tool. Whoever closes
     a session rewrites this block in place - step one, before the wrap-up.
     Backlog + git log are truth for exact task status / SHAs; if this block
     contradicts them, trust them and fix the block.

     THIS REPO IS PUBLIC. This block is committed and world-readable - keep
     it to "what content/feature is being built". Anything about employment
     status, targeting, or career narrative goes ONLY in the local deep
     handoff, never here.

       In flight: verify against Backlog (`backlog/tasks/`).
       - CI GATE GREEN & CANONICAL LINK RECONCILIATION (2026-10-08):
         Resolved GitHub Actions deployment pipeline failures across public index and HTML-Proofer gates:
         - Diagnosed `validate_public_index_mode` failure: `IntervieweeRedirectPage` emitted a relative target URL
           (`/interviews/people/adam-lear/`) in `<link rel="canonical">` instead of the fully-qualified canonical host.
           Updated `_plugins/generate_interviewees.rb` to resolve the canonical site URL (`https://www.just3ws.com`)
           safely while handling mock site objects in RSpec.
         - Diagnosed HTML-Proofer internal link hash failure on `/series/the-sound-above/episode-35/`: episode template
           linked to `#codas`, but the section anchor in `series/the-sound-above/index.html` was `#series-codas`.
           Updated `_layouts/series_episode.html` to reference `#series-codas`.
         - Maintained 100% em-dash-free compliance. All validation gates passing cleanly: validate:fast, validate:obs (46/46 assertions),
           validate:rendered_site (HTML-Proofer, SEO, Resume, ATS 88.2%), and rspec (100/100 tests).

       - TRANSCRIPT AUTOSCROLL STABILIZATION & PROGRESS RETENTION (2026-10-08):
         Resolved aggressive turn switching and jumpy transcript scrolling:
         - Diagnosed issue: high-frequency postMessage playback events (every 250ms) caused sub-second micro-turns
           (such as 0.4s and 1.0s affirmatives) to flash instantaneously and trigger continuous scroll re-centering,
           causing the reader to lose track of the conversation flow.
         - Introduced transition stabilization in `_includes/video-asset-player.html`: added a 600ms debounce floor
           (`MIN_TURN_DISPLAY_MS`) to prevent rapid flip-flopping during natural dialogue, strict half-open interval
           matching (`start <= t < end`), boundary retention, and `forceImmediate` bypass for intentional user clicks.
         - Added in-view viewport awareness: autoscroll now only triggers when the active turn drifts outside the
           comfortable visible zone of the transcript pane, preventing unnecessary jitter while reading.
         - Removed layout-shifting scale transform (`transform: scale(1.01)`) from `.is-speaking` in `_sass/_p_main.scss`.
         - Maintained 100% em-dash-free compliance. All validation gates passing cleanly: validate:fast, validate:obs (46/46 assertions),
           and rspec (100/100 tests).

       - TRANSCRIPT AUTOSCROLL CONTAINER BOUNDS & VIDEO PLAYER VIEWPORT ANCHOR (2026-10-08):
         Fixed transcript autoscroll scrolling the video player out of view:
         - Diagnosed issue: invoking `matched.scrollIntoView()` on an unconstrained document flow caused the whole browser
           window to scroll down to the active turn, pushing the video player above the viewport.
         - Encapsulated `.sync-transcript-stream` within an independent scroll container in `_sass/_p_main.scss` (`max-height: 70vh`,
           `overflow-y: auto`, `overscroll-behavior: contain`) with subtle craftsman themed scrollbars and book paper palette.
         - Updated autoscroll handler in `_includes/video-asset-player.html` to use scoped container scrolling (`stream.scrollTo()`),
           centering the active turn smoothly within the transcript pane while keeping the video player firmly anchored in the viewport.
         - Maintained 100% em-dash-free compliance. All validation gates passing cleanly: validate:fast, validate:obs (46/46 assertions),
           and rspec (100/100 tests).

       - LIVE CC SYNCHRONIZATION & VIDEO PLAYER CONTROL BAR TIDY (2026-10-08):
         Resolved real-time transcript progress tracking in the LIVE CC subtitle box and polished player controls:
         - Diagnosed why the LIVE CC box did not update as video played: YouTube and Vimeo iframes require an active
           postMessage listening handshake (`{"event": "listening"}` and `{"method": "addEventListener", "value": "timeupdate"}`)
           to emit `infoDelivery` / `timeupdate` playback events to the parent window.
         - Upgraded `_includes/video-asset-player.html` and `assets/js/deferred-embeds.js` to register the listening handshake
           immediately upon iframe load and periodically during playback polling. Added multi-event support handling
           `infoDelivery`, `initialDelivery`, `timeupdate`, and HTML5 native video time tracking.
         - Polished messy player controls in `_sass/_p_main.scss`: converted `.video-details-bar` into a responsive flex layout
           with discrete indicator and action groupings, replaced awkward solid-white/borderless buttons with digital patina
           craftsman tokens, and refined `.sync-cc-overlay` with sumi ink background and craftsman teal accents.
         - Maintained 100% em-dash-free compliance. All validation gates passing cleanly: validate:fast, validate:obs (46/46 assertions),
           and rspec (100/100 tests).

       - CONFERENCE PRESENTATION MAPPING & SPEAKER TALK EMBED ENHANCEMENTS (2026-10-08):
         Connected interviewees directly to the conference presentations they delivered across GOTO Chicago, RailsConf 2014, and SCNA:
         - Resolved identifier fragmentation in `_data/interview_related_videos.yml`: normalized 46 legacy YouTube and slug
           records to canonical interview IDs and added presentation links for RailsConf 2014 (DHH's "Writing Software" keynote,
           Joel Turnbull's Pry debugging, Alexander Dymo's memory optimization, Carlos Antonio da Silva's Rails tricks, Coraline Ada Ehmke's
           apprenticeship talk) and SCNA 2012 (Gary Bernhardt's "Boundaries" debut).
         - Upgraded `_layouts/interviewee_detail.html` with responsive presentation video embeds, presentation abstracts, and
           outbound links for all conference-presentation-video and conference-presentation-page assets.
         - Expanded interviewees index with verified presentation links from 4 to 40 speakers (including Corey Haines, Adrian Cockcroft,
           Anita Sengupta, Camille Fournier, Chad Fowler, Charles Nutter, Dave Thomas, Dean Wampler, Gary Bernhardt, Kyle Kingsbury,
           Rich Hickey, and David Heinemeier Hansson).
         - Enriched `_data/interview_conferences.yml` with deep thematic context, exact calendar dates, and historical venues:
           SCNA 2011 (Swissotel Chicago on Chicago River, Nov 18-19, 2011), SCNA 2012 (Mid-America Club on Aon Center 80th floor,
           Nov 9-10, 2012), WindyCityRails 2012 (Sep 7-12, 2012), and RailsConf 2014 (Apr 22-25, 2014) documenting the TDD debate,
           runtime maturation, and engineering apprenticeship.
         - Maintained 100% em-dash-free compliance. All validation gates passing cleanly: validate:fast, validate:obs (46/46 assertions),
           and rspec (100/100 tests).

       - HISTORICAL RECORDING DATE RECONCILIATION & DYNAMIC EPISODE PAGES (2026-10-08):
         Resolved historical date distortion across 79 conference/UGtastic interviews and completed episode rendering:
         - Reconciled 79 interviews that defaulted to 2022 YouTube platform re-upload dates:
           calibrated GOTO Chicago 2013 (April 23-26, 2013), GOTO Chicago 2014 (May 20-21, 2014),
           GOTO Chicago 2015 (May 11-12, 2015), RailsConf 2014 (April 22-25, 2014), WebVisions 2013
           (September 28, 2013), and SCNA 2011-2013 sessions in `_data/interviews.yml` and
           `_data/interview_conferences.yml` with true historical provenance dates.
         - Built dynamic Series Episode generator plugin (`_plugins/generate_series_episodes.rb`)
           and shared layout (`_layouts/series_episode.html`) to render individual showcase pages
           for all 35 interview episodes (`/series/the-sound-above/episode-02/` through `episode-35/`)
           with Schema.org VideoObject, verified transcript cross-links, prev/next movement navigation,
           and responsive video embed players.
         - Updated series curriculum overview (`series/the-sound-above/index.html`) to link every episode
           card directly to its dedicated showcase page.
         - Regenerated master CareerOS datalake endpoints (`career_datalake.json`, `career_datalake.jsonl`).
         - Maintained 100% em-dash-free compliance across all code, templates, and data files.
         - All validation gates passing cleanly: validate:fast, validate:obs (46/46 assertions),
           rspec (100/100 tests), and Jekyll build (1,013 pages generated).

       - THE SOUND ABOVE 37-EPISODE CURRICULUM HUB & ARCHIVE AUDIT (2026-10-07):
         Built dedicated series curriculum hub page and clarified exact archive counts:
         - Verified ground-truth archive metrics across the corpus: 201 total items (184 UGtastic interviews,
           12 SCMC recordings, 5 one-off community presentations), 191 unique UGtastic interviewees (199 total speakers),
           and 6 conferences (SCNA, GOTO, RailsConf, WindyCityRails, ChicagoWebConf, WebVisions) spanning 2011 to 2015.
         - Created comprehensive series curriculum overview at `/series/the-sound-above/` (`series/the-sound-above/index.html`)
           displaying all 37 episodes grouped across 6 historical movements, with guest names, conferences,
           years, core inquiry prompts, AI-era parallels, and links to verified interactive transcripts.
         - Updated global navigation (`_data/navigation.yml`) and interviews spotlight (`interviews/index.html`)
           to link to the 37-episode curriculum overview.
         - Exposed `_data/sound_above_sequence.json` for deterministic template rendering.
         - Maintained 100% em-dash-free compliance across all additions. All validation gates passing cleanly:
           validate:fast, validate:obs (44/44 assertions), and rspec (98/98).

       - INTERVIEWS ARCHIVE EDITORIAL REVIEW & NAVIGATION TIDY (2026-10-07):
         Overhauled `/interviews/` and archive components into full alignment with the site's
         canonical Digital Patina & Editorial Craft design tokens:
         - Fixed archive card date distortion: cards in `_includes/interview-card.html` now
           prioritize `recorded_date` over the 2022 YouTube platform re-upload date, correctly
           rendering primary historical dates (e.g. 'Nov 2011' for SCNA 2011 sessions).
         - Replaced legacy Bootstrap/pastel blue fallbacks (`#007bff`, `#0284c7`, `#2196f3`, `#e3f2fd`,
           `#7e9cd8`, `#363646`, `#2a2a37`) in `_sass/_p_main.scss` and `_sass/_p_surface_components.scss`
           with warm book paper canvas (`#faf8f5`), pure cards (`#ffffff`), subtle paper (`#f4f0e8`),
           craftsman teal (`#0f766e`), warm amber (`#b45309`), and sumi ink (`#1e232a`).
         - Added prominent editorial spotlight for 'The Sound Above' 37-episode rewatch series
           directly on `/interviews/`, linking to Episode 1, the Chicago Monograph, and the Community Timeline.
         - Tidied navigation hierarchy: separated in-page collection filtering (All Media, UGtastic, SCMC)
           from cross-corpus exploration guides (Speaker Directory, SCMC 17-Year Hub, Knowledge Graph,
           Corpus Intelligence, IronLanguages).
         - Updated `series/the-sound-above/episode-01.html` styles to match digital patina tokens.
         - Maintained 100% em-dash-free compliance. All validation gates passing cleanly:
           validate:fast, validate:obs (44/44 assertions), and rspec (98/98).

       - CAREEROS DATALAKE LESSONS & 37-EPISODE CURRICULUM RETENTION (2026-10-07):
         Retained historical conference, role, and oral history curriculum lessons into CareerOS datalake:
         - Updated `bin/generate_career_datalake.rb` to persist `oral_history_curriculum` directly into
           `career_datalake.json`, `career_datalake.jsonl`, `exports/career_datalake.json`, and `exports/career_datalake.jsonl`.
         - Recorded official UGtastic launch provenance: launched on-site at SCNA 2011 (November 18-19, 2011
           at the Swissotel Chicago downtown on the Chicago River).
         - Calibrated historical host positioning: recorded that Mike Hall was a Senior Software Developer
           when recording the UGtastic archive (2009-2015), preserving authentic historical truth.
         - Embedded full 37-episode 'The Sound Above' rewatch sequence and 12-item pre-curated Errata broadcast catalog
           directly into master datalake schema.
         - Updated MCP server `bin/career_datalake_mcp_server.rb` to expose `career://datalake/curriculum` resource.
         - Expanded rewatch curriculum to 37 episodes and implemented zero-dependency canonical URL redirection
           in `_plugins/generate_interviewees.rb` from `/interviews/people/anna-lear/` to `/interviews/people/adam-lear/`.
         - Updated `bin/broadcast` CLI, manual pages (`broadcast.1`, `obs-livestream.1`), OBS documentation,
           and automated test suites (`bin/validate_obs_setup.rb`, `spec/plugins/interviewee_generator_spec.rb`,
           `spec/series/sound_above_series_spec.rb`).
         - Maintained 100% em-dash-free compliance across all code, JSON/YAML schemas, and prose. All validation
           gates passing cleanly: validate:fast, validate:obs (44/44 assertions), rspec (98/98), and benchmark:ats (88.2%).

       - ADAM LEAR NAME & GENDER AFFIRMATION & SCNA 2011 SWISSOTEL HISTORICAL VENUE (2026-10-07):
         Handled Adam Lear name transition with accuracy and respect, and recorded SCNA 2011 venue context:
         - Verified that interviewee Anna Lear transitioned to Adam Lear (software developer at Stack Overflow).
         - Updated speaker attribution to Adam Lear in `_data/transcripts/interview-with-anna-lear-general.yml`
           with respectful historical context: 'Adam Lear · Community Manager, Stack Exchange (recorded as Anna Lear)'.
         - Updated interviewee list in `_data/interviews.yml` and catalog description/tags in `_data/video_assets.yml`.
         - Preserved the verbatim 2013 spoken audio and historical transcript text unchanged.
         - Recorded primary provenance for SCNA 2011 (November 18-19, 2011 held at the Swissotel Chicago downtown
           on the Chicago River) in `docs/style-guide-and-canonical-naming.md` and `series/the-sound-above/episode-01.html`.
         - Maintained 100% em-dash-free compliance. All validation gates passing cleanly:
           validate:fast, validate:obs (44/44 assertions), and rspec (97/97).

       - HISTORICAL RECORDING DATE RESTORATION & ERRATA BEHIND-THE-SCENES BROADCASTS (2026-10-07):
         Resolved archival date distortion on interview pages and expanded Errata broadcast archetype:
         - Diagnosed and fixed interview hero header date conflation: pages previously displayed
           the 2022 YouTube archival re-upload date instead of the primary historical event date.
         - Updated `_includes/video-asset-player.html` and `_layouts/interview.html` to resolve
           `archive_item.recorded_date` (e.g. November 19, 2011 for Sergio Pereira) and display
           event context (e.g. 'Recorded at SCNA 2011'), falling back safely through Vimeo and YouTube metadata.
         - Expanded the Errata broadcast archetype to explicitly support and document Behind the Scenes (BTS)
           broadcasts (studio tours, broadcast engineering, OBS and Golden Gate CoreAudio routing, toolchains).
         - Updated `bin/broadcast` CLI (--bts flag, --mode bts), `man/man1/broadcast.1`,
           `obs/schemas/overlay-state.schema.json`, `obs/scripts/update-overlay-state.sh`,
           `obs/overlays/lower-third.html` (dynamic 'STUDIO OPS' credo banner), and `obs/README.md`.
         - Added curated BTS entries to `obs/curation/errata-manifest.json` and thumbnail generation support in
           `bin/generate_errata_thumbnail.rb`.
         - Replaced lingering 'Software Craftsmanship #106' broadcast host defaults with canonical professional
           identity: 'Mike Hall (Staff Software Engineer & SCMC Co-Founder)'.
         - Maintained 100% em-dash-free compliance. All validation gates passing cleanly:
           validate:fast, validate:obs (44/44 assertions), rspec (97/97), and resume_quality.

       - CANONICAL IDENTITY REFINEMENT & DATE SPAN PURGE (2026-10-07):
         Eliminated intrusive 'Signatory #106' branding and purged artificial '2005-2026' date callouts:
         - Removed spurious '2005-2026' and '(2005-2010)' ranges across Community Timeline, subnav,
           blog links, OBS sequence manifests, thumbnail templates, and overlay states.
         - Restored clean movement names across all six broadcast movements: The Chicago Crucible,
           The Practice and the Dojo, The Human Communication Layer & Inclusion, Philosophy, Empathy &
           Craftsmanship, The Architecture and Testing Reckoning, and The AI Horizon & The Observable Control Plane.
         - Retained the March 6, 2009 ledger record as factual historical context and evidence
           in forensics reports and origin essays.
         - Restored canonical professional identity across public and tooling surfaces:
           Staff Software Engineer, UGtastic Creator/Host, and SCMC Co-Founder.
         - Purged employer names (BDI, TicketsNow) from community initiatives and milestone lists,
           restoring pure practitioner rooms: 8th Light Pair Friday, SCNA, CDG, and SCMC.
         - Zero em dashes maintained. All gates passing: validate:fast, validate:obs (44/44),
           rspec (97/97), and resume_quality.

       - COMMUNITY TIMELINE CRAFTSMANSHIP OVERHAUL & ITERM2 INTEGRATION (2026-10-07):
         Overhauled `/timeline/community/` into full alignment with the site's canonical
         Digital Patina & Editorial Craft design tokens:
         - Eliminated legacy silver borders (#363646) and low-contrast pastel tones (#7e9cd8, #c8c093).
         - Applied warm book paper canvas (#faf8f5), pure cards (#ffffff), subtle paper (#f4f0e8),
           deep sumi ink (#1e232a), slate headings (#0f172a), craftsman teal (#0f766e),
           and warm amber accents (#b45309).
         - Replaced inline hex color attributes with semantic classes in `_sass/_p_timeline.scss`.
         - Updated `.surface-editorial` and `.archive-note` in `_sass/_p_surface_components.scss`.
         - Integrated `The Sound Above (Broadcast)` iTerm2 profile (`obs/iterm2/the-sound-above.json`),
           resolved dynamic profile GUID collision with fresh unique UUID, and bound Scene 05
           (`05. Workbench - Code & Terminal`) window capture owner to `iTerm2`.
         - Documented Section 8 in `docs/style-guide-and-canonical-naming.md` establishing design
           tokens and contrast hierarchy across site, OBS overlays, Orion, and iTerm2.
         - Maintained 100% zero em dashes across all code and documentation. All gates passing:
           validate:fast, validate:obs (44/44 assertions), rspec (97/97), and resume_quality.

       - UNIFIED BROADCAST DIRECTOR & AI-ASSISTED TOOLING SUITE (2026-10-07):
         Created unified live broadcast CLI (`bin/broadcast`) and manual (`man/man1/broadcast.1`)
         to orchestrate all three broadcast archetypes:
         - Archetype 1 ('The Sound Above'): Forensic oral history rewatches (Episodes 1 to 31).
         - Archetype 2 ('Errata'): Solo broadcasts (readings, concepts, live demos, stories, artifacts)
           backed by pre-curated catalog in `obs/curation/errata-manifest.json`.
         - Archetype 3 ('The Room'): Invited peer dialogues and community roundtables.
         Updated `obs-livestream.1` man page to reflect 31 episodes and `bin/broadcast` CLI integration.
         Created comprehensive, unambiguous `docs/runbooks/broadcast-operations-playbook.md`
         defining sequential pre-flight, live execution, and post-stream teardown checklists.
         Updated `oral-history-broadcaster` agent and skill definitions across `.agents/skills/`
         and `.claude/agents/` to equip autonomous AI assistants for broadcast setup and verification.
         Zero em dashes maintained. All validation gates passing cleanly: validate:obs (40/40),
         validate:fast, rspec (97/97), resume_quality, and benchmark:ats (88.2%).

       - TRI-ARCHETYPE BROADCAST ARCHITECTURE & 'ERRATA' TEMPLATE (2026-10-06):
         Established polymorphic broadcast architecture across three core archetypes:
         - Archetype 1 ('The Sound Above'): Forensic oral history rewatches and commentary.
         - Archetype 2 ('Errata'): Personal insights, book readings, live code demonstrations,
           concept breakdowns, and physical archival memorabilia / artifact showcases.
         - Archetype 3 ('The Room'): Invited guest conversations, collegial peer dialogues, and roundtables.
         Updated overlay state schema (obs/schemas/overlay-state.schema.json) and controller
         (obs/overlays/js/overlay-controller.js) to dynamically configure lower-third HUDs,
         reading citation cards, starting title screens, and outros.
         Enhanced CLI cueing tool (obs/scripts/update-overlay-state.sh) with --errata, --rewatch,
         --dialogue, and fine-grained mode flags (--mode reading|concept|demo|story|artifact).
         Zero em dashes maintained. All validation gates passing cleanly: validate:obs (40/40),
         validate:fast, rspec (97/97), resume_quality, and benchmark:ats (88.2%).

       - 31-EPISODE ORAL HISTORY SEQUENCE EXPANSION (2026-10-06):
         Expanded 'The Sound Above' oral history rewatch series to 31 episodes across 6 distinct movements:
         - Added Ginny Hendry (Episode 12, 'A Legacy of Learning: Community Hospitality, RailsBridge & In Memoriam')
           with delicate, honorable focus on her lifelong mentorship, 8th Light owner tribute, and Chicago RailsBridge leadership.
         - Added Leon Gersing (Episode 13, 'Hold Yourself to a Standard, But Let There Be Joy: Overcoming Developer Shame')
           with radical empathy, vulnerability, and developer joy framing from SCNA 2012.
         - Curated full 31-episode roadmap across 6 movements in obs/curation/sequence-manifest.json and rewatch-curation-sequence.md.
         - Updated YouTube rewatch playlist synchronization tool (bin/sync_youtube_rewatch_playlist.rb) with all 31 sessions.
         - Maintained 100% em-dash-free compliance and strict canonical contracts.
         - All validation gates passing cleanly: validate:obs (40/40 assertions), validate:fast, rspec (97/97),
           resume_quality, and benchmark:ats (88.2%).

       - MOVEMENT 1 BROADCAST STAGING & DETERMINISTIC THUMBNAILS (2026-10-06):
         Generated 1080p and 720p craftsmanship-theme thumbnails and scheduled live broadcasts
         for all 5 episodes of Movement 1 ('The Chicago Crucible'):
         - Episode 01: Sergio Pereira (eGXG7Qu4G1E, The First Room / Alt.NET)
         - Episode 02: Ray Hightower (rUH7UAeka4c, The Ambassador / Chicago Ruby & 1871)
         - Episode 03: Micah Martin & Mike Jansen (aCbqGDJ3BE4, Pair Friday in Libertyville / 8th Light)
         - Episode 04: Dave Hoover ( -ZnHI8BnyK4, The Apprenticeship Move / Obtiva & Dev Bootcamp)
         - Episode 05: Ryan Gerry & Jim Suchy (3UScVYlNnQg, The 17-Year Continuous Room / SCMC & Follett)
         Uploaded high-res 1080p editorial thumbnails to YouTube Live Studio for each broadcast,
         bound streams, and synced IDs into obs/curation/sequence-manifest.json.
         All gates passing: validate:obs (40/40 assertions), validate:fast, and rspec (97/97).



       - REWATCH SERIES LAUNCH & REPOSITORY TIDY (2026-10-06):
         Pre-flight audit and white-glove review complete for 'The Sound Above' rewatch broadcast.
         Enforced strict canonical casing for Alt.NET across data catalogs,
         career datalake, and style guide. Created series mirror page at
         series/the-sound-above/episode-01.html with Schema.org VideoObject
         linked to YouTube playlist PLVcmLmfz2uyA and interactive transcript.
         Clarified Gleacher Center historical venue and added a11y, heading
         hierarchy, and readability rules to style guide. Cleansed em dashes
         from 2026-10-02 post. Pruned repo hygiene allowed files and excluded
         AGENT.md from Jekyll build. Patched 5 NPM security vulnerabilities
         (npm audit 0 vulnerabilities) and updated bundle dependencies cleanly.
         Standardized CLI help options on validators (validate_repo_hygiene,
         validate_data_uniqueness, validate_data). Synchronized YouTube live
         metadata for playlist PLVcmLmfz2uyA and video qOHdZKz1WFw with verified
         13 chapters and Sears Tower Alt.NET context. Authored phased rollout
         recommendation in docs/phased-approach-rewatch-broadcast-rollout.md.
         Synthesized Isaac Asimov's Foundation knowledge preservation mandate into
         series documentation: stewarding oral history to shorten the interregnum
         between software eras. All validation gates passing (validate:fast,
         validate:obs 40/40 assertions, rspec 90/90, resume_quality, benchmark:ats 88.2%).
       - YOUTUBE CAPTION SYNC & OBS REWATCH AUDIT (2026-10-05):
         Audited YouTube captions pipeline against YouTube Data API v3.
         Diagnosed why Sergio Pereira (qOHdZKz1WFw) defaulted to YouTube ASR:
         the August 30 caption sync paused at video 48/207 due to API quota limits.
         Uploaded high-fidelity 44-turn WebVTT caption track to YouTube via
         bin/sync_youtube_captions.rb and verified serving status.
         Audited OBS Studio setup for Episode 1 rewatch (35 assertions passing,
         all 8 production scenes, 4-track audio capture routing, Golden Gate
         SCK audio capture, craftsmanship overlays cued to Episode 1).
         Audited Scott Seely interviews (CLQfARayJV0 and pzpyJMpCwso): identified
         collapsed turns, missing recording blocks, duplicate sentences, and
         Whisper hallucination loops in queue for remediation.
       - VIDEO PLAYER & CHAPTER TIMELINE RESTORATION (2026-10-05):
         Restored interactive timeline scrubber bars and deferred embed video seeking.
         Fixed player element lookup across video-stage.html, deferred-embed.html,
         interview-timeline.html, and video-asset-player.html.
         Exposed window.loadDeferredEmbed and window.seekDeferredEmbed in
         assets/js/deferred-embeds.js to allow seeking into deferred YouTube/Vimeo
         embeds directly from transcript turn timestamps and chapter links.
         Added 13 verified chapters to Sergio Pereira interview transcript and
         calibrated DHH RailsConf 2014 chapters across the full 928-second span.
         All gates clean (fast validation, rspec, obs, archive validation).
       - THE SOUND ABOVE OBS PROJECT (2026-10-04): Full OBS Studio project
         created at `obs/` for the UGtastic oral history rewatch series.
         8-scene collection (Apple M4 hardware profile, 1080p60, apple_h264),
         macOS Golden Gate native audio (DesktopAudioDevice1 + sck_audio_capture),
         5 HTML overlays with craftsmanship-theme palette, 21-episode sequence
         manifest across 5 eras. Automation: `bundle exec rake validate:obs`
         (35 assertions, 7 gates). Man page: `man/man1/obs-livestream.1`.
         New skill: `oral-history-broadcaster` in `.agents/skills/` and
         `.claude/agents/`. Repo hygiene updated (obs/ in allowed_directories
         + Jekyll exclude list). All validation gates clean.
       - VIDEO SERIES PLATFORM NARRATIVE (2026-10-02): 5-part series
         "The Observable Control Plane" blueprint approved. Capstone post drafted:
         `_posts/2026-10-02-without-zdots-there-was-nothing.md`
         (Tier 3 AI-augmented, routes to /ai/2026/10/02/..., Jekyll build
         clean). Series blueprint: /Users/mike/.gemini/antigravity-cli/brain/
           0e5b4dee-44a7-4486-846e-ebb7264cfcf6/video_series_blueprint.md
       Deep handoff (local-only, never commit):
         ~/.config/adots/handoffs/2026-10-07.md

     Close ritual: rewrite this block + commit; write the deep handoff for
     anything personal or unfinished. Reference impl: wwworkremote/core's
     docs/agents/session-handoff.md.
     ═══════════════════════════════════════════════════════════════════════ -->

# Project Agent Instructions

## Required Project Context

Before changing this repository:

1. Read `CONTEXT.md` for the public-canon, local-runtime, and publication
   contracts.
2. Read `CODEX.md` before evaluating or changing resume content, positioning,
   titles, or generated resume surfaces.
3. Read `docs/career-strategy-audhd-principal-engineering.md` for title-to-scale
   role calibration and interview positioning strategies.
4. Read `docs/style-guide-and-canonical-naming.md` for permanent canonical naming,
   casing, and compound word standards across all content, data, and transcripts.

Do not treat this repository as an isolated Jekyll checkout. Its installed
localhost site is part of Mike's local system and is a required verification
surface for user-facing changes.

## System Identity

You are operating in `just3ws.github.io` — Mike Hall's public resume/
portfolio Jekyll site, the public-facing half of a two-repo CareerOS
platform. Peer system: `wwworkremote.localhost` (career intelligence / job
search side), synchronized via `src/collaboration/peer_mutex.rb`
(`CareerOS::PeerMutex`) and `bin/sync_career_peer.rb`.

Cross-session and cross-repo comms run on the zdots message bus. This
repo's registered identity is `agent-just3ws`:

- `zdots-ctx bus-whoami` — confirm identity resolves; if not,
  `zdots-ctx bus-register agent-just3ws --kind agent` then
  `export ZDOTS_BUS_PARTICIPANT=agent-just3ws`.
- `job-leads` channel — just3ws <-> wwworkremote coordination.
- `general` channel — cross-cutting platform ops; also reaches Mike
  (`mike`) and `zdots` (formerly `claude-code-main`).
- Bus problems get filed as a `zdots-issue` — this repo's agents don't
  patch zdots infrastructure directly.

Every persona under `.claude/agents/` operates inside this same identity
and system context, not as an isolated actor.

## Panoramic View Labs (PVL) Platform Identity

Canonical naming is permanent. Read this before using any Panoramic View term in prose, code, or agent output.

- **Panoramic View** is a technique (the system-cartography method). It is not an initiative name.
- **Panoramic View Labs** (short code `PVL`, pronounced "Pavel") is the initiative name. Use it when referring to the organizational umbrella, not the method.
- **Pavel** is the name of the Panoramic View specialist agent. Named from the PVL pronunciation.
- **zdots** is the root local-system platform for the Panoramic View initiative. All PVL capabilities live in and depend on zdots, not just3ws or wwworkremote.

Full disambiguation rules: `docs/style-guide-and-canonical-naming.md` §7.

## Agent skills

### Issue tracker

GitHub issues. See `docs/agents/issue-tracker.md`.

### Triage labels
Standard triage workflow labels. See `docs/agents/triage-labels.md`.

### Domain docs
Single-context layout (root-level CONTEXT.md + docs/adr/). See `docs/agents/domain.md`.

### Agent RACI Matrix
Cross-persona task ownership, review obligations, and decision authority are defined in `docs/agents/agent-raci-matrix.md`. Mike Hall's SME working group delegation strategy (proven at OneMain Financial) and the multi-archive claim verification playbook are codified in `docs/sme-delegation-and-multi-archive-playbook.md`.

## Registered Skills
Use these skills by default for this repository. **Status**: 9 of the 22
below have real `SKILL.md` content in `.agents/skills/` (marked ✓; see
`docs/tooling-user-guide.md` §6) — the other 13 have no skill file anywhere.
All 22 also have `.claude/agents/*.md` subagent persona coverage (TASK-262),
which is a separate mechanism (a spawned subagent, not a loaded skill) and
does not require a `.agents/skills/` file to exist.

## Persona Review Council

Aneta is the trusted editorial and strategy lead for Mike's public identity.
The council definition and method map live in
`docs/persona-review-council.md`. Its independent reviewers protect methods,
provenance, professional audiences, practitioner audiences, accessibility,
prose, privacy, and public-boundary safety.

Use the council before publishing or revising a method, quote, diagram, title,
metric, named person, historical interpretation, or cross-link between archive
and professional surfaces. An unresolved authorship or public-safety concern is
a hold, not an invitation to invent a smoother explanation.

1. `gh-fix-ci` - Diagnose and fix failing GitHub Actions checks.
2. `gh-address-comments` - Process and resolve PR review comments.
3. `playwright` - Run browser-based smoke checks and regression checks.
4. `screenshot` - Capture visual evidence for UI regressions.
5. `security-best-practices` - Run focused security reviews (JS/TS/Ruby-adjacent patterns).
6. `security-threat-model` - Produce threat models for pipeline/content flows.
7. `transcript-import-batch` - Batch ingest transcript files from outbox with dry-run/apply + validation workflow.
8. `transcript-review-gate` - Review low-confidence transcript mappings before apply.
9. `transcript-quality-check` - Audit transcript integrity and content quality in canonical data.
10. `transcript-ops-report` - Summarize transcript ingestion throughput and corpus growth.
11. `site-refresh-director` - Audit a site surface and produce a bounded, evidence-backed refresh brief.
12. `site-refresh-builder` - Implement an approved refresh brief in the existing Jekyll/Liquid/SCSS stack.
13. `site-refresh-reviewer` - Independently gate visual, accessibility, SEO, and public-archive quality.
14. `system-cartographer` ✓ - Audit, structure, and generate 4-dimensional System Cartography case studies.
15. `executive-brief-generator` ✓ - Generate tailored 1-page executive pitch briefs for target Principal Engineer roles.
16. `job-lead-evaluator` ✓ - Evaluate job leads from wwworkremote against personal OS context and canonical resume data.
17. `prose-humanity-auditor` ✓ - Audit technical prose across site Markdown, YAML data, and resume surfaces for plain language, neuroinclusive readability, cognitive load, and zero AI jargon.
18. `no-em-dashes` ✓ - Enforce em-dash-free writing across prose, case studies, briefs, and documentation to eliminate machine-writing cadence and maintain authentic human voice.
19. `public-surface-auditor` ✓ - Audit the rendered public boundary for privacy, provenance, quarantine, and internal topology leaks before publication.
20. `tmi-auditor` ✓ - Audit public-facing content for oversharing, discrimination-vector signals, and PII/PHI exposure.
21. `canonical-surface-steward` ✓ - Keep canonical identity, shorthand, agents, skills, documentation, CLI help, validators, and generated surfaces synchronized.
22. `oral-history-broadcaster` ✓ - Direct, validate, cue, and audit live oral history rewatch broadcasts, OBS Studio production scene contracts, dynamic HTML overlays, and "Sound Above" commentary arcs across the UGtastic and Chicago Software Craftsmanship corpus.

## Career Datalake & MCP Server Interface

This repository provides full-corpus deterministic query interfaces over the career archive (29 positions, 136 skills, 156 blog posts, 211 interviews, and 402 knowledge graph nodes):

* **CLI Query Engine:** `ruby bin/query_career_datalake.rb [options]` (supports `--tech`, `--company`, `--search`, `--archetype`, `--era`, `--interviewee`, `--json`, and `--man`).
* **MCP Server:** `ruby bin/career_datalake_mcp_server.rb` registered in `mcp.json` (tools: `query_career_history`, `get_technology_provenance`, `get_position_dossier`, `get_archetype_strategy`, `query_oral_history`, `query_transcript`).
* **HTTP Endpoints:** `https://just3ws.localhost/career_datalake.json` and `https://just3ws.localhost/career_datalake.jsonl`.
* **Guides:** See `docs/career-datalake-and-mcp-guide.md` and `docs/mcp-setup-guide.md`.

## Automated Resume Quality & ATS Benchmarking Suite

This repository maintains continuous ATS parseability, keyword match density, and structural data validation:

* **Resume Quality Validator:** `bundle exec rake validate:resume_quality` (`bin/validate_resume_quality.rb`) - Simulates ATS plain-text parsing, checks Schema.org `Person` JSON-LD linked data, action verb ratios, and enforces strict zero em dashes.
* **ATS Keyword Benchmark Engine:** `bundle exec rake benchmark:ats` (`bin/benchmark_ats_keywords.rb`) - Benchmarks resume exports against 5 target Staff+/Principal role profiles (Huntress Rails/SOC, Coder Platform, Enterprise Telemetry, Fintech Modernizer, Founding Staff AI).
* **Automated CI/CD Gating:** `bundle exec rake validate:ats_benchmarks` asserts composite match score >= 85.0% and minimum archetype floor >= 75.0%.
* **Guides:** See `docs/resume-narrative-and-storytelling-guide.md`, `docs/resume-quality-and-ats-benchmarking-guide.md`, and `docs/tooling-user-guide.md` (§8, §9).

## Executive Pitch Briefs & Direct Outreach Tooling ("Wayfinder")

This repository provides automated generation of tailored 1-page executive pitch briefs, interview calibration scripts, and high-signal outreach copy:

* **Executive Brief Generator:** `ruby bin/generate_executive_brief.rb [options]` (supports `--company`, `--role`, `--domain`, `--tier`, `--comp`, `--mandate`, `--html`, `--pdf`, `--json`).
* **MCP Tool Integration:** `generate_executive_brief` in `bin/career_datalake_mcp_server.rb` callable by `wwworkremote.localhost` and any agent tool.
* **Direct Outreach Playbook:** `docs/direct-hiring-manager-outreach-playbook.md` (cold hiring manager, warm peer, and founder/CTO outreach archetypes).
* **Protocol & Specifications:** `docs/executive-brief-generator-protocol.md` and `docs/career-strategy-audhd-principal-engineering.md`.
* **Rendered Briefs Hub:** `https://just3ws.localhost/exports/briefs/` with downloadable vector PDFs.


## Site Refresh Agent Workflow

For visual refresh work, use the three roles in order:

1. `$site-refresh-director` outputs a Refresh Brief and does not edit code.
2. `$site-refresh-builder` implements one authorized slice and outputs Build Evidence.
3. `$site-refresh-reviewer` inspects rendered desktop and mobile output and returns `pass` or `changes requested`.

Do not let the builder self-approve a visual change. Preserve routes, navigation labels, canonical content, analytics hooks, accessibility wins, and archive provenance unless the user explicitly expands scope.

## GitHub Pages / Pipeline Focus
For this site, prioritize:

1. CI reliability and reproducibility (Ruby/Bundler parity).
2. Jekyll build + internal link validation as required checks.
3. Smoke testing key pages via Playwright before merge.

## SEO + HTML Standards Guidance
There is no dedicated curated skill currently installed for HTML standards or SEO architecture.
Use this stack instead:

1. `playwright` for navigation/indexability smoke tests.
2. Jekyll plugins and templates (`jekyll-seo-tag`, sitemap, metadata includes) for structured SEO output.
3. CI checks (`html-proofer` + targeted assertions) for broken links and markup regressions.

<!-- BACKLOG.MD MCP GUIDELINES START -->

<CRITICAL_INSTRUCTION>

## BACKLOG WORKFLOW INSTRUCTIONS

This project uses Backlog.md MCP for all task and project management activities.

**CRITICAL GUIDANCE**

- If your client supports MCP resources, read `backlog://workflow/overview` to understand when and how to use Backlog for this project.
- If your client only supports tools or the above request fails, call `backlog.get_backlog_instructions()` to load the tool-oriented overview. Use the `instruction` selector when you need `task-creation`, `task-execution`, or `task-finalization`.

- **First time working here?** Read the overview resource IMMEDIATELY to learn the workflow
- **Already familiar?** You should have the overview cached ("## Backlog.md Overview (MCP)")
- **When to read it**: BEFORE creating tasks, or when you're unsure whether to track work

These guides cover:
- Decision framework for when to create tasks
- Search-first workflow to avoid duplicates
- Links to detailed guides for task creation, execution, and finalization
- MCP tools reference

You MUST read the overview resource to understand the complete workflow. The information is NOT summarized here.

</CRITICAL_INSTRUCTION>

<!-- BACKLOG.MD MCP GUIDELINES END -->

## graphify

This project has a knowledge graph at graphify-out/ with god nodes, community structure, and cross-file relationships.

When the user types `/graphify`, use the installed graphify skill or instructions before doing anything else.

Rules:
- For codebase questions, first run `graphify query "<question>"` when graphify-out/graph.json exists. Use `graphify path "<A>" "<B>"` for relationships and `graphify explain "<concept>"` for focused concepts. These return a scoped subgraph, usually much smaller than GRAPH_REPORT.md or raw grep output.
- Dirty graphify-out/ files are expected after hooks or incremental updates; dirty graph files are not a reason to skip graphify. Only skip graphify if the task is about stale or incorrect graph output, or the user explicitly says not to use it.
- If graphify-out/wiki/index.md exists, use it for broad navigation instead of raw source browsing.
- Read graphify-out/GRAPH_REPORT.md only for broad architecture review or when query/path/explain do not surface enough context.
- After modifying code, run `graphify update .` to keep the graph current (AST-only, no API cost).
