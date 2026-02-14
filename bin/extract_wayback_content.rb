#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "fileutils"
require "nokogiri"
require "open3"
require "optparse"
require "pathname"
require "time"

ROOT = Pathname(__dir__).join("..").expand_path
DEFAULT_OUTPUT_DIR = ROOT.join("tmp", "wayback")
URL_REGEX = %r{https?://web\.archive\.org/web/[^\s\)\]\">]+}

def slugify(value)
  value.to_s.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/\A-+|-+\z/, "").slice(0, 120)
end

def discover_wayback_urls(paths)
  urls = paths.flat_map do |path|
    next [] unless File.file?(path)

    File.read(path).scan(URL_REGEX)
  end
  urls.compact.uniq.sort
end

def fetch_html(url, timeout:)
  stdout, stderr, status = Open3.capture3(
    "curl", "-fsSL", "--max-time", timeout.to_s, url
  )
  raise "curl failed: #{stderr.strip}" unless status.success?

  stdout
end

def extract_content(html)
  doc = Nokogiri::HTML(html)
  title = doc.at_css("title")&.text&.strip.to_s
  node = doc.at_css("main") || doc.at_css("article") || doc.at_css("body")
  node ||= doc

  node.css("script,style,noscript,iframe,svg").remove
  text = node.text.gsub(/\s+/, " ").strip

  {
    title: title,
    text: text
  }
end

def write_outputs(output_dir:, url:, html:, title:, text:)
  stamp = url[%r{/web/(\d{14})/}, 1] || "unknown"
  source = url.sub(%r{^https?://web\.archive\.org/web/\d{14}/}, "")
  base = slugify("#{stamp}-#{source}")
  base = "wayback-#{stamp}" if base.empty?

  html_path = output_dir.join("#{base}.html")
  text_path = output_dir.join("#{base}.txt")
  json_path = output_dir.join("#{base}.json")

  html_path.write(html)
  text_path.write(text)
  json_path.write(
    JSON.pretty_generate(
      {
        archived_url: url,
        extracted_at: Time.now.utc.iso8601,
        title: title,
        text_path: text_path.relative_path_from(ROOT).to_s,
        html_path: html_path.relative_path_from(ROOT).to_s
      }
    ) + "\n"
  )

  {
    html: html_path,
    text: text_path,
    json: json_path
  }
end

options = {
  output: DEFAULT_OUTPUT_DIR.to_s,
  timeout: 30,
  input_files: ["_data/resources.yml", "README.md"]
}

OptionParser.new do |opts|
  opts.banner = "Usage: bin/extract_wayback_content.rb [options]"
  opts.on("--output DIR", "Output directory (default: tmp/wayback)") { |v| options[:output] = v }
  opts.on("--timeout SECONDS", Integer, "curl max time in seconds (default: 30)") { |v| options[:timeout] = v }
  opts.on("--from FILES", "Comma-separated files to scan for Wayback URLs") do |v|
    options[:input_files] = v.split(",").map(&:strip).reject(&:empty?)
  end
end.parse!

output_dir = Pathname(options[:output]).expand_path
output_dir.mkpath

scan_paths = options[:input_files].map { |p| Pathname(p).expand_path(ROOT).to_s }
urls = discover_wayback_urls(scan_paths)

if urls.empty?
  warn "No Wayback URLs found in: #{options[:input_files].join(', ')}"
  exit 1
end

results = []
urls.each do |url|
  begin
    html = fetch_html(url, timeout: options[:timeout])
    extracted = extract_content(html)
    paths = write_outputs(
      output_dir: output_dir,
      url: url,
      html: html,
      title: extracted[:title],
      text: extracted[:text]
    )
    puts "OK  #{url} -> #{paths[:text].relative_path_from(ROOT)}"
    results << { url: url, status: "ok", title: extracted[:title], files: paths.transform_values { |v| v.relative_path_from(ROOT).to_s } }
  rescue StandardError => e
    warn "ERR #{url} -> #{e.message}"
    results << { url: url, status: "error", error: e.message }
  end
end

summary_path = output_dir.join("summary.json")
summary_path.write(JSON.pretty_generate(results) + "\n")
puts "Summary: #{summary_path.relative_path_from(ROOT)}"
