#!/usr/bin/env ruby
# frozen_string_literal: true

require 'yaml'

ROOT_DIR = File.expand_path('..', __dir__)

command = ARGV.shift.to_s.downcase

case command
when 'schedule', 'calendar', ''
  plan = YAML.safe_load_file(File.join(ROOT_DIR, '_data', 'publication_schedule.yml')) || {}
  puts 'THE SOUND ABOVE: SEASON ONE WORKING PLAN'
  puts 'No release dates are set.'
  puts "Current target: #{plan.fetch('target_interviews', 17)} interviews. Episodes -1 and 0 are setup pieces."
  puts 'The order and scope can change; there is no release schedule.'
  puts 'See /series/the-sound-above/ for the current outline.'
when 'script', 'teleprompter'
  episode = ARGV.shift
  abort 'Usage: bin/youtube_pipeline.rb script <episode-number>' unless episode

  exec('ruby', File.join(ROOT_DIR, 'bin', 'generate_sound_above_teleprompter.rb'), '--episode', episode)
when 'help', '-h', '--help'
  puts <<~HELP
    Usage: bin/youtube_pipeline.rb <command>

    Commands:
      schedule    Show the Season One working target without release dates
      script N    Generate local teleprompter material from an episode dossier
      help        Show this message

    YouTube uploads, captions, metadata, playlist changes, status, and quota belong to media-pipeline.
    Live broadcast scheduling is not available through this repository.
  HELP
when 'audit', 'status', 'telemetry', 'resequence', 'quota', 'publish', 'upload', 'captions', 'playlist'
  warn "#{command} is a YouTube publishing operation owned by media-pipeline."
  warn 'Use media-pipeline bin/mp for supported publishing operations.'
  exit 64
else
  warn "Unknown local content command: #{command}"
  warn 'Use `schedule`, `script N`, or `help`.'
  exit 1
end
