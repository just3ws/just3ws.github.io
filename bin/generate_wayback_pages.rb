#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "optparse"
require "pathname"
require "time"
require "cgi"

ROOT = Pathname(__dir__).join("..").expand_path
DEFAULT_SUMMARY = ROOT.join("tmp", "wayback", "summary.json")
DEFAULT_OUTPUT = ROOT.join("docs", "wayback")

def yaml_quote(value)
  "\"" + value.to_s.gsub("\\", "\\\\").gsub("\"", "\\\"") + "\""
end

def wrap_text(text, width: 100)
  words = text.to_s.split(/\s+/)
  return "" if words.empty?

  lines = []
  current = +""
  words.each do |word|
    if current.empty?
      current << word
    elsif current.length + 1 + word.length <= width
      current << " " << word
    else
      lines << current
      current = word.dup
    end
  end
  lines << current unless current.empty?
  lines.join("\n")
end

def provenance_note(source_url)
  host = source_url.to_s.downcase
  return nil unless host.include?("ugl.st")

  "Provenance note: `ugl.st` had prior ownership periods unrelated to the User-Group List project. These snapshots are included because their archived content explicitly reflects the UGl.st user-group directory context."
end

options = {
  summary: DEFAULT_SUMMARY.to_s,
  output: DEFAULT_OUTPUT.to_s,
  base_url: "/docs/wayback/",
  title: "Wayback Archives",
  description: "Archived snapshots extracted from Wayback Machine links referenced in this repository.",
  breadcrumb: "Wayback Archives"
}

OptionParser.new do |opts|
  opts.banner = "Usage: bin/generate_wayback_pages.rb [options]"
  opts.on("--summary PATH", "Path to tmp/wayback/summary.json") { |v| options[:summary] = v }
  opts.on("--output DIR", "Output docs directory (default: docs/wayback)") { |v| options[:output] = v }
  opts.on("--base-url URL", "Published base URL for generated pages (default: /docs/wayback/)") { |v| options[:base_url] = v }
  opts.on("--title TEXT", "Index title (default: Wayback Archives)") { |v| options[:title] = v }
  opts.on("--description TEXT", "Index description/front matter description") { |v| options[:description] = v }
  opts.on("--breadcrumb TEXT", "Index breadcrumb label") { |v| options[:breadcrumb] = v }
end.parse!

summary_path = Pathname(options[:summary]).expand_path
output_dir = Pathname(options[:output]).expand_path
pages_dir = output_dir.join("snapshots")
pages_dir.mkpath
base_url = options[:base_url].to_s
base_url = "/#{base_url}" unless base_url.start_with?("/")
base_url = "#{base_url}/" unless base_url.end_with?("/")

unless summary_path.exist?
  warn "Missing summary file: #{summary_path}"
  exit 1
end

records = JSON.parse(summary_path.read)
ok_records = records.select { |r| r["status"] == "ok" }

if ok_records.empty?
  warn "No successful wayback records in #{summary_path}"
  exit 1
end

index_rows = []

ok_records.each do |record|
  archived_url = record["url"].to_s
  files = record["files"] || {}
  source_url = archived_url.sub(%r{^https?://web\.archive\.org/web/\d{14}/}, "")
  stamp = archived_url[%r{/web/(\d{14})/}, 1]
  archived_at = begin
    Time.strptime(stamp, "%Y%m%d%H%M%S").utc
  rescue StandardError
    nil
  end

  text_path = ROOT.join(files["text"].to_s)
  page_slug = text_path.basename(".txt").to_s
  title = record["title"].to_s.strip
  title = source_url if title.empty?

  extracted_text = text_path.exist? ? text_path.read : ""
  excerpt = extracted_text.strip[0, 360].to_s
  excerpt = excerpt.gsub(/\s+/, " ").strip
  excerpt += "..." if extracted_text.length > excerpt.length

  page_path = pages_dir.join("#{page_slug}.md")
  page_url = "#{base_url}snapshots/#{page_slug}/"
  readable_text = wrap_text(extracted_text)

  page = +""
  page << "---\n"
  page << "layout: minimal\n"
  page << "title: #{yaml_quote("Wayback Snapshot: #{title}")}\n"
  page << "description: #{yaml_quote("Archived content republished from Wayback: #{source_url}")}\n"
  page << "breadcrumb: #{yaml_quote("Wayback Snapshot")}\n"
  page << "breadcrumb_parent_name: Wayback Archives\n"
  page << "breadcrumb_parent_url: /docs/wayback/\n"
  page << "---\n\n"
  page << "{% include breadcrumbs.html %}\n\n"
  page << "# #{title}\n\n"
  page << "- Archived source: [#{archived_url}](#{archived_url})\n"
  page << "- Original URL: [#{source_url}](#{source_url})\n"
  page << "- Snapshot timestamp: #{archived_at ? archived_at.strftime("%Y-%m-%d %H:%M:%S UTC") : stamp}\n\n"
  note = provenance_note(source_url)
  if note
    page << "> #{note}\n\n"
  end
  page << "## Archive Snapshot\n\n"
  page << "<pre>\n#{CGI.escapeHTML(readable_text)}\n</pre>\n"

  page_path.write(page)

  index_rows << {
    title: title,
    page_url: page_url,
    archived_url: archived_url,
    source_url: source_url,
    archived_at: archived_at,
    excerpt: excerpt,
    provenance_note: provenance_note(source_url)
  }
end

index_rows.sort_by! { |r| r[:archived_at] || Time.at(0) }
index_rows.reverse!

index = +""
index << "---\n"
index << "layout: minimal\n"
index << "title: #{options[:title]}\n"
index << "description: #{options[:description]}\n"
index << "breadcrumb: #{options[:breadcrumb]}\n"
index << "breadcrumb_parent_name: Docs\n"
index << "breadcrumb_parent_url: /docs/\n"
index << "---\n\n"
index << "{% include breadcrumbs.html %}\n\n"
index << "# #{options[:title]}\n\n"
index << "Archive snapshots extracted from referenced Wayback Machine links and republished with attribution.\n\n"

index_rows.each do |row|
  date_label = row[:archived_at] ? row[:archived_at].strftime("%Y-%m-%d") : "Unknown date"
  index << "## [#{row[:title]}](#{row[:page_url]})\n\n"
  index << "- Snapshot: #{date_label}\n"
  index << "- Original: [#{row[:source_url]}](#{row[:source_url]})\n"
  index << "- Wayback: [#{row[:archived_url]}](#{row[:archived_url]})\n\n"
  if row[:provenance_note]
    index << "> #{row[:provenance_note]}\n\n"
  end
  index << "#{row[:excerpt]}\n\n"
end

output_dir.join("index.md").write(index)

puts "Generated #{index_rows.size} Wayback pages in #{pages_dir.relative_path_from(ROOT)}"
puts "Index: #{output_dir.join("index.md").relative_path_from(ROOT)}"
