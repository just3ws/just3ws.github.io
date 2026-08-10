const { Client } = require("@modelcontextprotocol/sdk/client/index.js");
const { StdioClientTransport } = require("@modelcontextprotocol/sdk/client/stdio.js");
const path = require("path");

async function runSelfVerification() {
  console.log("🔍 Initializing MCP Client for repository self-verification test...");

  const serverScript = path.join(__dirname, "mcp_server.js");
  const transport = new StdioClientTransport({
    command: "node",
    args: [serverScript],
  });

  const client = new Client(
    {
      name: "mcp-verifier-client",
      version: "1.0.0",
    },
    {
      capabilities: {},
    }
  );

  await client.connect(transport);
  console.log("✅ MCP Client connected to just3ws stdio server.");

  // 1. Verify Tools Discovery
  const toolsResponse = await client.listTools();
  console.log(`\n🛠️  Discovered ${toolsResponse.tools.length} Self-Describing MCP Tools:`);
  toolsResponse.tools.forEach((t) => console.log(`   - ${t.name}: ${t.description}`));

  // 2. Verify Resources Discovery
  const resourcesResponse = await client.listResources();
  console.log(`\n📦 Discovered ${resourcesResponse.resources.length} MCP Resources:`);
  resourcesResponse.resources.forEach((r) => console.log(`   - ${r.name} (${r.uri})`));

  // 3. Execute verify_site_contracts tool
  console.log("\n🧪 Executing 'verify_site_contracts' via MCP...");
  const verifyResult = await client.callTool({
    name: "verify_site_contracts",
    arguments: { strict: true },
  });
  console.log(verifyResult.content[0].text);

  // 4. Execute validate_skills_spec tool
  console.log("\n🧪 Executing 'validate_skills_spec' via MCP...");
  const skillsResult = await client.callTool({
    name: "validate_skills_spec",
    arguments: {},
  });
  console.log(skillsResult.content[0].text);

  await client.close();
  console.log("\n🎉 MCP Spec Self-Verification Suite completed successfully!");
}

runSelfVerification().catch((err) => {
  console.error("❌ MCP Verification failed:", err);
  process.exit(1);
});
