# The Sound Above Producer: Data Schema & Template Reference

This reference is part of **The Sound Above Producer** skillset:
- **[SKILL.md](SKILL.md)**: Main workflow overview & 5-stage production lifecycle.
- **[SCHEMA_SPECIFICATION.md](SCHEMA_SPECIFICATION.md)**: Exhaustive YAML schema & field-to-surface mapping matrix.
- **[RESEARCH_GUIDE.md](RESEARCH_GUIDE.md)**: Transcript forensics, ear-checking, and exact Wayback CDX capture recovery.
- **[SCRIPTING_PLAYBOOK.md](SCRIPTING_PLAYBOOK.md)**: Spoken voice guidelines for Mike Hall, 6-act broadcast arc, and Errata formulation.

---

## 1. Canonical Episode YAML Schema (`_data/episodes/episode-NN.yml`)

Every episode converges on one canonical YAML contract in `just3ws.github.io/_data/episodes/episode-NN.yml`:

```yaml
episode: 2
series: The Sound Above
title: "The Ambassador: ChicagoRuby & Grassroots Hospitality"
status: scheduled # scheduled | prep | cued | recorded | published
interviewee: Ray Hightower
conference: SCNA 2011
year: 2011
location: Chicago, IL
slug: ray-hightower-chicagoruby-software-craftsmanship-north-america-2011
era_id: the-chicago-workshop
era_name: The Chicago Workshop
youtube_broadcast_id: rUH7UAeka4c
youtube_video_id: XZqGbf5C76E
rewatch_youtube_id: null # populated after Track A publication

# Narrative & Intellectual Spine
narrative:
  theme: Community Hospitality & Radical Practitioner Inclusion
  tone: Reflective, forensic, and empathetic with craftsman rigor
  core_inquiry: Who showed the early community organizers how to welcome newcomers with radical hospitality?
  chicago_context: Ray Hightower served as the welcoming ambassador bridging corporate IT, independent consultants, and open-source practitioners.
  ai_era_parallel: In an era of automated code synthesis, human hospitality and community mentorship become more valuable, not less.

# Track A: Scripted Teleprompter Acts (1-6)
teleprompter_script:
  act_1: | # 01. Starting Soon VO -> 02. Monologue
  act_2: | # 02. Monologue historical logistics
  act_3: | # 04. Split Screen 3 archival receipts
  act_4: | # 03. Unscripted rewatch cue summary (no script read aloud)
  act_5: | # 02. Monologue synthesis & present-day echo
  act_6: | # 08. Outro credits & next episode tease

# Track A: Structured Rewatch Cues (Drives 3-Pane Workbench & Video Sync)
rewatch_cues:
  - time: "00:00"
    seconds: 0
    label: "Intro & Tone"
    guest_says: "..."
    watch_for: "..."
    artifact_label: "Interactive Transcript"
    artifact_url: "/interviews/<slug>/"

# Track A: 3-Part Archival Receipts (Wayback HTTP 200 URLs)
archival_receipts:
  - title: "..."
    summary: "..."
    url: "https://web.archive.org/web/<YYYYMMDDHHMMSS>/..."

# Track B: Companion Errata (Unscripted Deep Dive)
errata:
  title: "Episode 2 Errata: Exploring ChicagoRuby, WindyCityRails & Midway Diner Context"
  status: planned # planned | recorded | published
  format: unscripted
  focus: "Freeform walkthrough of era-specific ChicagoRuby and WindyCityRails Wayback snapshots, WisdomGroup archives, and the bridge into Episode 3."
  unscripted_prompts:
    - "Explore early ChicagoRuby and WindyCityRails Wayback captures from 2008-2011."
    - "Share unscripted memories of crossing from .NET to Ruby and Cucumber at Midway Restaurant."
  demonstrations:
    - name: "Wayback captures for chicagoruby.org & windycityrails.org"
      url: "https://web.archive.org/web/20111101093510/http://chicagoruby.org:80/"
      notes: "Show the team credits and conference sponsor lineup."

# Era-Specific Research Attachments (Synced to Chromium Bookmarks & Public Episode Page)
research_attachments:
  - title: "..."
    type: archive_document # site_archive_page | research_report | archive_document | article
    url: "https://web.archive.org/web/<YYYYMMDDHHMMSS>/..."
```

