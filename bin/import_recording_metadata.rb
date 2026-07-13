#!/usr/bin/env ruby
# frozen_string_literal: true

# Phase-1 scrubber bridge: fold zdots pipeline sidecars into per-interview
# transcript metadata so the front-end has data to render a timeline bar.
#
# Reads, per source, from ~/.local/state/zdots/ingest-sources:
#   *.boundaries.json  → interview start/end + theme-song intro/outro (has_lyrics)
#   *.timeline.json    → curated key moments (bookmarkable chapters)
# and writes a `recording:` block into _data/transcripts/<transcript_id>.yml.
# NON-DESTRUCTIVE: touches only the recording block, never speaker_map/turns.
# Mapping: sidecar's parent dir is the youtube/vimeo asset_id → video_assets →
# transcript_id. Idempotent. Dry-run by default; --apply writes.

require "json"
require_relative "../src/generators/core/yaml_io"

ROOT            = File.expand_path("..", __dir__)
ASSETS_PATH     = File.join(ROOT, "_data", "video_assets.yml")
TRANSCRIPTS_DIR = File.join(ROOT, "_data", "transcripts")
ZDOTS_SOURCES   = File.expand_path("~/.local/state/zdots/ingest-sources")

apply = ARGV.include?("--apply")

# asset_id (youtube/vimeo video id) → transcript_id
asset_to_tid = {}
(Generators::Core::YamlIo.load(ASSETS_PATH)["items"] || []).each do |a|
  tid = a["transcript_id"]
  next unless tid
  Array(a["platforms"]).each { |p| asset_to_tid[p["asset_id"]] = tid if p["asset_id"] }
end

# Tolerant JSON read — a pipeline sidecar may be malformed (e.g. the LLM timeline
# stage emitting an unescaped quote). Never let one bad file abort the bridge.
def read_json(path)
  JSON.parse(File.read(path))
rescue JSON::ParserError => e
  warn "  ! skipping malformed #{File.basename(path)}: #{e.message.split("\n").first}"
  nil
end

updated = 0
skipped = 0
Dir.glob(File.join(ZDOTS_SOURCES, "**", "*.boundaries.json")).sort.each do |bpath|
  asset_id = File.basename(File.dirname(bpath))
  tid      = asset_to_tid[asset_id]
  tpath    = tid && File.join(TRANSCRIPTS_DIR, "#{tid}.yml")
  unless tpath && File.exist?(tpath)
    skipped += 1
    next
  end

  rec = read_json(bpath)
  if rec.nil?
    skipped += 1
    next
  end

  tl_path = bpath.sub(/\.boundaries\.json\z/, ".timeline.json")
  if File.exist?(tl_path) && (tl = read_json(tl_path))
    chapters = Array(tl["timeline"]).map { |m|
      { "start_sec" => m["start_sec"], "end_sec" => m["end_sec"], "title" => m["title"] }
        .reject { |_, v| v.nil? }
    }.reject { |c| c["start_sec"].nil? || c["title"].to_s.strip.empty? }
    rec["chapters"] = chapters unless chapters.empty?
  end

  if apply
    data = Generators::Core::YamlIo.load(tpath)
    data["recording"] = rec
    Generators::Core::YamlIo.dump(tpath, data)
  end
  updated += 1
  puts format("  %-52s start=%-6s lyrics=%-5s chapters=%d",
              tid, rec["interview_start_sec"], rec["has_lyrics"], rec["chapters"]&.size || 0)
end

puts
puts "#{updated} transcripts #{apply ? 'updated' : 'to update'}; #{skipped} sidecars skipped (no asset/transcript match)"
puts "dry-run — re-run with --apply to write" unless apply
