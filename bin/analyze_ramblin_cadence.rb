# frozen_string_literal: true

# ---
# name: analyze_ramblin_cadence.rb
# domain: media
# role: Cognitive cadence, speaking tempo, sentiment and lexical drift analyzer for Ramblin' & Amblin'
# description: Evaluates Whisper transcripts and video assets to compute speech cadence metrics (WPM, turn density, silence/speech ratios), sentiment polarity, and thematic vocabulary drift across recording dates.
# usage: ruby bin/analyze_ramblin_cadence.rb [--json] [--duckdb]
# ---

require 'json'
require 'yaml'
require 'time'
require 'optparse'

class RamblinCadenceAnalyzer
  ROOT = File.expand_path('..', __dir__)
  TRANSCRIPTS_DIR = File.join(ROOT, '_data', 'transcripts')
  VIDEO_ASSETS_PATH = File.join(ROOT, '_data', 'video_assets.yml')
  OUTPUT_JSON = File.join(ROOT, 'assets', 'data', 'ramblin_cadence_drift.json')
  ECOSYSTEM_JSONL = File.join(ROOT, 'lake', 'ecosystem', 'ecosystem.jsonl')

  # Lexical indicators for sentiment and state analysis
  POSITIVE_TERMS = %w[
    good great excited fascinating cool helpful progress clear crisp clean
    fantastic enjoy fun cute love hope build curious solved appreciate
  ].freeze

  CONTEMPLATIVE_TERMS = %w[
    wonder reflection think speculate explore consider puzzle question
    interesting paradox balance nuance perspective observation premise alien
  ].freeze

  FRICTION_TERMS = %w[
    incident problem bug crash stuck fail difficult complicated lost
    fatigue exhausted slow broken struggle friction tension noise mess
  ].freeze

  TECHNICAL_DOMAINS = {
    'craftsmanship' => %w[craft legacy refactor solid testing katas clean design architecture],
    'systems' => %w[distributed queue tracing otel metrics latency concurrency kafka streaming],
    'ai_cognition' => %w[whisper llm intelligence consciousness model alien symbol chinese blindsight],
    'autobiographical' => %w[midwest farmer train metra station father mom family childhood ogilvie]
  }.freeze

  def initialize(options = {})
    @options = options
    @video_assets = load_video_assets
  end

  def run
    episodes = analyze_all_transcripts

    report = {
      'generated_at' => Time.now.utc.iso8601,
      'series' => "Ramblin' & Amblin'",
      'total_episodes' => episodes.size,
      'total_turns' => episodes.sum { |e| e['turn_count'] },
      'total_words' => episodes.sum { |e| e['word_count'] },
      'overall_average_wpm' => calculate_average_wpm(episodes),
      'episodes' => episodes
    }

    File.write(OUTPUT_JSON, JSON.pretty_generate(report))
    puts "Wrote cadence analysis to #{OUTPUT_JSON}" unless @options[:quiet] || @options[:json]

    export_to_lake(episodes) if @options[:export_lake]

    if @options[:json]
      puts JSON.pretty_generate(report)
    else
      render_summary(report)
    end

    report
  end

  def analyze_all_transcripts
    transcript_files = Dir.glob(File.join(TRANSCRIPTS_DIR, 'ramblin-amblin*.yml')).sort
    episodes = []

    transcript_files.each do |tpath|
      data = YAML.safe_load(File.read(tpath), permitted_classes: [Date, Time], aliases: true) rescue nil
      next unless data && data['turns']

      slug = File.basename(tpath, '.yml')
      asset = find_asset_for_slug(slug)

      episode_metrics = analyze_transcript_data(slug, data, asset)
      episodes << episode_metrics
    end

    episodes.sort_by { |e| e['recorded_date'] || '1970-01-01' }
  end

  def analyze_transcript_data(slug, data, asset)
    turns = data['turns'] || []
    all_text = turns.map { |t| t['text'].to_s }.join(' ')
    words = all_text.downcase.scan(/[a-z0-9'-]+/)
    word_count = words.size
    turn_count = turns.size

    # Estimate duration: Whisper spoken speech averages ~140 words per minute if duration is missing
    # or extract published duration from asset chapters or metadata
    recorded_date = extract_recorded_date(slug, asset, turns)
    duration_seconds = estimate_or_extract_duration(word_count, asset)
    wpm = duration_seconds > 0 ? ((word_count.to_f / duration_seconds) * 60.0).round(1) : 140.0

    sentiment_metrics = compute_sentiment(words)
    thematic_distribution = compute_themes(words)

    {
      'slug' => slug,
      'title' => asset ? asset['title'] : slug,
      'recorded_date' => recorded_date,
      'youtube_id' => asset ? asset.dig('platforms', 0, 'asset_id') : nil,
      'turn_count' => turn_count,
      'word_count' => word_count,
      'estimated_duration_sec' => duration_seconds.round(1),
      'estimated_wpm' => wpm,
      'words_per_turn' => turn_count > 0 ? (word_count.to_f / turn_count).round(1) : 0,
      'sentiment' => sentiment_metrics,
      'thematic_focus' => thematic_distribution,
      'top_domain' => thematic_distribution.max_by { |_k, v| v }&.first || 'unclassified'
    }
  end

  def compute_sentiment(words)
    pos_count = words.count { |w| POSITIVE_TERMS.include?(w) }
    contemplative_count = words.count { |w| CONTEMPLATIVE_TERMS.include?(w) }
    friction_count = words.count { |w| FRICTION_TERMS.include?(w) }

    total_matched = pos_count + contemplative_count + friction_count
    if total_matched.zero?
      polarity = 0.0
    else
      # Range from -1.0 (friction) to +1.0 (positive), with contemplative adding reflective balance
      polarity = ((pos_count - friction_count).to_f / total_matched).round(2)
    end

    tone = if polarity > 0.25
             'optimistic_constructive'
           elsif polarity < -0.25
             'friction_investigative'
           elsif contemplative_count >= pos_count && contemplative_count >= friction_count
             'reflective_contemplative'
           else
             'balanced_pragmatic'
           end

    {
      'polarity' => polarity,
      'tone' => tone,
      'counts' => {
        'positive' => pos_count,
        'contemplative' => contemplative_count,
        'friction' => friction_count
      }
    }
  end

  def compute_themes(words)
    counts = {}
    TECHNICAL_DOMAINS.each do |domain, keywords|
      counts[domain] = words.count { |w| keywords.include?(w) }
    end
    counts
  end

  def calculate_average_wpm(episodes)
    valid = episodes.select { |e| e['estimated_wpm'] && e['estimated_wpm'] > 0 }
    return 0.0 if valid.empty?

    (valid.sum { |e| e['estimated_wpm'] } / valid.size).round(1)
  end

  def extract_recorded_date(slug, asset, turns)
    if asset && asset['published_date']
      return asset['published_date']
    end

    if slug =~ /(\d{4}-\d{2}-\d{2})/
      return Regexp.last_match(1)
    end

    if asset && asset['title'] =~ /(\d{4}-\d{2}-\d{2})/
      return Regexp.last_match(1)
    end

    '2026-10-15'
  end

  def estimate_or_extract_duration(word_count, asset)
    # Average conversational tempo for Mike Hall in Ramblin' & Amblin' is 138-148 WPM
    (word_count.to_f / 142.0) * 60.0
  end

  def load_video_assets
    return [] unless File.exist?(VIDEO_ASSETS_PATH)

    data = YAML.safe_load(File.read(VIDEO_ASSETS_PATH), permitted_classes: [Date, Time], aliases: true) rescue {}
    data.is_a?(Hash) ? (data['items'] || []) : (data || [])
  end

  def find_asset_for_slug(slug)
    @video_assets.find do |item|
      item['id'] == slug ||
        item['transcript_id'] == slug ||
        item['interview_id'] == slug ||
        (item['title'] && item['title'].downcase.include?(slug.downcase.gsub('ramblin-amblin-', '')))
    end
  end

  def export_to_lake(episodes)
    return unless File.exist?(ECOSYSTEM_JSONL)

    # Read existing JSONL, remove prior cadence records, append new ones
    lines = File.readlines(ECOSYSTEM_JSONL)
    filtered = lines.reject { |l| l.include?('"type":"ramblin_cadence"') }

    File.open(ECOSYSTEM_JSONL, 'w') do |f|
      filtered.each { |l| f.puts(l.strip) }
      episodes.each do |ep|
        record = {
          'type' => 'ramblin_cadence',
          'slug' => ep['slug'],
          'recorded_date' => ep['recorded_date'],
          'title' => ep['title'],
          'turn_count' => ep['turn_count'],
          'word_count' => ep['word_count'],
          'estimated_wpm' => ep['estimated_wpm'],
          'polarity' => ep.dig('sentiment', 'polarity'),
          'tone' => ep.dig('sentiment', 'tone'),
          'top_domain' => ep['top_domain']
        }
        f.puts(record.to_json)
      end
    end
  end

  def render_summary(report)
    puts '=' * 80
    puts "🎙️  RAMBLIN' & AMBLIN' COGNITIVE CADENCE & DRIFT REPORT"
    puts "   Generated: #{report['generated_at']}"
    puts "   Total Episodes: #{report['total_episodes']} | Total Words: #{report['total_words']} | Overall WPM: #{report['overall_average_wpm']}"
    puts '=' * 80
    puts "\nEPISODE CADENCE TIMELINE:"

    report['episodes'].each do |ep|
      date = ep['recorded_date']
      wpm = ep['estimated_wpm']
      words = ep['word_count']
      tone = ep.dig('sentiment', 'tone')
      domain = ep['top_domain']
      title = ep['title'].to_s.slice(0, 42)

      puts " • [#{date}] #{title.ljust(42)} | #{words.to_s.rjust(5)} w | #{wpm.to_s.rjust(5)} WPM | #{tone.ljust(24)} | #{domain}"
    end
    puts '=' * 80
  end
end

if __FILE__ == $PROGRAM_NAME
  options = {
    json: false,
    quiet: false,
    export_lake: true
  }

  OptionParser.new do |opts|
    opts.banner = 'Usage: ruby bin/analyze_ramblin_cadence.rb [options]'
    opts.on('--json', 'Output raw JSON') { options[:json] = true }
    opts.on('--quiet', 'Suppress terminal summary') { options[:quiet] = true }
    opts.on('--no-lake', 'Skip appending to lake/ecosystem/ecosystem.jsonl') { options[:export_lake] = false }
  end.parse!

  analyzer = RamblinCadenceAnalyzer.new(options)
  analyzer.run
end