---

## 2. Zero Hand-Coded HTML Architecture

Every episode from Episode 1 through Episode 35 follows a standardized data-driven rendering pipeline:

1. **`_layouts/series_episode.html` (Public Editorial Page)**:
   - Consumes `page.dossier` to render:
     - **Broadcast Cockpit HUD**: Part A (Acts 1-3), Part B (Act 4 Rewatch), Part C (Acts 5-6), plus direct Textream action bar (`Act 1`, `Act 2`, `Act 3`, `Act 5`, `Act 6`, Launch Intro, Launch Outro, Launch Full Script).
     - **Canonical Hosted Interview Stage Card**: Direct `#t=` chapter jump buttons syncing to `/interviews/<slug>/`.
     - **Structured Rewatch Cue Board**: Dialogue quotes and watch-for moments.
     - **Archival Receipts & Evidence Ledger**: Verified HTTP 200 Wayback receipts.
     - **Track B Companion Errata Card**: Focus statement and unscripted discussion prompts.
     - **Research Attachments**: Primary historical sources.
     - **Dynamic Client Scripting**: Auto-encodes spoken prompter copy into `textream://read?text=...` URI parameters and wires `BroadcastChannel('just3ws-interview-sync')` to all jump buttons.
     - **Unique Retrospective Prose**: Injected cleanly via `{{ content }}` without duplicating page boilerplate.
2. **`_layouts/series_workbench.html` (3-Pane Live Broadcast Workbench)**:
   - Left Pane: OBS Scene cues (Acts 1-6 + Errata card).
   - Middle Pane: Filterable prompter rundown, live rewatch cue table, and errata prompt cards.
   - Right Pane: Textream launchers, canonical interview controller (`BroadcastChannel`), and live research tabs.
3. **`bin/prepare_sound_above_episode.rb <NN>`**:
   - Single CLI command that validates YAML rules (checks zero em dashes, no wildcard Wayback URLs, first-person voice), compiles `obs/teleprompter/episode-NN.textream`, rebuilds Jekyll, and syncs the localhost webroot.

---

## 3. Ingestion Targets & Pipeline Configuration

| Target Series | Slugs / Directory | YouTube Playlist | Default Privacy | Archetype |
| :--- | :--- | :--- | :--- | :--- |
| **Track A: Primary Episode** | `the-sound-above` | `PLVcmLmfz2uyA` | Public (post-review) | `the_sound_above` |
| **Track B: Companion Errata** | `errata` | `PLKPAHha6I990` | Unlisted (companion) | `structured_errata` |

Both targets are configured in `_data/media_intake_targets.yml` and point to the channel `@just3ws-mike` with the physical root `~/ai/media-pipeline/just3ws-mike/`.

---

## 4. Verification & CLI Commands

### Find Exact HTTP 200 Era-Specific Wayback Capture
```bash
curl -s "https://web.archive.org/cdx/search/cdx?url=<URL>&output=json&fl=timestamp,original,statuscode,length&filter=statuscode:200&from=2007&to=2015&limit=5"
```

### Validate & Prepare Episode Surfaces
```bash
cd ~/github.com/just3ws/just3ws.github.io
ruby bin/prepare_sound_above_episode.rb <NN> --check
ruby bin/prepare_sound_above_episode.rb <NN> --cue-overlay
```

### Track A & Track B Pipeline Closeout
```bash
# Ingest Track A (The Sound Above)
mv "$HOME/Movies/<recording_sound_above>.mov" "$HOME/ai/media-pipeline/just3ws-mike/the-sound-above/pending/"

# Ingest Track B (Companion Errata)
mv "$HOME/Movies/<recording_errata>.mov" "$HOME/ai/media-pipeline/just3ws-mike/errata/pending/"

# Trigger ingestion scan in media-pipeline
cd ~/github.com/just3ws/media-pipeline && bin/mp scan
```
