#!/usr/bin/env ruby
# frozen_string_literal: true

require "nokogiri"
require "optparse"
require "pathname"
require "set"
require "time"
require "uri"

ROOT = Pathname(__dir__).join("..").expand_path
POSTS_DIR = ROOT.join("_posts")
SOURCE_DIR = ROOT.join("tmp", "wbm", "wordpress")
MANIFEST_PATH = ROOT.join("docs", "wayback", "targets-personal-wordpress-posts-local.txt")
WAYBACK_PREFIX = %r{\Ahttps?://web\.archive\.org/web/\d{14}[a-z_]*/}i
WP_POST_PATH = %r{/(\d{4})/(\d{2})/(\d{2})/[^/?#]+/?}i

def slugify(value)
  value.to_s.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/\A-+|-+\z/, "").slice(0, 90)
end

def yaml_quote(value)
  "\"" + value.to_s.gsub("\\", "\\\\").gsub("\"", "\\\"") + "\""
end

def dewayback(url)
  url.to_s.sub(WAYBACK_PREFIX, "").sub(":80/", "/")
end

def wayback_stamp(url)
  url.to_s[%r{/web/(\d{14})}, 1].to_s
end

def choose_preferred_wayback(existing_url, candidate_url)
  return candidate_url if existing_url.to_s.empty?
  return existing_url if candidate_url.to_s.empty?

  old_stamp = wayback_stamp(existing_url)
  new_stamp = wayback_stamp(candidate_url)
  return existing_url if new_stamp.empty?
  return candidate_url if old_stamp.empty?

  new_stamp >= old_stamp ? candidate_url : existing_url
end

def sanitize_fragment(fragment)
  fragment.css("script,style,iframe,form,noscript,.sharing,.snap_preview_anywhere").remove
  fragment.css("*").each do |node|
    next unless node.element?

    if node["href"]
      href = dewayback(node["href"].to_s)
      node["href"] = href
      node["rel"] = "noopener noreferrer"
      node["target"] = "_blank"
    end
    next unless node["src"]

    node["src"] = dewayback(node["src"].to_s)
    node["loading"] = "lazy"
    node["decoding"] = "async"
  end
  fragment.to_html.strip
end

def parse_date_from_meta(meta_node, original_url, post_node: nil)
  if post_node
    raw_post = post_node.at_css(".postMeta .date, .postMeta span.date")&.text.to_s.strip
    raw_post = "" unless raw_post.match?(/\d{4}|January|February|March|April|May|June|July|August|September|October|November|December/i)
    date_from_post =
      begin
        Time.parse(raw_post).to_date unless raw_post.empty?
      rescue StandardError
        nil
      end
    return date_from_post unless date_from_post.nil?
  end

  raw = meta_node&.at_css(".signature p:nth-of-type(2)")&.text.to_s.strip
  date =
    begin
      Time.parse(raw).to_date unless raw.empty?
    rescue StandardError
      nil
    end
  return date unless date.nil?

  if original_url =~ WP_POST_PATH
    return Date.new(Regexp.last_match(1).to_i, Regexp.last_match(2).to_i, Regexp.last_match(3).to_i)
  end

  Date.today
end

def build_frontmatter(title:, date:, description:, tags:, original_url:)
  lines = ["---"]
  lines << "layout: \"post\""
  lines << "title: #{yaml_quote(title)}"
  lines << "date: #{yaml_quote(date.to_s)}"
  lines << "description: #{yaml_quote(description)}" unless description.to_s.empty?
  lines << "tags:"
  tags.each { |tag| lines << "  - #{tag}" }
  lines << "originally_published_on: \"WordPress\""
  lines << "original_url: #{yaml_quote(original_url)}"
  lines << "original_published_at: #{yaml_quote(date.to_s)}"
  lines << "archive_note: #{yaml_quote("Originally published on just3ws.wordpress.com. Republished from local Wayback snapshot exports.")}"
  lines << "---"
  lines.join("\n")
end

options = {
  source_dir: SOURCE_DIR.to_s,
  dry_run: false,
  overwrite: false
}

OptionParser.new do |opts|
  opts.banner = "Usage: bin/import_wordpress_local_snapshots.rb [--source-dir PATH] [--dry-run] [--overwrite]"
  opts.on("--source-dir PATH", "Directory with local WordPress archive HTML snapshots.") { |v| options[:source_dir] = v }
  opts.on("--dry-run", "Preview work without writing files.") { options[:dry_run] = true }
  opts.on("--overwrite", "Overwrite existing post files.") { options[:overwrite] = true }
end.parse!

source_dir = Pathname(options[:source_dir]).expand_path
unless source_dir.exist?
  warn "Source directory not found: #{source_dir}"
  exit 1
end

html_files = Dir.glob(source_dir.join("*.html").to_s).sort
if html_files.empty?
  warn "No HTML files found in #{source_dir}"
  exit 1
end

discovered_by_original = {}
rows_by_original = {}

html_files.each do |file|
  doc = Nokogiri::HTML(File.read(file))

  doc.css("a[href]").each do |a|
    href = a["href"].to_s.strip
    next unless href.match?(%r{\Ahttps?://web\.archive\.org/web/\d{14}[a-z_]*/https?://just3ws\.wordpress\.com(?::80)?/\d{4}/\d{2}/\d{2}/[^/?#]+/?}i)

    original = dewayback(href)
    discovered_by_original[original] = choose_preferred_wayback(discovered_by_original[original], href)
  end

  doc.css("h2[id^='post-']").each do |heading|
    link = heading.at_css("a[href]")
    next if link.nil?

    wayback_url = link["href"].to_s.strip
    next unless wayback_url.match?(%r{just3ws\.wordpress\.com(?::80)?/\d{4}/\d{2}/\d{2}/}i)

    original = dewayback(wayback_url)
    discovered_by_original[original] = choose_preferred_wayback(discovered_by_original[original], wayback_url)

    title = link.text.to_s.gsub(/\u00A0/, " ").strip
    next if title.empty?

    body_node = nil
    meta_node = nil
    heading.xpath("following-sibling::*").each do |sib|
      break if sib.name == "h2" && sib["id"].to_s.start_with?("post-")
      body_node ||= sib if sib.name == "div" && sib["class"].to_s.split.include?("main")
      meta_node ||= sib if sib.name == "div" && sib["class"].to_s.split.include?("meta")
      break if body_node && meta_node
    end
    next if body_node.nil?

    body_html = sanitize_fragment(Nokogiri::HTML.fragment(body_node.inner_html))
    plain = Nokogiri::HTML.fragment(body_html).text.gsub(/\s+/, " ").strip
    description = plain[0, 180]
    date = parse_date_from_meta(meta_node, original, post_node: nil)

    tags = %w[wordpress republished wayback]
    if meta_node
      tag_links = meta_node.css(".tags a[rel='tag'], .tags a[rel='category tag']")
      tag_links.each do |a|
        t = slugify(a.text.to_s)
        tags << t unless t.empty?
      end
    end
    tags = tags.uniq

    existing = rows_by_original[original]
    if existing.nil? || wayback_stamp(wayback_url) >= wayback_stamp(existing[:wayback_url])
      rows_by_original[original] = {
        wayback_url: wayback_url,
        original_url: original,
        title: title,
        date: date,
        body_html: body_html,
        description: description,
        tags: tags
      }
    end
  end

  doc.css("div.post.hentry").each do |post_block|
    link = post_block.at_css("h2 a[href]")
    next if link.nil?

    wayback_url = link["href"].to_s.strip
    next unless wayback_url.match?(%r{just3ws\.wordpress\.com(?::80)?/\d{4}/\d{2}/\d{2}/}i)

    original = dewayback(wayback_url)
    discovered_by_original[original] = choose_preferred_wayback(discovered_by_original[original], wayback_url)

    title = link.text.to_s.gsub(/\u00A0/, " ").strip
    next if title.empty?

    entry = post_block.at_css("div.entry")
    next if entry.nil?

    body_html = sanitize_fragment(Nokogiri::HTML.fragment(entry.inner_html))
    plain = Nokogiri::HTML.fragment(body_html).text.gsub(/\s+/, " ").strip
    description = plain[0, 180]
    date = parse_date_from_meta(nil, original, post_node: post_block)

    tags = %w[wordpress republished wayback]
    post_block.css("a[rel='tag'], a[rel='category tag']").each do |a|
      t = slugify(a.text.to_s)
      tags << t unless t.empty?
    end
    tags = tags.uniq

    existing = rows_by_original[original]
    if existing.nil? || wayback_stamp(wayback_url) >= wayback_stamp(existing[:wayback_url])
      rows_by_original[original] = {
        wayback_url: wayback_url,
        original_url: original,
        title: title,
        date: date,
        body_html: body_html,
        description: description,
        tags: tags
      }
    end
  end
end

MANIFEST_PATH.dirname.mkpath
manifest_urls = discovered_by_original.values.compact.uniq.sort
manifest_body = +""
manifest_body << "# Discovered just3ws.wordpress.com post URLs from local Wayback snapshot exports\n"
manifest_body << "# Source directory: #{source_dir}\n"
manifest_urls.each { |url| manifest_body << "#{url}\n" }
if options[:dry_run]
  puts "[dry-run] would write #{MANIFEST_PATH.relative_path_from(ROOT)} (#{manifest_urls.size} URLs)"
else
  MANIFEST_PATH.write(manifest_body)
  puts "Wrote #{MANIFEST_PATH.relative_path_from(ROOT)} (#{manifest_urls.size} URLs)"
end

rows = rows_by_original.values.sort_by { |r| [r[:date].to_s, r[:title]] }
wrote = 0
skipped = 0
planned = Set.new

rows.each do |row|
  slug = slugify(row[:title])
  if slug.empty?
    skipped += 1
    next
  end

  out_path = POSTS_DIR.join("#{row[:date]}-#{slug}.html")
  if planned.include?(out_path.to_s)
    skipped += 1
    next
  end
  planned << out_path.to_s

  if out_path.exist? && !options[:overwrite]
    skipped += 1
    next
  end

  fm = build_frontmatter(
    title: row[:title],
    date: row[:date],
    description: row[:description],
    tags: row[:tags],
    original_url: row[:wayback_url]
  )

  if options[:dry_run]
    puts "[dry-run] would write #{out_path.relative_path_from(ROOT)}"
  else
    out_path.write("#{fm}\n\n#{row[:body_html]}\n")
    puts "Wrote #{out_path.relative_path_from(ROOT)}"
  end
  wrote += 1
end

puts "Done. extracted=#{rows.size} wrote=#{wrote} skipped=#{skipped}"
