# The Sound Above: YAML Schema & Surface Mapping Specification

This document specifies the exact contract for `_data/episodes/episode-NN.yml` and how each field drives public pages, studio workbenches, teleprompter documents, and OBS overlays.

---

## 1. Schema Definition & Validation Rules

The CLI validator `bin/prepare_sound_above_episode.rb <NN> --check` enforces this schema fail-closed before any recording or build:

```yaml
# ─────────────────────────────────────────────────────────────────
# 1. CORE EPISODE IDENTITY (MANDATORY)
# ─────────────────────────────────────────────────────────────────
episode: 2                                              # Integer: Episode number (1..35)
series: "The Sound Above"                               # String: Canonical series name
title: "The Ambassador: ChicagoRuby & Grassroots Hospitality" # String: Episode title
status: scheduled                                       # Enum: scheduled | prep | cued | recorded | published
interviewee: "Ray Hightower"                            # String: Full name of the interviewee
conference: "SCNA 2011"                                 # String: Conference where interview was recorded
year: 2011                                              # Integer: Year recorded
location: "Chicago, IL"                                 # String: City and state
slug: "ray-hightower-chicagoruby-software-craftsmanship-north-america-2011" # String: Canonical interview slug
era_id: "the-chicago-workshop"                          # String: Era identifier
era_name: "The Chicago Workshop"                        # String: Era display name
youtube_broadcast_id: "rUH7UAeka4c"                     # String: Scheduled YouTube broadcast ID
youtube_video_id: "XZqGbf5C76E"                         # String: Original UGtastic source YouTube ID
rewatch_youtube_id: null                                # String: Published Sound Above video ID (null until published)

# ─────────────────────────────────────────────────────────────────
# 2. NARRATIVE & INTELLECTUAL SPINE (MANDATORY)
# ─────────────────────────────────────────────────────────────────
narrative:
  theme: "Community Hospitality & Radical Practitioner Inclusion" # String: Core human theme
  tone: "Reflective, forensic, and empathetic with craftsman rigor" # String: Spoken delivery tone
  core_inquiry: "Who showed the early community organizers how to welcome newcomers with radical hospitality?" # String: Guiding question
  chicago_context: "Ray Hightower served as the welcoming ambassador bridging corporate IT, independent consultants, and open-source practitioners." # String: Physical & geographical context
  ai_era_parallel: "In an era of automated code synthesis, human hospitality and community mentorship become more valuable, not less." # String: 2026 AI era echo

# ─────────────────────────────────────────────────────────────────
# 3. TRACK A: SCRIPTED TELEPROMPTER ACTS (MANDATORY)
# ─────────────────────────────────────────────────────────────────
teleprompter_script:
  act_1: | # String: Cold open hook (Scene 01) -> Monologue greeting & personal context (Scene 02)
  act_2: | # String: Monologue historical logistics, meeting timing & room size (Scene 02)
  act_3: | # String: Split Screen 3 archival receipts & core inquiry statement (Scene 04)
  act_4: | # String: Unscripted rewatch cue summary for prompter (Scene 03 / Scene 04)
  act_5: | # String: Monologue wrap-up, transcript citation, and present-day AI echo (Scene 02)
  act_6: | # String: Outro credits, comments invitation, support link & next episode tease (Scene 08)

# ─────────────────────────────────────────────────────────────────
# 4. TRACK A: STRUCTURED REWATCH CUES (MANDATORY, MINIMUM 3)
# ─────────────────────────────────────────────────────────────────
rewatch_cues:
  - time: "00:00"                                       # String: MM:SS timestamp
    seconds: 0                                          # Integer: Exact seconds (must equal hms_to_seconds(time))
    label: "Intro & Tone"                               # String: Short cue title
    guest_says: "Introduces himself as organizer..."   # String: What the interviewee is saying
    watch_for: "Sets the frame: operations focus..."    # String: Direction for the host / context tip
    artifact_label: "Interactive Transcript"            # String: Optional label for jump link
    artifact_url: "/interviews/<slug>/"                 # String: Optional URL for jump link

# ─────────────────────────────────────────────────────────────────
# 5. TRACK A: ARCHIVAL RECEIPTS (MANDATORY, MINIMUM 1)
# ─────────────────────────────────────────────────────────────────
archival_receipts:
  - title: "ChicagoRuby.org (Nov 1, 2011 Wayback)"      # String: Display title
    summary: "Eighteen days before SCNA 2011..."        # String: Evidence description
    url: "https://web.archive.org/web/20111101093510/http://chicagoruby.org:80/" # String: Exact HTTP 200 Wayback URL (no wildcards)

# ─────────────────────────────────────────────────────────────────
# 6. TRACK B: COMPANION ERRATA (MANDATORY BLOCK)
# ─────────────────────────────────────────────────────────────────
errata:
  title: "Episode 2 Errata: Exploring ChicagoRuby..."  # String: Errata episode title
  status: planned                                       # Enum: planned | recorded | published
  format: unscripted                                    # String: Strictly "unscripted"
  focus: "Freeform walkthrough of era-specific..."     # String: Scope statement
  unscripted_prompts:                                   # Array of Strings: Discussion prompt bullets
    - "Explore early ChicagoRuby and WindyCityRails Wayback captures from 2008-2011."
    - "Share unscripted memories of crossing from .NET to Ruby and Cucumber at Midway Restaurant."
  demonstrations:                                       # Array of Objects: Live tools/screen shares
    - name: "Wayback captures for chicagoruby.org"     # String: Demo title
      url: "https://web.archive.org/web/20111101093510/http://chicagoruby.org:80/" # String: URL
      notes: "Show the team credits and conference sponsor lineup." # String: Context

# ─────────────────────────────────────────────────────────────────
# 7. RESEARCH ATTACHMENTS (MANDATORY)
# ─────────────────────────────────────────────────────────────────
research_attachments:
  - title: "Ray Hightower Interview Profile"            # String: Attachment title
    type: site_archive_page                             # Enum: site_archive_page | archive_document | research_report | article | document
    url: "https://just3ws.com/interviews/<slug>/"       # String: URL (auto-synced to Chromium bookmarks)
```

