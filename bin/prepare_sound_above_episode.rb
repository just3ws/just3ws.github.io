#!/usr/bin/env ruby
# frozen_string_literal: true

# ---
# name: prepare_sound_above_episode.rb
# domain: media
# purpose: One-command weekly preparation for a The Sound Above episode
# usage: bin/prepare_sound_above_episode.rb <NN> [--check] [--cue-overlay] [--bookmarks]
# description: Validates _data/episodes/episode-NN.yml against the episode
#   contract, compiles the Textream document, rebuilds Jekyll, and syncs the
#   localhost webroot. --check validates only. --cue-overlay also cues the OBS
#   overlay state. --bookmarks reinstalls Chromium bookmarks (restarts Chromium).
# ---

require 'date'
require 'optparse'
require 'yaml'

ROOT = File.expand_path('..', __dir__)
EPISODES_DIR = File.join(ROOT, '_data', 'episodes')
ACTS = %w[act_1 act_2 act_3 act_4 act_5 act_6].freeze
REQUIRED_KEYS = %w[title interviewee conference year slug teleprompter_script rewatch_cues archival_receipts
                   research_attachments].freeze
WAYBACK = %r{\Ahttps://web\.archive\.org/web/(\d{14})/}
EM_DASH = "\u2014"

def hms_to_seconds(str)
  parts = str.to_s.split(':').map(&:to_i)
  parts.reduce(0) { |acc, part| (acc * 60) + part }
end

def validate(number, raw, dossier)
  errors = []
  warnings = []

  errors << "em dash found (#{raw.count(EM_DASH)})" if raw.include?(EM_DASH)
  REQUIRED_KEYS.each { |key| errors << "missing key: #{key}" if dossier[key].nil? || dossier[key].respond_to?(:empty?) && dossier[key].empty? }
  return [errors, warnings] unless errors.empty?

  script = dossier['teleprompter_script']
  ACTS.each { |act| errors << "missing #{act}" if script[act].to_s.strip.empty? }

  cues = dossier['rewatch_cues']
  errors << 'need at least 3 rewatch_cues' if cues.size < 3
  previous = -1
  cues.each_with_index do |cue, i|
    %w[time seconds label guest_says watch_for].each { |k| errors << "cue #{i + 1} missing #{k}" if cue[k].to_s.empty? }
    if cue['seconds'].to_i != hms_to_seconds(cue['time'])
      errors << "cue #{i + 1} time #{cue['time']} does not match seconds #{cue['seconds']}"
    end
    errors << "cue #{i + 1} is out of order" if cue['seconds'].to_i < previous
    previous = cue['seconds'].to_i
  end

  urls = dossier['archival_receipts'].map { |r| r['url'] } + dossier['research_attachments'].map { |r| r['url'] }
  urls.compact.each do |url|
    next unless url.include?('web.archive.org')

    errors << "Wayback URL without a 14-digit capture timestamp or with wildcard: #{url}" if url.include?('*') || url !~ WAYBACK
  end

  ACTS.each do |act|
    script[act].to_s.each_line.with_index(1) do |line, n|
      warnings << "#{act}:#{n} plural voice: #{line.strip[0, 80]}" if line =~ /\b(we|we're|our|ours|us)\b/i
    end
  end

  if dossier['errata'].nil?
    warnings << 'no errata companion block (optional)'
  elsif dossier['errata']['unscripted_prompts'].to_a.empty?
    warnings << 'errata block has no unscripted_prompts'
  end

  warnings << 'episode status is still scheduled or prep' if %w[scheduled prep].include?(dossier['status'].to_s) && number > 1
  [errors, warnings]
end

def run!(cmd, label)
  puts "==> #{label}"
  system(cmd) || abort("FAILED: #{label}")
end

options = { check: false, cue: false, bookmarks: false }
OptionParser.new do |opts|
  opts.banner = 'Usage: bin/prepare_sound_above_episode.rb <NN> [options]'
  opts.on('--check', 'Validate only') { options[:check] = true }
  opts.on('--cue-overlay', 'Cue the OBS overlay state for this episode') { options[:cue] = true }
  opts.on('--bookmarks', 'Reinstall Chromium bookmarks (restarts Chromium)') { options[:bookmarks] = true }
end.parse!

number = ARGV.first.to_s[/\d+/]
abort 'Usage: bin/prepare_sound_above_episode.rb <NN> [--check] [--cue-overlay] [--bookmarks]' unless number

num = number.to_i
file = File.join(EPISODES_DIR, format('episode-%02d.yml', num))
abort "No dossier at #{file}" unless File.file?(file)

raw = File.read(file)
dossier = YAML.safe_load(raw, permitted_classes: [Date, Time], aliases: true)
errors, warnings = validate(num, raw, dossier)

puts "Episode #{num}: #{dossier['title']}"
warnings.each { |w| puts "  WARN  #{w}" }
errors.each { |e| puts "  ERROR #{e}" }
abort "Episode #{num} failed validation (#{errors.size} errors)." unless errors.empty?
puts "  OK    contract valid (#{dossier['rewatch_cues'].size} cues, #{dossier['archival_receipts'].size} receipts, #{dossier['research_attachments'].size} attachments, #{warnings.size} warnings)"
exit 0 if options[:check]

Dir.chdir(ROOT) do
  run!("ruby bin/generate_sound_above_teleprompter.rb -e #{num} -s > /dev/null", 'Compile Textream document')
  run!("ruby bin/broadcast --rewatch #{num} > /dev/null", 'Cue OBS overlay state') if options[:cue]
  run!('bundle exec jekyll build', 'Build site')
  run!('bundle exec rake localhost:sync', 'Sync localhost webroot')
  run!('ruby bin/episode_bookmarks.rb --install', 'Install Chromium bookmarks') if options[:bookmarks]
end

slug = format('episode-%02d', num)
puts "Ready: https://www.just3ws.localhost/series/the-sound-above/#{slug}/ and /#{slug}/workbench/"
