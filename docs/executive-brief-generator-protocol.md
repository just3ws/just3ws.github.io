# Wayfinder Protocol: Cross-Repo Executive Pitch Brief Generation

This document defines the architecture, parameters, MCP tool contracts, CLI interfaces, and bus messaging protocols enabling **`wwworkremote.localhost`** (Job Market Intelligence & Search Engine) to command **`just3ws.localhost`** (Candidate History & Public Portfolio) to generate on-demand, tailored **1-Page Executive Pitch Briefs and Interview Prep Sheets**.

---

## 1. System Overview & Interaction Topology

```
+--------------------------------------------------------------------------------------------------+
|                                    wwworkremote.localhost                                        |
|                          (Job Leads, Ingested Postings, LLM Matcher)                             |
+--------------------------------------------------------------------------------------------------+
                                        |
           +----------------------------+----------------------------+
           | (MCP Tool Call)            | (CLI Execution)            | (zdots Message Bus)
           v                            v                            v
+--------------------------------------------------------------------------------------------------+
|                                      just3ws.localhost                                           |
|                            (CareerOS Datalake & Resume Engine)                                   |
+--------------------------------------------------------------------------------------------------+
  1. Synthesizes Canonical 3-Act Narrative & 4D Cartography Evidence
  2. Creates Markdown Brief in `docs/executive-briefs/<slug>.md`
  3. Compiles Semantic HTML Page at `https://just3ws.localhost/exports/briefs/<slug>/`
  4. Generates Vector PDF at `exports/briefs/pdfs/<slug>-executive-brief-mike-hall.pdf`
  5. Calibrates 30-Second "Answer, Frame, and Pause" Interview Script
```

---

## 2. Interface 1: CareerOS Model Context Protocol (MCP)

When an AI agent (Claude Code, Antigravity, Codex CLI, Cursor) operates within `wwworkremote.localhost` or a shared developer terminal, it connects directly to the CareerOS MCP server (`bin/career_datalake_mcp_server.rb`).

### MCP Tool: `generate_executive_brief`

#### Parameters Specification:

| Parameter | Type | Required | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `company` | `string` | **Yes** | — | Target company name (e.g. `Huntress`, `Coder`, `NextPatient`). |
| `role` | `string` | No | `"Principal Software Engineer"` | Exact target role title from job posting. |
| `domain` | `string` | No | `"<role> Platform Architecture"` | Engineering domain focus (e.g. `SOC / Rails`, `Legacy Modernization`). |
| `comp_range` | `string` | No | `nil` | Target compensation string (e.g. `"$200,000 to $260,000 / yr"`). |
| `target_tier` | `string` | No | `"principal"` | Archetype tier: `principal`, `staff`, `founding`, `contractor`, `observability`. |
| `company_mandate`| `string` | No | Standard platform mandate | Summary of what the company is scaling, de-risking, or modernizing. |

#### Example Tool Call Payload:

```json
{
  "name": "generate_executive_brief",
  "arguments": {
    "company": "Huntress",
    "role": "Principal Software Engineer",
    "domain": "Cybersecurity / SOC / Rails",
    "comp_range": "$200,000 to $260,000 / yr (Remote, US)",
    "target_tier": "principal",
    "company_mandate": "Scaling high-concurrency Ruby on Rails platforms that power 24/7 Security Operations Center (SOC) threat detection and incident response."
  }
}
```

#### Structured Tool Response:

```json
{
  "status": "ok",
  "company": "Huntress",
  "role": "Principal Software Engineer",
  "tier": "principal",
  "markdown_path": "/Users/mike/github.com/just3ws/just3ws.github.io/docs/executive-briefs/huntress_principal_software_engineer.md",
  "localhost_url": "https://just3ws.localhost/exports/briefs/huntress-principal-software-engineer/",
  "pdf_path": "exports/briefs/pdfs/huntress-principal-software-engineer-executive-brief-mike-hall.pdf",
  "calibration_script": "\"I specialize in high-consequence Ruby on Rails and distributed platforms where uptime, data integrity, and deep observability are non-negotiable...\"",
  "calibration_hook": "\"I can dive deeper into how we traced distributed state across Rails and backend gateways, or we can look at how we built the 5-phase database deletion engine. Which direction would you prefer to explore?\""
}
```

---

## 3. Interface 2: CLI Command Line Engine

Any script, cron job, or subagent can invoke the generator directly from the command line:

```bash
ruby bin/generate_executive_brief.rb \
  --company "Huntress" \
  --role "Principal Software Engineer" \
  --domain "SOC / Rails Platform" \
  --tier "principal" \
  --comp "$200,000 to $260,000 / yr" \
  --mandate "Scaling 24/7 high-concurrency event ingestion for SOC operations" \
  --pdf \
  --json
