---
name: patreon-integrator
description: Connects to Patreon API v2 and Chrome browser automation to manage campaign tiers, brand styling, recurring compute funds, and closing credit attributions for just3ws broadcasts and open projects.
---

# Patreon Integrator Skill

Use this skill when managing, integrating, querying, or synchronizing Patreon memberships, calculating recurring compute funding, and formatting patron attribution for **UGtastic / WHOIS Tech Community**, **The Sound Above**, and **Phalanx Duel**.

---

## 🎯 Ground Truth and Canonical Identity

* **Primary Creator Identity**: Mike Hall (`mike@just3ws.com`, username `just3ws`).
* **Canonical URL**: `https://www.patreon.com/c/just3ws` (supersedes legacy `whoistechcmty`).
* **Campaign ID**: `15677398`.
* **Theme Styling**: Craftsmanship Theme with **Deep Craftsman Teal (`#0F766E`)** as the primary brand accent, matching `etc/themes/craftsmanship.yaml` and `_sass/_p_variables.scss`.
* **Consolidated Projects**:
  1. **UGtastic / WHOIS Tech Community**: Preserving 200+ Software Craftsmanship McHenry County (SCMC) oral histories, transcripts, and Whisper compute.
  2. **Phalanx Duel**: Ongoing strategy card game platform and community mechanics.

---

## 🏛️ Tier Architecture & Benefits

| Tier Slug | Title | Monthly Price | Core Scope & Deliverables |
| :--- | :--- | :--- | :--- |
| `tier_interviewee` | **Interviewee Alumni** | **$0 / month** | Honorary lifetime membership for all 192 historical interviewees with full post feed and community access. |
| `tier_1` | **Community Supporter** | **$1 / month** | Grassroots backer tier supporting open craftsmanship archives and Phalanx Duel game development. |
| `tier_5` | **Community Member** | **$5 / month** | Coffee-level recurring community patron tier. |
| `tier_7` | **Archive Preservationist** | **$7 / month** | Underwrites Whisper GPU transcription, timecode alignment, and static hosting. Early access to uncompressed WebVTT captions and Markdown dossiers. |
| `tier_20` | **Workbench Craftsman** | **$20 / month** | Underwrites audio DSP restoration, local tool development, and game playtests. Includes engineering marginalia, Python DSP notch scripts, and playtest builds. |
| `tier_97` | **Engineering Patron** | **$97 / month** | Executive and institutional underwriting for multi-movement broadcast arcs. Spoken outro credits in Act 6, description underwriting lines, and quarterly 1-on-1 systems architecture discussions. |

---

## ⚙️ Operational Interfaces & CLI

### 1. Unified Pipeline CLI (`bin/patreon_pipeline.rb` / `bin/pipeline patreon`)

```bash
# Check campaign status, active members, and compute funding:
ruby bin/patreon_pipeline.rb status
bin/pipeline patreon status

# Auto-discover or verify campaign metadata via API v2:
ruby bin/patreon_pipeline.rb campaign

# List members and current tier classifications:
ruby bin/patreon_pipeline.rb members

# Generate teleprompter read-along credits and YouTube descriptions:
ruby bin/patreon_pipeline.rb credits

# Synchronize live remote roster to _data/patreon_roster.json:
ruby bin/patreon_pipeline.rb sync
```

### 2. Browser Automation (Chrome via AppleScript)

When active in Chrome with **View > Developer > Allow JavaScript from Apple Events** enabled:

```bash
# Inspect active Patreon tab:
osascript -e 'tell application "Google Chrome" to get {title, URL} of active tab of front window'

# Execute JavaScript inside Patreon tab:
osascript -e 'tell application "Google Chrome" to tell active tab of front window to execute javascript "..."'
```

---

## 🛡️ Credential Storage Seams

Credentials must never be hardcoded or checked into source control:

1. **Option A (Personal OS Keychain)**:
   ```bash
   zdots-keychain add PATREON_CREATOR_TOKEN "<token>"
   zdots-keychain add PATREON_CAMPAIGN_ID "15677398"
   ```
2. **Option B (Repository-scoped .env)**:
   Add to `.env` (which is gitignored and tracked in `_data/repo_hygiene.yml`):
   ```sh
   PATREON_CREATOR_TOKEN="<token>"
   PATREON_CAMPAIGN_ID="15677398"
   ```
   `PatreonPipeline#load_env_if_present` automatically loads this file on demand.
