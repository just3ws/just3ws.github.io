#!/usr/bin/env node
// ---
// name: mcp_server.js
// domain: validate
// role: Personal Site & Archive MCP Server (Node.js STDIO)
// description: >
//   Exposes self-describing MCP tools, resources, and resource templates for
//   site corpus integrity, skill spec verification (.agents/skills and skills),
//   and transcript audit reporting.
// usage:
//   node bin/mcp_server.js
// ---

const { Server } = require("@modelcontextprotocol/sdk/server/index.js");
const { StdioServerTransport } = require("@modelcontextprotocol/sdk/server/stdio.js");
const {
  CallToolRequestSchema,
  ListToolsRequestSchema,
  ListResourcesRequestSchema,
  ReadResourceRequestSchema,
  ListResourceTemplatesRequestSchema,
} = require("@modelcontextprotocol/sdk/types.js");
const { execSync } = require("child_process");
const fs = require("fs");
const path = require("path");

const ROOT_DIR = path.resolve(__dirname, "..");

function discoverWorkspaceSkills() {
  const roots = [
    { label: ".agents/skills", dir: path.join(ROOT_DIR, ".agents", "skills") },
    { label: "skills", dir: path.join(ROOT_DIR, "skills") },
  ];
  const map = new Map();
  for (const r of roots) {
    if (!fs.existsSync(r.dir)) continue;
    for (const entry of fs.readdirSync(r.dir)) {
      const fullDir = path.join(r.dir, entry);
      if (!fs.statSync(fullDir).isDirectory()) continue;
      const skillFile = fs.existsSync(path.join(fullDir, "SKILL.md"))
        ? path.join(fullDir, "SKILL.md")
        : fs.existsSync(path.join(fullDir, "skill.md"))
        ? path.join(fullDir, "skill.md")
        : null;
      if (!map.has(entry)) {
        map.set(entry, { name: entry, source: r.label, skillFile });
      }
    }
  }
  return Array.from(map.values()).sort((a, b) => a.name.localeCompare(b.name));
}

const server = new Server(
  {
    name: "just3ws-mcp-server",
    version: "1.0.0",
  },
  {
    capabilities: {
      tools: {},
      resources: {},
      resourceTemplates: {},
    },
  }
);

/**
 * Self-describing MCP Tools Definition
 */
server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: [
      {
        name: "verify_site_contracts",
        description: "Self-verifying tool: Runs declarative schema validation, export parity checks, and transcript audits across the repository.",
        inputSchema: {
          type: "object",
          properties: {
            strict: {
              type: "boolean",
              description: "Whether to fail fast on any soft warning.",
              default: true,
            },
          },
        },
      },
      {
        name: "validate_skills_spec",
        description: "Self-describing tool: Audits all registered workspace skills (.agents/skills and skills) for valid SKILL.md frontmatter, schema compliance, and zero em dashes.",
        inputSchema: {
          type: "object",
          properties: {
            skill_name: {
              type: "string",
              description: "Optional specific skill directory to validate. Omit to validate all.",
            },
          },
        },
      },
      {
        name: "audit_transcript_corpus",
        description: "Self-describing tool: Runs structural, turn-segmentation, and speaker-map integrity checks on transcript YAML data.",
        inputSchema: {
          type: "object",
          properties: {
            detailed: {
              type: "boolean",
              description: "Return complete audit breakdown including short transcripts and ending validations.",
              default: true,
            },
          },
        },
      },
      {
        name: "query_media_pipeline",
        description: "Lightweight tool: Queries the live media intake queue, YouTube publishing status, worker lock, quota cooldown, and recent events.",
        inputSchema: {
          type: "object",
          properties: {
            section: {
              type: "string",
              description: "Optional section to query: 'all', 'summary', 'queues', 'quota', 'worker', 'activity'.",
              enum: ["all", "summary", "queues", "quota", "worker", "activity"],
              default: "all",
            },
            target: {
              type: "string",
              description: "Optional specific target filter (e.g. 'phalanx-duel', 'ramblin-amblin', 'the-sound-above', 'errata').",
            },
            format: {
              type: "string",
              description: "Output format: 'text' (human readable summary) or 'json' (raw structured data).",
              enum: ["text", "json"],
              default: "text",
            },
          },
        },
      },
    ],
  };
});

