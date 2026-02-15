#!/usr/bin/env ruby
# frozen_string_literal: true

require "cgi"
require "json"
require "nokogiri"
require "pathname"
require "time"
require "uri"
require "yaml"

ROOT = Pathname(__dir__).join("..").expand_path
SOURCE_DIR = ROOT.join("tmp", "wbm", "ugtastic")
VIDEO_ASSETS_PATH = ROOT.join("_data", "video_assets.yml")
OUT_YAML = ROOT.join("docs", "wayback", "ugtastic-interview-context.yml")
OUT_JSON = ROOT.join("docs", "wayback", "ugtastic-interview-context.json")
OUT_MATCHES = ROOT.join("docs", "wayback", "ugtastic-context-matches.md")
WAYBACK_PREFIX = %r{\Ahttps?://web\.archive\.org/web/\d{14}[a-z_]*/}i

def dewayback(url)
  url.to_s.sub(WAYBACK_PREFIX, "")
end

def normalize_text(value)
  value.to_s.downcase.gsub(/[^a-z0-9]+/, " ").strip.gsub(/\s+/, " ")
end

def normalize_title_key(value)
  key = value.to_s.downcase
  key = key.gsub(/\binterview with\b/i, "")
  key = key.gsub(/\bkeynote speaker\b/i, "")
  key = key.gsub(/\s+@\s+.*\z/, "")
  key = key.gsub(/\s+at\s+.*\z/, "")
  normalize_text(key)
end

def normalize_slug(value)
  value.to_s.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/\A-+|-+\z/, "")
end

def parse_date(node, fallback_url)
  raw =
    node.at_css(".onDate a")&.text.to_s.strip
  raw = node.at_css("time")&.[]("datetime").to_s.strip if raw.empty?
  raw = node.at_css("time")&.text.to_s.strip if raw.empty?
  begin
    return Time.parse(raw).strftime("%Y-%m-%d") unless raw.empty?
  rescue StandardError
    nil
  end

  y = fallback_url[%r{/(\d{4})/(\d{2})/(\d{2})/}, 1]
  m = fallback_url[%r{/(\d{4})/(\d{2})/(\d{2})/}, 2]
  d = fallback_url[%r{/(\d{4})/(\d{2})/(\d{2})/}, 3]
  return "#{y}-#{m}-#{d}" if y && m && d

  ""
end

def extract_summary(entry_content)
  return "" if entry_content.nil?

  clone = entry_content.dup
  clone.css("script,style,iframe,.sharedaddy,.jp-relatedposts,.sd-sharing,.jp-relatedposts-post,.wp-caption-text,.postmetadata,.entry-meta").remove
  paragraphs = clone.css("p").map { |p| p.text.gsub(/\s+/, " ").strip }.reject(&:empty?)
  paragraphs.find do |text|
    text.length >= 40 &&
      !text.start_with?("Socializers") &&
      !text.match?(/\ALike this[:\s]/i) &&
      !text.match?(/\ATwitter\z/i)
  end.to_s[0, 500]
end

