#!/usr/bin/env ruby

require "json"
require "fileutils"
require "time"

ROOT = File.expand_path("..", __dir__)
SITE_DIR = File.join(ROOT, "_site")
OUT_DIR = File.join(ROOT, "tmp")
DOT_PATH = File.join(OUT_DIR, "schema-graph.dot")
SUMMARY_PATH = File.join(OUT_DIR, "schema-graph-summary.json")

abort("Missing _site directory. Run ./bin/pipeline build first.") unless Dir.exist?(SITE_DIR)

def json_ld_script_contents(html)
  html.scan(%r{<script[^>]+type=["']application/ld\+json["'][^>]*>(.*?)</script>}mi).flatten
end

def flatten_nodes(value)
  case value
  when Array
    value.flat_map { |entry| flatten_nodes(entry) }
  when Hash
    nodes = [value]
    graph = value["@graph"]
    nodes.concat(flatten_nodes(graph)) if graph
    nodes
  else
    []
  end
end

def dot_escape(value)
  value.to_s.gsub("\\", "\\\\\\").gsub('"', '\"')
end

def compact_label(parts)
  parts.compact.map(&:to_s).map(&:strip).reject(&:empty?).join("\\n")
end

def collect_ref_ids(value)
  refs = []
  case value
  when Hash
    refs << value["@id"] if value["@id"].is_a?(String) && !value["@id"].strip.empty?
    value.each_value { |entry| refs.concat(collect_ref_ids(entry)) }
  when Array
    value.each { |entry| refs.concat(collect_ref_ids(entry)) }
  end
  refs
end

def collect_ref_edges(value, predicate, source_id, edges)
  case value
  when Hash
    if value["@id"].is_a?(String) && !value["@id"].strip.empty?
      edges << [source_id, value["@id"], predicate]
    else
      value.each do |key, entry|
        collect_ref_edges(entry, "#{predicate}.#{key}", source_id, edges)
      end
    end
  when Array
    value.each { |entry| collect_ref_edges(entry, predicate, source_id, edges) }
  end
end

all_html_paths = Dir.glob(File.join(SITE_DIR, "**", "*.html")).sort

nodes_by_id = {}
edges = []
json_errors = []
synthetic_index = 0
external_node_ids = {}

all_html_paths.each do |path|
  relative = path.sub("#{SITE_DIR}/", "")
  html = File.read(path)
  scripts = json_ld_script_contents(html)
  scripts.each_with_index do |raw_json, script_index|
    parsed =
      begin
        JSON.parse(raw_json.strip)
      rescue JSON::ParserError => e
        json_errors << "#{relative} JSON-LD script ##{script_index + 1}: #{e.message}"
        next
      end

    flatten_nodes(parsed).each do |node|
      next unless node.is_a?(Hash)

      node_id = node["@id"]
      if !node_id.is_a?(String) || node_id.strip.empty?
        synthetic_index += 1
        node_id = "anon:#{relative}##{script_index + 1}.#{synthetic_index}"
      end

      types = node["@type"]
      types = [types] unless types.is_a?(Array)
      types = types.compact.map(&:to_s).reject(&:empty?)

      label = compact_label([
        node["name"],
        node["headline"],
        node["jobTitle"],
        node["url"]
      ])

      entry = nodes_by_id[node_id] ||= {
        id: node_id,
        types: [],
        labels: [],
        pages: []
      }
      entry[:types] = (entry[:types] + types).uniq
      entry[:labels] = (entry[:labels] + [label]).reject(&:empty?).uniq
      entry[:pages] = (entry[:pages] + [relative]).uniq

      node.each do |key, value|
        next if key.start_with?("@")

        collect_ref_edges(value, key, node_id, edges)
      end
    end
  end
end

typed_counts = Hash.new(0)
nodes_by_id.values.each do |node|
  node[:types].each { |type| typed_counts[type] += 1 }
end

dot_lines = []
dot_lines << "digraph schema_graph {"
dot_lines << "  rankdir=LR;"
dot_lines << "  graph [fontsize=10, fontname=\"Helvetica\"];"
dot_lines << "  node [shape=box, style=rounded, fontsize=9, fontname=\"Helvetica\"];"
dot_lines << "  edge [fontsize=8, fontname=\"Helvetica\", color=\"#6b7280\"];"

nodes_by_id.keys.sort.each do |id|
  node = nodes_by_id[id]
  type_text = node[:types].empty? ? "UnTyped" : node[:types].join(", ")
  title = node[:labels].first.to_s.strip
  title = "(no name/headline)" if title.empty?
  label = compact_label([type_text, title])
  dot_lines << "  \"#{dot_escape(id)}\" [label=\"#{dot_escape(label)}\"];"
end

edges.uniq.sort.each do |source, target, predicate|
  next unless nodes_by_id[source]

  unless nodes_by_id[target]
    external_node_ids[target] = true
    nodes_by_id[target] = {
      id: target,
      types: ["ExternalRef"],
      labels: [target],
      pages: []
    }
  end

  dot_lines << "  \"#{dot_escape(source)}\" -> \"#{dot_escape(target)}\" [label=\"#{dot_escape(predicate)}\"];"
end
dot_lines << "}"

FileUtils.mkdir_p(OUT_DIR)
File.write(DOT_PATH, dot_lines.join("\n") + "\n")

summary = {
  generated_at: Time.now.utc.iso8601,
  html_pages_total: all_html_paths.size,
  json_ld_nodes: nodes_by_id.size,
  external_ref_nodes: external_node_ids.size,
  typed_nodes: typed_counts.sort.to_h,
  edges_total: edges.uniq.size,
  dot_path: DOT_PATH,
  json_errors_count: json_errors.size,
  json_errors: json_errors.first(200)
}
File.write(SUMMARY_PATH, JSON.pretty_generate(summary) + "\n")

puts "Semantic graph nodes: #{summary[:json_ld_nodes]}"
puts "Semantic graph edges: #{summary[:edges_total]}"
puts "Typed node counts: #{summary[:typed_nodes]}"
puts "DOT graph: #{DOT_PATH}"
puts "Summary: #{SUMMARY_PATH}"
if json_errors.any?
  warn "JSON-LD parse warnings: #{json_errors.size}"
end
