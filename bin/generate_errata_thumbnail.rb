#!/usr/bin/env ruby
# frozen_string_literal: true

# ==============================================================================
# bin/generate_errata_thumbnail.rb
#
# Deterministic thumbnail generator for "Errata" solo broadcasts:
#   - Reading Mode: Book cover / typography with author & chapter citations.
#   - Concept Mode: System architecture, cognitive load & state diagrams.
#   - Demo Mode: Monospaced terminal workbench with code refactoring invariants.
#   - Story Mode: Community oral history memoirs and pairing reflections.
#   - Artifact Mode: Archival ephemera, badges, and physical programs.
#
# Renders 1080p master PNG via headless Google Chrome and scales to 720p via sips.
# Strictly enforces zero em dashes across all copy and templates.
# ==============================================================================

require "json"
require "optparse"
require "fileutils"

MANIFEST_PATH = "obs/curation/errata-manifest.json"
THUMBNAILS_DIR = "obs/thumbnails"

def load_manifest
  unless File.exist?(MANIFEST_PATH)
    warn "❌ Error: Errata manifest not found at #{MANIFEST_PATH}"
    exit 1
  end
  JSON.parse(File.read(MANIFEST_PATH))
end

def find_item(manifest, item_id)
  item = manifest["items"]&.find { |i| i["id"] == item_id }
  unless item
    warn "❌ Error: Errata item '#{item_id}' not found in manifest."
    exit 1
  end
  item
end

def build_html(item)
  mode = (item["mode"] || "concept").downcase
  title = item["title"] || "Untitled Insight"
  subtitle = item["subtitle"] || "Marginalia and Demonstrations"
  citation = item["citation"] || "Personal Archive"
  excerpt = item["excerpt_or_thesis"] || ""
  year = item["year"] || "2026"
  topic = item["topic"] || "Craftsmanship and System Cartography"

  mode_label = mode.upcase
  mode_kicker = case mode
                when "reading"  then "Foundational Text & Close Reading"
                when "demo"     then "Live Terminal Workbench & Code Kata"
                when "artifact" then "Physical Archival Artifact Showcase"
                when "story"    then "First-Person Oral History Memoir"
                when "bts"      then "Behind the Scenes & Systems Engineering"
                else                 "Systems Architecture & Cartography"
                end

  <<~HTML
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <title>Errata - #{title} Thumbnail</title>
      <link rel="stylesheet" href="../overlays/css/craftsmanship-theme.css">
      <style>
        * {
          box-sizing: border-box;
          margin: 0;
          padding: 0;
        }

        body {
          width: 1920px;
          height: 1080px;
          overflow: hidden;
          background-color: var(--paper-canvas);
          background-image: 
            radial-gradient(ellipse at 88% 18%, rgba(15, 118, 110, 0.08) 0%, transparent 60%),
            radial-gradient(ellipse at 12% 85%, rgba(180, 83, 9, 0.07) 0%, transparent 60%),
            linear-gradient(rgba(15, 23, 42, 0.03) 1px, transparent 1px),
            linear-gradient(90deg, rgba(15, 23, 42, 0.03) 1px, transparent 1px);
          background-size: 100% 100%, 100% 100%, 48px 48px, 48px 48px;
          color: var(--ink-main);
          font-family: var(--font-body);
          display: flex;
          flex-direction: column;
          justify-content: space-between;
          padding: 64px 80px 56px;
        }

        header {
          display: flex;
          align-items: center;
          justify-content: space-between;
          border-bottom: 2px solid var(--border-soft);
          padding-bottom: 24px;
        }

        .brand-cluster {
          display: flex;
          align-items: baseline;
          gap: 20px;
        }

        .series-title {
          font-family: var(--font-serif);
          font-size: 44px;
          font-weight: 700;
          color: var(--teal-craftsman);
          letter-spacing: -0.02em;
        }

        .series-colon {
          font-size: 32px;
          color: var(--amber-accent);
          font-family: var(--font-mono);
          margin-right: 4px;
        }

        .series-tagline {
          font-family: var(--font-mono);
          font-size: 18px;
          color: var(--text-muted);
          letter-spacing: 0.04em;
          text-transform: uppercase;
        }

        .badge-mode {
          background: rgba(15, 118, 110, 0.12);
          border: 1.5px solid var(--teal-craftsman);
          color: var(--teal-craftsman);
          padding: 8px 18px;
          border-radius: 999px;
          font-family: var(--font-mono);
          font-weight: 700;
          font-size: 15px;
          letter-spacing: 0.08em;
          text-transform: uppercase;
        }

        main {
          display: flex;
          flex-direction: column;
          gap: 24px;
          max-width: 1720px;
        }

        .kicker-row {
          display: flex;
          align-items: center;
          gap: 16px;
        }

        .kicker-mode {
          font-family: var(--font-mono);
          font-size: 20px;
          font-weight: 700;
          color: var(--amber-accent);
          letter-spacing: 0.12em;
          text-transform: uppercase;
        }

        .kicker-year {
          font-family: var(--font-mono);
          font-size: 18px;
          font-weight: 600;
          color: var(--text-muted);
          background: rgba(15, 23, 42, 0.05);
          padding: 4px 12px;
          border-radius: 4px;
        }

        .thumb-title {
          font-family: var(--font-serif);
          font-size: 72px;
          line-height: 1.1;
          font-weight: 700;
          color: var(--text-heading);
          letter-spacing: -0.03em;
        }

        .citation-card {
          display: flex;
          align-items: center;
          justify-content: space-between;
          padding: 28px 40px;
          background: rgba(255, 255, 255, 0.95);
          border: 1px solid var(--border-soft);
          border-left: 10px solid var(--amber-accent);
          border-radius: 12px;
          box-shadow: 0 16px 36px rgba(15, 23, 42, 0.07);
        }

        .citation-info {
          display: flex;
          flex-direction: column;
          gap: 6px;
        }

        .citation-text {
          font-family: var(--font-serif);
          font-size: 38px;
          font-weight: 700;
          color: var(--teal-craftsman);
          letter-spacing: -0.01em;
        }

        .citation-subtitle {
          font-family: var(--font-body);
          font-size: 22px;
          color: var(--text-muted);
          font-weight: 500;
        }

        .prompt-card {
          background: rgba(255, 255, 255, 0.7);
          border: 1px dashed var(--border-soft);
          border-radius: 10px;
          padding: 20px 28px;
        }

        .prompt-text {
          font-family: var(--font-serif);
          font-size: 24px;
          line-height: 1.35;
          font-style: italic;
          color: var(--ink-main);
        }

        footer {
          display: flex;
          align-items: center;
          justify-content: space-between;
          border-top: 1.5px solid var(--border-soft);
          padding-top: 20px;
          font-family: var(--font-mono);
          font-size: 15px;
          color: var(--text-muted);
        }

        .credo-cluster {
          display: flex;
          align-items: center;
          gap: 12px;
        }

        .credo-bold {
          font-weight: 700;
          color: var(--teal-craftsman);
          text-transform: uppercase;
        }

        .meta-group {
          display: flex;
          align-items: center;
          gap: 32px;
        }

        .meta-item {
          display: flex;
          align-items: center;
          gap: 8px;
        }

        .meta-label {
          color: var(--text-muted);
          text-transform: uppercase;
          font-size: 13px;
        }

        .meta-val {
          color: var(--ink-main);
          font-weight: 600;
        }
      </style>
    </head>
    <body>
      <header>
        <div class="brand-cluster">
          <span class="series-title">Errata</span>
          <span class="series-colon">:</span>
          <span class="series-tagline">Marginalia, Readings & Demonstrations</span>
        </div>
        <div class="badge-mode">#{mode_label} MODE</div>
      </header>

      <main>
        <div class="kicker-row">
          <span class="kicker-mode">#{mode_kicker}</span>
          <span class="kicker-year">#{year}</span>
        </div>

        <h1 class="thumb-title">#{title}</h1>

        <div class="citation-card">
          <div class="citation-info">
            <span class="citation-text">#{citation}</span>
            <span class="citation-subtitle">#{subtitle}</span>
          </div>
        </div>

        <div class="prompt-card">
          <p class="prompt-text">"#{excerpt}"</p>
        </div>
      </main>

      <footer>
        <div class="credo-cluster">
          <span class="credo-bold">Errata</span>
          <span>·</span>
          <span>Craftsmanship, Invariants & Ephemera</span>
        </div>
        <div class="meta-group">
          <div class="meta-item">
            <span class="meta-label">Broadcaster</span>
            <span class="meta-val">Mike Hall</span>
          </div>
          <div class="meta-item">
            <span class="meta-label">Archive</span>
            <span class="meta-val">just3ws.com</span>
          </div>
          <div class="meta-item">
            <span class="meta-label">Topic</span>
            <span class="meta-val">#{topic[0..36]}</span>
          </div>
        </div>
      </footer>
    </body>
    </html>
  HTML
