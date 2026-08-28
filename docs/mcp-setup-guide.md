# CareerOS Datalake & UGtastic Archive Model Context Protocol (MCP) Guide

This repository exposes its entire **20+ year engineering datalake** and **211-interview oral history corpus (~456,000 words)** via standard Model Context Protocol (MCP) STDIO servers.

Any MCP client: including **Claude Code**, **Claude Desktop**, **Antigravity**, **Cursor**, **Windsurf**, or custom agent pipelines: can connect directly to inspect, query, and reason over Mike Hall's complete career provenance.

---

## 1. Registered MCP Servers

The repository configuration is defined in [`mcp.json`](file:///Users/mike/github.com/just3ws/just3ws.github.io/mcp.json):

```json
{
  "mcpServers": {
    "career-datalake": {
      "command": "ruby",
      "args": [
        "/Users/mike/github.com/just3ws/just3ws.github.io/bin/career_datalake_mcp_server.rb"
      ],
      "description": "Model Context Protocol (MCP) server exposing 20+ years of career datalake history, 29 positions, technology provenance matrix, 156 technical writings, case studies, and reader empathy strategies."
    },
    "ugtastic-archive": {
      "command": "ruby",
      "args": [
        "/Users/mike/github.com/just3ws/just3ws.github.io/bin/ugtastic_mcp_server.rb"
      ],
      "description": "Model Context Protocol (MCP) interface exposing 207 historical developer interviews, 402-node knowledge graph, and search capabilities over the UGtastic oral history canon."
    }
  }
}
```

---

## 2. Client Setup Configurations

### A. Claude Code / Antigravity CLI
Add to `~/.gemini/antigravity-cli/mcp_config.json` or project MCP config:

```json
{
  "mcpServers": {
    "career-datalake": {
      "command": "ruby",
      "args": [
        "/Users/mike/github.com/just3ws/just3ws.github.io/bin/career_datalake_mcp_server.rb"
      ]
    }
  }
}
```

### B. Claude Desktop
Add to `~/Library/Application Support/Claude/claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "career-datalake": {
      "command": "ruby",
      "args": [
        "/Users/mike/github.com/just3ws/just3ws.github.io/bin/career_datalake_mcp_server.rb"
      ]
    }
  }
}
```

### C. Cursor / Windsurf
In **Settings → Features → MCP**, add a new STDIO server:
* **Name:** `career-datalake`
* **Command:** `ruby`
* **Args:** `/Users/mike/github.com/just3ws/just3ws.github.io/bin/career_datalake_mcp_server.rb`

---

## 3. Callable MCP Tools Reference

The `career-datalake` MCP server equips agents with the following tools:

### 1. `query_career_history(query: string)`
* **Description:** Performs multi-corpus search across positions, case studies, 156 blog articles, and engineering milestones.
* **Example:** `query_career_history("legacy modernization")`

### 2. `get_technology_provenance(technology: string)`
* **Description:** Retrieves the active era, first/last seen year, total occurrences, and specific roles where a technology or skill was applied.
* **Example:** `get_technology_provenance("OpenTelemetry")` or `get_technology_provenance("pgvector")`

### 3. `get_position_dossier(company: string)`
* **Description:** Retrieves granular tenure, title, summary, quantified highlights, and skills for a company or role slug.
* **Example:** `get_position_dossier("onemain")` or `get_position_dossier("groupon")`

### 4. `get_archetype_strategy(archetype_slug: string)`
* **Description:** Retrieves tailored pitch strategy, target tier, audience psychology, wants vs needs, and cover letter empathy anchors.
* **Slugs:** `principal_systems_architect`, `staff_platform_enablement`, `observability_resilience_specialist`, `founding_staff_fullstack`, `senior_ruby_rails_contractor`.
* **Example:** `get_archetype_strategy("principal_systems_architect")`

### 5. `query_oral_history(query: string)`
* **Description:** Searches across 211 software engineering interviews and transcripts for technical dialogue and concepts.
* **Example:** `query_oral_history("Aaron Patterson")`

### 6. `query_transcript(transcript_id: string)`
* **Description:** Retrieves full structured dialogue turns, timestamps, and speaker maps for a specific interview transcript ID.
* **Example:** `query_transcript("jez-humble-goto-conference-2014")`

---

## 4. Available MCP Resources

Agents can read structured data via MCP resource URIs:

| Resource URI | Description | MIME Type |
| :--- | :--- | :--- |
| `career://datalake/manifest` | Complete CareerOS master datalake manifest (550+ KB JSON). | `application/json` |
| `career://datalake/technology-provenance` | Complete matrix of 136 engineering skills and active eras. | `application/json` |
| `career://datalake/archetypes` | 5 tailored resume archetype strategies and empathy bridges. | `application/json` |
| `ugtastic://archive/intelligence` | Phrase statistics and tropes frequency across 211 interviews. | `application/json` |
| `ugtastic://archive/knowledge-graph` | 402-node entity graph linking guests, conferences, and technologies. | `application/json` |

---

## 5. Standalone Testing & Verification

You can test the MCP server directly via terminal using JSON-RPC STDIO:

```bash
# Test MCP tools/list
echo '{"jsonrpc":"2.0","id":1,"method":"tools/list","params":{}}' | ruby bin/career_datalake_mcp_server.rb

# Test MCP tool call
echo '{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"get_technology_provenance","arguments":{"technology":"pgvector"}}}' | ruby bin/career_datalake_mcp_server.rb
```
