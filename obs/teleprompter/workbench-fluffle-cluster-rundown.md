# Studio Workbench: The Fluffle & The Ship of Theseus

**Format:** Process cinema and live architectural walkthrough  
**Episode Heading:** Fluffle: Five Raspberry Pis and 1K+ Transcript Pairs  
**Bridge From:** Studio Workbench Episode 1: *The Ship of Theseus: From Wooden Boat to Space Station* (https://www.youtube.com/watch?v=R_WagKejbtw)  
**Target Length:** 25 to 30 minutes  
**Setting:** Desk setup (MacBook Air DRR sticker), Obsidian JSON Canvas (`docs/fluffle-architecture-walkthrough.canvas`), terminal (`~/github.com/just3ws/fluffle`), and `media-pipeline` cockpit  

---

## Pre-Flight OBS & Desk Checklist

1. **Physical Prop:** MacBook Air lid with Dead Rabbit Radio sticker positioned for Act 1 close-up.
2. **OBS Overlay State:** `obs/overlays/overlay-state.json` cued to `workbench-fluffle-cluster`.
3. **Teleprompter:** `obs/teleprompter/workbench-fluffle-cluster.textream` loaded in Textream.
4. **Screen Share Tabs Ready:**
   - Obsidian / Canvas viewer: `docs/fluffle-architecture-walkthrough.canvas`
   - Briefing & Mermaid diagrams: `docs/studio-workbench-fluffle-theseus-briefing.md`
   - Terminal in `~/github.com/just3ws/fluffle` (`git log --oneline`, `Rakefile`, `bin/transcribe`, `bin/episode_checker.rb`, `replacements.yaml`, `transcripts/ep_0769_travis_scott_comp.srt`)
   - `episodes.html` (Milligram status grid) beside `media-pipeline` live cockpit

---

## Act-by-Act Cue Sheet

### Act 1: The Sticker, The Helicopter & The Pivot Plank (00:00 to 03:00)
- **Cam:** Desk setup, MacBook Air DRR sticker close-up.
- **Key Beat:** Bridge directly from Studio Workbench Episode 1 (*The Ship of Theseus*, 1h 19m YouTube master) to the single most important plank replacement: April 2023.
- **Proof Point:** `ep_0769_travis_scott_comp.srt` (`2021-11-08`, `00:00:49` and `00:14:53`): *"Give it up for Mike Hall... Mike Hall is flying us around the carbon [Carpenter] helicopter."* (Whisper `ggml-small.bin` misheard Jason's signature **Carpenter Copter / Carpenter Helicopter**).

### Act 2: Why Not Start on UGtastic? (03:00 to 06:00)
- **Screen:** `many-hands-make-light-work` (2014-04-04) vs `just3ws/fluffle` (2023-04-06).
- **Key Beat:** Refusing to beta-test an unproven local AI pipeline on 200+ irreplaceable Chicago community interviews.

### Act 3: Walking the Original Fluffle Architecture (06:00 to 15:00)
- **Screen:** `fluffle-architecture-walkthrough.canvas` + Mermaid Topology, Sequence, State Machine, and Equilibrium diagrams.
- **Key Code:**
  - `Rakefile`: `Curl::Easy`, `Nokogiri`, `Down.download(max_redirects: 16)`, `FFMPEG::Movie` (`16_000` Hz mono `pcm_s16le`), `Net::SSH` (`MIN_MB_AVAILABLE_ON_NODE = 5_000`, `MAX_PODCAST_GB_PER_NODE = 2`), `rsync -avzP`, `du -b == File.size`.
  - `bin/transcribe`: `.log` lock, `ggml-small.bin`, `rm episode.wav`, `sleep 120` thermal cooldown.
  - Dotfiles (`.downloading`, `.downloaded`, `.converted`, `.distributed`, `.failed`) -> 2026 Maildir (`staged/`, `pending/`, `processing/`, `processed/`, `failed/`).

### Act 4: The *Blindsight* Moment (15:00 to 20:00)
- **Screen:** `fluffle/README.md` + `fluffle/replacements.yaml` + `git log` on May 17, 2023 (`07:03` to `07:13 AM`).
- **Key Beat:** 30+ Whisper misspellings of "Jason Carpenter" (`Garpenter`, `Garbineiro`, `Krupper`) + `deadrabberdurgible`. Deterministic YAML regexes (`d8cd747`, `4db66d1`) fixing 981 files in one pass.

### Act 5: Git Archaeology & Where It Stopped (20:00 to 25:00)
- **Screen:** `git log` (79 commits across 67 days) + `bin/episode_checker.rb` / `episodes.html`.
- **Key Beats:**
  - Before/after-work cadence (`06:04` AM, `12:21` PM, `21:27` PM), `abc718c` (Rudie Jazz), `2fac228` (`-52,952` lines duplicate `.wav.srt`).
  - `3122642` (509-file manual edit, Apr 25) -> 22-day silence -> May 17 systems pivot.
  - Off-air blessing from Jason Carpenter (no on-air DRR episode discussed `just3ws/fluffle`).
  - `bc4ec64` (`Process 2.0`, Jun 12, 4,135 files): multi-feed XML drift + solo maintenance ceiling.

### Act 6: Coda & Next on The Sound Above (25:00 to 28:00)
- **Screen:** `episodes.html` beside `media-pipeline` live cockpit (Apple Silicon M4 Metal, 103s Whisper, 0B permanent SSD waste).
- **Outro:** Thank Jason Carpenter, Patreon callout (`patreon.com/whoistechcmty`), preview of *The Sound Above*, sign-off: *"Keep your feedback loops fast, and your code humane."*
