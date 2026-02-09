#!/usr/bin/env ruby

require 'json'

ROOT = File.expand_path('..', __dir__)
SITE_DIR = File.join(ROOT, '_site')

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

def field_present?(node, dotted_key)
  value = dotted_key.split('.').reduce(node) do |current, part|
    current.is_a?(Hash) ? current[part] : nil
  end
  value_present?(value)
end

def validate_json_ld_type(nodes:, expected_type:, required_fields:, context:, errors:)
  typed_nodes = nodes.select { |node| node.is_a?(Hash) && node_has_type?(node, expected_type) }
  if typed_nodes.empty?
    errors << "#{context} missing #{expected_type} JSON-LD"
    return
  end

  typed_nodes.each_with_index do |node, index|
    missing = required_fields.reject { |key| field_present?(node, key) }
    next if missing.empty?

    errors << "#{context} #{expected_type} JSON-LD ##{index + 1} missing required fields: #{missing.join(', ')}"
  end
end

errors = []
checked = 0

Dir.glob(File.join(SITE_DIR, '**', '*.html')).sort.each do |path|
  relative = path.sub("#{SITE_DIR}/", '')
  next if relative.start_with?('AGENTS.')
  next if relative == 'resume-minimal.html' || relative == 'resume-minimal/index.html'

  html = read(path)
  checked += 1

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
validate_json_ld_type(
  nodes: index_nodes,
  expected_type: 'Person',
  required_fields: %w[name url jobTitle],
  context: 'index.html',
  errors: errors
)

home_html_path = File.join(SITE_DIR, 'home', 'index.html')
if File.file?(home_html_path)
  home_html = read(home_html_path)
  home_nodes = json_ld_nodes(home_html, 'home/index.html', errors)
  if home_nodes.any? { |node| node.is_a?(Hash) && node_has_type?(node, 'Person') }
    errors << 'home/index.html should not expose Person JSON-LD'
  end
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
    required_fields: ['headline', 'datePublished', 'mainEntityOfPage.@id'],
    context: relative,
    errors: errors
  )
end

if errors.empty?
  puts "Semantic output validation passed (checked=#{checked})."
  exit 0
end

warn 'Semantic output validation failed:'
errors.each { |error| warn "  - #{error}" }
exit 1
