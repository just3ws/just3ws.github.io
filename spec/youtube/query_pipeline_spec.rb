# frozen_string_literal: true

require 'spec_helper'
require 'open3'
require 'json'

RSpec.describe 'Pipeline Query Engine & MCP Integration' do
  let(:root_dir) { File.expand_path('../..', __dir__) }
  let(:query_script) { File.join(root_dir, 'bin', 'query_pipeline.rb') }
  let(:pipeline_runner) { File.join(root_dir, 'bin', 'pipeline') }
  let(:mcp_server) { File.join(root_dir, 'bin', 'mcp_server.js') }

  describe 'Script Hygiene & Structure' do
    it 'exists and is executable' do
      expect(File.exist?(query_script)).to be true
      expect(File.executable?(query_script)).to be true
    end

    it 'contains zero em dashes across query_pipeline.rb' do
      content = File.read(query_script)
      expect(content).not_to include("\u2014")
      expect(content).not_to match(/\s--\s/)
    end

    it 'contains zero em dashes across mcp_server.js' do
      content = File.read(mcp_server)
      expect(content).not_to include("\u2014")
      expect(content).not_to match(/\s--\s/)
    end
  end

  describe 'CLI (bin/query_pipeline.rb)' do
    it 'outputs full dashboard by default' do
      stdout, stderr, status = Open3.capture3(query_script)
      expect(status.success?).to be true
      expect(stdout).to include('MEDIA INTAKE & PUBLISHING PIPELINE STATUS')
      expect(stdout).to include('System Health:')
      expect(stdout).to include('YouTube Quota:')
      expect(stdout).to include('TARGET QUEUES')
    end

    it 'supports --compact flag for one-line status' do
      stdout, stderr, status = Open3.capture3(query_script, '--compact')
      expect(status.success?).to be true
      expect(stdout).to match(/^\[HEALTH:\s+[^\]]+\]/)
      expect(stdout).to include('Queues:')
      expect(stdout).to include('Worker:')
      expect(stdout).to include('Quota:')
    end

    it 'supports --json flag for machine-readable output' do
      stdout, stderr, status = Open3.capture3(query_script, '--json')
      expect(status.success?).to be true
      parsed = JSON.parse(stdout)
      expect(parsed).to have_key('health')
      expect(parsed).to have_key('worker')
      expect(parsed).to have_key('quota')
      expect(parsed).to have_key('queue_summary')
      expect(parsed).to have_key('targets')
      expect(parsed).to have_key('streamer')
    end

    it 'supports --target filter' do
      stdout, stderr, status = Open3.capture3(query_script, '--target', 'phalanx-duel')
      expect(status.success?).to be true
      expect(stdout).to include('phalanx-duel')
      expect(stdout).not_to include('ramblin-amblin')
    end

    it 'supports section filters (--queues, --quota, --worker)' do
      stdout, stderr, status = Open3.capture3(query_script, '--quota', '--json')
      expect(status.success?).to be true
      parsed = JSON.parse(stdout)
      expect(parsed).to have_key('daily_limit')
      expect(parsed).to have_key('units_needed')
      expect(parsed).to have_key('in_cooldown')
    end

    it 'falls back gracefully to disk when streamer daemon is offline' do
      stdout, stderr, status = Open3.capture3(query_script, '-p', '7999', '--json')
      expect(status.success?).to be true
      parsed = JSON.parse(stdout)
      expect(parsed['source']).to eq('disk_fallback')
      expect(parsed['streamer']['status']).to eq('offline')
      expect(parsed).to have_key('health')
      expect(parsed).to have_key('queue_summary')
    end
  end

  describe 'Pipeline Router Integration (bin/pipeline media)' do
    it 'routes bin/pipeline media query' do
      stdout, stderr, status = Open3.capture3(pipeline_runner, 'media', 'query', '--compact')
      expect(status.success?).to be true
      expect(stdout).to match(/^\[HEALTH:\s+[^\]]+\]/)
    end

    it 'routes bin/pipeline media status' do
      stdout, stderr, status = Open3.capture3(pipeline_runner, 'media', 'status', '--compact')
      expect(status.success?).to be true
      expect(stdout).to match(/^\[HEALTH:\s+[^\]]+\]/)
    end

    it 'routes bin/pipeline query' do
      stdout, stderr, status = Open3.capture3(pipeline_runner, 'query', '--compact')
      expect(status.success?).to be true
      expect(stdout).to match(/^\[HEALTH:\s+[^\]]+\]/)
    end
  end

  describe 'MCP Server Integration (bin/mcp_server.js)' do
    it 'exposes query_media_pipeline tool and site://pipeline/status resource' do
      skip 'Node MCP SDK not available' unless system('node -e "require(\"@modelcontextprotocol/sdk/client/index.js\")" >/dev/null 2>&1')

      node_script = <<~NODE
        const { Client } = require("@modelcontextprotocol/sdk/client/index.js");
        const { StdioClientTransport } = require("@modelcontextprotocol/sdk/client/stdio.js");
        const path = require("path");

        async function verify() {
          const transport = new StdioClientTransport({
            command: "node",
            args: ["#{mcp_server}"],
          });
          const client = new Client({ name: "rspec-test", version: "1.0.0" }, { capabilities: {} });
          await client.connect(transport);

          const toolsRes = await client.listTools();
          const toolNames = toolsRes.tools.map(t => t.name);
          if (!toolNames.includes("query_media_pipeline")) {
            throw new Error("Missing query_media_pipeline tool");
          }

          const resourcesRes = await client.listResources();
          const uris = resourcesRes.resources.map(r => r.uri);
          if (!uris.includes("site://pipeline/status")) {
            throw new Error("Missing site://pipeline/status resource");
          }

          const callRes = await client.callTool({
            name: "query_media_pipeline",
            arguments: { section: "summary" }
          });
          if (!callRes.content[0].text.includes("[HEALTH:")) {
            throw new Error("Invalid tool output: " + callRes.content[0].text);
          }

          const readRes = await client.readResource({ uri: "site://pipeline/status" });
          const parsed = JSON.parse(readRes.contents[0].text);
          if (!parsed.health || !parsed.queue_summary) {
            throw new Error("Invalid resource JSON: " + readRes.contents[0].text);
          }

          await client.close();
          console.log("MCP_VERIFIED_CLEAN");
        }
        verify().catch(e => { console.error(e); process.exit(1); });
      NODE

      stdout, stderr, status = Open3.capture3('node', '-e', node_script)
      expect(status.success?).to be true
      expect(stdout).to include('MCP_VERIFIED_CLEAN')
    end
  end
end
