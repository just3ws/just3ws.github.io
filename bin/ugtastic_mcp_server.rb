#!/usr/bin/env ruby
# frozen_string_literal: true

# bin/ugtastic_mcp_server.rb — Model Context Protocol (MCP) Server for UGtastic Archive
#
# Implements a standard JSON-RPC 2.0 STDIO MCP server exposing resources and tools
# over the 207 historical interviews (~456,000 words), knowledge graph, and intelligence datasets.

require 'json'
require 'yaml'

class UGtasticMCPServer
  ROOT = File.expand_path("..", __dir__)
  TRANSCRIPTS_DIR = File.join(ROOT, "_data", "transcripts")
  INTELLIGENCE_FILE = File.join(ROOT, "_data", "archive_intelligence.json")
  GRAPH_FILE = File.join(ROOT, "_data", "knowledge_graph.json")

  def run
    $stdout.sync = true
    $stderr.puts "🚀 Starting UGtastic Archive MCP Server (STDIO)..."

    $stdin.each_line do |line|
      line = line.strip
      next if line.empty?

      begin
        request = JSON.parse(line)
        response = handle_request(request)
        if response
          $stdout.puts(JSON.generate(response))
        end
      rescue => e
        $stderr.puts "MCP Error: #{e.message}"
      end
    end
  end

  private

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
            name: "ugtastic-archive-mcp",
            version: "1.0.0"
          }
        }
      }

    when "notifications/initialized"
      nil # Notification response not required

    when "resources/list"
      {
        jsonrpc: "2.0",
        id: id,
        result: {
          resources: [
            {
              uri: "ugtastic://archive/intelligence",
              name: "UGtastic Corpus Intelligence & Tropes",
              mimeType: "application/json",
              description: "Phrase distribution, tropes frequency, and era metrics across 207 interviews (~456k words)."
            },
            {
              uri: "ugtastic://archive/knowledge-graph",
              name: "UGtastic Entity Knowledge Graph Network",
              mimeType: "application/json",
              description: "402 nodes and 612 edges linking interviewees, conferences, user groups, and open source projects."
            },
            {
              uri: "ugtastic://archive/timeline",
              name: "Historical Era Timeline (2009-2026)",
              mimeType: "application/json",
              description: "Chronological milestone timeline across 17 years of software craftsmanship and tech evolution."
            }
          ]
        }
      }

    when "resources/read"
      uri = params["uri"].to_s
      content = ""

      case uri
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
              name: "query_transcript",
              description: "Retrieves full structured dialogue turns and speaker map for a specific transcript ID.",
              inputSchema: {
                type: "object",
                properties: {
                  transcript_id: { type: "string", description: "Transcript ID slug (e.g. jez-humble-goto-conference-2014)" }
                },
                required: ["transcript_id"]
              }
            },
            {
              name: "search_archive",
              description: "Searches dialogue text across all 207 historical interviews for matching keywords or concepts.",
              inputSchema: {
                type: "object",
                properties: {
                  query: { type: "string", description: "Keyword or phrase to search (e.g. Lean, TDD, Clojure)" }
                },
                required: ["query"]
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
      when "query_transcript"
        t_id = arguments["transcript_id"].to_s
        path = File.join(TRANSCRIPTS_DIR, "#{t_id}.yml")
        if File.exist?(path)
          data = YAML.load_file(path, permitted_classes: [Date, Time], aliases: true) rescue {}
          result_text = JSON.pretty_generate(data)
        else
          result_text = JSON.generate({ error: "Transcript ID '#{t_id}' not found." })
        end

      when "search_archive"
        q = arguments["query"].to_s.downcase
        matches = []
        Dir.glob(File.join(TRANSCRIPTS_DIR, "*.yml")).each do |p|
          data = YAML.load_file(p, permitted_classes: [Date, Time], aliases: true) rescue next
          turns = data["turns"] || []
          matched_turns = turns.select { |t| t["text"].to_s.downcase.include?(q) }
          if matched_turns.any?
            matches << {
              transcript_id: File.basename(p, ".yml"),
              matched_turns_count: matched_turns.size,
              snippets: matched_turns.first(3).map { |t| "#{t['speaker']}: #{t['text'].slice(0, 150)}..." }
            }
          end
        end
        result_text = JSON.pretty_generate({ total_matches: matches.size, items: matches.first(15) })
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

UGtasticMCPServer.new.run
