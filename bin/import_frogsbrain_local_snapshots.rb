#!/usr/bin/env ruby
# frozen_string_literal: true

require "nokogiri"
require "optparse"
require "pathname"
require "set"
require "time"
require "cgi"
require "uri"

ROOT = Pathname(__dir__).join("..").expand_path
POSTS_DIR = ROOT.join("_posts")
SOURCE_DIR = ROOT.join("tmp", "wbm", "frogsbrain")
WAYBACK_TARGETS = ROOT.join("docs", "wayback", "targets-personal-blogger-frogsbrain-posts-local.txt")
WAYBACK_PREFIX = %r{\Ahttps?://web\.archive\.org/web/\d{14}[a-z_]*/}i

def slugify(value)
  value.to_s.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/\A-+|-+\z/, "").slice(0, 90)
end

def yaml_quote(value)
  "\"" + value.to_s.gsub("\\", "\\\\").gsub("\"", "\\\"") + "\""
end

def dewayback(url)
  url.to_s.sub(WAYBACK_PREFIX, "")
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

def sanitize_content(fragment)
  fragment.css("script,style,iframe,form,noscript").remove
  fragment.css("a[href*='dotnetkicks.com']").each do |a|
    parent_p = a.ancestors("p").first
    if parent_p && parent_p.text.strip.empty?
      parent_p.remove
    else
      a.remove
    end
  end
  fragment.css("img[alt*='Submit this story to DotNetKicks']").remove
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

