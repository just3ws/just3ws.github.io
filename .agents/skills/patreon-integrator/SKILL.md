---
name: patreon-integrator
description: Connects to Patreon API v2, manages campaign tiers, tracks recurring compute funding, and formats closing credit attributions for The Sound Above broadcasts.
---

# Patreon Integrator Skill

Use this skill when integrating, querying, or synchronizing Patreon memberships, calculating recurring compute funding, and formatting patron attribution for **The Sound Above**, **Errata**, and **Ramblin' & Amblin'** broadcasts.

---

## 🎯 Core Capabilities & Architecture

1. **Patreon API v2 Integration (`bin/patreon_pipeline.rb`)**:
   - Queries the Patreon API v2 JSON:API endpoints:
     * `GET /api/oauth2/v2/campaigns/{campaign_id}`: Campaign stats and pledge aggregates.
     * `GET /api/oauth2/v2/campaigns/{campaign_id}/members`: Active patron identities, entitled tiers, and pledge amounts.
     * `POST /api/oauth2/v2/campaigns/{campaign_id}/posts`: Automated patron post creation.
   - Falls back gracefully to the deterministic sandbox fixture (`_data/patreon_roster.json`) when `PATREON_CREATOR_TOKEN` is unset during offline development or local testing.

2. **Three Calibrated Patron Tiers**:
   - **Archive Preservationist ($7/month)**: Underwrites Whisper compute, token consumption, and static site hosting. Patrons receive uncompressed WebVTTs, raw JSONL turns, and early YAML dossiers.
   - **Workbench Craftsman ($19/month)**: Underwrites audio DSP instrumentation and local-agent tooling. Patrons receive engineering marginalia (OBS configurations, Python DSP notch filter scripts) and teleprompter rundowns.
   - **Engineering Patron / Institutional Underwriter ($97/month)**: Underwrites 6-movement broadcast arcs and digital humanities preservation. Patrons receive named broadcast underwriting in Act 6, quarterly 1-on-1 advisory sessions on system cartography, and corporate learning budget documentation.

3. **In-Stream & Metadata Syndication**:
   - Teleprompter Act 6 Outro:
     ```bash
     bin/patreon_pipeline.rb credits
     ```
     Generates customized host read-along thank you lines for Engineering Patrons.
   - YouTube Descriptions: Automatically prepends patron acknowledgments into staged video descriptions.

4. **CLI Commands Reference**:
   ```bash
   # Display campaign status and monthly compute fund:
   bin/patreon_pipeline.rb status
   bin/pipeline patreon status

   # List active members and tier classifications:
   bin/patreon_pipeline.rb members

   # Generate closing credit attributions:
   bin/patreon_pipeline.rb credits

   # Sync live members to _data/patreon_roster.json:
   bin/patreon_pipeline.rb sync
   ```

5. **Staging and Verification**:
   Before every live broadcast, run the staging harness to ensure patron attribution is rendered cleanly:
   ```bash
   bin/stage_episode_workflow.rb <N>
   bin/pipeline stage <N>
   ```
