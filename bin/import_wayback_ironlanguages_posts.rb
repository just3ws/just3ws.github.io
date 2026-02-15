#!/usr/bin/env ruby
# frozen_string_literal: true

require "nokogiri"
require "open3"
require "optparse"
require "pathname"
require "time"
require "uri"

ROOT = Pathname(__dir__).join("..").expand_path
POSTS_DIR = ROOT.join("_posts")
ASSETS_DIR = ROOT.join("assets", "images", "writing", "ironlanguages")
WAYBACK_PREFIX = %r{\Ahttps?://web\.archive\.org/web/\d{14}[a-z_]*/}i

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

def fetch_url(url, timeout: 50, retries: 5)
  attempts = 0
  begin
    stdout, stderr, status = Open3.capture3("curl", "-fsSL", "--max-time", timeout.to_s, url)
    raise stderr.strip unless status.success?

    stdout
  rescue StandardError => e
    attempts += 1
    raise "curl failed for #{url}: #{e}" if attempts > retries

    sleep(1.0 * attempts)
    retry
  end
end

def download_file(url, destination)
  destination.dirname.mkpath
  cmd = "curl -fsSL #{shell_escape(url)} -o #{shell_escape(destination.to_s)}"
  system(cmd)
end

def strip_wayback_from_attrs(node)
  return unless node.element?

  if node["href"]
    clean = normalize_url(dewayback(node["href"]))
    node["href"] = clean
    node["rel"] = "noopener noreferrer"
    node["target"] = "_blank"
  end
  return unless node["src"]

  clean = normalize_url(dewayback(node["src"]))
  node["src"] = clean
  node["loading"] = "lazy"
  node["decoding"] = "async"
end

def extract_post(page_html, wayback_url)
  doc = Nokogiri::HTML(page_html)
  post = doc.at_css("div.post")
  return nil if post.nil?

  title = post.at_css("h2[id^='posttitle_'] a")&.text.to_s.strip
  title = doc.at_css("meta[property='og:title']")&.[]("content").to_s.strip if title.empty?
  title = doc.at_css("title")&.text.to_s.strip if title.empty?
  return nil if title.empty?

  pub_epoch = post.at_css("span[data-posterous-pubdate]")&.[]("data-posterous-pubdate").to_s
  date = begin
    Time.at(pub_epoch.to_i).utc.to_date
  rescue StandardError
    nil
  end
  date ||= begin
    original = dewayback(wayback_url)
    if original =~ %r{/(\d{4})/(\d{2})/(\d{2})/}
      Date.new(Regexp.last_match(1).to_i, Regexp.last_match(2).to_i, Regexp.last_match(3).to_i)
    end
  rescue StandardError
    nil
  end
  date ||= Date.today

  body = post.dup
  body.css("h2[id^='posttitle_'], .sharing, .infobar, script, style, form, iframe, .posterous_ojs").remove
  body.css("*").each { |node| strip_wayback_from_attrs(node) }

  hero_source = body.at_css("img")&.[]("src").to_s.strip
  content_html = body.inner_html.to_s.strip
  plain = Nokogiri::HTML.fragment(content_html).text.gsub(/\s+/, " ").strip
  description = plain[0, 180]

  {
    title: title,
    date: date,
    content_html: content_html,
    description: description,
    hero_source: hero_source
  }
end

def build_frontmatter(title:, date:, description:, tags:, original_url:)
  lines = ["---"]
  lines << "layout: \"post\""
  lines << "title: #{yaml_quote(title)}"
  lines << "date: #{yaml_quote(date.to_s)}"
  lines << "description: #{yaml_quote(description)}" unless description.to_s.empty?
  lines << "tags:"
  tags.each { |tag| lines << "  - #{tag}" }
  lines << "originally_published_on: \"IronLanguages\""
  lines << "original_url: #{yaml_quote(original_url)}"
  lines << "original_published_at: #{yaml_quote(date.to_s)}"
  lines << "archive_note: #{yaml_quote("Originally published on ironlanguages.net. Republished from an archived Wayback snapshot.")}"
  lines << "---"
  lines.join("\n")
end

options = {
  url_file: ROOT.join("docs", "wayback", "targets-personal-ironlanguages-posts.txt").to_s,
  dry_run: false,
  overwrite: false
}

OptionParser.new do |opts|
  opts.banner = "Usage: bin/import_wayback_ironlanguages_posts.rb [--url-file PATH] [--dry-run] [--overwrite]"
  opts.on("--url-file PATH", "Text file with one Wayback post URL per line.") { |v| options[:url_file] = v }
  opts.on("--dry-run", "Preview work without writing files.") { options[:dry_run] = true }
  opts.on("--overwrite", "Overwrite existing post files.") { options[:overwrite] = true }
end.parse!

url_file = Pathname(options[:url_file]).expand_path
unless url_file.exist?
  warn "URL file not found: #{url_file}"
  exit 1
end

urls = url_file.read.lines.map(&:strip).reject { |line| line.empty? || line.start_with?("#") }
if urls.empty?
  warn "No URLs in #{url_file}"
  exit 1
end

wrote = 0
skipped = 0

urls.each_with_index do |url, idx|
  begin
    html = fetch_url(url)
    extracted = extract_post(html, url)
    if extracted.nil?
      skipped += 1
      warn "Skipped #{idx + 1}/#{urls.size}: unable to extract #{url}"
      next
    end

    slug = slugify(extracted[:title])
    if slug.empty?
      skipped += 1
      warn "Skipped #{idx + 1}/#{urls.size}: empty slug #{url}"
      next
    end

    out_path = POSTS_DIR.join("#{extracted[:date]}-#{slug}.html")
    if out_path.exist? && !options[:overwrite]
      skipped += 1
      puts "Skip existing #{out_path.relative_path_from(ROOT)}"
      next
    end

    hero_local = nil
    unless extracted[:hero_source].empty?
      ext = File.extname(URI(extracted[:hero_source]).path).downcase
      ext = ".jpg" unless %w[.jpg .jpeg .png .gif .webp].include?(ext)
      hero_local = ASSETS_DIR.join("#{extracted[:date]}-#{slug}#{ext}")
      download_file(extracted[:hero_source], hero_local) unless options[:dry_run]
    end

    body = +""
    if hero_local
      rel = "/" + hero_local.relative_path_from(ROOT).to_s
      body << "<figure><img src=\"#{rel}\" alt=\"#{extracted[:title].gsub('"', '&quot;')}\"></figure>\n\n"
    end
    body << extracted[:content_html]
    frontmatter = build_frontmatter(
      title: extracted[:title],
      date: extracted[:date],
      description: extracted[:description],
      tags: %w[podcast ironlanguages republished wayback],
      original_url: url
    )

    if options[:dry_run]
      puts "[dry-run] would write #{out_path.relative_path_from(ROOT)}"
    else
      out_path.write("#{frontmatter}\n\n#{body}\n")
      puts "Wrote #{out_path.relative_path_from(ROOT)}"
    end
    wrote += 1
  rescue StandardError => e
    skipped += 1
    warn "Failed #{idx + 1}/#{urls.size} #{url}: #{e.message}"
  end
end

puts "Done. wrote=#{wrote} skipped=#{skipped} total=#{urls.size}"