def title_from_url(original_url)
  slug = original_url.to_s[%r{/([^/?#]+)\.html}, 1].to_s
  return "" if slug.empty?

  slug.tr("-", " ").gsub(/\s+/, " ").strip.split.map { |part| part.capitalize }.join(" ")
end

def extract_title(link_node, body_node, original_url)
  from_link = link_node&.text.to_s.strip
  return from_link unless from_link.empty?

  body_html = body_node&.inner_html.to_s
  unless body_html.empty?
    # Older Blogger templates often use the first paragraph line as the title.
    first_chunk = body_html.split(/<br\s*\/?>\s*<br\s*\/?>/i, 2).first.to_s
    candidate = Nokogiri::HTML.fragment(first_chunk).text.gsub(/\s+/, " ").strip
    return candidate unless candidate.empty?

    # Some posts only expose title in the DotNetKicks submit URL query string.
    dotnetkicks_href = Nokogiri::HTML.fragment(body_html).at_css("a[href*='dotnetkicks.com/submit/?url=']")&.[]("href").to_s
    unless dotnetkicks_href.empty?
      encoded_title = dotnetkicks_href[/[?&]title=([^&]+)/, 1].to_s
      unless encoded_title.empty?
        decoded_title = CGI.unescape(encoded_title).gsub(/\s+/, " ").strip
        return decoded_title unless decoded_title.empty?
      end
    end
  end

  title_from_url(original_url)
end

def extract_date(post_node, post_url)
  stamp_text = post_node.at_css(".post-footer a.timestamp-link")&.text.to_s.strip
  date =
    begin
      Time.parse(stamp_text).to_date unless stamp_text.empty?
    rescue StandardError
      nil
    end

  return date unless date.nil?

  if post_url =~ %r{/(\d{4})/(\d{2})/}
    return Date.new(Regexp.last_match(1).to_i, Regexp.last_match(2).to_i, 1)
  end

  Date.today
end

def build_frontmatter(title:, date:, description:, original_url:)
  lines = ["---"]
  lines << "layout: \"post\""
  lines << "title: #{yaml_quote(title)}"
  lines << "date: #{yaml_quote(date.to_s)}"
  lines << "description: #{yaml_quote(description)}" unless description.to_s.empty?
  lines << "tags:"
  %w[blogger frogsbrain republished wayback].each { |tag| lines << "  - #{tag}" }
  lines << "originally_published_on: \"Blogger\""
  lines << "original_url: #{yaml_quote(original_url)}"
  lines << "original_published_at: #{yaml_quote(date.to_s)}"
  lines << "archive_note: #{yaml_quote("Originally published on frogsbrain.blogspot.com. Republished from local Wayback snapshot exports.")}"
  lines << "---"
  lines.join("\n")
end

options = {
  source_dir: SOURCE_DIR.to_s,
  dry_run: false,
  overwrite: false
}

OptionParser.new do |opts|
  opts.banner = "Usage: bin/import_frogsbrain_local_snapshots.rb [--source-dir PATH] [--dry-run] [--overwrite]"
  opts.on("--source-dir PATH", "Directory containing local frogsbrain Wayback HTML snapshots.") { |v| options[:source_dir] = v }
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

seen_original_urls = Set.new
discovered_urls_by_original = {}
rows = []

html_files.each do |html_file|
  doc = Nokogiri::HTML(File.read(html_file))
  doc.css("a[href]").each do |a|
    href = a["href"].to_s.strip
    next if href.empty?
    if href.match?(%r{\Ahttps?://web\.archive\.org/web/\d{14}[a-z_]*/https?://frogsbrain\.blogspot\.com/\d{4}/\d{2}/[^/?#]+\.html}i) ||
       href.match?(%r{\Ahttps?://frogsbrain\.blogspot\.com/\d{4}/\d{2}/[^/?#]+\.html}i)
      original = dewayback(href)
      discovered_urls_by_original[original] = choose_preferred_wayback(discovered_urls_by_original[original], href)
      next
    end

    next unless href.include?("dotnetkicks.com/submit/?url=")

    begin
      extracted = href[/[?&]url=([^&]+)/, 1]
      next if extracted.to_s.empty?

      target = CGI.unescape(extracted)
      next unless target.match?(%r{\Ahttps?://frogsbrain\.blogspot\.com/\d{4}/\d{2}/[^/?#]+\.html}i)

      stamp = href[%r{/web/(\d{14})}, 1]
      candidate = stamp ? "https://web.archive.org/web/#{stamp}/#{target}" : target
      discovered_urls_by_original[target] = choose_preferred_wayback(discovered_urls_by_original[target], candidate)
    rescue StandardError
      next
    end
  end

  doc.css("div.post").each do |post|
    link = post.at_css("h3.post-title a")
    permalink = post.at_css(".post-footer a.timestamp-link")
    wayback_url = link&.[]("href").to_s.strip
    if wayback_url.empty? || !wayback_url.include?("frogsbrain.blogspot.com/")
      wayback_url = permalink&.[]("href").to_s.strip
    end
    next if wayback_url.empty?
    next unless wayback_url.include?("frogsbrain.blogspot.com/")
    original = dewayback(wayback_url)
    next if seen_original_urls.include?(original)
    body_node = post.at_css("div.post-body")
    next if body_node.nil?
    title = extract_title(link, body_node, original)
    next if title.empty?
    body_fragment = Nokogiri::HTML.fragment(body_node.inner_html)
    body_html = sanitize_content(body_fragment)
    plain = Nokogiri::HTML.fragment(body_html).text.gsub(/\s+/, " ").strip
    description = plain[0, 180]
    discovered_urls_by_original[original] = choose_preferred_wayback(discovered_urls_by_original[original], wayback_url)
    date = extract_date(post, original)

    rows << {
      wayback_url: wayback_url,
      title: title,
      date: date,
      body_html: body_html,
      description: description
    }
    seen_original_urls << original
  end
end

if rows.empty?
  warn "No posts extracted from local snapshots."
  exit 1
end

WAYBACK_TARGETS.dirname.mkpath
targets = discovered_urls_by_original.values.compact.uniq.sort
targets_body = +""
targets_body << "# Discovered frogsbrain post URLs from local Wayback snapshot exports\n"
targets_body << "# Source directory: #{source_dir}\n"
targets.each { |url| targets_body << "#{url}\n" }
WAYBACK_TARGETS.write(targets_body) unless options[:dry_run]
puts(options[:dry_run] ? "[dry-run] would write #{WAYBACK_TARGETS.relative_path_from(ROOT)} (#{targets.size} URLs)" : "Wrote #{WAYBACK_TARGETS.relative_path_from(ROOT)} (#{targets.size} URLs)")

wrote = 0
skipped = 0
planned_outputs = Set.new
rows.sort_by { |r| [r[:date].to_s, r[:title]] }.each do |row|
  slug = slugify(row[:title])
  if slug.empty?
    skipped += 1
    next
  end
  out_path = POSTS_DIR.join("#{row[:date]}-#{slug}.html")
  if planned_outputs.include?(out_path.to_s)
    skipped += 1
    next
  end
  planned_outputs << out_path.to_s
  if out_path.exist? && !options[:overwrite]
    skipped += 1
    next
  end

  fm = build_frontmatter(
    title: row[:title],
    date: row[:date],
    description: row[:description],
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
