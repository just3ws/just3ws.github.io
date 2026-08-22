# UGtastic Archive Model Context Protocol (MCP) Integration Guide

The **UGtastic Archive** is 100% **MCP-ready**! Any AI assistant or agent client supporting the Model Context Protocol (MCP): including Claude Desktop, Antigravity, Cursor, Windsurf, or custom LLM pipelines: can connect directly to this repository to inspect, search, and reason over the entire **207-interview canon (~456,000 words)**.

---

## 1. Quick Setup Configuration

Add the following to your MCP client configuration (e.g. `~/.config/Claude/claude_desktop_config.json` or `~/.gemini/antigravity-cli/mcp_config.json`):

```json
{
  "mcpServers": {
    "ugtastic-archive": {
      "command": "ruby",
      "args": [
        "/Users/mike/github.com/just3ws/just3ws.github.io/bin/ugtastic_mcp_server.rb"
      ]
    }
  }
}
```

---

## 2. Available MCP Resources

The MCP server exposes standard URIs for instant context loading:

| Resource URI | Description | MIME Type |
| :--- | :--- | :--- |
| `ugtastic://archive/intelligence` | Phrase statistics, tropes distribution, and era metrics across 207 interviews (~456k words). | `application/json` |
| `ugtastic://archive/knowledge-graph` | 402-node, 612-edge force-directed entity network linking speakers, conferences, and topics. | `application/json` |
| `ugtastic://archive/timeline` | 17-year historical era timeline (2009–2026) with conference milestones. | `application/json` |

---

## 3. Available MCP Tools

AI agents can execute real-time tools over STDIO:

1. `query_transcript(transcript_id)`
   - **Description:** Retrieves full structured dialogue turns, timestamps, and speaker maps for a specific transcript slug (e.g. `jez-humble-goto-conference-2014`).
2. `search_archive(query)`
   - **Description:** Performs instant keyword and concept searching across all 207 transcript YAML files, returning matching turns and snippet contexts.

---

## 4. Testing the MCP Server Standalone

You can test the MCP server directly via terminal:

```bash
ruby bin/ugtastic_mcp_server.rb
```
Or run the automated protocol check:
```bash
ruby -r json -e '
require "open3"
Open3.popen3("ruby bin/ugtastic_mcp_server.rb") do |stdin, stdout|
  stdin.puts JSON.generate({ jsonrpc: "2.0", id: 1, method: "tools/list", params: {} })
  puts stdout.gets
end
'
```
