#!/usr/bin/env ruby
# frozen_string_literal: true

# Build a public-safe technical inventory of recovered UGtastic audio.
# This intentionally measures media boundaries without transcribing speech.

require "json"
require "open3"
require "optparse"
require "pathname"

options = { root: nil, output: "_data/ugtastic_audio_inventory.json" }
OptionParser.new do |parser|
  parser.banner = "Usage: ruby bin/analyze_ugtastic_audio.rb --root PATH [--output PATH]"
  parser.on("--root PATH", "Recovered UGtastic _audio directory") { |value| options[:root] = value }
  parser.on("--output PATH", "Output JSON path") { |value| options[:output] = value }
end.parse!

abort "--root is required" unless options[:root]

root = Pathname(options[:root]).expand_path
abort "Audio directory does not exist: #{root}" unless root.directory?

def run_command(*command)
  stdout, stderr, status = Open3.capture3(*command)
  abort "Command failed: #{command.join(' ')}\n#{stderr}" unless status.success?
  stdout
end

def number(value)
  Float(value).round(3)
rescue ArgumentError, TypeError
  nil
end

def ffprobe(path)
  JSON.parse(run_command("ffprobe", "-v", "error", "-show_entries", "format=duration:stream=codec_name,channels,sample_rate", "-of", "json", path.to_s))
end

def silence_boundaries(path)
  command = ["ffmpeg", "-hide_banner", "-nostats", "-i", path.to_s, "-af", "silencedetect=noise=-50dB:d=0.35", "-f", "null", "-"]
  _stdout, stderr, _status = Open3.capture3(*command)
  starts = stderr.scan(/silence_start: ([0-9.]+)/).flatten.map { |value| number(value) }
  ends = stderr.scan(/silence_end: ([0-9.]+)/).flatten.map { |value| number(value) }
  { starts: starts, ends: ends }
end

files = Dir[root.join("*.mp3").to_s].sort.map { |path| Pathname(path) }
records = files.map.with_index do |path, index|
  metadata = ffprobe(path)
  stream = metadata.fetch("streams", []).find { |item| item["codec_name"] }
  duration = number(metadata.dig("format", "duration"))
  boundaries = silence_boundaries(path)
  leading = boundaries[:starts].first
  trailing = duration && (boundaries[:ends].last || (boundaries[:starts].last if boundaries[:starts].length > boundaries[:ends].length))
  puts "[%3d/%3d] %s" % [index + 1, files.length, path.basename]
  {
    "file" => path.basename.to_s,
    "stem" => path.basename(".mp3").to_s,
    "duration_seconds" => duration,
    "codec" => stream && stream["codec_name"],
    "channels" => stream && stream["channels"],
    "sample_rate_hz" => stream && number(stream["sample_rate"]),
    "leading_silence_seconds" => leading,
    "trailing_silence_seconds" => trailing,
    "silence_detection" => { "threshold_db" => -50, "minimum_seconds" => 0.35 }
  }
end

with_leading = records.count { |record| record["leading_silence_seconds"] && record["leading_silence_seconds"] >= 0.35 }
with_trailing = records.count { |record| record["trailing_silence_seconds"] && (record["duration_seconds"] - record["trailing_silence_seconds"]) >= 0.35 }
total_duration = records.sum { |record| record["duration_seconds"] || 0 }

result = {
  "generated_at" => Time.now.strftime("%Y-%m-%dT%H:%M:%S%z"),
  "source" => "recovered UGtastic _audio export",
  "analysis_scope" => "Technical media boundaries only. No speech transcription or content classification.",
  "method" => {
    "metadata" => "ffprobe format and first audio stream",
    "boundary_detection" => "ffmpeg silencedetect at -50 dB with a 0.35 second minimum",
    "interpretation" => "A detected silence is a media boundary candidate, not proof of an edit, intro, outro, or musical cue."
  },
  "summary" => {
    "audio_files" => records.length,
    "total_duration_seconds" => total_duration.round(3),
    "total_duration_hours" => (total_duration / 3600).round(2),
    "files_with_leading_silence" => with_leading,
    "files_with_trailing_silence" => with_trailing,
    "stereo_files" => records.count { |record| record["channels"] == 2 },
    "sample_rates_hz" => records.map { |record| record["sample_rate_hz"] }.compact.tally
  },
  "records" => records
}

output = Pathname(options[:output]).expand_path
output.dirname.mkpath
output.write(JSON.pretty_generate(result) + "\n")
puts "Wrote #{output}"
puts JSON.pretty_generate(result["summary"])
