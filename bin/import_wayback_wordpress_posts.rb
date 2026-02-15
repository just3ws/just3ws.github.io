#!/usr/bin/env ruby
# frozen_string_literal: true

require "nokogiri"
require "open3"
require "optparse"
require "pathname"
require "set"
require "time"
require "uri"

ROOT = Pathname(__dir__).join("..").expand_path
POSTS_DIR = ROOT.join("_posts")
ASSETS_DIR = ROOT.join("assets", "images", "writing", "wordpress")
WAYBACK_PREFIX = %r{\Ahttps?://web\.archive\.org/web/\d{14}/}i
POST_URL_REGEX = %r{https?://web\.archive\.org/web/\d{14}/https?://just3ws\.wordpress\.com/\d{4}/\d{2}/\d{2}/[^/\s"']+/?}i

def shell_escape(value)
  "'" + value.to_s.gsub("'", %q('"'"')) + "'"
end

def slugify(value)
  value.to_s.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/\A-+|-+\z/, "").slice(0, 90)
end

def yaml_quote(value)
  "\"" + value.to_s.gsub("\\", "\\\\").gsub("\"", "\\\"") + "\""
end

def dewayback(url)
  url.to_s.sub(WAYBACK_PREFIX, "")
end

def normalize_url(url)
  value = url.to_s.strip
  return value if value.empty?
  return "https:#{value}" if value.start_with?("//")

  value
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

    sleep(0.8 * attempts)
    retry
  end
end

def download_file(url, destination)
  destination.dirname.mkpath
  cmd = "curl -fsSL #{shell_escape(url)} -o #{shell_escape(destination.to_s)}"
  system(cmd)
end

def parse_archive_urls(listing_html)
  urls = listing_html.scan(POST_URL_REGEX).map { |u| u.sub(/#.*/, "") }.uniq
  doc = Nokogiri::HTML(listing_html)
  doc.css("a[href]").each do |node|
    href = node["href"].to_s.strip
    next if href.empty?
    next unless href.match?(POST_URL_REGEX)

    urls << href.sub(/#.*/, "")
  end
  urls.uniq
end

def first_present(*values)
  values.each do |value|
    normalized = value.to_s.strip
    return normalized unless normalized.empty?
  end
  ""
end

def parse_date(value)
  Time.parse(value).to_date
rescue StandardError
  nil
end

def extract_post(page_html, wayback_url)
  doc = Nokogiri::HTML(page_html)
  title = first_present(
    doc.at_css("h2[id^='post-']")&.text,
    doc.at_css("h2.post-title")&.text,
    doc.at_css(".post-header h1")&.text,
    doc.at_css("h1.entry-title")&.text,
    doc.at_css("h1")&.text,
    doc.at_css("title")&.text&.sub(/\A.*?:\s*/, "")
  )

  author_line = first_present(doc.at_css(".post-header .author")&.text, doc.at_css(".entry-meta")&.text)
  date_text = author_line[/\bon\s+(.+)\z/i, 1].to_s.strip
  date_text = first_present(
    date_text,
    doc.at_css(".meta .signature p:nth-of-type(2)")&.text
  )
  date = parse_date(date_text)
  date ||= begin
    original = dewayback(wayback_url)
    if original =~ %r{/(\d{4})/(\d{2})/(\d{2})/}
      Date.new(Regexp.last_match(1).to_i, Regexp.last_match(2).to_i, Regexp.last_match(3).to_i)
    end
  rescue StandardError
    nil
  end
  date ||= Date.today

  content_node =
    doc.at_css(".post .entry") ||
    doc.at_css(".entry-content") ||
    doc.at_css("article") ||
    doc.at_css("div.main")
  return nil if content_node.nil?

  working = Nokogiri::HTML.fragment(content_node.inner_html)
  working.css("script,style,iframe,form,noscript,#comments,.comments,.comment-number,.commentlist,.navigation,.sharing,.robots-nocontent,.geo,.reply,.c-grav,.snap_nopreview,.snap_preview,.pd-rating").remove

  hero_source = working.at_css("img")&.[]("src").to_s.strip
  tags = doc.css(".meta a[rel='category tag']").map { |a| a.text.to_s.strip }.reject(&:empty?)

  working.css("a[href], img[src]").each do |node|
    attr = node.name == "a" ? "href" : "src"
    value = normalize_url(node[attr])
    if value.match?(WAYBACK_PREFIX)
      value = dewayback(value)
      value = normalize_url(value)
    end
    node[attr] = value

    if node.name == "a"
      node["rel"] = "noopener noreferrer"
      node["target"] = "_blank"
    else
      node["loading"] = "lazy"
      node["decoding"] = "async"
    end
  end

  content_html = working.to_html.strip
  description = working.text.gsub(/\s+/, " ").strip[0, 160]
  canonical = first_present(doc.at_css("link[rel='canonical']")&.[]("href"), dewayback(wayback_url))
  canonical = dewayback(canonical)

  {
    title: title,
    date: date,
    content_html: content_html,
    description: description,
    hero_source: hero_source,
    tags: tags,
    canonical: canonical
  }
end

def build_frontmatter(title:, date:, description:, tags:, original_url:, original_host:)
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
  lines << "archive_note: #{yaml_quote("Originally published on #{original_host}. Republished from an archived Wayback snapshot.")}"
  lines << "---"
  lines.join("\n")
end

options = {
  urls: [],
  url_file: nil,
  dry_run: false,
  overwrite: false
}

OptionParser.new do |opts|
  opts.banner = "Usage: bin/import_wayback_wordpress_posts.rb --url <wayback-archive-url> [--url ...] [--url-file PATH] [--dry-run]"
  opts.on("--url URL", "Wayback archive listing URL (repeatable).") { |v| options[:urls] << v.strip }
  opts.on("--url-file PATH", "Text file with one archive URL per line.") { |v| options[:url_file] = v }
  opts.on("--dry-run", "Preview work without writing files.") { options[:dry_run] = true }
  opts.on("--overwrite", "Overwrite existing post files.") { options[:overwrite] = true }
end.parse!

if options[:url_file]
  file_path = Pathname(options[:url_file]).expand_path
  if file_path.exist?
    options[:urls].concat(
      file_path.read.lines
        .map(&:strip)
        .reject { |line| line.empty? || line.start_with?("#") }
    )
  else
    warn "URL file not found: #{file_path}"
  end
end

if options[:urls].empty?
  warn "Provide at least one --url or --url-file."
  exit 1
end

archive_post_urls = Set.new

options[:urls].each do |listing_url|
  if listing_url.match?(POST_URL_REGEX)
    archive_post_urls << listing_url
    puts "Added direct post URL: #{listing_url} (posts so far: #{archive_post_urls.size})"
    next
  end

  begin
    html = fetch_url(listing_url)
    parse_archive_urls(html).each { |url| archive_post_urls << url }
    puts "Scanned listing: #{listing_url} (posts so far: #{archive_post_urls.size})"
  rescue StandardError => e
    warn "Failed listing #{listing_url}: #{e.message}"
  end
end

if archive_post_urls.empty?
  warn "No post URLs discovered from provided archive pages."
  exit 1
end

wrote = 0
skipped = 0
archive_post_urls.to_a.sort.each do |post_url|
  begin
    html = fetch_url(post_url)
    extracted = extract_post(html, post_url)
    if extracted.nil?
      skipped += 1
      warn "Skipped #{post_url}: no extractable content"
      next
    end

    slug = slugify(extracted[:title])
    if slug.empty?
      skipped += 1
      warn "Skipped #{post_url}: empty slug"
      next
    end

    out_path = POSTS_DIR.join("#{extracted[:date]}-#{slug}.html")
    if out_path.exist? && !options[:overwrite]
      skipped += 1
      puts "Skip existing #{out_path.relative_path_from(ROOT)}"
      next
    end

    hero_local = nil
    unless extracted[:hero_source].to_s.empty?
      hero_url = normalize_url(extracted[:hero_source])
      ext = File.extname(URI(hero_url).path).downcase
      ext = ".jpg" unless %w[.jpg .jpeg .png .gif .webp].include?(ext)
      hero_local = ASSETS_DIR.join("#{extracted[:date]}-#{slug}#{ext}")
      unless options[:dry_run]
        download_file(hero_url, hero_local)
      end
    end

    body = +""
    if hero_local
      rel = "/" + hero_local.relative_path_from(ROOT).to_s
      body << "<figure><img src=\"#{rel}\" alt=\"#{extracted[:title].gsub('"', '&quot;')}\"></figure>\n\n"
    end
    body << extracted[:content_html] << "\n"

    tag_values = (["wordpress", "republished", "wayback"] + extracted[:tags].map { |tag| slugify(tag) }).reject(&:empty?).uniq
    host = URI(extracted[:canonical]).host || URI(dewayback(post_url)).host || "just3ws.wordpress.com"
    frontmatter = build_frontmatter(
      title: extracted[:title],
      date: extracted[:date],
      description: extracted[:description],
      tags: tag_values,
      original_url: post_url,
      original_host: host
    )

    if options[:dry_run]
      puts "[dry-run] would write #{out_path.relative_path_from(ROOT)}"
      next
    end

    out_path.write("#{frontmatter}\n\n#{body}")
    puts "Wrote #{out_path.relative_path_from(ROOT)}"
    wrote += 1
  rescue StandardError => e
    skipped += 1
    warn "Failed post #{post_url}: #{e.message}"
  end
end

puts "Done. wrote=#{wrote} skipped=#{skipped} discovered=#{archive_post_urls.size}"
