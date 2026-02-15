#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"
require "time"
require "uri"
require "cgi"

ROOT = Pathname(__dir__).join("..").expand_path
WAYBACK_DIR = ROOT.join("docs", "wayback")
OUTPUT_PATH = WAYBACK_DIR.join("blog-import-inventory.md")
MANIFEST_GLOB = "targets-personal*.txt"

def load_manifest_urls(path)
  path.read
      .lines
      .map(&:strip)
      .reject { |line| line.empty? || line.start_with?("#") }
end

def article_url?(url)
  normalized = url.sub(%r{\Ahttps?://web\.archive\.org/web/\d{14}[a-z_]*/}i, "")
  blogger = normalized.match?(%r{\Ahttps?://[^/]+/\d{4}/\d{2}/[^?#]+\.html(?:[?#].*)?\z}i)
  wordpress = normalized.match?(%r{\Ahttps?://[^/]+/\d{4}/\d{2}/\d{2}/[^/?#]+/?(?:[?#].*)?\z}i)
  ironlanguages = normalized.match?(%r{\Ahttps?://ironlanguages\.net/(?!archive/|tag/|posts/|responses/|likes/|images/|themes/|mp3player/|feed|rss|$)[^?#/]+/?(?:[?#].*)?\z}i)
  blogger || wordpress || ironlanguages
end

def canonical_original_url(url)
  raw = url.to_s.sub(%r{\Ahttps?://web\.archive\.org/web/\d{14}[a-z_]*/}i, "")
  begin
    uri = URI(raw)
    host = uri.host.to_s.downcase.sub(/:80\z/, "")
    path = CGI.unescape(uri.path.to_s).sub(%r{//+}, "/")
    path = path.sub(%r{/\z}, "") unless path == "/"
    "https://#{host}#{path}"
  rescue StandardError
    raw.sub(%r{#.*\z}, "").sub(%r{/\z}, "")
  end
end

def imported_posts_by_original_url
  map = {}
  canonical_map = {}
  slug_map = {}
  Dir.glob(ROOT.join("_posts", "*").to_s).sort.each do |path|
    rel = Pathname(path).relative_path_from(ROOT).to_s
    file_slug = File.basename(path)[/\A\d{4}-\d{2}-\d{2}-(.+)\.(?:md|markdown|html)\z/, 1]
    slug_map[file_slug] = rel unless file_slug.to_s.empty?

    text = File.read(path)
    original = text[/^original_url:\s*"([^"]+)"/, 1]
    next if original.to_s.empty?

    map[original] = rel
    canonical_map[canonical_original_url(original)] = rel
  end
  [map, canonical_map, slug_map]
end

def host_and_slug(url)
  raw = url.to_s.sub(%r{\Ahttps?://web\.archive\.org/web/\d{14}[a-z_]*/}i, "")
  uri = URI(raw)
  host = uri.host.to_s.downcase
  path = uri.path.to_s.sub(%r{/\z}, "")
  slug = path[%r{/([^/]+)\z}, 1].to_s
  [host, slug]
rescue StandardError
  ["", ""]
end

def normalize_slug(slug)
  slug.to_s.downcase
      .sub(/\Aepidsode-/, "episode-")
      .gsub(/[^a-z0-9]+/, "-")
      .gsub(/\A-+|-+\z/, "")
end

def previous_status_overrides(path)
  return {} unless path.exist?

  overrides = {}
  path.read.lines.each do |line|
    next unless line.start_with?("| `")

    cols = line.split("|").map(&:strip)
    next if cols.length < 6

    status = cols[1].to_s.delete("`")
    url = cols[3].to_s
    next unless %w[missing_capture].include?(status)
    next if url.empty?

    overrides[url] = status
  end
  overrides
end

def status_for(url:, article:, imported_map:, imported_canonical_map:, imported_slug_map:, overrides:)
  return "source_only" unless article
  return "imported" if imported_map.key?(url)
  return "imported" if imported_canonical_map.key?(canonical_original_url(url))
  host, slug = host_and_slug(url)
  if host == "ironlanguages.net" && !slug.empty?
    normalized = normalize_slug(slug)
    return "imported" if imported_slug_map.key?(normalized)
  end
  return "missing_capture" if url.include?("/chicago-give-camp/")

  overrides.fetch(url, "pending")
end

manifests = Dir.glob(WAYBACK_DIR.join(MANIFEST_GLOB).to_s)
               .reject { |p| File.basename(p) == "targets-personal-articles.txt" }
               .sort
               .map { |p| Pathname(p) }
manifest_urls = manifests.each_with_object({}) do |manifest, acc|
  load_manifest_urls(manifest).each do |url|
    acc[url] ||= []
    acc[url] << manifest.relative_path_from(ROOT).to_s
  end
end

imported_map, imported_canonical_map, imported_slug_map = imported_posts_by_original_url
overrides = previous_status_overrides(OUTPUT_PATH)

rows = manifest_urls.keys.sort.map do |url|
  article = article_url?(url)
  status = status_for(
    url: url,
    article: article,
    imported_map: imported_map,
    imported_canonical_map: imported_canonical_map,
    imported_slug_map: imported_slug_map,
    overrides: overrides
  )
  {
    status: status,
    type: article ? "article" : "archive_source",
    url: url,
    imported_post: (imported_map[url] || imported_canonical_map[canonical_original_url(url)]).to_s,
    source_manifest: manifest_urls[url].join(", ")
  }
end

article_rows = rows.select { |r| r[:type] == "article" }
source_rows = rows.select { |r| r[:type] == "archive_source" }
status_counts = article_rows.each_with_object(Hash.new(0)) { |row, acc| acc[row[:status]] += 1 }

content = +""
content << "---\n"
content << "layout: minimal\n"
content << "title: Wayback Blog Import Inventory\n"
content << "description: Inventory of personal blog/article URLs discovered via Wayback and their import status.\n"
content << "breadcrumb: Wayback Blog Inventory\n"
content << "breadcrumb_parent_name: Wayback Archives\n"
content << "breadcrumb_parent_url: /docs/wayback/\n"
content << "---\n\n"
content << "{% include breadcrumbs.html %}\n\n"
content << "# Wayback Blog Import Inventory\n\n"
content << "- Generated: #{Time.now.utc.strftime("%Y-%m-%d %H:%M:%S UTC")}\n"
content << "- Manifest files: #{manifests.size}\n"
content << "- Article URLs: #{article_rows.size}\n"
content << "- Imported: #{status_counts["imported"]}\n"
content << "- Pending: #{status_counts["pending"]}\n"
content << "- Missing capture: #{status_counts["missing_capture"]}\n"
content << "- Archive source URLs (discovery targets): #{source_rows.size}\n\n"
content << "## Status Legend\n\n"
content << "- `imported`: Post imported into `_posts`.\n"
content << "- `pending`: Identified article URL not yet imported.\n"
content << "- `missing_capture`: Known article URL with no available capture found yet.\n"
content << "- `source_only`: Archive/listing URL used for discovering article URLs.\n\n"
content << "## URL Inventory\n\n"
content << "| Status | Type | URL | Imported Post | Source Manifest |\n"
content << "|---|---|---|---|---|\n"
rows.each do |row|
  content << "| `#{row[:status]}` | `#{row[:type]}` | #{row[:url]} | "
  content << (row[:imported_post].empty? ? "" : "`#{row[:imported_post]}`")
  content << " | `#{row[:source_manifest]}` |\n"
end

OUTPUT_PATH.write(content)
puts "Wrote #{OUTPUT_PATH.relative_path_from(ROOT)}"