/**
 * Handle MCP Tool Execution Requests
 */
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  try {
    if (name === "verify_site_contracts") {
      const output = execSync("bundle exec rake validate:all && ruby bin/validate_exports.rb && ruby bin/validate_repo_hygiene.rb", {
        cwd: ROOT_DIR,
        encoding: "utf-8",
        env: { ...process.env, LANG: "en_US.UTF-8", LC_ALL: "en_US.UTF-8" },
      });
      return {
        content: [{ type: "text", text: `✅ Site Contracts Verified Cleanly:\n\n${output}` }],
      };
    }

    if (name === "validate_skills_spec") {
      const discovered = discoverWorkspaceSkills();
      if (discovered.length === 0) {
        return { content: [{ type: "text", text: "No skills directories found." }] };
      }

      const results = [];
      for (const item of discovered) {
        if (args && args.skill_name && item.name !== args.skill_name) continue;
        if (!item.skillFile) {
          results.push(`❌ ${item.name} (${item.source}): Missing SKILL.md`);
        } else {
          const content = fs.readFileSync(item.skillFile, "utf-8");
          const hasFrontmatter = content.startsWith("---") && content.includes("name:") && content.includes("description:");
          results.push(hasFrontmatter ? `✅ ${item.name} (${item.source}): Self-verifying SKILL.md standard compliant` : `⚠️ ${item.name} (${item.source}): Invalid YAML frontmatter`);
        }
      }

      return {
        content: [{ type: "text", text: `Skill Specification Audit Results (${results.length} skills):\n\n${results.join("\n")}` }],
      };
    }

    if (name === "audit_transcript_corpus") {
      const output = execSync("./bin/transcripts audit", {
        cwd: ROOT_DIR,
        encoding: "utf-8",
      });
      return {
        content: [{ type: "text", text: `Transcript Corpus Audit Report:\n\n${output}` }],
      };
    }

    if (name === "query_media_pipeline") {
      const argsList = [];
      if (args && args.format === "json") argsList.push("--json");
      if (args && args.section === "queues") argsList.push("--queues");
      if (args && args.section === "quota") argsList.push("--quota");
      if (args && args.section === "worker") argsList.push("--worker");
      if (args && args.section === "activity") argsList.push("--activity");
      if (args && args.section === "summary") argsList.push("--compact");
      if (args && args.target) argsList.push(`--target "${args.target}"`);

      const cmd = `ruby bin/query_pipeline.rb ${argsList.join(" ")}`.trim();
      const output = execSync(cmd, {
        cwd: ROOT_DIR,
        encoding: "utf-8",
      });
      return {
        content: [{ type: "text", text: output.trim() }],
      };
    }

    throw new Error(`Unknown tool: ${name}`);
  } catch (error) {
    return {
      isError: true,
      content: [{ type: "text", text: `Tool execution failed: ${error.message}\n${error.stdout || ""}` }],
    };
  }
});

/**
 * Self-describing MCP Resources Definition
 */
server.setRequestHandler(ListResourcesRequestSchema, async () => {
  return {
    resources: [
      {
        uri: "site://contracts/schema",
        name: "Site Data Schema Contracts",
        description: "Self-describing JSON schema rules for positions, profile, and navigation data.",
        mimeType: "application/json",
      },
      {
        uri: "site://skills/index",
        name: "Registered Workspace Skills",
        description: "Index of all registered workspace skills (.agents/skills and skills) and their self-describing frontmatter capabilities.",
        mimeType: "application/json",
      },
      {
        uri: "site://audit/status",
        name: "Archive Audit & Corpus Status",
        description: "Real-time verification metrics for archive transcripts, video assets, and speakers.",
        mimeType: "application/json",
      },
      {
        uri: "site://pipeline/status",
        name: "Live Media Pipeline Status",
        description: "Real-time queue counts, worker lock state, quota cooldown status, and recent activity.",
        mimeType: "application/json",
      },
    ],
  };
});

/**
 * Self-describing MCP Resource Templates
 */
server.setRequestHandler(ListResourceTemplatesRequestSchema, async () => {
  return {
    resourceTemplates: [
      {
        uriTemplate: "site://skills/{skill_name}",
        name: "Skill Specification View",
        description: "Retrieve self-describing SKILL.md specification for any registered workspace skill.",
        mimeType: "text/markdown",
      },
    ],
  };
});

/**
 * Handle MCP Resource Read Requests
 */
server.setRequestHandler(ReadResourceRequestSchema, async (request) => {
  const { uri } = request.params;

  if (uri === "site://contracts/schema") {
    const validatorPath = path.join(ROOT_DIR, "src", "validators", "site_schema.rb");
    const content = fs.existsSync(validatorPath) ? fs.readFileSync(validatorPath, "utf-8") : "{}";
    return {
      contents: [{ uri, mimeType: "text/plain", text: content }],
    };
  }

  if (uri === "site://audit/status" || uri === "site://pipeline/status") {
    const output = execSync("ruby bin/query_pipeline.rb --json", {
      cwd: ROOT_DIR,
      encoding: "utf-8",
    });
    return {
      contents: [{ uri, mimeType: "application/json", text: output.trim() }],
    };
  }

  if (uri === "site://skills/index") {
    const discovered = discoverWorkspaceSkills();
    return {
      contents: [{
        uri,
        mimeType: "application/json",
        text: JSON.stringify({
          skills: discovered.map((s) => s.name),
          entries: discovered,
          count: discovered.length,
        }, null, 2),
      }],
    };
  }

  if (uri.startsWith("site://skills/")) {
    const skillName = uri.replace("site://skills/", "");
    const match = discoverWorkspaceSkills().find((s) => s.name === skillName);
    if (match && match.skillFile && fs.existsSync(match.skillFile)) {
      return {
        contents: [{ uri, mimeType: "text/markdown", text: fs.readFileSync(match.skillFile, "utf-8") }],
      };
    }
  }

  throw new Error(`Resource not found: ${uri}`);
});

async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error("just3ws MCP Server running on stdio");
}

main().catch((err) => {
  console.error("Fatal error in MCP Server:", err);
  process.exit(1);
});
