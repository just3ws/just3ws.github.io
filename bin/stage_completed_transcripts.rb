#!/usr/bin/env ruby
require 'yaml'
require 'json'
require 'fileutils'
require_relative 'lib/transcript_sanity'

# Choose one transcript file per video id, preferring the known-terms-corrected
# `<id>.cleaned.txt` (the /transcriptions learning-loop output) over the raw
# `<id>.txt` / `<id>.stitched.txt`, so operator corrections are what reach the
# site. Video ids carry no dots (YouTube [A-Za-z0-9_-]{11}, Vimeo digits), so the
# id is the basename up to the first dot — which also folds a source's
# `.stitched` / `.cleaned` variants together.
def preferred_transcript_files(paths)
  paths.group_by { |p| File.basename(p).split('.').first }.map do |_video_id, group|
    group.find { |p| p.end_with?('.cleaned.txt') } ||
      group.find { |p| p.end_with?('.stitched.txt') } ||
      group.min_by { |p| File.basename(p).length }
  end
end

# Diarization sidecars (`diarization.json`) may live next to the `.txt` in
# either the recipe/short path (~/Downloads/transcripts/<id>/) or the ingest
# retention root (~/.local/state/zdots/ingest-sources/<mid>/<...>/). Both write
# the sidecar as a sibling of the transcript `.txt`, so we key it off that
# neighbor and stage it as <video_asset_id>.diarization.json.
# Sanity gate: a mock or degenerate diarization sidecar (the shape that shipped
# before the HF-token fix — one speaker spanning the whole file) must not reach
# the site. Refuse to stage it, loudly. Returns :staged / :rejected / :skip.
def stage_sidecar(txt_file, staging_key, staging_dir)
  sidecar = File.join(File.dirname(txt_file), "diarization.json")
  return :skip unless File.exist?(sidecar)

  dest = File.join(staging_dir, "#{staging_key}.diarization.json")
  return :skip if File.exist?(dest)

  data = JSON.parse(File.read(sidecar)) rescue nil
  ok, why = TranscriptSanity.diarization_sane?(data)
  unless ok
    warn "  REJECTED diarization for #{staging_key}: #{why}"
    return :rejected
  end

  FileUtils.cp(sidecar, dest)
  puts "Staged diarization: #{staging_key}.diarization.json"
  :staged
end

if __FILE__ == $PROGRAM_NAME
  assets = YAML.load_file("_data/video_assets.yml")["items"]
  staging_dir = "tmp/transcript-id-staging"
  FileUtils.mkdir_p(staging_dir)

  staged_count = 0
  staged_diarization = 0
  rejected_diarization = 0
  looping_warnings = 0
  transcript_globs = [
    File.expand_path("~/Downloads/transcripts/*/*.txt"),
    File.expand_path("~/.local/state/zdots/ingest-sources/**/*.txt")
  ]

  preferred_transcript_files(Dir.glob(transcript_globs)).each do |txt_file|
    video_id = File.basename(txt_file).split('.').first

    # Find the corresponding video_asset_id (check both YouTube and Vimeo)
    asset = assets.find do |a|
      a["platforms"]&.any? { |p| (p["platform"] == "youtube" || p["platform"] == "vimeo") && p["asset_id"] == video_id }
    end

    if asset
      video_asset_id = asset["id"]
      dest_txt = File.join(staging_dir, "#{video_asset_id}.txt")

      unless File.exist?(dest_txt)
        FileUtils.cp(txt_file, dest_txt)
        puts "Staged: #{video_id} -> #{video_asset_id}.txt"
        staged_count += 1
        if (s = TranscriptSanity.loop_score(File.read(txt_file))) && s['severity'] == 'high'
          warn "  WARNING #{video_asset_id}: transcript still looping (score #{s['score']}) — reprocess before publishing"
          looping_warnings += 1
        end
      end

      case stage_sidecar(txt_file, video_asset_id, staging_dir)
      when :staged then staged_diarization += 1
      when :rejected then rejected_diarization += 1
      end
    else
      # Fallback: check if the filename itself is a video_asset_id
      asset_by_id = assets.find { |a| a["id"] == video_id }
      if asset_by_id
        dest_txt = File.join(staging_dir, "#{video_id}.txt")
        unless File.exist?(dest_txt)
          FileUtils.cp(txt_file, dest_txt)
          puts "Staged by ID: #{video_id}"
          staged_count += 1
        end

        case stage_sidecar(txt_file, video_id, staging_dir)
        when :staged then staged_diarization += 1
        when :rejected then rejected_diarization += 1
        end
      end
    end
  end

  puts "Staged #{staged_count} new transcripts."
  puts "Staged #{staged_diarization} diarization sidecars." if staged_diarization.positive?
  warn "Rejected #{rejected_diarization} mock/degenerate diarization sidecars." if rejected_diarization.positive?
  warn "#{looping_warnings} staged transcripts still looping — reprocess before publishing." if looping_warnings.positive?
end
