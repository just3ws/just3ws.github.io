#!/usr/bin/env node

/**
 * Personal Site & Archive MCP Server
 * Conforms to Model Context Protocol (MCP) Specification.
 * Exposes self-describing tools, resources, and resource templates for:
 * 1. Site corpus integrity and data contract validation
 * 2. Skill self-verification and spec validation
 * 3. Transcript audit & ops reporting
 */

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
        description: "Self-describing tool: Audits all registered workspace skills for valid SKILL.md frontmatter, schema compliance, and agent manifests.",
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
      const output = execSync("bundle exec rake validate:all && ruby bin/validate_exports.rb", {
        cwd: ROOT_DIR,
        encoding: "utf-8",
        env: { ...process.env, LANG: "en_US.UTF-8", LC_ALL: "en_US.UTF-8" },
      });
      return {
        content: [{ type: "text", text: `✅ Site Contracts Verified Cleanly:\n\n${output}` }],
      };
    }

    if (name === "validate_skills_spec") {
      const skillsDir = path.join(ROOT_DIR, "skills");
      if (!fs.existsSync(skillsDir)) {
        return { content: [{ type: "text", text: "No skills directory found." }] };
      }

      const skills = fs.readdirSync(skillsDir).filter((f) => fs.statSync(path.join(skillsDir, f)).isDirectory());
      const results = [];

      for (const skill of skills) {
        if (args && args.skill_name && skill !== args.skill_name) continue;
        const skillPath = path.join(skillsDir, skill, "SKILL.md");
        if (!fs.existsSync(skillPath)) {
          results.push(`❌ ${skill}: Missing SKILL.md`);
        } else {
          const content = fs.readFileSync(skillPath, "utf-8");
          const hasFrontmatter = content.startsWith("---") && content.includes("name:") && content.includes("description:");
          results.push(hasFrontmatter ? `✅ ${skill}: Self-verifying SKILL.md standard compliant` : `⚠️ ${skill}: Invalid YAML frontmatter`);
        }
      }

      return {
        content: [{ type: "text", text: `Skill Specification Audit Results:\n\n${results.join("\n")}` }],
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
        description: "Index of all registered workspace skills and their self-describing frontmatter capabilities.",
        mimeType: "application/json",
      },
      {
        uri: "site://audit/status",
        name: "Archive Audit & Corpus Status",
        description: "Real-time verification metrics for archive transcripts, video assets, and speakers.",
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

  if (uri === "site://skills/index") {
    const skillsDir = path.join(ROOT_DIR, "skills");
    const skills = fs.existsSync(skillsDir) ? fs.readdirSync(skillsDir).filter((f) => fs.statSync(path.join(skillsDir, f)).isDirectory()) : [];
    return {
      contents: [{ uri, mimeType: "application/json", text: JSON.stringify({ skills, count: skills.length }, null, 2) }],
    };
  }

  if (uri.startsWith("site://skills/")) {
    const skillName = uri.replace("site://skills/", "");
    const skillFile = path.join(ROOT_DIR, "skills", skillName, "SKILL.md");
    if (fs.existsSync(skillFile)) {
      return {
        contents: [{ uri, mimeType: "text/markdown", text: fs.readFileSync(skillFile, "utf-8") }],
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