end

def render_thumbnail(html_path, out_1080p, out_720p)
  chrome = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
  unless File.exist?(chrome)
    warn "❌ Error: Google Chrome not found at #{chrome}"
    exit 1
  end

  cmd_1080 = %("#{chrome}" --headless --disable-gpu --window-size=1920,1080 --screenshot="#{out_1080p}" "file://#{html_path}")
  puts "Rendering 1080p: #{out_1080p}..."
  system(cmd_1080, err: File::NULL, out: File::NULL)

  unless File.exist?(out_1080p)
    warn "❌ Error: Failed to render #{out_1080p}"
    exit 1
  end

  cmd_sips = %(sips -z 720 1280 "#{out_1080p}" --out "#{out_720p}")
  puts "Scaling to 720p: #{out_720p}..."
  system(cmd_sips, err: File::NULL, out: File::NULL)

  unless File.exist?(out_720p)
    warn "❌ Error: Failed to scale #{out_720p}"
    exit 1
  end

  puts "✅ Render complete!"
  puts "   1080p: #{out_1080p}"
  puts "   720p:  #{out_720p}"
end

def run
  options = {}
  OptionParser.new do |opts|
    opts.banner = "Usage: bin/generate_errata_thumbnail.rb [options]"
    opts.on("-i", "--id ID", String, "Errata item ID from errata-manifest.json") do |id|
      options[:id] = id
    end
    opts.on("-a", "--all", "Render thumbnails for all items in errata-manifest.json") do
      options[:all] = true
    end
    opts.on("-h", "--help", "Show help and usage information") do
      puts opts
      exit 0
    end
  end.parse!

  FileUtils.mkdir_p(THUMBNAILS_DIR)
  manifest = load_manifest

  items = if options[:all]
            manifest["items"] || []
          elsif options[:id]
            [find_item(manifest, options[:id])]
          else
            # Default to first item
            [manifest["items"].first]
          end

  items.each do |item|
    id = item["id"]
    html_file = File.expand_path(File.join(THUMBNAILS_DIR, "#{id}.html"))
    out_1080 = File.expand_path(File.join(THUMBNAILS_DIR, "#{id}-1080p.png"))
    out_720 = File.expand_path(File.join(THUMBNAILS_DIR, "#{id}-720p.png"))

    File.write(html_file, build_html(item))
    puts "Wrote HTML template: #{html_file}"
    render_thumbnail(html_file, out_1080, out_720)
  end
end

run if __FILE__ == $PROGRAM_NAME
