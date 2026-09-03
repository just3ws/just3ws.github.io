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
require 'sqlite3'

class CareerDatalakeMCPServer
  ROOT = File.expand_path("..", __dir__)
  DATALAKE_FILE = File.join(ROOT, "career_datalake.json")
  TRANSCRIPTS_DIR = File.join(ROOT, "_data", "transcripts")
  INTELLIGENCE_FILE = File.join(ROOT, "_data", "archive_intelligence.json")
  GRAPH_FILE = File.join(ROOT, "_data", "knowledge_graph.json")
  WITC_DB = ENV.fetch("WITC_CORPUS_DB", File.join(ROOT, "lake", "witc", "corpus.db"))

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
              uri: "career://datalake/narrative-synthesis",
              name: "CareerOS 3-Act Narrative & Cover Letter Synthesis Baseline",
              mimeType: "application/json",
              description: "Canonical 3-Act Career Narrative (Foundation, Crucible, Offering) and Cover Letter Synthesis Blueprint."
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
            },
            {
              uri: "witc://archive/manifest",
              name: "WITC Local Corpus Manifest",
              mimeType: "application/json",
              description: "Provenance and safety metadata for the local WHOIS Tech Community and UGtastic SQLite corpus."
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
      when "career://datalake/narrative-synthesis"
        content = JSON.pretty_generate(@data["narrative_synthesis"] || {})
      when "ugtastic://archive/intelligence"
        content = File.exist?(INTELLIGENCE_FILE) ? File.read(INTELLIGENCE_FILE) : "{}"
      when "ugtastic://archive/knowledge-graph"
        content = File.exist?(GRAPH_FILE) ? File.read(GRAPH_FILE) : "{}"
      when "witc://archive/manifest"
        content = witc_manifest
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
                  company: { type: "string", description: "Company name or slug (e.g. 'onemain', 'groupon', 'activecampaign', 'sk-holdings')" }
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
            },
            {
              name: "query_witc_corpus",
              description: "Searches the local WITC/UGtastic SQLite corpus with bounded, provenance-preserving results.",
              inputSchema: {
                type: "object",
                properties: {
                  query: { type: "string", description: "Search terms" },
                  kind: { type: "string", description: "Optional source kind: transcript, metadata, documentation, or source" },
                  limit: { type: "integer", description: "Maximum results, capped at 100" }
                },
                required: ["query"]
              }
            },
            {
              name: "get_witc_corpus_stats",
              description: "Returns counts and time bounds for the local WITC/UGtastic corpus.",
              inputSchema: { type: "object", properties: {} }
            },
            {
              name: "get_narrative_synthesis_baseline",
              description: "Retrieves the canonical 3-Act Career Narrative (Foundation, Crucible, Offering) and Cover Letter Synthesis Blueprint for synthesizing custom pitch memos and cover letters against target job leads.",
              inputSchema: {
                type: "object",
                properties: {
                  focus_domain: { type: "string", description: "Optional focus area to filter proof points (e.g. 'modernization', 'observability', 'ai_systems', 'leadership', 'general')" }
                }
              }
            },
            {
              name: "generate_executive_brief",
              description: "Generates a tailored 1-page executive pitch brief and interview prep sheet on just3ws.localhost using the 3-Act Narrative baseline, 4D System Cartography evidence, and Progressive Disclosure.",
              inputSchema: {
                type: "object",
                properties: {
                  company: { type: "string", description: "Target company name (e.g. 'Huntress', 'Coder', 'NextPatient')" },
                  role: { type: "string", description: "Target role title (default: 'Principal Software Engineer')" },
                  domain: { type: "string", description: "Target engineering domain (e.g. 'SOC / Rails', 'Platform Architecture', 'Legacy Modernization')" },
                  comp_range: { type: "string", description: "Optional compensation range (e.g. '$200,000 to $260,000 / yr')" },
                  target_tier: { type: "string", description: "Target archetype tier: 'principal', 'staff', 'founding', 'contractor', 'observability'" },
                  company_mandate: { type: "string", description: "Company mandate or engineering challenge description" }
                },
                required: ["company"]
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
      when "generate_executive_brief"
        company = arguments["company"].to_s.strip
        role = arguments["role"] || "Principal Software Engineer"
        domain = arguments["domain"] || "#{role} Platform Architecture"
        tier = arguments["target_tier"] || "principal"
        comp = arguments["comp_range"]
        mandate = arguments["company_mandate"] || "scaling high-reliability production platforms and modernizing critical legacy architectures"

        cmd = [
          "ruby",
          File.join(ROOT, "bin", "generate_executive_brief.rb"),
          "-c", company,
          "-r", role,
          "-d", domain,
          "-t", tier,
          "-m", mandate,
          "--json"
        ]
        cmd += ["--comp", comp] if comp && !comp.empty?

        require "shellwords"
        out = `#{cmd.shelljoin}`
        result_text = out.strip

      when "get_narrative_synthesis_baseline"
        domain = (arguments["focus_domain"] || "general").to_s.downcase
        baseline = @data["narrative_synthesis"] || {}
        result_text = JSON.pretty_generate({
          framework: baseline["framework"],
          narrative_acts: baseline["narrative_acts"],
          cover_letter_synthesis_blueprint: baseline["cover_letter_synthesis_blueprint"],
          focus_domain: domain,
          verified_proof_points: [
            "Speedfunds instant loan disbursement (minutes vs multi-day ACH)",
            "Architecture discovery across 7 heterogeneous acquisition channels",
            "5-phase automated PII deletion engine across 30+ tables and legacy clarity_ orphans",
            "Elimination of 4% silent traffic loss defect via DynamoDB session storage remediation",
            "3-year enterprise community arc (Geekfest and OTel WG) transitioned sustainably to SRE"
          ]
        })

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

      when "query_witc_corpus"
        result_text = JSON.pretty_generate(query_witc(arguments["query"], arguments["kind"], arguments["limit"]))

      when "get_witc_corpus_stats"
        result_text = JSON.pretty_generate(witc_stats)

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

  def witc_db
    return nil unless File.file?(WITC_DB)
    db = SQLite3::Database.new(WITC_DB)
    db.results_as_hash = true
    db
  end

  def witc_manifest
    db = witc_db
    return JSON.generate({ "corpus" => "witc", "available" => false, "database" => WITC_DB }) unless db
    rows = db.execute("SELECT key, value FROM corpus_metadata").to_h do |r|
      value = begin
        JSON.parse(r["value"])
      rescue JSON::ParserError
        r["value"]
      end
      [r["key"], value]
    end
    db.close
    JSON.pretty_generate(rows.merge("available" => true, "database" => WITC_DB))
  end

  def witc_stats
    db = witc_db
    return { "corpus" => "witc", "available" => false, "database" => WITC_DB } unless db
    result = { "corpus" => "witc", "available" => true, "database" => WITC_DB, "documents" => db.get_first_value("SELECT COUNT(*) FROM documents"), "threads" => db.get_first_value("SELECT COUNT(*) FROM threads"), "by_kind" => db.execute("SELECT source_kind, COUNT(*) AS count FROM documents GROUP BY source_kind").to_h { |r| [r["source_kind"], r["count"]] } }
    db.close
    result
  end

  def query_witc(query, kind, requested_limit)
    db = witc_db
    return { "corpus" => "witc", "available" => false, "database" => WITC_DB } unless db
    requested = requested_limit.to_i
    limit = [[requested, 1].max, 100].min
    limit = 20 if requested.zero?
    clauses = ["documents_fts MATCH ?"]
    params = [query.to_s]
    if kind && !kind.to_s.empty?
      clauses << "d.source_kind = ?"; params << kind.to_s
    end
    rows = db.execute("SELECT d.id, substr(d.content, 1, 1600) AS excerpt, d.source_path, d.project, d.source_kind, d.created_at, d.time_kind, d.sha256 FROM documents_fts f JOIN documents d ON d.id = f.doc_ref WHERE #{clauses.join(' AND ')} ORDER BY bm25(documents_fts), d.created_at LIMIT ?", params + [limit])
    db.close
    { "corpus" => "witc", "query" => query, "count" => rows.size, "records" => rows.map { |r| r.merge("created_at_iso" => Time.at(r["created_at"]).utc.iso8601) } }
  end
end

CareerDatalakeMCPServer.new.run if __FILE__ == $PROGRAM_NAME
