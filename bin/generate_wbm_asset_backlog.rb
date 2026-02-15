#!/usr/bin/env ruby
# frozen_string_literal: true

require "date"
require "json"
require "nokogiri"
require "pathname"
require "set"
require "uri"
require "yaml"

ROOT = Pathname(__dir__).join("..").expand_path
WBM_DIR = ROOT.join("tmp", "wbm")
BLOG_INVENTORY_PATH = ROOT.join("docs", "wayback", "blog-import-inventory.md")
UGTASTIC_CONTEXT_PATH = ROOT.join("docs", "wayback", "ugtastic-interview-context.yml")
OUT_YAML = ROOT.join("docs", "wayback", "wbm-derived-assets.yml")
OUT_MD = ROOT.join("docs", "wayback", "wbm-spider-backlog.md")
WITC_OUTPUT_DIR = Pathname("/Volumes/Dock_1TB/WITC/_output")
ASSETS_PATH = ROOT.join("_data", "video_assets.yml")

WAYBACK_PREFIX = %r{\Ahttps?://web\.archive\.org/web/\d{14}[a-z_]*/}i

def dewayback(url)
  url.to_s.sub(WAYBACK_PREFIX, "")
end

def extract_pending_from_inventory(path)
  return [] unless path.exist?

  rows = []
  path.read.lines.each do |line|
    next unless line.start_with?("| `pending` ")

    cols = line.split("|").map(&:strip)
    next if cols.length < 5

    rows << cols[3]
  end
  rows
end

def collect_wbm_urls(html_files)
  host_counts = Hash.new(0)
  media_urls = Set.new
  all_urls = Set.new

  html_files.each do |file|
    doc = Nokogiri::HTML(File.read(file))
    doc.css("a[href], img[src], source[src], video[src], iframe[src]").each do |node|
      raw = node["href"] || node["src"]
      next if raw.to_s.empty?

      url = dewayback(raw)
      next unless url.match?(%r{\Ahttps?://}i)

      begin
        uri = URI(url)
        host = uri.host.to_s.downcase
        next if host.empty?

        host_counts[host] += 1
        all_urls << url
        media_urls << url if url.match?(%r{\.(mp4|m4v|webm)(?:\?|$)}i)
      rescue StandardError
        next
      end
    end
  end

  [host_counts, media_urls.to_a.sort, all_urls.to_a.sort]
end

def unmatched_ugtastic_context(path)
  return [] unless path.exist?

  parsed = YAML.safe_load(path.read, permitted_classes: [Date, Time], aliases: true) || {}
  items = parsed["items"] || []
  items
    .select { |item| Array(item["matched_video_asset_ids"]).empty? }
    .map do |item|
      {
        "published_at" => item["published_at"],
        "title" => item["title"],
        "source_url" => item["source_url"],
        "media_urls" => Array(item["media_urls"])
      }
    end
end

def likely_external_domains(host_counts)
  excluded = %w[
    web.archive.org archive.org web-static.archive.org blog.archive.org help.archive.org
    apps.apple.com openlibrary.org microsoftedge.microsoft.com addons.mozilla.org
    chrome.google.com play.google.com change.org
  ]
  host_counts
    .reject { |host, _| excluded.include?(host) }
    .sort_by { |host, count| [-count, host] }
end

def witc_analysis
  return { "present" => false } unless WITC_OUTPUT_DIR.exist?

  transcripts = Dir.glob(WITC_OUTPUT_DIR.join("transcripts", "*.txt").to_s).sort
  metadata_files = Dir.glob(WITC_OUTPUT_DIR.join("metadata", "*.json").to_s).sort
  catalog_rows = []
  catalog_path = WITC_OUTPUT_DIR.join("catalog.json")
  if catalog_path.exist?
    parsed = JSON.parse(catalog_path.read) rescue nil
    catalog_rows = if parsed.is_a?(Array)
                     parsed
                   elsif parsed.is_a?(Hash)
                     parsed["items"] || []
                   else
                     []
                   end
  end

  assets = YAML.safe_load(ASSETS_PATH.read, permitted_classes: [Date, Time], aliases: true) || {}
  known = Set.new
  Array(assets["items"]).each do |item|
    Array(item["platforms"]).each do |platform|
      next if platform["platform"].to_s.empty? || platform["asset_id"].to_s.empty?

      known << [platform["platform"].to_s, platform["asset_id"].to_s]
    end
  end

  missing_platform_assets = []
  metadata_files.each do |file|
    parsed = JSON.parse(File.read(file)) rescue nil
    next if parsed.nil?

    url = parsed["url"].to_s
    title = parsed["title"].to_s
    platform = nil
    asset_id = nil
    if (match = url.match(%r{youtube\.com/watch\?v=([A-Za-z0-9_-]+)}))
      platform = "youtube"
      asset_id = match[1]
    elsif (match = url.match(%r{vimeo\.com/(\d+)}))
      platform = "vimeo"
      asset_id = match[1]
    end
    next if platform.nil? || asset_id.nil?
    next if known.include?([platform, asset_id])

    missing_platform_assets << {
      "platform" => platform,
      "asset_id" => asset_id,
      "title" => title,
      "url" => url,
      "metadata_file" => File.basename(file)
    }
  end

  {
    "present" => true,
    "output_dir" => WITC_OUTPUT_DIR.to_s,
    "transcript_files" => transcripts.size,
    "metadata_files" => metadata_files.size,
    "catalog_entries" => catalog_rows.size,
    "catalog_sample_titles" => catalog_rows.first(12).map { |row| row.is_a?(Hash) ? (row["title"] || row["subject"]).to_s : row.to_s },
    "missing_platform_assets" => missing_platform_assets.sort_by { |row| [row["platform"], row["title"]] }
  }
end

html_files = Dir.glob(WBM_DIR.join("**", "*.html").to_s).sort
host_counts, media_urls, all_urls = collect_wbm_urls(html_files)
pending_import_urls = extract_pending_from_inventory(BLOG_INVENTORY_PATH)
unmatched_ugtastic = unmatched_ugtastic_context(UGTASTIC_CONTEXT_PATH)
external_domains = likely_external_domains(host_counts)
witc = witc_analysis

vol_doc_exists = Dir.exist?("/Volumes/Doc")
dock_candidates = [
  "/Volumes/Dock_1TB/mike.hall/doc",
  "/Volumes/Dock_1TB/mike.hall/Documents",
  "/Volumes/Dock_1TB/WITC",
  "/Volumes/Dock_1TB/vimeo"
].select { |path| Dir.exist?(path) }

dataset = {
  "generated_at" => Time.now.utc.strftime("%Y-%m-%d %H:%M:%S UTC"),
  "sources" => {
    "tmp_wbm_html_files" => html_files.size,
    "tmp_wbm_total_urls" => all_urls.size,
    "tmp_wbm_media_urls" => media_urls.size
  },
  "blog_import_pending_urls" => pending_import_urls,
  "ugtastic_unmatched_context" => unmatched_ugtastic,
  "media_asset_urls" => media_urls,
  "domain_frequency" => host_counts.sort_by { |host, count| [-count, host] }.to_h,
  "external_domain_candidates" => external_domains.map { |host, count| { "host" => host, "count" => count } },
  "volumes_doc" => {
    "requested_path" => "/Volumes/Doc",
    "exists" => vol_doc_exists,
    "nearby_candidates" => dock_candidates
  },
  "witc_output_analysis" => witc
}

OUT_YAML.parent.mkpath
OUT_YAML.write(dataset.to_yaml)

md = +"---\n"
md << "layout: minimal\n"
md << "title: Wayback Spider Backlog\n"
md << "description: Prioritized spider/recovery backlog derived from local tmp/wbm captures.\n"
md << "breadcrumb: Wayback Spider Backlog\n"
md << "breadcrumb_parent_name: Wayback Archives\n"
md << "breadcrumb_parent_url: /docs/wayback/\n"
md << "---\n\n"
md << "{% include breadcrumbs.html %}\n\n"
md << "# Wayback Spider Backlog\n\n"
md << "- Generated: #{dataset['generated_at']}\n"
md << "- HTML snapshot files scanned: #{html_files.size}\n"
md << "- Unique URLs extracted: #{all_urls.size}\n"
md << "- Media URLs extracted (`.mp4`/`.webm`/`.m4v`): #{media_urls.size}\n\n"

md << "## Highest Value: Pending Blog Imports\n\n"
if pending_import_urls.empty?
  md << "No pending blog-import URLs found.\n\n"
else
  pending_import_urls.each { |url| md << "- #{url}\n" }
  md << "\n"
end

md << "## Highest Value: UGtastic Unmatched Interview Context\n\n"
if unmatched_ugtastic.empty?
  md << "No unmatched UGtastic context entries.\n\n"
else
  unmatched_ugtastic.each do |row|
    md << "- `#{row['published_at']}` [#{row['title']}](#{row['source_url']})\n"
  end
  md << "\n"
end

md << "## Media Recovery Candidates\n\n"
media_urls.first(80).each { |url| md << "- #{url}\n" }
remaining_media = media_urls.size - 80
md << "- _... #{remaining_media} additional media URLs in `docs/wayback/wbm-derived-assets.yml`._\n\n" if remaining_media.positive?

md << "## External Domains Worth Spidering Later\n\n"
external_domains.first(30).each do |host, count|
  md << "- `#{host}` (#{count} links)\n"
end
md << "\n"

md << "## `/Volumes/Doc` Check\n\n"
if vol_doc_exists
  md << "- `/Volumes/Doc` exists and can be scanned in a follow-up pass.\n"
else
  md << "- `/Volumes/Doc` was not found on this machine.\n"
  unless dock_candidates.empty?
    md << "- Nearby likely source locations found:\n"
    dock_candidates.each { |path| md << "  - `#{path}`\n" }
  end
end

md << "\n## WITC `_output` Preservation Candidates\n\n"
if witc["present"]
  md << "- `_output` path: `#{witc['output_dir']}`\n"
  md << "- Catalog entries: #{witc['catalog_entries']}\n"
  md << "- Transcript files: #{witc['transcript_files']}\n"
  md << "- Metadata JSON files: #{witc['metadata_files']}\n"
  md << "- Platform assets present in WITC metadata but missing in current `video_assets`: #{witc['missing_platform_assets'].size}\n\n"
  witc["missing_platform_assets"].first(40).each do |row|
    md << "- `#{row['platform']}:#{row['asset_id']}` #{row['title']} (#{row['url']})\n"
  end
  remaining = witc["missing_platform_assets"].size - 40
  if remaining.positive?
    md << "- _... #{remaining} additional missing platform assets in `docs/wayback/wbm-derived-assets.yml`._\n"
  end
else
  md << "- `#{WITC_OUTPUT_DIR}` was not found.\n"
end

md << "\n## Data File\n\n"
md << "- Full machine-readable extraction: `docs/wayback/wbm-derived-assets.yml`\n"

OUT_MD.write(md)

puts "Wrote #{OUT_YAML.relative_path_from(ROOT)}"
puts "Wrote #{OUT_MD.relative_path_from(ROOT)}"
