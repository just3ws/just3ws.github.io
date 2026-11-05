# Patreon Integration and Community Sponsorship Guide

This manual documents the architecture, credential handling, tier structure, Craftsmanship theme tokens, and automation workflows for Mike Hall's Patreon presence at `https://www.patreon.com/c/just3ws`.

---

## 1. Ground Truth and Strategic Consolidation

Mike Hall (`just3ws`, `mike@just3ws.com`) consolidates community support and digital humanities underwriting under his primary personal identity.

### Ecosystem Lineage
* **UGtastic and WHOIS Tech Community**: These represent the same historical initiative across successive eras. UGtastic is the founding name (2011 to 2014); WHOIS Tech Community represents the subsequent brand iteration. Both are now unified under `just3ws`.
* **Primary Supported Projects**:
  1. **UGtastic / WHOIS Tech Community**: Preserving 200+ Software Craftsmanship McHenry County (SCMC) oral history recordings, interview transcripts, and Whisper GPU transcription compute.
  2. **Phalanx Duel**: Ongoing strategy card game design, rules engine, and playtest platform.
  3. **WWWorkRemote & Open Tooling**: Distributed work intelligence and systems architecture utilities.
* **Canonical URL**: `https://www.patreon.com/c/just3ws` (supersedes legacy `whoistechcmty`).
* **Campaign ID**: `15677398`.

---

## 2. Design Tokens and Craftsmanship Theme Styling

The Patreon creator presence adheres strictly to the canonical **Craftsmanship Theme** defined in `etc/themes/craftsmanship.yaml` and `_sass/_p_variables.scss`:

| Token | Hex Value | Semantic Role on Patreon |
| :--- | :--- | :--- |
| **`--accent`** | **`#0F766E`** | **Brand Color (Deep Craftsman Teal)**: Used for buttons, highlights, badges, and link states. |
| **`--yellow`** | **`#B45309`** | **Warm Leather Accent**: Secondary highlight in graphics and video overlays. |
| **`--bg`** | **`#FAF8F5`** | **Canvas Paper**: Warm linen background for banner cards and profile art. |
| **`--text`** | **`#1E232A`** | **Sumi Ink**: High-contrast body typography. |
| **`--heading`** | **`#0F172A`** | **Slate Ink**: Header typography. |

The brand color on Patreon is set to `#0F766E`.

---

## 3. Tier Taxonomy and Pricing Ladder

The membership structure incorporates a free level for historical alumni alongside five calibrated subscription tiers:

```mermaid
flowchart LR
    A["Interviewee Alumni ($0/mo)"] --> B["Community Supporter ($1/mo)"]
    B --> C["Community Member ($5/mo)"]
    C --> D["Archive Preservationist ($7/mo)"]
    D --> E["Workbench Craftsman ($20/mo)"]
    E --> F["Engineering Patron ($97/mo)"]
```

### Tier Definitions

1. **Interviewee Alumni ($0 / month)**:
   * *Audience*: All 192 historical guests from Software Craftsmanship McHenry County and UGtastic.
   * *Mechanism*: Native Free Membership on Patreon.
   * *Deliverable*: Lifetime free access to community updates, post feeds, and honorary recognition in broadcast outro rolls.

2. **Community Supporter ($1 / month)**:
   * *Audience*: Grassroots backers and community members.
   * *Deliverable*: Ongoing general support for open archives, oral history transcriptions, and Phalanx Duel development.

3. **Community Member ($5 / month)**:
   * *Audience*: Recurring supporters contributing monthly studio support.
   * *Deliverable*: Standard community backer tier for meetups and platform infrastructure.

4. **Archive Preservationist ($7 / month)**:
   * *Audience*: Digital humanities supporters and researchers.
   * *Deliverable*: Underwrites Whisper GPU compute, timecode alignments, and static site hosting. Early access to uncompressed WebVTT captions and Markdown transcript dossiers.

5. **Workbench Craftsman ($20 / month)**:
   * *Audience*: Software craft practitioners, audio engineers, and game mechanics enthusiasts.
   * *Deliverable*: Underwrites lossless audio DSP restoration, local tool development, and Phalanx Duel playtesting. Includes engineering marginalia, Python DSP notch filter scripts, teleprompter rundowns, and playtest builds.

6. **Engineering Patron ($97 / month)**:
   * *Audience*: Executive underwriters and institutional sponsors.
   * *Deliverable*: Multi-movement broadcast underwriting. Named spoken credit in Act 6 teleprompter read-alongs, description underwriting lines, and quarterly 1-on-1 systems architecture discussions.

---

## 4. Pipeline Automation (`bin/patreon_pipeline.rb`)

The CLI script `bin/patreon_pipeline.rb` provides deterministic interfaces for synchronization, credits generation, and fund tracking:

```bash
# Check status, member counts, and recurring compute fund tally:
ruby bin/patreon_pipeline.rb status
bin/pipeline patreon status

# Discover or verify campaign metadata via Patreon API v2:
ruby bin/patreon_pipeline.rb campaign

# List active members and tier classifications:
ruby bin/patreon_pipeline.rb members

# Generate teleprompter read-along credits and YouTube descriptions:
ruby bin/patreon_pipeline.rb credits

# Synchronize remote members into _data/patreon_roster.json:
ruby bin/patreon_pipeline.rb sync
```

---

## 5. Browser Automation Seam (Chrome via AppleScript)

For browser-level administration, the operator or agent interacts directly with an open Chrome session when **View > Developer > Allow JavaScript from Apple Events** is toggled on:

```bash
# Verify active tab:
osascript -e 'tell application "Google Chrome" to get {title, URL} of active tab of front window'

# Execute JavaScript inside active Patreon tab:
osascript -e 'tell application "Google Chrome" to tell active tab of front window to execute javascript "..."'
```

This enables automated configuration of:
* Tier titles, descriptions, and pricing without manual form entry.
* Brand hex color adjustments to `#0F766E`.
* Page details and layout sections.