```

### CLI Flag Reference:

* `-c, --company COMPANY` : **(Required)** Target organization name.
* `-r, --role ROLE` : Role title (default: `Principal Software Engineer`).
* `-d, --domain DOMAIN` : Core technical domain or platform focus.
* `--comp COMP` : Compensation range note.
* `-t, --tier TIER` : Target archetype tier (`principal`, `staff`, `founding`, `contractor`, `observability`).
* `-m, --mandate TEXT` : Mission/mandate summary describing the technical challenge.
* `-k, --key-pains LIST` : Comma-separated list of key technical bottlenecks.
* `-l, --lead-id ID` : Optional `wwworkremote` lead ID for provenance linking.
* `-p, --posting-id ID` : Optional `wwworkremote` posting ID.
* `--[no-]html` : Compiles Jekyll HTML page (default: true).
* `--pdf` : Generates vector PDF export via headless browser.
* `-j, --json` : Outputs machine-parsable JSON for automation pipelines.

---

## 4. Interface 3: Cross-Repo Message Bus (`zdots-ctx bus-*`)

When systems run asynchronously across different terminal windows, `wwworkremote` communicates with `just3ws` over the `job-leads` bus channel:

### 1. Request Message (`wwworkremote` -> `agent-just3ws`):

```bash
zdots-ctx bus-post job-leads '{
  "event": "REQUEST_EXECUTIVE_BRIEF",
  "lead_id": 126,
  "company": "Huntress",
  "role": "Principal Software Engineer",
  "domain": "SOC / Rails",
  "comp_range": "$200k-$260k",
  "target_tier": "principal",
  "requester": "agent-wwworkremote"
}' --as agent-wwworkremote
```

### 2. Fulfillment Broadcast (`agent-just3ws` -> `wwworkremote`):

```bash
zdots-ctx bus-post job-leads '{
  "event": "EXECUTIVE_BRIEF_GENERATED",
  "lead_id": 126,
  "company": "Huntress",
  "localhost_url": "https://just3ws.localhost/exports/briefs/huntress-principal-software-engineer/",
  "pdf_path": "exports/briefs/pdfs/huntress-principal-software-engineer-executive-brief-mike-hall.pdf",
  "ats_composite_score": "97.3%",
  "status": "ready"
}' --as agent-just3ws
```

---

## 5. Synthesis Rules & Content Constraints

Every generated executive brief must strictly uphold the following standards:

1. **The 3-Act Narrative Alignment:**
   * **Act 1 (Foundation):** Autodidact roots, Software Craftsmanship, TDD rigor, Chicago community leadership.
   * **Act 2 (Crucible):** High-Consequence Stabilizer (OneMain Acquisition Lane Architect, 7 ingress channels, 5-phase PII remediation engine across 30+ tables, 4% traffic loss elimination, 3-year Geekfest/OTel WG community arc).
   * **Act 3 (Offering):** Calm, deterministic platform leadership, local AI orchestration, and production resilience.
2. **Progressive Disclosure & The "Answer, Frame, and Pause" Rule:**
   * Includes a self-contained 30-to-45-second spoken calibration script for live interviews.
   * Ends with an explicit pause and two technical choices for the interviewer to direct.
3. **Punctuation & Human Voice:**
   * **Zero em dashes (`—`, `--`, ` - ` as pauses).** Use colons, semicolons, parentheses, or periods.
4. **Privacy & System Boundaries:**
   * No internal proprietary table names, internal column names, or microservice endpoint identifiers.
   * Ground all claims in generic architectural patterns and attested numbers from `_data/resume/`.

---

## 6. Generated Output Locations

* **Markdown Source:** `docs/executive-briefs/<company_slug>_<role_slug>.md`
* **Localhost Web Surface:** `https://just3ws.localhost/exports/briefs/<company_slug>-<role_slug>/`
* **Vector PDF Document:** `exports/briefs/pdfs/<company_slug>-<role_slug>-executive-brief-mike-hall.pdf`
