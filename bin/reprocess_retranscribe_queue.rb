#!/usr/bin/env ruby
# frozen_string_literal: true

# Reverse feed: take the site's re-transcription queue and enqueue each video
# into the zdots transcription pipeline, reusing the idempotent
# `zdots-ingest-media` path (skip-existing on media_sources.source_uri +
# insert_conflict on the job fingerprint live in zdots-brain, so this script
# stays thin — it resolves URLs and delegates dedup). Dry-run by default;
# --apply actually enqueues.
require 'yaml'
require 'optparse'

QUEUE_PATH      = '_data/transcript_retranscribe_queue.yml'
ASSETS_PATH     = '_data/video_assets.yml'
INTERVIEWS_PATH = '_data/interviews.yml'
# Prefer the absolute path (known location); fall back to PATH lookup.
CLI_ABS = File.expand_path('~/.config/zsh/bin/zdots-ingest-media')
CLI = File.exist?(CLI_ABS) ? CLI_ABS : 'zdots-ingest-media'

# Resolve a queue transcript_id to its canonical platform URL via video_assets.
# Prefers the asset's primary_platform when it's youtube/vimeo, else the first
# youtube/vimeo platform carrying an asset_id. Returns {platform, asset_id, url}
# or nil when the id resolves to no playable source.
def resolve_url(transcript_id, by_tid, by_id)
  asset = by_tid[transcript_id] || by_id[transcript_id]
  return nil unless asset

  plats = Array(asset['platforms']).select { |p| %w[youtube vimeo].include?(p['platform']) && p['asset_id'] }
  return nil if plats.empty?

  plat = plats.find { |p| p['platform'] == asset['primary_platform'] } || plats.first
  url = plat['url'] ||
        (plat['platform'] == 'vimeo' ? "https://vimeo.com/#{plat['asset_id']}"
                                     : "https://www.youtube.com/watch?v=#{plat['asset_id']}")
  { 'platform' => plat['platform'], 'asset_id' => plat['asset_id'], 'url' => url }
end

options = { apply: false, force: false, limit: nil, profile: 'standard', tag: nil }
OptionParser.new do |o|
  o.banner = 'Usage: ruby ./bin/reprocess_retranscribe_queue.rb [options]'
  o.on('--apply', 'Enqueue into the pipeline (default: dry-run, enqueues nothing)') { options[:apply] = true }
  o.on('--force', 'Reprocess sources already ingested (passed to zdots-ingest-media)') { options[:force] = true }
  o.on('--limit N', Integer, 'Only process the first N queue items') { |n| options[:limit] = n }
  o.on('--profile P', 'Whisper profile (default: standard)') { |p| options[:profile] = p }
  o.on('--tag T', 'Only process assets containing this tag') { |t| options[:tag] = t }
end.parse!

queue      = YAML.load_file(QUEUE_PATH)['items'] || []
assets     = YAML.load_file(ASSETS_PATH)['items'] || []
interviews = YAML.load_file(INTERVIEWS_PATH)['items'] || []

by_tid = {}
by_id  = {}
assets.each do |a|
  by_id[a['id']] = a
  tid = a['transcript_id']
  by_tid[tid] ||= a if tid && !tid.to_s.empty?
end

# Diarization speaker-count hint per video_asset_id: interviewees + interviewer.
# Only interviews carry this; talks/solo videos stay unmapped and diarize
# unconstrained. The hint is a min/max bracket for pyannote, not an exact count.
speakers_by_asset = {}
interviews.each do |iv|
  aid = iv['video_asset_id']
  next unless aid
  count = Array(iv['interviewees']).size
  next if count.zero?
  count += 1 unless iv['interviewer'].to_s.strip.empty?
  speakers_by_asset[aid] = count
end

# Filter by tag if requested
if options[:tag]
  queue.select! do |item|
    tid = item['transcript_id']
    asset = by_tid[tid] || by_id[tid]
    asset && asset['tags'] && asset['tags'].include?(options[:tag])
  end
end

queue  = queue.first(options[:limit]) if options[:limit]

resolved = []
unresolved = []
queue.each do |item|
  tid = item['transcript_id']
  hit = resolve_url(tid, by_tid, by_id)
  unless hit
    unresolved << tid
    next
  end
  asset = by_tid[tid] || by_id[tid]
  num_speakers = asset && speakers_by_asset[asset['id']]
  resolved << { 'transcript_id' => tid, 'num_speakers' => num_speakers }.merge(hit)
end

mode = options[:apply] ? 'apply' : 'dry-run'
puts "reprocess-retranscribe-queue [#{mode}] — #{queue.size} queue items"
resolved.each do |r|
  spk = r['num_speakers'] ? "  [#{r['num_speakers']} spk]" : ''
  puts "  #{r['transcript_id']}  ->  #{r['platform']} #{r['asset_id']}  ->  #{r['url']}#{spk}"
end
unless unresolved.empty?
  puts "\nUNRESOLVED (#{unresolved.size}) — no youtube/vimeo asset:"
  unresolved.each { |tid| puts "  #{tid}" }
end
puts "\n#{resolved.size} resolvable / #{queue.size} queue items (#{unresolved.size} unresolved)"

if options[:apply]
  puts "\nEnqueuing (idempotent — already-ingested sources skip themselves)…"
  resolved.each_with_index do |r, i|
    args = [CLI, r['url'], '--profile', options[:profile]]
    args << '--force' if options[:force]
    args += ['--num-speakers', r['num_speakers'].to_s] if r['num_speakers']
    puts "[#{i + 1}/#{resolved.size}] #{r['transcript_id']} -> #{r['url']}"
    Bundler.with_unbundled_env do
      system(*args)
    end
  end
  puts 'Done. Process with the zdots worker (com.zdots.worker).'
else
  puts "\nDry-run only — no jobs enqueued. Re-run with --apply " \
       '(add --force to reprocess already-ingested sources).'
end
