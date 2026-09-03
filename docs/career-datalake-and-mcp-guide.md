# CareerOS Datalake & Query Engine: Agent Guide & Manual

This manual documents the architecture, data structures, CLI options, MCP tools, and cross-repo interfaces for the **CareerOS Datalake** within `just3ws.github.io` and its sibling `wwworkremote.localhost`.

---

## 1. System Architecture & Capabilities

The CareerOS Datalake synthesizes Mike Hall's technical career archive into queryable, deterministic datasets:

* **29 Positions:** From early web & .NET systems (2006) to Groupon, ActiveCampaign, OneMain Financial, and 2026 Local AI Orchestration.
* **136 Technologies Tracked:** Provenance matrix recording first active year, last active year, role occurrences, and context.
* **156 Blog Articles:** Full technical archive spanning 2006 to 2026 with tags, categories, and excerpts.
* **211 Technical Interviews:** The UGtastic oral history canon with structured transcript dialogue turns.
* **402-Node Knowledge Graph:** Entity network mapping software luminaries, open-source projects, and conferences.
* **5 Tailored Archetype Strategies:** Complete reader psychology, unstated pressures, wants vs needs, and empathy bridges.

```
                   ┌──────────────────────────────────────────────┐
                   │         CareerOS Datalake Generator          │
                   │      (bin/generate_career_datalake.rb)       │
                   └──────────────────────┬───────────────────────┘
                                          │
                   ┌──────────────────────┴───────────────────────┐
                   ▼                                              ▼
       ┌───────────────────────┐                      ┌───────────────────────┐
       │  career_datalake.json │                      │ career_datalake.jsonl │
       │  (550+ KB Master JSON)│                      │ (Streaming Line JSON) │
       └───────────┬───────────┘                      └───────────┬───────────┘
                   │                                              │
    ┌──────────────┼──────────────────────────────┬───────────────┤
    ▼              ▼                              ▼               ▼
┌────────┐ ┌────────────────┐            ┌────────────────┐ ┌─────────────┐
│  HTTP  │ │   CLI Engine   │            │   MCP Server   │ │ Peer Mutex  │
│  API   │ │(query_datalake)│            │(career_datalake│ │  (zdots bus │
│        │ │                │            │  _mcp_server)  │ │ 'job-leads')│
└────────┘ └────────────────┘            └────────────────┘ └─────────────┘
```

---

## 2. CLI Query Interface Reference (`bin/query_career_datalake.rb`)

The CLI interface allows agents and human operators to query the datalake instantly from the terminal or shell wrappers.

### Synopsis
```bash
ruby bin/query_career_datalake.rb [OPTIONS]
```

### Options
| Flag | Name | Description |
| :--- | :--- | :--- |
| `-t`, `--tech` | `<skill>` | Query technology provenance, active years, and roles where applied. |
| `-c`, `--company` | `<name>` | Query deep position dossier, summary, and highlights for a company. |
| `-s`, `--search` | `<query>` | Multi-corpus full-text search across positions, case studies, posts, and interviews. |
| `-a`, `--archetype` | `<slug>` | Retrieve archetype positioning strategy, reader psychology, and empathy bridge. |
| `-i`, `--interviewee` | `<name>` | Search oral history interviews by guest name or topic. |
| `-e`, `--era` | `<years>` | Filter writings, milestones, and interviews within a year range (e.g. `'2009-2015'`). |
| `-j`, `--json` | | Format output as structured JSON for downstream piping to `jq` or LLMs. |
| `--stats` | | Display high-level dataset metrics. |
| `-m`, `--man` | | Print the complete manual and examples. |
| `-h`, `--help` | | Show usage help. |

### CLI Usage Examples

```bash
# Query technology provenance for OpenTelemetry
ruby bin/query_career_datalake.rb --tech "OpenTelemetry"

# Query pgvector with JSON output for pipeline scripting
ruby bin/query_career_datalake.rb --tech "pgvector" --json

# Query role dossier for OneMain Financial
ruby bin/query_career_datalake.rb --company "OneMain"

# Retrieve strategy and cover letter empathy bridge for Principal Systems Architect
ruby bin/query_career_datalake.rb --archetype "principal"

# Search the entire 20-year corpus for legacy modernization
ruby bin/query_career_datalake.rb --search "legacy modernization"

# Filter the Software Craftsmanship era (2009 to 2015)
ruby bin/query_career_datalake.rb --era "2009-2015"
```

---

## 3. Model Context Protocol (MCP) Server Reference

The STDIO server is implemented in [`bin/career_datalake_mcp_server.rb`](file:///Users/mike/github.com/just3ws/just3ws.github.io/bin/career_datalake_mcp_server.rb) and registered in [`mcp.json`](file:///Users/mike/github.com/just3ws/just3ws.github.io/mcp.json).

### Callable Tools
1. **`query_career_history(query)`**: Search across all positions, case studies, 156 blog articles, and milestones.
2. **`get_technology_provenance(technology)`**: Return active era, timeline, and exact roles for any skill.
3. **`get_position_dossier(company)`**: Return granular highlights, metrics, and architecture scope for a company.
4. **`get_archetype_strategy(archetype_slug)`**: Return reader profile, wants vs needs, and empathy bridges.
5. **`query_oral_history(query)`**: Search across the 211 software engineering interviews and transcripts.
6. **`query_transcript(transcript_id)`**: Retrieve dialogue turns and speaker maps for a specific interview.

### Resource URIs
* `career://datalake/manifest`: Complete master JSON dictionary.
* `career://datalake/technology-provenance`: Technology matrix.
* `career://datalake/archetypes`: 5 archetype strategies.
* `ugtastic://archive/intelligence`: Tropes and phrase statistics.
* `ugtastic://archive/knowledge-graph`: 402-node entity graph.

---

## 4. Cross-Repo Querying for `wwworkremote.localhost`

When agents operating in `wwworkremote.localhost` evaluate job postings or generate tailored applications, they can retrieve deep candidate context in three ways:

1. **HTTP Ingestion:** `GET https://just3ws.localhost/career_datalake.json`
2. **Local CLI Querying:** `ruby /Users/mike/github.com/just3ws/just3ws.github.io/bin/query_career_datalake.rb --tech "<TECH>" --json`
3. **Message Bus Sync:** Peer state is tracked atomically in `~/.local/state/career-os/state.json` and sync events broadcast to `job-leads` via `zdots-ctx`.