---

## 2. Surface Mapping Matrix

This table shows how each YAML field renders across the live surfaces:

| YAML Field | Public Episode Page (`series_episode.html`) | 3-Pane Workbench (`series_workbench.html`) | Textream (`.textream`) | OBS Overlay (`overlay-state.json`) |
| :--- | :--- | :--- | :--- | :--- |
| `episode` | Kicker badge & Wayfinding | HUD Header badge | File naming & Header | `"episode.number"` |
| `title` | Hero `<h1>` | HUD Title | File title | `"episode.title"` |
| `interviewee` | Hero subtitle & Context card | HUD Subtitle & Prompt headers | Spoken references | `"episode.interviewee"` |
| `conference` / `year` | Context card & Schema.org | HUD Subtitle | Act 1 intro | `"episode.conference"` / `"year"` |
| `narrative.core_inquiry`| *Questions for this episode* | Inquiry callout box | Act 3 spoken conclusion | `"episode.sound_above_prompt"` |
| `narrative.chicago_context` | *Historical Context & Roots* | Act 2 card lead | Act 2 spoken scene | N/A |
| `teleprompter_script` | Cockpit HUD Textream launchers | Column 2 Prompter cards & Textream launchers | Compiled native document | N/A |
| `rewatch_cues` | Chapter jump buttons + Cues table | Column 2 Cue table + Column 3 Jump list | Act 4 summary | N/A |
| `archival_receipts` | Evidence Ledger cards | Act 3 Split Screen prompt card | Act 3 spoken receipts | N/A |
| `errata` | Track B Companion Errata card | Column 1 Errata scene button + Column 2 Card | N/A | N/A |
| `research_attachments`| *Explore Archive* links | Column 3 Research & Presentation tabs | N/A | Chromium Bookmarks |

---

## 3. Automated Validation Contract (`bin/prepare_sound_above_episode.rb`)

The validator checks the following rules on every episode YAML file:
1. **Zero Em Dashes**: The entire raw file string must contain zero instances of `\u2014`.
2. **Required Keys**: All 7 mandatory blocks (`title`, `interviewee`, `conference`, `year`, `slug`, `teleprompter_script`, `rewatch_cues`, `archival_receipts`, `research_attachments`) must be present and non-empty.
3. **All 6 Acts Present**: `act_1` through `act_6` must exist in `teleprompter_script`.
4. **Cue Timing Parity**: Each cue's `time` string (e.g., `"02:19"`) must mathematically match its `seconds` integer (`139`).
5. **Cue Monotonic Ordering**: Cues must appear in strictly ascending chronological order.
6. **Immutable Wayback Captures**: Every URL on `web.archive.org` must start with a 14-digit timestamp (`/web/YYYYMMDDHHMMSS/`) and cannot contain a wildcard `*`.
7. **First-Person Voice Guard**: Warns if plural pronouns (`we`, `our`, `us`) appear in spoken teleprompter acts, ensuring Mike's personal voice.
8. **Errata Block Guard**: Confirms companion errata prompts exist.
