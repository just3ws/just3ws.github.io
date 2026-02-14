#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "nokogiri"
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

def parse_date_or_nil(value)
  return nil if value.to_s.strip.empty?
  Time.parse(value).to_date
rescue StandardError
  nil
end

def extension_from_url(url)
  path = URI(url).path
  ext = File.extname(path).downcase
  return ext if %w[.jpg .jpeg .png .webp .gif].include?(ext)

  ".jpg"
rescue StandardError
  ".jpg"
end

def absolutize_linkedin_href(href)
  return href if href.to_s.strip.empty?
  return href if href.start_with?("http://", "https://", "mailto:", "tel:")
  return "https://www.linkedin.com#{href}" if href.start_with?("/")

  href
end

def sanitize_article_fragment(fragment)
  fragment.xpath("//comment()").remove
  fragment.traverse do |node|
    next unless node.text?
    cleaned = node.text.gsub("<!---->", "")
    cleaned = cleaned.gsub(/[ \t\r\n]+/, " ")
    node.content = cleaned
  end
  fragment.css("script,style,iframe,svg,button,nav,header,footer,form").remove
  fragment.css("span.white-space-pre").each { |node| node.replace(" ") }

  fragment.css("p").each do |p|
    if p.at_css("ul,ol")
      p.replace(p.children)
      next
    end
    p.remove if p.text.to_s.strip.empty? && p.css("img,video,iframe").empty?
  end

  fragment.css("*").each do |node|
    allowed_attrs = %w[href src alt title]
    node.attribute_nodes.each do |attr|
      node.remove_attribute(attr.name) unless allowed_attrs.include?(attr.name)
    end

    next unless node.name == "a"
    node["href"] = absolutize_linkedin_href(node["href"])
    node["rel"] = "noopener noreferrer"
    node["target"] = "_blank"
  end
end

def extract_article_parts(content_html)
  doc = Nokogiri::HTML.fragment(content_html.to_s)

  body_root = doc.at_css('[data-scaffold-immersive-reader-content] .reader-content-blocks-container') ||
    doc.at_css(".reader-content-blocks-container") ||
    doc.at_css('[data-scaffold-immersive-reader-content]') ||
    doc.at_css(".reader-article-content--content-blocks") ||
    doc

  published_text = doc.at_css("time")&.text&.strip
  hero_image_url = doc.at_css("figure img, .reader-cover-image__wrapper-right-rail-layout img, img")&.[]("src")

  fragment = Nokogiri::HTML.fragment(body_root.inner_html.to_s)
  sanitize_article_fragment(fragment)

  blocks = fragment.children.map do |node|
    html = node.to_html.to_s.gsub("<!---->", "").strip
    next nil if html.empty?
    html
  end.compact
  normalized_html = blocks.join("\n\n")

  {
    article_html: normalized_html,
    published_text: published_text,
    hero_image_url: hero_image_url
  }
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

def escape_html(text)
  text.to_s
    .gsub("&", "&amp;")
    .gsub("<", "&lt;")
    .gsub(">", "&gt;")
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
  published_at_input = article["published_at"].to_s.strip
  hero_image_url = article["hero_image_url"].to_s.strip
  content_html = article["content_html"].to_s.strip
  excerpt = article["excerpt"].to_s.strip

  if title.empty? || original_url.empty? || content_html.empty?
    warn "Skipping item #{idx + 1}: requires title, original_url, and content_html."
    next
  end

  extracted = extract_article_parts(content_html)
  content_published_date = parse_date_or_nil(extracted[:published_text])
  input_published_date = parse_date_or_nil(published_at_input)

  date = if content_published_date && (input_published_date.nil? || input_published_date == Date.today)
           content_published_date
         else
           parse_date(published_at_input)
         end

  published_at = if content_published_date
                   content_published_date.strftime("%Y-%m-%d")
                 elsif input_published_date
                   input_published_date.strftime("%Y-%m-%d")
                 else
                   date.strftime("%Y-%m-%d")
                 end

  if hero_image_url.empty? && !extracted[:hero_image_url].to_s.strip.empty?
    hero_image_url = extracted[:hero_image_url].strip
  end
  content_html = extracted[:article_html]
  if content_html.empty?
    warn "Skipping item #{idx + 1}: unable to extract clean article content."
    next
  end
  slug = slugify(title)
  slug = "linkedin-article-#{idx + 1}" if slug.empty?

  image_path = nil
  downloaded_image_path = nil
  unless hero_image_url.empty?
    ext = extension_from_url(hero_image_url)
    image_path = ASSETS_DIR.join("#{date}-#{slug}#{ext}")
    downloaded_image_path = download_image(hero_image_url, image_path, dry_run: options[:dry_run])
  end

  relative_image = if downloaded_image_path
                     "/" + downloaded_image_path.relative_path_from(ROOT).to_s
                   elsif image_path&.exist?
                     "/" + image_path.relative_path_from(ROOT).to_s
                   elsif !hero_image_url.empty?
                     hero_image_url
                   else
                     nil
                   end

  body_parts = []
  if relative_image
    body_parts << "<figure><img src=\"#{relative_image}\" alt=\"#{escape_html(title)}\"></figure>"
    body_parts << ""
  end
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
    "original_published_at" => published_at
  }

  post_path = POSTS_DIR.join("#{date}-#{slug}.html")
  content = wrap_frontmatter(frontmatter, body)

  if options[:dry_run]
    puts "[dry-run] write #{post_path}"
  else
    post_path.write(content)
    puts "Wrote #{post_path}"
  end
end
