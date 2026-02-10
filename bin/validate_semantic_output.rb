#!/usr/bin/env ruby

require 'json'
require 'fileutils'
require 'time'

ROOT = File.expand_path('..', __dir__)
SITE_DIR = File.join(ROOT, '_site')
DEFAULT_SCHEMA_REPORT_PATH = File.join(ROOT, 'tmp', 'schema-coverage-report.json')
schema_report_path = ENV.fetch('SCHEMA_REPORT_JSON', DEFAULT_SCHEMA_REPORT_PATH)
PLACEHOLDER_VALUES = [
  'tbd',
  'todo',
  'n/a',
  'na',
  'unknown',
  'placeholder',
  'lorem ipsum',
  'coming soon'
].freeze

def read(path)
  File.read(path)
end

def match_count(text, regex)
  text.scan(regex).size
end

def json_ld_script_contents(html)
  html.scan(%r{<script[^>]+type=["']application/ld\+json["'][^>]*>(.*?)</script>}mi).flatten
end

def flatten_json_ld_nodes(value)
  case value
  when Array
    value.flat_map { |entry| flatten_json_ld_nodes(entry) }
  when Hash
    nodes = [value]
    graph = value['@graph']
    nodes.concat(flatten_json_ld_nodes(graph)) if graph
    nodes
  else
    []
  end
end

def json_ld_nodes(html, relative, errors)
  nodes = []
  json_ld_script_contents(html).each_with_index do |raw_json, index|
    begin
      parsed = JSON.parse(raw_json.strip)
      nodes.concat(flatten_json_ld_nodes(parsed))
    rescue JSON::ParserError => e
      errors << "#{relative} has invalid JSON-LD script ##{index + 1}: #{e.message}"
    end
  end
  nodes
end

def node_has_type?(node, expected_type)
  node_type = node['@type']
  return false unless node_type
  return node_type.include?(expected_type) if node_type.is_a?(Array)

  node_type == expected_type
end

def value_present?(value)
  case value
  when nil
    false
  when String
    !value.strip.empty?
  when Array
    !value.empty?
  when Hash
    !value.empty?
  else
    true
  end
end

def field_value(node, dotted_key)
  dotted_key.split('.').reduce(node) do |current, part|
    current.is_a?(Hash) ? current[part] : nil
  end
end

def field_present?(node, dotted_key)
  value_present?(field_value(node, dotted_key))
end

def placeholder_string?(value)
  return false unless value.is_a?(String)

  normalized = value.strip.downcase.gsub(/\s+/, ' ')
  PLACEHOLDER_VALUES.include?(normalized)
end

def contains_placeholder?(value)
  case value
  when String
    placeholder_string?(value)
  when Array
    value.any? { |entry| contains_placeholder?(entry) }
  when Hash
    value.values.any? { |entry| contains_placeholder?(entry) }
  else
    false
  end
end

def validate_json_ld_type(nodes:, expected_type:, required_fields:, context:, errors:)
  typed_nodes = nodes.select { |node| node.is_a?(Hash) && node_has_type?(node, expected_type) }
  if typed_nodes.empty?
    errors << "#{context} missing #{expected_type} JSON-LD"
    return
  end

  typed_nodes.each_with_index do |node, index|
    missing = required_fields.reject { |key| field_present?(node, key) }
    unless missing.empty?
      errors << "#{context} #{expected_type} JSON-LD ##{index + 1} missing required fields: #{missing.join(', ')}"
      next
    end

    placeholders = required_fields.select { |key| contains_placeholder?(field_value(node, key)) }
    next if placeholders.empty?

    errors << "#{context} #{expected_type} JSON-LD ##{index + 1} has placeholder values in: #{placeholders.join(', ')}"
  end
end

errors = []
checked = 0
all_html_paths = Dir.glob(File.join(SITE_DIR, '**', '*.html')).sort
coverage = {
  html_pages_total: 0,
  html_pages_checked: 0,
  json_ld_nodes_total: 0,
  typed_nodes: Hash.new(0),
  pages_with_type: Hash.new(0),
  route_contracts: {},
  errors_count: 0,
  errors: []
}

all_html_paths.each do |path|
  relative = path.sub("#{SITE_DIR}/", '')
  next if relative == 'AGENTS.html'
  next if relative.start_with?('AGENTS.')

  coverage[:html_pages_total] += 1
  next if relative == 'resume-minimal.html' || relative == 'resume-minimal/index.html'

  html = read(path)
  checked += 1
  coverage[:html_pages_checked] += 1

  errors << "#{relative} missing html[lang]" unless html.match?(/<html[^>]+lang=["'][^"']+["']/i)
  errors << "#{relative} missing skip-link" unless html.match?(/<a[^>]+class=["'][^"']*\bskip-link\b[^"']*["']/i)
  errors << "#{relative} missing main target id=\"main-content\"" unless html.match?(/<main[^>]+id=["']main-content["']/i)

  main_count = match_count(html, /<main\b/i)
  errors << "#{relative} expected exactly one <main>, found #{main_count}" unless main_count == 1

  h1_count = match_count(html, /<h1\b/i)
  errors << "#{relative} expected exactly one <h1>, found #{h1_count}" unless h1_count == 1

  html.scan(/<img\b[^>]*>/i).each do |img_tag|
    errors << "#{relative} has <img> missing alt attribute" unless img_tag.match?(/\balt=["'][^"']*["']/i)
  end

  html.scan(/<nav\b[^>]*>/i).each do |nav_tag|
    next if nav_tag.match?(/\baria-label=["'][^"']+["']/i)
    next if nav_tag.match?(/\baria-labelledby=["'][^"']+["']/i)

    errors << "#{relative} has <nav> without aria-label/aria-labelledby"
  end
end

index_html = read(File.join(SITE_DIR, 'index.html'))
index_nodes = json_ld_nodes(index_html, 'index.html', errors)
index_person_nodes = index_nodes.select { |node| node.is_a?(Hash) && node_has_type?(node, 'Person') }
validate_json_ld_type(
  nodes: index_nodes,
  expected_type: 'Person',
  required_fields: %w[name url jobTitle],
  context: 'index.html',
  errors: errors
)
coverage[:route_contracts]['/'] = {
  person_json_ld_count: index_person_nodes.size,
  person_required_fields_present: !index_person_nodes.empty? && %w[name url jobTitle].all? { |key| field_present?(index_person_nodes.first, key) },
  person_required_fields_non_placeholder: !index_person_nodes.empty? && %w[name url jobTitle].none? { |key| contains_placeholder?(field_value(index_person_nodes.first, key)) }
}

home_html_path = File.join(SITE_DIR, 'home', 'index.html')
if File.file?(home_html_path)
  home_html = read(home_html_path)
  home_nodes = json_ld_nodes(home_html, 'home/index.html', errors)
  home_person_nodes = home_nodes.select { |node| node.is_a?(Hash) && node_has_type?(node, 'Person') }
  errors << 'home/index.html should not expose Person JSON-LD' if home_person_nodes.any?

  coverage[:route_contracts]['/home/'] = {
    person_json_ld_count: home_person_nodes.size,
    person_absent: home_person_nodes.empty?
  }
end

Dir.glob(File.join(SITE_DIR, 'videos', '**', 'index.html')).sort.each do |path|
  relative = path.sub("#{SITE_DIR}/", '')
  next if relative == 'videos/index.html'

  html = read(path)
  nodes = json_ld_nodes(html, relative, errors)
  validate_json_ld_type(
    nodes: nodes,
    expected_type: 'VideoObject',
    required_fields: %w[name description url uploadDate],
    context: relative,
    errors: errors
  )
end

Dir.glob(File.join(SITE_DIR, '[0-9][0-9][0-9][0-9]', '**', '*.html')).sort.each do |path|
  relative = path.sub("#{SITE_DIR}/", '')
  html = read(path)
  nodes = json_ld_nodes(html, relative, errors)
  validate_json_ld_type(
    nodes: nodes,
    expected_type: 'Article',
    required_fields: ['headline', 'datePublished', 'dateModified', 'mainEntityOfPage.@id'],
    context: relative,
    errors: errors
  )
end

all_html_paths.each do |path|
  relative = path.sub("#{SITE_DIR}/", '')
  next if relative == 'AGENTS.html'
  next if relative.start_with?('AGENTS.')

  html = read(path)
  nodes = json_ld_nodes(html, relative, errors)
  coverage[:json_ld_nodes_total] += nodes.size
  typed_pages = Hash.new(false)

  nodes.each do |node|
    next unless node.is_a?(Hash)

    node_type = node['@type']
    types = node_type.is_a?(Array) ? node_type : [node_type]
    types.compact.each do |type|
      coverage[:typed_nodes][type] += 1
      typed_pages[type] = true
    end
  end

  typed_pages.each_key do |type|
    coverage[:pages_with_type][type] += 1
  end
end

coverage[:errors_count] = errors.size
coverage[:errors] = errors.first(200)

schema_report = {
  generated_at: Time.now.utc.iso8601,
  html_pages_total: coverage[:html_pages_total],
  html_pages_checked: coverage[:html_pages_checked],
  json_ld_nodes_total: coverage[:json_ld_nodes_total],
  typed_nodes: coverage[:typed_nodes].sort.to_h,
  pages_with_type: coverage[:pages_with_type].sort.to_h,
  route_contracts: coverage[:route_contracts],
  errors_count: coverage[:errors_count],
  errors: coverage[:errors]
}

FileUtils.mkdir_p(File.dirname(schema_report_path))
File.write(schema_report_path, JSON.pretty_generate(schema_report) + "\n")

if errors.empty?
  puts "Semantic output validation passed (checked=#{checked})."
  puts "Schema coverage report: #{schema_report_path}"
  exit 0
end

warn 'Semantic output validation failed:'
errors.each { |error| warn "  - #{error}" }
warn "Schema coverage report: #{schema_report_path}"
exit 1
