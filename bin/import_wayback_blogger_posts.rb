#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "nokogiri"
require "optparse"
require "pathname"
require "time"
require "uri"
require "open3"
require "set"

ROOT = Pathname(__dir__).join("..").expand_path
POSTS_DIR = ROOT.join("_posts")
ASSETS_DIR = ROOT.join("assets", "images", "writing", "blogger")
WAYBACK_URL_REGEX = %r{https?://web\.archive\.org/web/\d{14}/[^\s\)\]\">]+}

def shell_escape(value)
  "'" + value.to_s.gsub("'", %q('"'"')) + "'"
end

def slugify(value)
  value.to_s.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/\A-+|-+\z/, "").slice(0, 90)
end

def yaml_quote(value)
  "\"" + value.to_s.gsub("\\", "\\\\").gsub("\"", "\\\"") + "\""
end

def extract_wayback_candidates(value)
  value.to_s.scan(WAYBACK_URL_REGEX)
end

def normalize_wayback_input(value)
  raw = value.to_s.strip
  if raw.include?("#!")
    fragment_target = raw.split("#!", 2).last.to_s.strip
    raw = fragment_target if fragment_target.match?(%r{\Ahttps?://web\.archive\.org/web/})
  end

  candidates = extract_wayback_candidates(raw)
  return raw if candidates.empty?

  candidates.last
end

def wayback_stamp(url)
  url[%r{/web/(\d{14})/}, 1]
end

def wayback_original_url(url)
  url.sub(%r{\Ahttps?://web\.archive\.org/web/\d{14}[a-z_]*\/}, "")
end

def fetch_url(url, timeout: 40, retries: 4)
  attempts = 0
  begin
    stdout, stderr, status = Open3.capture3("curl", "-fsSL", "--max-time", timeout.to_s, url)
    raise stderr.strip unless status.success?

    stdout
  rescue StandardError => e
    attempts += 1
    raise "curl failed for #{url}: #{e}" if attempts > retries

    sleep(0.75 * attempts)
    retry
  end
end

def parse_post_page(page_html)
  doc = Nokogiri::HTML(page_html)
  title = doc.at_css("meta[property='og:title']")&.[]("content").to_s.strip
  description = doc.at_css("meta[property='og:description']")&.[]("content").to_s.strip
  og_image = doc.at_css("meta[property='og:image']")&.[]("content").to_s.strip
  canonical = doc.at_css("link[rel='canonical']")&.[]("href").to_s.strip

  script_blob = doc.css("script").map(&:text).join("\n")
  post_id = script_blob[/postId':\s*'(\d+)'/, 1] || script_blob[/postId":\s*"?(\d+)/, 1]

  {
    title: title,
    description: description,
    og_image: og_image,
    canonical: canonical,
    post_id: post_id
  }
end

def discover_blogger_post_urls(page_html:, stamp:, blog_host:)
  doc = Nokogiri::HTML(page_html)
  links = doc.css("a[href]").map { |a| a["href"].to_s.strip }.reject(&:empty?)
  post_pattern = %r{\Ahttps?://#{Regexp.escape(blog_host)}/\d{4}/\d{2}/[^?#]+\.html(?:[?#].*)?\z}i

  links
    .map { |href| href.start_with?("//") ? "https:#{href}" : href }
    .map { |href| href.match?(%r{\Ahttps?://web\.archive\.org/web/\d{14}[a-z_]*\/}i) ? wayback_original_url(href) : href }
    .select { |href| href.match?(post_pattern) }
    .map { |href| href.sub(/[?#].*$/, "") }
    .uniq
    .map { |href| "https://web.archive.org/web/#{stamp}/#{href}" }
end

def parse_blogger_feed(feed_json)
  parsed = JSON.parse(feed_json)
  entry = parsed.fetch("entry")
  title = entry.dig("title", "$t").to_s.strip
  content_html = entry.dig("content", "$t").to_s
  published = entry.dig("published", "$t").to_s.strip
  tags = Array(entry["category"]).map { |c| c["term"].to_s.strip }.reject(&:empty?)
  alternate = Array(entry["link"]).find { |l| l["rel"] == "alternate" } || {}

  {
    title: title,
    content_html: content_html,
    published: published,
    tags: tags,
    original_post_url: alternate["href"].to_s
  }
end

def extension_from_url(url)
  path = URI(url).path
  ext = File.extname(path).downcase
  return ext if %w[.jpg .jpeg .png .webp .gif].include?(ext)

  ".jpg"
rescue StandardError
  ".jpg"
end

def absolutize_url(url)
  value = url.to_s.strip
  return value if value.empty?
  return "https:#{value}" if value.start_with?("//")

  value
end

def sanitize_content(html)
  fragment = Nokogiri::HTML.fragment(html.to_s)
  fragment.css("script,style,iframe,form,noscript").remove

  fragment.css("*").each do |node|
    allowed_attrs = %w[href src alt title]
    node.attribute_nodes.each do |attr|
      node.remove_attribute(attr.name) unless allowed_attrs.include?(attr.name)
    end

    if node.name == "a" && node["href"]
      node["href"] = absolutize_url(node["href"])
      node["rel"] = "noopener noreferrer"
      node["target"] = "_blank"
    end

    if node.name == "img" && node["src"]
      node["src"] = absolutize_url(node["src"])
      node["loading"] = "lazy"
      node["decoding"] = "async"
    end
  end

  fragment.to_html
end

def download_image(url, dest_path, dry_run:)
  return nil if url.to_s.strip.empty?
  return dest_path if dry_run

  dest_path.dirname.mkpath
  cmd = "curl -fsSL #{shell_escape(url)} -o #{shell_escape(dest_path.to_s)}"
  return dest_path if system(cmd)

  nil
end

def build_frontmatter(data)
  lines = ["---"]
  lines << "layout: \"post\""
  lines << "title: #{yaml_quote(data[:title])}"
  lines << "date: #{yaml_quote(data[:date])}"
  lines << "description: #{yaml_quote(data[:description])}" unless data[:description].to_s.empty?
  lines << "tags:"
  data[:tags].each { |tag| lines << "  - #{tag}" }
  lines << "originally_published_on: \"Blogger\""
  lines << "original_url: #{yaml_quote(data[:original_url])}"
  lines << "original_published_at: #{yaml_quote(data[:original_published_at])}"
  lines << "archive_note: #{yaml_quote("Originally published on #{data[:original_host]}. Republished from an archived Wayback snapshot.")}"
  lines << "---"
  lines.join("\n")
end

options = {
  input: nil,
  dry_run: false
}

OptionParser.new do |opts|
  opts.banner = "Usage: bin/import_wayback_blogger_posts.rb --input <json-or-txt> [--dry-run]"
  opts.on("--input PATH", "Input file. JSON array/string or plaintext URLs (one per line).") { |v| options[:input] = v }
  opts.on("--dry-run", "Preview actions without writing files.") { options[:dry_run] = true }
end.parse!

if options[:input].to_s.strip.empty?
  warn "Missing required --input"
  exit 1
end

input_path = Pathname(options[:input]).expand_path
unless input_path.exist?
  warn "Input file not found: #{input_path}"
  exit 1
end

raw = input_path.read
items =
  begin
    parsed = JSON.parse(raw)
    parsed.is_a?(Array) ? parsed : [parsed]
  rescue JSON::ParserError
    raw.lines
      .map(&:strip)
      .reject { |line| line.empty? || line.start_with?("#") }
  end

queue = items.dup
seen_urls = Set.new
processed = 0

while (item = queue.shift)
  source_value = if item.is_a?(Hash)
                   item["url"] || item["wayback_url"] || item["original_url"] || item.to_s
                 else
                   item.to_s
                 end
  wayback_url = normalize_wayback_input(source_value)
  next if wayback_url.empty?
  next if seen_urls.include?(wayback_url)

  seen_urls << wayback_url
  processed += 1
  stamp = wayback_stamp(wayback_url)
  unless stamp
    warn "Skipping item #{processed}: not a valid Wayback URL: #{source_value}"
    next
  end

  begin
    page_html = fetch_url(wayback_url)
    page = parse_post_page(page_html)
    original_url = wayback_original_url(wayback_url)
    blog_host = URI(original_url).host || "just3ws.blogspot.com"

    if page[:post_id].to_s.empty?
      discovered = discover_blogger_post_urls(page_html: page_html, stamp: stamp, blog_host: blog_host)
      if discovered.any?
        puts "Discovered #{discovered.size} post URL(s) from #{wayback_url}"
        discovered.each { |url| queue << url unless seen_urls.include?(url) }
      else
        warn "Skipping item #{processed}: unable to locate postId in #{wayback_url}"
      end
      next
    end

    feed_url = "https://web.archive.org/web/#{stamp}/http://#{blog_host}/feeds/posts/default/#{page[:post_id]}?alt=json"
    feed_json = fetch_url(feed_url)
    entry = parse_blogger_feed(feed_json)

    published_at = Time.parse(entry[:published]).to_date
    title = entry[:title].empty? ? page[:title] : entry[:title]
    slug = slugify(title)
    if slug.empty?
      warn "Skipping item #{idx + 1}: unable to compute slug from title."
      next
    end

    hero_url = page[:og_image].to_s
    image_path = nil
    if !hero_url.empty?
      ext = extension_from_url(hero_url)
      image_path = ASSETS_DIR.join("#{published_at}-#{slug}#{ext}")
      downloaded = download_image(hero_url, image_path, dry_run: options[:dry_run])
      image_path = downloaded || image_path
    end

    description = page[:description].to_s.strip
    if description.empty?
      plain = Nokogiri::HTML.fragment(entry[:content_html].to_s).text.gsub(/\s+/, " ").strip
      description = plain[0, 160]
    end

    clean_body = sanitize_content(entry[:content_html])
    body = +""
    if image_path
      relative_image = "/" + image_path.relative_path_from(ROOT).to_s
      body << "<figure><img src=\"#{relative_image}\" alt=\"#{title.gsub('"', '&quot;')}\"></figure>\n\n"
    end
    body << clean_body

    fm = build_frontmatter(
      title: title,
      date: published_at.to_s,
      description: description,
      tags: (["blogger", "republished", "wayback"] + entry[:tags].map { |t| slugify(t) }).uniq,
      original_url: wayback_url,
      original_published_at: published_at.to_s,
      original_host: blog_host
    )

    output_path = POSTS_DIR.join("#{published_at}-#{slug}.html")
    if options[:dry_run]
      puts "[dry-run] would write #{output_path.relative_path_from(ROOT)}"
      next
    end

    output_path.write("#{fm}\n\n#{body}\n")
    puts "Wrote #{output_path.relative_path_from(ROOT)}"
  rescue StandardError => e
    warn "Error processing item #{processed}: #{e.message}"
  end
end
