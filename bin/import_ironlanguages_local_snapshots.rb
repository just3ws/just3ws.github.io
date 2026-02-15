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
SOURCE_DIR = ROOT.join("tmp", "wbm", "ironlanguages")
ASSETS_DIR = ROOT.join("assets", "images", "writing", "ironlanguages")
MANIFEST_PATH = ROOT.join("docs", "wayback", "targets-personal-ironlanguages-posts-local.txt")
WAYBACK_PREFIX = %r{\Ahttps?://web\.archive\.org/web/\d{14}[a-z_]*/}i

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

def sanitize_fragment(fragment)
  fragment.css("script,style,iframe,form,noscript,.sharing,.infobar,.posterous_ojs,.posterous_tweet_button,.posterous_fb_like_widget").remove
  fragment.css("*").each do |node|
    next unless node.element?

    if node["href"]
      node["href"] = dewayback(node["href"].to_s)
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

def parse_date(post_node, original_url)
  epoch = post_node.at_css("span[data-posterous-pubdate]")&.[]("data-posterous-pubdate").to_s
  date =
    begin
      Time.at(epoch.to_i).utc.to_date unless epoch.empty?
    rescue StandardError
      nil
    end
  return date unless date.nil?

  if original_url =~ %r{/(\d{4})/(\d{2})/(\d{2})/}
    return Date.new(Regexp.last_match(1).to_i, Regexp.last_match(2).to_i, Regexp.last_match(3).to_i)
  end

  Date.today
end

def ext_for(path)
  ext = File.extname(path.to_s).downcase
  return ext if %w[.jpg .jpeg .png .gif .webp].include?(ext)

  ".jpg"
end

def build_frontmatter(title:, date:, description:, original_url:)
  lines = ["---"]
  lines << "layout: \"post\""
  lines << "title: #{yaml_quote(title)}"
  lines << "date: #{yaml_quote(date.to_s)}"
  lines << "description: #{yaml_quote(description)}" unless description.to_s.empty?
  lines << "tags:"
  %w[podcast ironlanguages republished wayback].each { |tag| lines << "  - #{tag}" }
  lines << "originally_published_on: \"IronLanguages\""
  lines << "original_url: #{yaml_quote(original_url)}"
  lines << "original_published_at: #{yaml_quote(date.to_s)}"
  lines << "archive_note: #{yaml_quote("Originally published on ironlanguages.net. Republished from local Wayback snapshot exports.")}"
  lines << "---"
  lines.join("\n")
end

options = {
  source_dir: SOURCE_DIR.to_s,
  dry_run: false,
  overwrite: false
}

OptionParser.new do |opts|
  opts.banner = "Usage: bin/import_ironlanguages_local_snapshots.rb [--source-dir PATH] [--dry-run] [--overwrite]"
  opts.on("--source-dir PATH", "Directory with local ironlanguages HTML snapshots.") { |v| options[:source_dir] = v }
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

post_rows = {}
manifest_urls = Set.new

html_files.each do |file|
  doc = Nokogiri::HTML(File.read(file))
  doc.css("div.post").each do |post|
    link = post.at_css("h2[id^='posttitle_'] a[href]")
    next if link.nil?

    wayback_url = link["href"].to_s.strip
    next unless wayback_url.include?("ironlanguages.net/")
    original = dewayback(wayback_url)
    manifest_urls << wayback_url

    title = link.text.to_s.gsub(/\u00A0/, " ").strip
    next if title.empty?

    body = post.dup
    body.css("h2[id^='posttitle_']").remove
    body_html = sanitize_fragment(Nokogiri::HTML.fragment(body.inner_html))
    plain = Nokogiri::HTML.fragment(body_html).text.gsub(/\s+/, " ").strip
    description = plain[0, 180]
    date = parse_date(post, original)

    hero_node = post.at_css("img[src]")
    hero_src = hero_node&.[]("src").to_s
    existing = post_rows[original]
    if existing.nil? || wayback_stamp(wayback_url) >= wayback_stamp(existing[:wayback_url])
      post_rows[original] = {
        wayback_url: wayback_url,
        title: title,
        date: date,
        body_html: body_html,
        description: description,
        hero_src: hero_src
      }
    end
  end
end

manifest_body = +""
manifest_body << "# Discovered ironlanguages.net post URLs from local Wayback snapshot exports\n"
manifest_body << "# Source directory: #{source_dir}\n"
manifest_urls.to_a.sort.each { |url| manifest_body << "#{url}\n" }
if options[:dry_run]
  puts "[dry-run] would write #{MANIFEST_PATH.relative_path_from(ROOT)} (#{manifest_urls.size} URLs)"
else
  MANIFEST_PATH.write(manifest_body)
  puts "Wrote #{MANIFEST_PATH.relative_path_from(ROOT)} (#{manifest_urls.size} URLs)"
end

wrote = 0
skipped = 0
planned = Set.new

post_rows.values.sort_by { |r| [r[:date].to_s, r[:title]] }.each do |row|
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

  hero_rel = nil
  unless row[:hero_src].to_s.empty?
    src = row[:hero_src]
    begin
      parsed = URI(src)
      if !parsed.host.to_s.empty?
        file_name = File.basename(parsed.path)
        local_candidate = source_dir.join("The Iron Languages Podcast - The revolution will not be compiled._files", file_name)
        if local_candidate.exist?
          ext = ext_for(local_candidate)
          dest = ASSETS_DIR.join("#{row[:date]}-#{slug}#{ext}")
          unless options[:dry_run]
            dest.dirname.mkpath
            File.write(dest, File.binread(local_candidate))
          end
          hero_rel = "/" + dest.relative_path_from(ROOT).to_s
        end
      end
    rescue StandardError
      nil
    end
  end

  body = +""
  body << "<figure><img src=\"#{hero_rel}\" alt=\"#{row[:title].gsub('"', '&quot;')}\"></figure>\n\n" unless hero_rel.to_s.empty?
  body << row[:body_html]

  fm = build_frontmatter(
    title: row[:title],
    date: row[:date],
    description: row[:description],
    original_url: row[:wayback_url]
  )

  if options[:dry_run]
    puts "[dry-run] would write #{out_path.relative_path_from(ROOT)}"
  else
    out_path.write("#{fm}\n\n#{body}\n")
    puts "Wrote #{out_path.relative_path_from(ROOT)}"
  end
  wrote += 1
end

puts "Done. extracted=#{post_rows.size} wrote=#{wrote} skipped=#{skipped}"
