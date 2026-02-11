#!/usr/bin/env ruby

require "json"
require "time"
require "fileutils"

ROOT = File.expand_path("..", __dir__)
SCHEMA_COVERAGE_PATH = File.join(ROOT, "tmp", "schema-coverage-report.json")
SCHEMA_GRAPH_PATH = File.join(ROOT, "tmp", "schema-graph-summary.json")
TAXONOMY_PATH = File.join(ROOT, "tmp", "taxonomy-quality-report.json")
OUT_PATH = File.join(ROOT, "tmp", "semantic-quality-report.json")

def read_json(path)
  return nil unless File.file?(path)

  JSON.parse(File.read(path))
end

schema_coverage = read_json(SCHEMA_COVERAGE_PATH)
schema_graph = read_json(SCHEMA_GRAPH_PATH)
taxonomy = read_json(TAXONOMY_PATH)

issues = []

if schema_coverage
  errors_count = schema_coverage.fetch("errors_count", 0).to_i
  issues << "schema_coverage_errors=#{errors_count}" if errors_count.positive?
else
  issues << "missing_schema_coverage_report"
end

if taxonomy
  unknown_topics = taxonomy.fetch("unknown_topics_count", 0).to_i
  unknown_communities = taxonomy.fetch("unknown_communities_count", 0).to_i
  unknown_conferences = taxonomy.fetch("unknown_conferences_count", 0).to_i
  issues << "unknown_topics=#{unknown_topics}" if unknown_topics.positive?
  issues << "unknown_communities=#{unknown_communities}" if unknown_communities.positive?
  issues << "unknown_conferences=#{unknown_conferences}" if unknown_conferences.positive?
else
  issues << "missing_taxonomy_report"
end

if schema_graph
  json_errors = schema_graph.fetch("json_errors_count", 0).to_i
  issues << "schema_graph_json_errors=#{json_errors}" if json_errors.positive?
else
  issues << "missing_schema_graph_report"
end

report = {
  generated_at: Time.now.utc.iso8601,
  status: issues.empty? ? "ok" : "attention",
  issues: issues,
  reports: {
    schema_coverage: SCHEMA_COVERAGE_PATH,
    schema_graph: SCHEMA_GRAPH_PATH,
    taxonomy: TAXONOMY_PATH
  },
  snapshot: {
    schema_coverage: schema_coverage,
    schema_graph: schema_graph,
    taxonomy: taxonomy
  }
}

FileUtils.mkdir_p(File.dirname(OUT_PATH))
File.write(OUT_PATH, JSON.pretty_generate(report) + "\n")

puts "Semantic audit status: #{report[:status]}"
puts "Issues: #{issues.join(', ')}" unless issues.empty?
puts "Report: #{OUT_PATH}"
