#!/usr/bin/env ruby
# frozen_string_literal: true

# ---
# name: assemble_sound_above_episode.rb
# domain: media
# purpose: Lossless 3-take segment assembly for The Sound Above episodes
# usage: bin/assemble_sound_above_episode.rb <NN> [options]
# description: Losslessly concatenates modular recording takes (Intro, Rewatch, Outro)
#   using ffmpeg stream-copy (ffmpeg -c copy) into a unified master file.
# ---

require 'fileutils'
require 'optparse'
require 'tempfile'

SERIES_BASE = File.expand_path('~/ai/media-pipeline/just3ws-mike/the-sound-above')
STAGED_DIR = File.join(SERIES_BASE, 'staged')
PENDING_DIR = File.join(SERIES_BASE, 'pending')

options = {
  dry_run: false,
  intro: nil,
  rewatch: nil,
  outro: nil,
  output: nil
}

parser = OptionParser.new do |opts|
  opts.banner = 'Usage: bin/assemble_sound_above_episode.rb <NN> [options]'
  opts.separator ''
  opts.separator 'Losslessly concatenates Take 1 (Intro), Take 2 (Rewatch), and Take 3 (Outro)'
  opts.separator 'into the final pending episode master using ffmpeg stream-copy.'
  opts.separator ''

  opts.on('--intro PATH', 'Explicit path to Take 1 (Intro)') { |p| options[:intro] = File.expand_path(p) }
  opts.on('--rewatch PATH', 'Explicit path to Take 2 (Rewatch & Workbench)') { |p| options[:rewatch] = File.expand_path(p) }
  opts.on('--outro PATH', 'Explicit path to Take 3 (Outro)') { |p| options[:outro] = File.expand_path(p) }
  opts.on('--output PATH', 'Explicit path for output master file') { |p| options[:output] = File.expand_path(p) }
  opts.on('-d', '--dry-run', 'Inspect concatenation plan without running ffmpeg') { options[:dry_run] = true }
  opts.on_tail('-h', '--help', 'Show this help message') do
    puts opts
    exit 0
  end
end

parser.parse!

number = ARGV.first.to_s[/\d+/]
unless number
  warn parser
  exit 1
end

num_fmt = format('%02d', number.to_i)
default_output = File.join(PENDING_DIR, "The_Sound_Above_Episode_#{num_fmt}_Master.mov")
output_path = options[:output] || default_output

# If explicit takes not passed, look for the 3 most recent video files in staged
files = [options[:intro], options[:rewatch], options[:outro]]
if files.any?(&:nil?)
  staged_candidates = Dir.glob(File.join(STAGED_DIR, '*.{mov,mp4,mkv}')).sort_by { |f| File.mtime(f) }
  if staged_candidates.size < 3
    warn "Error: Found #{staged_candidates.size} video files in #{STAGED_DIR}, expected at least 3 takes."
    warn 'Please pass explicit takes using --intro, --rewatch, and --outro.'
    exit 1
  end
  # Take the 3 most recent
  files = staged_candidates.last(3)
  puts "Auto-detected 3 most recent takes from #{STAGED_DIR}:"
  puts "  1. Intro  : #{files[0]}"
  puts "  2. Rewatch: #{files[1]}"
  puts "  3. Outro  : #{files[2]}"
end

files.each do |f|
  unless File.file?(f)
    warn "Error: Take file not found: #{f}"
    exit 1
  end
end

puts "=================================================================="
puts " 🎬 The Sound Above: Lossless Episode Assembly (Episode #{num_fmt})"
puts "=================================================================="
puts "  Intro   : #{files[0]}"
puts "  Rewatch : #{files[1]}"
puts "  Outro   : #{files[2]}"
puts "  Target  : #{output_path}"
puts '  Mode    : Stream-copy concatenation (ffmpeg -f concat -c copy)'
puts "=================================================================="

if options[:dry_run]
  puts 'Dry-run requested: no files written.'
  exit 0
end

FileUtils.mkdir_p(File.dirname(output_path))

Tempfile.create(['sound_above_concat_', '.txt']) do |concat_file|
  files.each do |f|
    concat_file.puts "file '#{f}'"
  end
  concat_file.flush

  cmd = [
    'ffmpeg',
    '-y',
    '-f', 'concat',
    '-safe', '0',
    '-i', concat_file.path,
    '-c', 'copy',
    output_path
  ]

  puts "Executing: #{cmd.join(' ')}"
  success = system(*cmd)
  unless success
    warn 'Error: ffmpeg assembly failed.'
    exit 1
  end
end

puts "Successfully assembled master: #{output_path}"
