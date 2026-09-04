#!/usr/bin/env ruby
# frozen_string_literal: true

# Compare recovered UGtastic audio exports with finished-video exports and
# Final Cut event references. This reads media metadata and marker names only.

require "json"
require "open3"
require "optparse"
require "pathname"

options = {}
OptionParser.new do |parser|
  parser.banner = "Usage: ruby bin/analyze_ugtastic_production.rb --audio-root PATH --video-root PATH --fcp-root PATH"
  parser.on("--audio-root PATH") { |value| options[:audio_root] = value }
  parser.on("--video-root PATH") { |value| options[:video_root] = value }
  parser.on("--fcp-root PATH") { |value| options[:fcp_root] = value }
  parser.on("--output PATH") { |value| options[:output] = value }
end.parse!

%i[audio_root video_root fcp_root].each { |key| abort "--#{key.to_s.tr('_', '-')} is required" unless options[key] }
options[:output] ||= "_data/ugtastic_production_analysis.json"

def normalize(value)
  value.downcase.gsub(/[^a-z0-9]+/, "_").gsub(/^_|_$/, "")
end

def probe(path)
  stdout, stderr, status = Open3.capture3("ffprobe", "-v", "error", "-show_entries", "format=duration:stream=codec_name,codec_type,width,height", "-of", "json", path.to_s)
  abort "ffprobe failed for #{path}: #{stderr}" unless status.success?
  data = JSON.parse(stdout)
  video = data.fetch("streams", []).find { |stream| stream["codec_type"] == "video" }
  audio = data.fetch("streams", []).count { |stream| stream["codec_type"] == "audio" }
  { "duration_seconds" => data.dig("format", "duration")&.to_f&.round(3), "audio_streams" => audio, "width" => video && video["width"], "height" => video && video["height"] }
end

audio_files = Dir[Pathname(options[:audio_root]).expand_path.join("*.mp3").to_s].sort.map { |path| Pathname(path) }
video_files = Dir[Pathname(options[:video_root]).expand_path.join("*.{mp4,m4v}").to_s].sort.map { |path| Pathname(path) }
audio_stems = audio_files.to_h { |path| [normalize(path.basename(".mp3").to_s), path.basename(".mp3").to_s] }

videos = video_files.map.with_index do |path, index|
  title = path.basename.to_s.sub(/^UGtastic Interviews - \d+ - Interview with /i, "").sub(/\.(mp4|m4v)$/i, "")
  stem = normalize(title)
  puts "video [%3d/%3d] %s" % [index + 1, video_files.length, path.basename]
  { "file" => path.basename.to_s, "title" => title, "normalized_name" => stem, "audio_match" => audio_stems[stem], "media" => probe(path) }
end

events = Dir[Pathname(options[:fcp_root]).expand_path.join("**/CurrentVersion.fcpevent").to_s].sort.map do |path|
  text, _stderr, _status = Open3.capture3("strings", "-n", "8", path)
  { "event" => Pathname(path).relative_path_from(Pathname(options[:fcp_root]).expand_path).to_s, "life_of_riley_references" => text.scan(/Life of Riley/i).length, "outro_references" => text.scan(/UGtastic Outro/i).length, "intro_overlay_references" => text.scan(/intro(?:-overlay)?/i).length, "outro_overlay_references" => text.scan(/outro/i).length }
end

summary = {
  "audio_exports" => audio_files.length,
  "finished_video_exports" => videos.length,
  "filename_audio_video_matches" => videos.count { |video| video["audio_match"] },
  "videos_with_audio_stream" => videos.count { |video| video.dig("media", "audio_streams").to_i.positive? },
  "total_finished_video_hours" => (videos.sum { |video| video.dig("media", "duration_seconds").to_f } / 3600).round(2),
  "final_cut_event_files" => events.length,
  "events_referencing_life_of_riley" => events.count { |event| event["life_of_riley_references"].positive? },
  "events_referencing_ugtastic_outro" => events.count { |event| event["outro_references"].positive? },
  "events_referencing_intro_overlays" => events.count { |event| event["intro_overlay_references"].positive? }
}

result = {
  "generated_at" => Time.now.strftime("%Y-%m-%dT%H:%M:%S%z"),
  "source" => "recovered UGtastic audio, finished-video, and Final Cut event exports",
  "analysis_scope" => "Media metadata, filename joins, and named production references. No speech transcription.",
  "interpretation" => "A filename match links likely source and finished export. It does not prove the audio was used without an edit. Final Cut references establish project intent and reusable media presence, not finished-video placement.",
  "summary" => summary,
  "videos" => videos,
  "final_cut_events" => events
}

output = Pathname(options[:output]).expand_path
output.dirname.mkpath
output.write(JSON.pretty_generate(result) + "\n")
puts "Wrote #{output}"
puts JSON.pretty_generate(summary)
