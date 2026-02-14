#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "optparse"
require "pathname"
require "time"
require "uri"

ROOT = Pathname(__dir__).join("..").expand_path
POSTS_DIR = ROOT.join("_posts")
ASSETS_DIR = ROOT.join("assets", "images", "writing", "linkedin")

def shell_escape(value)
  "'" + value.to_s.gsub("'", %q('"'"')) + "'"
end

def slugify(value)
  value.to_s.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/\A-+|-+\z/, "").slice(0, 80)
end

def parse_date(value)
  return Date.today if value.to_s.strip.empty?
  Time.parse(value).to_date
rescue StandardError
  Date.today
end

def extension_from_url(url)
  path = URI(url).path
  ext = File.extname(path).downcase
  return ext if %w[.jpg .jpeg .png .webp .gif].include?(ext)

  ".jpg"
rescue StandardError
  ".jpg"
end

def wrap_frontmatter(frontmatter, body)
  lines = ["---"]
  frontmatter.each do |key, value|
    case value
    when Array
      lines << "#{key}:"
      value.each { |item| lines << "  - #{item}" }
    when nil
      next
    else
      escaped = value.to_s.gsub('"', '\"')
      lines << %(#{key}: "#{escaped}")
    end
  end
  lines << "---"
  lines << ""
  lines << body
  lines.join("\n")
end

def download_image(url, dest_path, dry_run:)
  return nil if url.to_s.strip.empty?

  if dry_run
    puts "[dry-run] download #{url} -> #{dest_path}"
    return dest_path
  end

  dest_path.dirname.mkpath
  cmd = "curl -fsSL #{shell_escape(url)} -o #{shell_escape(dest_path.to_s)}"
  ok = system(cmd)
  ok ? dest_path : nil
end

options = {
  input: nil,
  dry_run: false
}

OptionParser.new do |opts|
  opts.banner = "Usage: bin/import_linkedin_articles.rb --input <json-file> [--dry-run]"
  opts.on("--input PATH", "Path to JSON file generated from LinkedIn extractor") { |v| options[:input] = v }
  opts.on("--dry-run", "Preview output without writing files") { options[:dry_run] = true }
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

raw = JSON.parse(input_path.read)
articles = raw.is_a?(Array) ? raw : [raw]

if articles.empty?
  warn "No articles in input."
  exit 1
end

articles.each_with_index do |article, idx|
  title = article["title"].to_s.strip
  original_url = article["original_url"].to_s.strip
  author_name = article["author_name"].to_s.strip
  author_profile_url = article["author_profile_url"].to_s.strip
  published_at = article["published_at"].to_s.strip
  hero_image_url = article["hero_image_url"].to_s.strip
  content_html = article["content_html"].to_s.strip
  excerpt = article["excerpt"].to_s.strip

  if title.empty? || original_url.empty? || content_html.empty?
    warn "Skipping item #{idx + 1}: requires title, original_url, and content_html."
    next
  end

  date = parse_date(published_at)
  slug = slugify(title)
  slug = "linkedin-article-#{idx + 1}" if slug.empty?

  image_path = nil
  unless hero_image_url.empty?
    ext = extension_from_url(hero_image_url)
    image_path = ASSETS_DIR.join("#{date}-#{slug}#{ext}")
    download_image(hero_image_url, image_path, dry_run: options[:dry_run])
  end

  relative_image = image_path ? "/" + image_path.relative_path_from(ROOT).to_s : nil

  attribution = +"Originally published on LinkedIn"
  attribution << " by [#{author_name}](#{author_profile_url})" unless author_name.empty? || author_profile_url.empty?
  attribution << " on #{date.strftime("%B %-d, %Y")}"
  attribution << ". [View original article](#{original_url})."

  body_parts = []
  body_parts << "> #{attribution}"
  body_parts << ""
  body_parts << "![#{title}](#{relative_image})" if relative_image
  body_parts << "" if relative_image
  body_parts << content_html
  body = body_parts.join("\n")

  frontmatter = {
    "layout" => "post",
    "title" => title,
    "date" => date.to_s,
    "description" => excerpt.empty? ? nil : excerpt,
    "tags" => %w[linkedin republished],
    "originally_published_on" => "LinkedIn",
    "original_url" => original_url,
    "original_published_at" => published_at.empty? ? date.to_s : published_at
  }

  post_path = POSTS_DIR.join("#{date}-#{slug}.md")
  content = wrap_frontmatter(frontmatter, body)

  if options[:dry_run]
    puts "[dry-run] write #{post_path}"
  else
    post_path.write(content)
    puts "Wrote #{post_path}"
  end
end
