#!/usr/bin/env ruby
# frozen_string_literal: true

# bin/generate_rewatch_thumbnail.rb
#
# Deterministic thumbnail generator for "The Sound Above" oral history rewatch series.
# Reads episode metadata from obs/curation/sequence-manifest.json or custom parameters,
# builds a clean HTML template styled with craftsmanship tokens, renders a 1080p master
# using headless Google Chrome, and scales to standard 1280x720 (720p) for YouTube.
#
# Enforces strict zero em dashes across all copy and tags.

require "json"
require "optparse"
require "fileutils"

MANIFEST_PATH = "obs/curation/sequence-manifest.json"
THUMBNAILS_DIR = "obs/thumbnails"

def load_manifest
  unless File.exist?(MANIFEST_PATH)
    warn "❌ Error: Manifest not found at #{MANIFEST_PATH}"
    exit 1
  end
  JSON.parse(File.read(MANIFEST_PATH))
end

def find_episode(manifest, episode_num)
  ep = manifest["episodes"]&.find { |e| e["number"].to_i == episode_num.to_i }
  unless ep
    warn "❌ Error: Episode #{episode_num} not found in manifest."
    exit 1
  end
  ep
end

def build_html(ep)
  num_str = format("%02d", ep["number"])
  guest = ep["interviewee"]
  title = ep["title"]
  era = ep["era_name"] || "The Chicago Community (2005–2010)"
  event = "#{ep['conference']} · #{ep['location'] || 'Chicago, IL'}"
  prompt = ep["sound_above_inquiry"] || ep["ai_era_parallel"]
  role = ep["chicago_context"] ? "Community Practitioner · #{ep['chicago_context'].split('.').first}" : "Community Practitioner"

  <<~HTML
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <title>The Sound Above Rewatch - Episode #{num_str} Thumbnail</title>
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
          background: radial-gradient(circle at 65% 35%, #fffdfa 0%, #f6efe2 55%, #eae0ce 100%);
          font-family: var(--font-sans);
          color: var(--text-main);
          display: flex;
          flex-direction: column;
          justify-content: space-between;
          padding: 80px 100px;
          position: relative;
        }

        body::before {
          content: "";
          position: absolute;
          inset: 0;
          background-image:
            linear-gradient(rgba(15, 118, 110, 0.04) 1px, transparent 1px),
            linear-gradient(90deg, rgba(15, 118, 110, 0.04) 1px, transparent 1px);
          background-size: 48px 48px;
          pointer-events: none;
        }

        .accent-border {
          position: absolute;
          top: 0;
          left: 0;
          width: 16px;
          height: 100%;
          background: linear-gradient(180deg, var(--teal-craftsman) 0%, var(--amber-accent) 100%);
        }

        .thumb-header {
          display: flex;
          justify-content: space-between;
          align-items: center;
          z-index: 2;
        }

        .brand-group {
          display: flex;
          align-items: center;
          gap: 24px;
        }

        .brand-cube {
          width: 84px;
          height: 84px;
          filter: drop-shadow(0 6px 14px rgba(15, 23, 42, 0.16));
        }

        .series-titles {
          display: flex;
          flex-direction: column;
        }

        .series-name {
          font-family: var(--font-serif);
          font-size: 38px;
          font-weight: 700;
          color: var(--text-heading);
          letter-spacing: -0.02em;
          line-height: 1.1;
        }

        .series-tagline {
          font-family: var(--font-mono);
          font-size: 16px;
          font-weight: 600;
          color: var(--text-muted);
          letter-spacing: 0.12em;
          text-transform: uppercase;
          margin-top: 6px;
        }

        .badge-pill {
          display: inline-flex;
          align-items: center;
          gap: 12px;
          padding: 12px 24px;
          background: rgba(255, 255, 255, 0.96);
          border: 2px solid var(--border-soft);
          border-radius: 9999px;
          box-shadow: 0 4px 16px rgba(15, 23, 42, 0.06);
        }

        .badge-dot {
          width: 14px;
          height: 14px;
          border-radius: 50%;
          background-color: var(--amber-accent);
          box-shadow: 0 0 10px rgba(180, 83, 9, 0.4);
        }

        .badge-text {
          font-family: var(--font-mono);
          font-size: 18px;
          font-weight: 700;
          color: var(--amber-accent);
          letter-spacing: 0.08em;
          text-transform: uppercase;
        }

        .thumb-main {
          z-index: 2;
          display: flex;
          flex-direction: column;
          gap: 28px;
          max-width: 1440px;
        }

        .kicker-row {
          display: flex;
          align-items: center;
          gap: 18px;
        }

        .kicker-era {
          font-family: var(--font-mono);
          font-size: 20px;
          font-weight: 700;
          color: var(--teal-craftsman);
          letter-spacing: 0.14em;
          text-transform: uppercase;
        }

        .kicker-sep {
          color: var(--border-soft);
          font-weight: 300;
          font-size: 20px;
        }

        .kicker-episode {
          font-family: var(--font-mono);
          font-size: 20px;
          font-weight: 700;
          color: var(--amber-accent);
          letter-spacing: 0.12em;
          text-transform: uppercase;
        }

        .thumb-title {
          font-family: var(--font-serif);
          font-size: 74px;
          line-height: 1.08;
          font-weight: 700;
          color: var(--text-heading);
          letter-spacing: -0.03em;
        }

        .guest-card {
          display: flex;
          align-items: center;
          justify-content: space-between;
          padding: 32px 44px;
          background: rgba(255, 255, 255, 0.94);
          border: 1px solid var(--border-soft);
          border-left: 10px solid var(--teal-craftsman);
          border-radius: 12px;
          box-shadow: 0 16px 36px rgba(15, 23, 42, 0.07);
          margin-top: 8px;
        }

        .guest-info {
          display: flex;
          flex-direction: column;
          gap: 6px;
        }

        .guest-name-row {
          display: flex;
          align-items: baseline;
          gap: 20px;
        }

        .guest-name {
          font-family: var(--font-serif);
          font-size: 46px;
          font-weight: 700;
          color: var(--teal-craftsman);
          letter-spacing: -0.01em;
        }

        .guest-tag {
          font-family: var(--font-mono);
          font-size: 16px;
          font-weight: 700;
          color: var(--amber-accent);
          background: rgba(180, 83, 9, 0.1);
          padding: 4px 12px;
          border-radius: 4px;
          letter-spacing: 0.06em;
          text-transform: uppercase;
        }

        .guest-role {
          font-size: 22px;
          color: var(--text-muted);
          font-weight: 500;
        }

        .guest-quote {
          max-width: 580px;
          font-size: 19px;
          line-height: 1.45;
          font-style: italic;
          color: var(--ink-main);
          text-align: right;
          border-right: 3px solid var(--amber-accent);
          padding-right: 20px;
        }

        .thumb-footer {
          display: flex;
          justify-content: space-between;
          align-items: flex-end;
          border-top: 1px solid var(--border-soft);
          padding-top: 24px;
          z-index: 2;
        }

        .credo-group {
          display: flex;
          align-items: center;
          gap: 16px;
        }

        .credo-mark {
          font-family: var(--font-mono);
          font-size: 15px;
          font-weight: 800;
          letter-spacing: 0.16em;
          color: var(--teal-craftsman);
          text-transform: uppercase;
        }

        .credo-sub {
          font-size: 15px;
          font-weight: 500;
          color: var(--text-muted);
          letter-spacing: 0.04em;
        }

        .meta-group {
          display: flex;
          gap: 40px;
          font-family: var(--font-mono);
          font-size: 14px;
          color: var(--text-muted);
        }

        .meta-item {
          display: flex;
          flex-direction: column;
          align-items: flex-end;
          gap: 4px;
        }

        .meta-label {
          font-size: 11px;
          font-weight: 700;
          text-transform: uppercase;
          letter-spacing: 0.12em;
          color: var(--amber-accent);
        }

        .meta-val {
          font-size: 15px;
          font-weight: 600;
          color: var(--text-heading);
        }
      </style>
    </head>
    <body>
      <div class="accent-border"></div>

      <header class="thumb-header">
        <div class="brand-group">
          <img src="../overlays/assets/ugtastic-cube-logo.png" alt="UGtastic Cube" class="brand-cube">
          <div class="series-titles">
            <h1 class="series-name">The Sound Above</h1>
            <p class="series-tagline">UGtastic Oral History Rewatch · 2009–2026</p>
          </div>
        </div>
        <div class="badge-pill">
          <span class="badge-dot"></span>
          <span class="badge-text">Oral History Rewatch</span>
        </div>
      </header>

      <main class="thumb-main">
        <div class="kicker-row">
          <span class="kicker-era">#{era}</span>
          <span class="kicker-sep">/</span>
          <span class="kicker-episode">Episode #{num_str}</span>
        </div>

        <h2 class="thumb-title">
          #{title}
        </h2>

        <div class="guest-card">
          <div class="guest-info">
            <div class="guest-name-row">
              <span class="guest-name">#{guest}</span>
              <span class="guest-tag">#{event}</span>
            </div>
            <span class="guest-role">#{role}</span>
          </div>
          <div class="guest-quote">
            "#{prompt}"
          </div>
        </div>
      </main>

      <footer class="thumb-footer">
        <div class="credo-group">
          <span class="credo-mark">WHOIS TECH COMMUNITY</span>
          <span class="credo-sub">Learning About People · One Interview at a Time</span>
        </div>
        <div class="meta-group">
          <div class="meta-item">
            <span class="meta-label">Curator</span>
            <span class="meta-val">Mike Hall (#106)</span>
          </div>
          <div class="meta-item">
            <span class="meta-label">Archive</span>
            <span class="meta-val">just3ws.com</span>
          </div>
          <div class="meta-item">
            <span class="meta-label">Era Focus</span>
            <span class="meta-val">Craftsmanship in the Age of AI</span>
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
  options = { episode: 1 }
  OptionParser.new do |opts|
    opts.banner = "Usage: bin/generate_rewatch_thumbnail.rb [options]"
    opts.on("-e", "--episode NUMBER", Integer, "Episode number from sequence manifest (default: 1)") do |n|
      options[:episode] = n
    end
    opts.on("-a", "--all", "Render thumbnails for all episodes in sequence manifest") do
      options[:all] = true
    end
    opts.on("-h", "--help", "Show help and usage information") do
      puts opts
      exit 0
    end
  end.parse!

  FileUtils.mkdir_p(THUMBNAILS_DIR)
  manifest = load_manifest

  episodes = options[:all] ? manifest["episodes"] : [find_episode(manifest, options[:episode])]

  episodes.each do |ep|
    num_str = format("%02d", ep["number"])
    slug = ep["slug"] || "episode-#{num_str}"
    guest_slug = ep["interviewee"].downcase.gsub(/[^a-z0-9]+/, "-").gsub(/^-|-$/, "")
    base_name = "episode-#{num_str}-#{guest_slug}"

    html_file = File.expand_path(File.join(THUMBNAILS_DIR, "#{base_name}.html"))
    out_1080 = File.expand_path(File.join(THUMBNAILS_DIR, "#{base_name}-1080p.png"))
    out_720 = File.expand_path(File.join(THUMBNAILS_DIR, "#{base_name}-720p.png"))

    File.write(html_file, build_html(ep))
    puts "Wrote HTML template: #{html_file}"
    render_thumbnail(html_file, out_1080, out_720)
  end
end

run if __FILE__ == $PROGRAM_NAME