def extract_media_urls(entry_content)
  return [] if entry_content.nil?

  urls = []
  entry_content.css("source[src],a[href],iframe[src]").each do |node|
    attr = node["src"] || node["href"]
    next if attr.to_s.empty?

    url = dewayback(attr)
    next unless url.match?(%r{\Ahttps?://}i)
    next unless url.match?(%r{(youtube\.com|youtu\.be|vimeo\.com|\.mp4(?:\?|$)|\.m4v(?:\?|$)|\.webm(?:\?|$)|soundcloud\.com)}i)

    urls << url
  end
  urls.uniq
end

def load_video_asset_index
  data = YAML.safe_load(VIDEO_ASSETS_PATH.read, permitted_classes: [Date, Time], aliases: true) || {}
  items = data["items"] || []
  by_title = {}
  by_core_title = {}
  by_slug = {}
  items.each do |item|
    id = item["id"].to_s
    title = item["title"].to_s
    next if id.empty?

    by_slug[id] = id
    nt = normalize_text(title)
    by_title[nt] ||= []
    by_title[nt] << id unless nt.empty?

    core = normalize_title_key(title)
    by_core_title[core] ||= []
    by_core_title[core] << id unless core.empty?
  end
  [by_title, by_core_title, by_slug]
end

unless SOURCE_DIR.exist?
  warn "Source directory not found: #{SOURCE_DIR}"
  exit 1
end

by_title, by_core_title, by_slug = load_video_asset_index
entries = {}

Dir.glob(SOURCE_DIR.join("*.html").to_s).sort.each do |path|
  doc = Nokogiri::HTML(File.read(path))
  doc.css("article.post, article.hentry, div.post").each do |post|
    title_link = post.at_css("h1.entry-title a, h2.entry-title a, h3.entry-title a")
    next if title_link.nil?

    title = title_link.text.gsub(/\s+/, " ").strip
    next unless title.downcase.include?("interview")

    raw_url = title_link["href"].to_s.strip
    next if raw_url.empty?
    canonical_url = dewayback(raw_url)
    canonical_url = canonical_url.sub(%r{/\z}, "")
    key = canonical_url
    entry_content = post.at_css(".entry-content, .post-body, .entry-summary")

    summary = extract_summary(entry_content)
    media_urls = extract_media_urls(entry_content)
    date = parse_date(post, canonical_url)

    candidate = {
      "title" => title,
      "source_url" => canonical_url,
      "published_at" => date,
      "summary" => summary,
      "media_urls" => media_urls,
      "source_snapshot_file" => Pathname(path).relative_path_from(ROOT).to_s
    }

    existing = entries[key]
    if existing.nil? || candidate["summary"].length > existing["summary"].to_s.length
      entries[key] = candidate
    end
  end
end

items = entries.values.sort_by { |row| [row["published_at"], row["title"]] }

items.each do |row|
  normalized_title = normalize_text(row["title"])
  core_title = normalize_title_key(row["title"])
  slug = normalize_slug(URI(row["source_url"]).path.split("/").last.to_s)
  match_ids = (by_title[normalized_title] || []).dup
  match_ids.concat(by_core_title[core_title] || [])
  match_ids << by_slug[slug] if by_slug.key?(slug)
  row["matched_video_asset_ids"] = match_ids.compact.uniq
end

OUT_YAML.parent.mkpath
OUT_YAML.write({ "items" => items }.to_yaml)
OUT_JSON.write(JSON.pretty_generate({ items: items }))

matched = items.count { |i| !i["matched_video_asset_ids"].to_a.empty? }
unmatched = items.size - matched
top_rich = items.select { |i| i["summary"].to_s.length >= 120 }.first(20)
unmatched_rows = items.select { |i| i["matched_video_asset_ids"].to_a.empty? }

md = +"# UGtastic Interview Context Extraction\n\n"
md << "- Source directory: `#{SOURCE_DIR.relative_path_from(ROOT)}`\n"
md << "- Extracted interview entries: #{items.size}\n"
md << "- Matched to `video_assets`: #{matched}\n"
md << "- Unmatched: #{unmatched}\n\n"
md << "## Rich Context Samples\n\n"
top_rich.each do |row|
  md << "- `#{row["published_at"]}` [#{row["title"]}](#{row["source_url"]})\n"
  md << "  - Summary: #{row["summary"]}\n"
  md << "  - Matches: #{row["matched_video_asset_ids"].join(", ")}\n"
end

md << "\n## Unmatched Entries\n\n"
unmatched_rows.each do |row|
  md << "- `#{row["published_at"]}` [#{row["title"]}](#{row["source_url"]})\n"
end

OUT_MATCHES.write(md)

puts "Wrote #{OUT_YAML.relative_path_from(ROOT)} (#{items.size} entries)"
puts "Wrote #{OUT_JSON.relative_path_from(ROOT)}"
puts "Wrote #{OUT_MATCHES.relative_path_from(ROOT)} (matched=#{matched}, unmatched=#{unmatched})"
