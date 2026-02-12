#!/usr/bin/env ruby

require "json"
require "time"

ROOT = File.expand_path("..", __dir__)
GRAPH_PATH = File.join(ROOT, "tmp", "schema-graph-summary.json")
COVERAGE_PATH = File.join(ROOT, "tmp", "schema-coverage-report.json")
OUT_PATH = File.join(ROOT, "docs", "architecture", "semantic-graph.md")

abort("Missing #{GRAPH_PATH}. Run ./bin/pipeline validate first.") unless File.file?(GRAPH_PATH)
abort("Missing #{COVERAGE_PATH}. Run ./bin/pipeline validate first.") unless File.file?(COVERAGE_PATH)

graph = JSON.parse(File.read(GRAPH_PATH))
coverage = JSON.parse(File.read(COVERAGE_PATH))

typed_nodes = (graph["typed_nodes"] || {}).sort_by { |key, _| key.to_s }
route_contracts = (coverage["route_contracts"] || {}).sort_by { |key, _| key.to_s }
pages_with_type = (coverage["pages_with_type"] || {}).sort_by { |key, _| key.to_s }

lines = []
lines << "---"
lines << "layout: minimal"
lines << "title: Semantic Graph Snapshot"
lines << "description: Rendered-page schema graph snapshot from validator artifacts with route-level contract checks."
lines << "breadcrumb: Semantic Graph Snapshot"
lines << "breadcrumb_parent_name: Semantic Model"
lines << "breadcrumb_parent_url: /docs/architecture/semantic-model/"
lines << "breadcrumb_grandparent_name: Docs"
lines << "breadcrumb_grandparent_url: /docs/"
lines << "---"
lines << ""
lines << "{% include breadcrumbs.html %}"
lines << ""
lines << "# Semantic Graph Snapshot"
lines << ""
lines << "Snapshot generated from rendered `_site` JSON-LD artifacts."
lines << ""
lines << "- Generated at (graph): `#{graph['generated_at']}`"
lines << "- Generated at (coverage): `#{coverage['generated_at']}`"
lines << "- Nodes: `#{graph['json_ld_nodes']}`"
lines << "- Edges: `#{graph['edges_total']}`"
lines << "- Connected components: `#{graph['connected_components']}`"
lines << "- Isolated nodes: `#{graph['isolated_nodes_count']}`"
lines << "- Unresolved references: `#{graph['external_ref_nodes']}`"
lines << ""
lines << "```mermaid"
lines << "graph TD"
lines << "  P[Person] --> O[Occupation]"
lines << "  P --> CH[Career ItemList]"
lines << "  CP[CollectionPage] --> IL[ItemList]"
lines << "  I[Interview] --> IP[Interviewee Person]"
lines << "  I --> V[VideoObject]"
lines << "  WP[WebPage] --> BL[BreadcrumbList]"
lines << "  A[Article] --> WP"
lines << "```"
lines << ""
lines << "## Typed Nodes"
lines << ""
lines << "| Type | Count |"
lines << "|---|---:|"
typed_nodes.each do |type, count|
  lines << "| `#{type}` | #{count} |"
end
lines << ""
lines << "## Pages With Type"
lines << ""
lines << "| Type | Pages |"
lines << "|---|---:|"
pages_with_type.each do |type, count|
  lines << "| `#{type}` | #{count} |"
end
lines << ""
lines << "## Route Contracts"
lines << ""
route_contracts.each do |route, details|
  lines << "### `#{route}`"
  details.sort_by { |key, _| key.to_s }.each do |key, value|
    lines << "- `#{key}`: `#{value}`"
  end
  lines << ""
end

unless Array(graph["orphan_node_ids"]).empty?
  lines << "## Sample Orphan Nodes"
  lines << ""
  graph["orphan_node_ids"].first(20).each do |node_id|
    lines << "- `#{node_id}`"
  end
  lines << ""
end

unless Array(graph["unresolved_reference_ids"]).empty?
  lines << "## Sample Unresolved References"
  lines << ""
  graph["unresolved_reference_ids"].first(20).each do |node_id|
    lines << "- `#{node_id}`"
  end
  lines << ""
end

lines << "## Artifacts"
lines << ""
lines << "- `tmp/schema-graph.dot`"
lines << "- `tmp/schema-graph-summary.json`"
lines << "- `tmp/schema-coverage-report.json`"
lines << ""

File.write(OUT_PATH, lines.join("\n"))
puts "Wrote #{OUT_PATH}"
