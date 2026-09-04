#!/usr/bin/env ruby
# frozen_string_literal: true

# Compare a known soundtrack with short opening and closing windows from
# finished videos. Chromaprint similarity is a candidate signal only.

require "json"
require "open3"
require "optparse"
require "pathname"
require "tmpdir"

options = {}
OptionParser.new do |parser|
  parser.banner = "Usage: ruby bin/match_ugtastic_soundtrack.rb --track PATH --videos PATH [--output PATH]"
  parser.on("--track PATH") { |value| options[:track] = value }
  parser.on("--videos PATH") { |value| options[:videos] = value }
  parser.on("--output PATH") { |value| options[:output] = value }
end.parse!
abort "--track and --videos are required" unless options[:track] && options[:videos]
options[:output] ||= "_data/ugtastic_soundtrack_matches.json"

def json_command(*command)
  stdout, stderr, status = Open3.capture3(*command)
  abort "Command failed: #{command.join(' ')}\n#{stderr}" unless status.success?
  JSON.parse(stdout)
end

def fingerprint(path, length: nil)
  command = ["fpcalc", "-raw", "-json"]
  command += ["-length", length.to_s] if length
  json_command(*command, path.to_s)["fingerprint"]
end

def hamming(left, right)
  (left ^ right).digits(2).sum
end

def similarity(candidate, source)
  return 0.0 if candidate.empty? || source.empty?
  width = [candidate.length, 12].min
  windows = (0..[source.length - width, 0].max).map { |offset| source[offset, width] }
  windows.map do |window|
    compared = [window.length, candidate.length, width].min
    next 0.0 if compared.zero?
    1.0 - (0...compared).sum { |index| hamming(window[index], candidate[index]) }.fdiv(compared * 32)
  end.max || 0.0
end

track = Pathname(options[:track]).expand_path
videos = Dir[Pathname(options[:videos]).expand_path.join("**/*.{mp4,m4v}").to_s].sort.map { |path| Pathname(path) }
source_fingerprint = fingerprint(track)

records = Dir.mktmpdir("ugtastic-soundtrack-") do |temporary_dir|
  videos.map.with_index do |video, index|
    puts "[%3d/%3d] %s" % [index + 1, videos.length, video.basename]
    open_path = Pathname(temporary_dir).join("open-#{index}.wav")
    close_path = Pathname(temporary_dir).join("close-#{index}.wav")
    duration = json_command("ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "json", video.to_s).dig("format", "duration").to_f
    [
      ["opening", ["-ss", "0", "-t", "30"]],
      ["closing", ["-ss", [duration - 30, 0].max.to_s, "-t", "30"]]
    ].each do |label, seek|
      target = label == "opening" ? open_path : close_path
      command = ["ffmpeg", "-hide_banner", "-loglevel", "error", *seek, "-i", video.to_s, "-vn", "-ac", "1", "-ar", "11025", "-y", target.to_s]
      _stdout, stderr, status = Open3.capture3(*command)
      abort "ffmpeg failed for #{video}: #{stderr}" unless status.success?
    end
    opening = fingerprint(open_path, length: 30)
    closing = fingerprint(close_path, length: 30)
    {
      "file" => video.basename.to_s,
      "duration_seconds" => duration.round(3),
      "opening_similarity" => similarity(opening, source_fingerprint).round(4),
      "closing_similarity" => similarity(closing, source_fingerprint).round(4)
    }
  end
end

result = {
  "generated_at" => Time.now.strftime("%Y-%m-%dT%H:%M:%S%z"),
  "track" => track.basename.to_s,
  "method" => "Chromaprint similarity between the source track and 30-second opening and closing windows. Candidate threshold: 0.75.",
  "interpretation" => "A high score is evidence of a likely audio match, not proof of an edit decision or a complete soundtrack placement. Mixed speech, compression, and soundtrack volume can lower scores.",
  "summary" => {
    "videos_analyzed" => records.length,
    "opening_candidates" => records.count { |record| record["opening_similarity"] >= 0.75 },
    "closing_candidates" => records.count { |record| record["closing_similarity"] >= 0.75 },
    "strongest_opening" => records.max_by { |record| record["opening_similarity"] },
    "strongest_closing" => records.max_by { |record| record["closing_similarity"] }
  },
  "records" => records
}

output = Pathname(options[:output]).expand_path
output.dirname.mkpath
output.write(JSON.pretty_generate(result) + "\n")
puts JSON.pretty_generate(result["summary"])
