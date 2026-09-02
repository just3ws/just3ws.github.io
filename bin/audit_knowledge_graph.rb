#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "set"
require "yaml"

root = File.expand_path("..", __dir__)
graph_path = File.join(root, "_data", "knowledge_graph.json")
audit_path = File.join(root, "_data", "knowledge_graph_audit.json")
abort "Missing #{graph_path}" unless File.exist?(graph_path)

graph = JSON.parse(File.read(graph_path))
nodes = Array(graph["nodes"])
edges = Array(graph["links"] || graph["edges"])
ids = nodes.filter_map { |node| node["id"] }
id_set = ids.to_set
duplicates = ids.tally.select { |_id, count| count > 1 }
missing = edges.filter_map do |edge|
  endpoints = [edge["source"], edge["target"]].compact.reject { |id| id_set.include?(id) }
  endpoints.empty? ? nil : { "source" => edge["source"], "target" => edge["target"], "missing" => endpoints }
end
linked = edges.flat_map { |edge| [edge["source"], edge["target"]] }.to_set
orphans = ids.uniq.reject { |id| linked.include?(id) }.sort
by_type = nodes.group_by { |node| node["type"] || "Unknown" }.transform_values(&:size)
interviews = YAML.load_file(File.join(root, "_data", "interviews.yml"), aliases: true)
engagements = YAML.load_file(File.join(root, "_data", "engagements.yml"), aliases: true)
case_studies = YAML.load_file(File.join(root, "_data", "case_studies.yml"), aliases: true)
topics = YAML.load_file(File.join(root, "_data", "interview_topics.yml"), aliases: true)
expected = {
  "Interview" => Array(interviews["items"]).size,
  "Interviewee" => Array(interviews["items"]).flat_map { |item| Array(item["interviewees"]) }.uniq.size,
  "Transcript" => Dir[File.join(root, "_data", "transcripts", "*.yml")].size,
  "Post" => Dir[File.join(root, "_posts", "*")].count { |path| File.file?(path) },
  "Position" => Dir[File.join(root, "_data", "resume", "positions", "*.yml")].size,
  "Engagement" => Array(engagements["engagement_models"]).size,
  "Case Study" => Array(case_studies["case_studies"]).size,
  "Technical Topic" => Array(topics["items"]).size
}
coverage_gaps = expected.each_with_object({}) do |(type, count), gaps|
  actual = by_type.fetch(type, 0)
  gaps[type] = { "expected" => count, "actual" => actual, "missing" => count - actual } if actual < count
end
status = duplicates.empty? && missing.empty? ? "ok" : "invalid"
report = {
  "schema_version" => "knowledge-graph-audit.v1",
  "graph_source" => "_data/knowledge_graph.json",
  "graph_generated_at" => graph["generated_at"],
  "node_count" => nodes.size,
  "edge_count" => edges.size,
  "node_counts_by_type" => by_type.sort.to_h,
  "expected_counts_by_type" => expected.sort.to_h,
  "coverage_gaps" => coverage_gaps,
  "duplicate_node_ids" => duplicates.sort.to_h,
  "missing_edge_endpoints" => missing,
  "orphan_node_ids" => orphans,
  "status" => status
}
File.write(audit_path, JSON.pretty_generate(report) + "\n")
puts "Knowledge graph audit: #{status}"
puts "  Nodes: #{nodes.size}"
puts "  Edges: #{edges.size}"
puts "  Orphans: #{orphans.size}"
puts "  Duplicate IDs: #{duplicates.size}"
puts "  Missing edge endpoints: #{missing.size}"
abort "Knowledge graph integrity is invalid." if status == "invalid"
