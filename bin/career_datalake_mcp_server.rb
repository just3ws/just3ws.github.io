#!/usr/bin/env ruby
# frozen_string_literal: true

# bin/career_datalake_mcp_server.rb
# Model Context Protocol (MCP) Server for CareerOS Datalake & Oral History Archive.
# Exposes resources and tools over 20+ years of career history, 29 positions,
# 156 technical articles, 211 developer interviews, and 402-node knowledge graph.

require 'json'
require 'yaml'
require 'date'
require 'time'

class CareerDatalakeMCPServer
  ROOT = File.expand_path("..", __dir__)
  DATALAKE_FILE = File.join(ROOT, "career_datalake.json")
  TRANSCRIPTS_DIR = File.join(ROOT, "_data", "transcripts")
  INTELLIGENCE_FILE = File.join(ROOT, "_data", "archive_intelligence.json")
  GRAPH_FILE = File.join(ROOT, "_data", "knowledge_graph.json")

  def initialize
    ensure_datalake_freshness
    @data = JSON.parse(File.read(DATALAKE_FILE)) rescue {}
  end

  def run
    $stdout.sync = true
    $stderr.puts "🚀 Starting CareerOS Datalake MCP Server (STDIO)..."

    $stdin.each_line do |line|
      line = line.strip
      next if line.empty?

      begin
        request = JSON.parse(line)
        response = handle_request(request)
        $stdout.puts(JSON.generate(response)) if response
      rescue StandardError => e
        $stderr.puts "MCP Error: #{e.message}"
      end
    end
  end

  private

  def ensure_datalake_freshness
    unless File.exist?(DATALAKE_FILE)
      system("ruby #{File.join(ROOT, 'bin', 'generate_career_datalake.rb')} > /dev/null 2>&1")
    end
  end

  def handle_request(req)
    id = req["id"]
    method = req["method"]
    params = req["params"] || {}

    case method
    when "initialize"
      {
        jsonrpc: "2.0",
        id: id,
        result: {
          protocolVersion: "2024-11-05",
          capabilities: {
            resources: {},
            tools: {}
          },
          serverInfo: {
            name: "career-datalake-mcp",
            version: "1.0.0"
          }
        }
      }

    when "notifications/initialized"
      nil

    when "resources/list"
      {
        jsonrpc: "2.0",
        id: id,
        result: {
          resources: [
            {
              uri: "career://datalake/manifest",
              name: "CareerOS Datalake Master Manifest",
              mimeType: "application/json",
              description: "Complete career datalake manifest containing profile, 29 positions, case studies, and 156 articles."
            },
            {
              uri: "career://datalake/technology-provenance",
              name: "CareerOS Technology Matrix & Provenance",
              mimeType: "application/json",
              description: "Historical usage, first/last seen year, and roles for 130+ engineering skills."
            },
            {
              uri: "career://datalake/archetypes",
              name: "CareerOS Resume Archetypes & Empathy Bridges",
              mimeType: "application/json",
              description: "5 tailored archetype strategies, reader profiles, and cover-letter empathy anchors."
            },
            {
              uri: "ugtastic://archive/intelligence",
              name: "UGtastic Corpus Intelligence & Tropes",
              mimeType: "application/json",
              description: "Phrase distribution, tropes frequency, and era metrics across 211 interviews (~456k words)."
            },
            {
              uri: "ugtastic://archive/knowledge-graph",
              name: "UGtastic Entity Knowledge Graph Network",
              mimeType: "application/json",
              description: "402 nodes and 612 edges linking interviewees, conferences, user groups, and open source projects."
            }
          ]
        }
      }

    when "resources/read"
      uri = params["uri"].to_s
      content = ""

      case uri
      when "career://datalake/manifest"
        content = File.exist?(DATALAKE_FILE) ? File.read(DATALAKE_FILE) : "{}"
      when "career://datalake/technology-provenance"
        content = JSON.pretty_generate(@data["technology_provenance"] || {})
      when "career://datalake/archetypes"
        content = JSON.pretty_generate(@data["archetypes"] || {})
      when "ugtastic://archive/intelligence"
        content = File.exist?(INTELLIGENCE_FILE) ? File.read(INTELLIGENCE_FILE) : "{}"
      when "ugtastic://archive/knowledge-graph"
        content = File.exist?(GRAPH_FILE) ? File.read(GRAPH_FILE) : "{}"
      else
        content = JSON.generate({ error: "Resource not found: #{uri}" })
      end

      {
        jsonrpc: "2.0",
        id: id,
        result: {
          contents: [
            {
              uri: uri,
              mimeType: "application/json",
              text: content
            }
          ]
        }
      }

    when "tools/list"
      {
        jsonrpc: "2.0",
        id: id,
        result: {
          tools: [
            {
              name: "query_career_history",
              description: "Searches across 20+ years of positions, case studies, 156 blog articles, and technical milestones for a keyword or topic.",
              inputSchema: {
                type: "object",
                properties: {
                  query: { type: "string", description: "Search query (e.g. 'OpenTelemetry', 'legacy modernization', 'Clojure', 'OneMain')" }
                },
                required: ["query"]
              }
            },
            {
              name: "get_technology_provenance",
              description: "Retrieves complete timeline, active era, and specific roles where a technology or skill was used.",
              inputSchema: {
                type: "object",
                properties: {
                  technology: { type: "string", description: "Technology name (e.g. 'PostgreSQL', 'Sidekiq', 'pgvector', 'Rust', 'Docker')" }
                },
                required: ["technology"]
              }
            },
            {
              name: "get_position_dossier",
              description: "Retrieves granular tenure, title, summary, highlights, and skills for a company or role slug.",
              inputSchema: {
                type: "object",
                properties: {
                  company: { type: "string", description: "Company name or slug (e.g. 'onemain', 'emr-bear', 'groupon', 'activecampaign', 'sk-holdings')" }
                },
                required: ["company"]
              }
            },
            {
              name: "get_archetype_strategy",
              description: "Retrieves tailored pitch strategy, target tier, audience psychology, and cover letter empathy anchors for a specific archetype.",
              inputSchema: {
                type: "object",
                properties: {
                  archetype_slug: { type: "string", description: "Archetype slug (e.g. 'principal_systems_architect', 'staff_platform_enablement', 'founding_staff_fullstack', 'observability_resilience_specialist', 'senior_ruby_rails_contractor')" }
                },
                required: ["archetype_slug"]
              }
            },
            {
              name: "query_oral_history",
              description: "Searches across 211 software engineering interviews and transcripts for technical dialogue and concepts.",
              inputSchema: {
                type: "object",
                properties: {
                  query: { type: "string", description: "Search query (e.g. 'Aaron Patterson', 'Ember', 'TDD', 'distributed systems')" }
                },
                required: ["query"]
              }
            },
            {
              name: "query_transcript",
              description: "Retrieves full structured dialogue turns and speaker map for a specific transcript ID.",
              inputSchema: {
                type: "object",
                properties: {
                  transcript_id: { type: "string", description: "Transcript ID slug (e.g. 'jez-humble-goto-conference-2014')" }
                },
                required: ["transcript_id"]
              }
            }
          ]
        }
      }

    when "tools/call"
      name = params["name"]
      arguments = params["arguments"] || {}
      result_text = ""

      case name
      when "query_career_history"
        q = arguments["query"].to_s.downcase
        pos_hits = @data["positions"].select { |k, v| JSON.generate(v).downcase.include?(q) }
        pub_hits = @data["publications_and_writings"].select { |p| (p["title"] || "").downcase.include?(q) || (p["excerpt"] || "").downcase.include?(q) }
        cs_hits = @data["case_studies"].select { |k, v| JSON.generate(v).downcase.include?(q) }

        result_text = JSON.pretty_generate({
          query: arguments["query"],
          total_position_matches: pos_hits.size,
          positions: pos_hits,
          total_case_study_matches: cs_hits.size,
          case_studies: cs_hits,
          total_publication_matches: pub_hits.size,
          publications: pub_hits.first(10)
        })

      when "get_technology_provenance"
        tech = arguments["technology"].to_s.downcase
        matches = @data["technology_provenance"].select { |k, v| k.downcase.include?(tech) }
        result_text = JSON.pretty_generate({ query: arguments["technology"], matches: matches })

      when "get_position_dossier"
        comp = arguments["company"].to_s.downcase
        matches = @data["positions"].select { |k, v| k.downcase.include?(comp) || (v.dig("company", "name") || "").downcase.include?(comp) }
        result_text = JSON.pretty_generate({ company: arguments["company"], matches: matches })

      when "get_archetype_strategy"
        arch = arguments["archetype_slug"].to_s.downcase
        matches = @data["archetypes"].select { |k, v| k.downcase.include?(arch) || (v["file_slug"] || "").downcase.include?(arch) }
        result_text = JSON.pretty_generate({ archetype: arguments["archetype_slug"], matches: matches })

      when "query_oral_history"
        q = arguments["query"].to_s.downcase
        matches = @data["oral_history_corpus"].select do |item|
          (item["title"] || "").downcase.include?(q) || (item["interviewee"] || "").downcase.include?(q)
        end
        result_text = JSON.pretty_generate({ query: arguments["query"], total_matches: matches.size, interviews: matches.first(15) })

      when "query_transcript"
        t_id = arguments["transcript_id"].to_s
        path = File.join(TRANSCRIPTS_DIR, "#{t_id}.yml")
        if File.exist?(path)
          t_data = YAML.load_file(path, permitted_classes: [Date, Time], aliases: true) rescue {}
          result_text = JSON.pretty_generate(t_data)
        else
          result_text = JSON.generate({ error: "Transcript ID '#{t_id}' not found." })
        end

      else
        result_text = JSON.generate({ error: "Unknown tool name '#{name}'" })
      end

      {
        jsonrpc: "2.0",
        id: id,
        result: {
          content: [
            {
              type: "text",
              text: result_text
            }
          ]
        }
      }

    else
      {
        jsonrpc: "2.0",
        id: id,
        error: {
          code: -32601,
          message: "Method not found: #{method}"
        }
      }
    end
  end
end

CareerDatalakeMCPServer.new.run if __FILE__ == $PROGRAM_NAME
