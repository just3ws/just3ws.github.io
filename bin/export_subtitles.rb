#!/usr/bin/env ruby
# frozen_string_literal: true

# bin/export_subtitles.rb — WebVTT / SRT Subtitle Exporter for YouTube Captions Sync
#
# Exports structured transcript turns into standard WebVTT (.vtt) caption files
# and builds a YouTube captions sync manifest.

require 'yaml'
require 'json'
require 'fileutils'

class SubtitleExporter
  TRANSCRIPTS_DIR = "_data/transcripts"
  ASSETS_FILE = "_data/video_assets.yml"
  OUTPUT_DIR = "assets/subtitles"
  MANIFEST_FILE = "_data/youtube_captions_manifest.json"

  def run
    puts "🎬 Exporting WebVTT Subtitles for YouTube Sync..."
    FileUtils.mkdir_p(OUTPUT_DIR)

    video_assets = YAML.load_file(ASSETS_FILE, permitted_classes: [Date, Time], aliases: true)["items"] rescue []
    asset_map = {}
    video_assets.each do |asset|
      pref = asset["platforms"]&.find { |p| p["platform"] == "youtube" } || asset["platforms"]&.first
      if pref
        yt_id = pref["video_id"]
        if yt_id.nil? || yt_id.empty?
          embed_u = pref["embed_url"].to_s
          url_u = pref["url"].to_s
          if embed_u.include?("/embed/")
            yt_id = embed_u.split("/embed/").last.split("?").first
          elsif url_u.include?("v=")
            yt_id = url_u.split("v=").last.split("&").first
          end
        end

        if yt_id && !yt_id.empty?
          asset_map[asset["id"]] = {
            youtube_id: yt_id,
            duration_sec: (pref["duration_minutes"] || 10).to_f * 60.0
          }
        end
      end
    end

    manifest = []
    exported_count = 0

    Dir.glob(File.join(TRANSCRIPTS_DIR, "*.yml")).sort.each do |path|
      t_id = File.basename(path, ".yml")
      data = YAML.load_file(path, permitted_classes: [Date, Time], aliases: true) rescue next
      turns = data["turns"]
      next unless turns && turns.any?

      recording_dur = data.dig("recording", "duration_sec")&.to_f
      if recording_dur.nil? || recording_dur == 0
        recording_dur = asset_map.dig(t_id, :duration_sec) || 600.0
      end

      total_chars = turns.sum { |t| (t["text"] || "").size }
      total_chars = 1 if total_chars == 0

      vtt_lines = [
        "WEBVTT - UGtastic Archival Caption Track",
        "Kind: captions",
        "Language: en",
        ""
      ]

      curr_chars = 0
      speaker_map = data["speaker_map"] || {}

      turns.each_with_index do |turn, idx|
        s_id = turn["speaker"]
        s_info = speaker_map[s_id]
        s_name = s_info.is_a?(Hash) ? (s_info["name"] || s_id) : (s_info || s_id)

        start_pct = curr_chars.to_f / total_chars
        start_sec = start_pct * recording_dur

        text = turn["text"].to_s
        turn_len = text.size
        curr_chars += turn_len

        end_pct = curr_chars.to_f / total_chars
        end_sec = end_pct * recording_dur

        vtt_lines << "#{format_vtt_time(start_sec)} --> #{format_vtt_time(end_sec)}"
        vtt_lines << "<v #{s_name}>#{text.gsub("\n", " ")}"
        vtt_lines << ""
      end

      vtt_path = File.join(OUTPUT_DIR, "#{t_id}.vtt")
      File.write(vtt_path, vtt_lines.join("\n"))
      exported_count += 1

      yt_info = asset_map[t_id]
      if yt_info
        manifest << {
          transcript_id: t_id,
          youtube_video_id: yt_info[:youtube_id],
          vtt_path: vtt_path,
          turn_count: turns.size
        }
      end
    end

    File.write(MANIFEST_FILE, JSON.pretty_generate({
      generated_at: Time.now.iso8601,
      total_captions: manifest.size,
      items: manifest
    }))

    puts "✅ Exported #{exported_count} WebVTT caption files to #{OUTPUT_DIR}."
    puts "✅ Generated YouTube Captions Manifest at #{MANIFEST_FILE} (#{manifest.size} YouTube linked videos)."
  end

  private

  def format_vtt_time(seconds)
    total_sec = seconds.to_f
    hours = (total_sec / 3600).floor
    mins = ((total_sec % 3600) / 60).floor
    secs = (total_sec % 60).floor
    millis = ((total_sec - total_sec.floor) * 1000).round

    format("%02d:%02d:%02d.%03d", hours, mins, secs, millis)
  end
end

SubtitleExporter.new.run
