#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'

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
def stage_sidecar(txt_file, staging_key, staging_dir)
  sidecar = File.join(File.dirname(txt_file), "diarization.json")
  return false unless File.exist?(sidecar)

  dest = File.join(staging_dir, "#{staging_key}.diarization.json")
  return false if File.exist?(dest)

  FileUtils.cp(sidecar, dest)
  puts "Staged diarization: #{staging_key}.diarization.json"
  true
end

if __FILE__ == $PROGRAM_NAME
  assets = YAML.load_file("_data/video_assets.yml")["items"]
  staging_dir = "tmp/transcript-id-staging"
  FileUtils.mkdir_p(staging_dir)

  staged_count = 0
  staged_diarization = 0
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
      end

      staged_diarization += 1 if stage_sidecar(txt_file, video_asset_id, staging_dir)
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

        staged_diarization += 1 if stage_sidecar(txt_file, video_id, staging_dir)
      end
    end
  end

  puts "Staged #{staged_count} new transcripts."
  puts "Staged #{staged_diarization} diarization sidecars." if staged_diarization.positive?
end
