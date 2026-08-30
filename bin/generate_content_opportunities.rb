#!/usr/bin/env ruby
# frozen_string_literal: true

# bin/generate_content_opportunities.rb
# Generates the content-opportunity backlog from enriched transcripts and insights.
# Derives candidate articles, playlists, shorts, durable wisdom, and research threads.
# Idempotent: Preserves existing human curation statuses on rerun.

require "yaml"
require "json"
require "digest"
require "fileutils"
require "time"

ROOT_DIR = File.expand_path("..", __dir__)
DATA_DIR = File.join(ROOT_DIR, "_data")
TRANSCRIPTS_DIR = File.join(DATA_DIR, "transcripts")
OUTPUT_FILE = File.join(DATA_DIR, "content_opportunities.yml")
INTERVIEWS_FILE = File.join(DATA_DIR, "interviews.yml")

# Load existing content opportunities to preserve human status curation
existing_data = {}
if File.exist?(OUTPUT_FILE)
  begin
    existing_data = YAML.safe_load_file(OUTPUT_FILE, permitted_classes: [Symbol, Time, Date]) || {}
  rescue StandardError => e
    warn "Warning: Could not parse existing #{OUTPUT_FILE}: #{e.message}"
  end
end

# Index existing statuses by candidate ID
status_lookup = {}
%w[shorts articles playlists linkedin_durable_wisdom ai_discovery research_threads].each do |cat|
  items = existing_data[cat] || []
  items.each do |item|
    status_lookup[item["id"]] = item["status"] if item["id"] && item["status"]
  end
end

# Load interviews index
interviews_by_slug = {}
if File.exist?(INTERVIEWS_FILE)
  begin
    raw = YAML.safe_load_file(INTERVIEWS_FILE, permitted_classes: [Symbol, Time, Date]) || {}
    raw_interviews = raw.is_a?(Hash) ? (raw["items"] || []) : raw
    raw_interviews.each do |inv|
      slug = inv["slug"] || inv["id"] || inv["video_asset_id"]
      interviews_by_slug[slug] = inv if slug
    end
  rescue StandardError => e
    warn "Warning: Could not load interviews.yml: #{e.message}"
  end
end

# Collect transcript files
transcript_files = Dir[File.join(TRANSCRIPTS_DIR, "*.yml")].sort

generated_shorts = []
generated_durable_wisdom = []
generated_ai_discovery = []
topic_clusters = Hash.new { |h, k| h[k] = [] }
conference_clusters = Hash.new { |h, k| h[k] = [] }
research_clusters = Hash.new { |h, k| h[k] = [] }

transcript_files.each do |file_path|
  slug = File.basename(file_path, ".yml")
  interview_meta = interviews_by_slug[slug] || {}
  interview_title = interview_meta["title"] || slug.split("-").map(&:capitalize).join(" ")
  conference = interview_meta["conference"] || "Community Archive"

  begin
    data = YAML.safe_load_file(file_path, permitted_classes: [Symbol, Time, Date]) || {}
  rescue StandardError => e
    warn "Error loading #{file_path}: #{e.message}"
    next
  end

  speaker_map = data["speaker_map"] || {}
  guest_speakers = speaker_map.reject { |k, v| (v["role"] || "").downcase.include?("interviewer") || (v["name"] || "").downcase.include?("mike hall") }
  guest_name = guest_speakers.values.map { |v| v["name"] }.join(", ")
  guest_name = guest_name.empty? ? (interview_meta["speaker"] || "Guest Speaker") : guest_name

  # Index conference clustering
  conference_clusters[conference] << { slug: slug, speaker: guest_name, title: interview_title }

  # 1. Process Turns for Shorts
  turns = data["turns"] || []
  turns.each_with_index do |turn, idx|
    speaker_id = turn["speaker"]
    speaker_info = speaker_map[speaker_id] || {}
    is_interviewer = (speaker_info["role"] || "").downcase.include?("interviewer") || (speaker_info["name"] || "").downcase.include?("mike hall")
    next if is_interviewer

    text = (turn["text"] || "").strip
    word_count = text.split(/\s+/).size
    # Filter for punchy, insightful quotes (25-75 words)
    next unless word_count.between?(25, 75)
    next if text.downcase.start_with?("hi,", "hello", "thanks", "yeah, so", "okay, so")

    candidate_id = "short-#{slug}-turn-#{idx}"
    title = "#{guest_name} on #{interview_title.split(':').first.strip}"
    
    generated_shorts << {
      "id" => candidate_id,
      "title" => title,
      "kind" => "short",
      "speaker" => guest_name,
      "rationale" => "Punchy #{word_count}-word insight from #{conference}",
      "sources" => [{ "slug" => slug, "turn_index" => idx }],
      "text" => text,
      "feeds_task" => "TASK-258",
      "status" => status_lookup[candidate_id] || "proposed"
    }
  end

  # 2. Process Insights (Durable Wisdom & AI Discovery)
  insights = data["insights"] || []
  insights.each_with_index do |ins, idx|
    statement = ins["statement"] || ins["text"]
    next unless statement && !statement.empty?

    # Durable Wisdom
    if ins["type"] == "durable" || (ins["confidence"] == "high")
      candidate_id = "wisdom-#{Digest::SHA256.hexdigest("#{slug}:#{statement}")[0..9]}"
      generated_durable_wisdom << {
        "id" => candidate_id,
        "title" => "#{guest_name}: #{statement.slice(0, 70)}...",
        "kind" => "durable_wisdom",
        "speaker" => guest_name,
        "statement" => statement,
        "lessons_for_now" => ins["lessons_for_now"] || "Timeless software engineering principle applicable to modern architectures.",
        "rationale" => "High-confidence durable engineering insight",
        "sources" => [{ "slug" => slug, "speaker" => guest_name, "title" => interview_title }],
        "feeds_task" => "TASK-238",
        "status" => status_lookup[candidate_id] || "proposed"
      }
    end

    # AI Discovery / Automation vs Craftsmanship
    statement_lower = statement.downcase
    if statement_lower.include?("tool") || statement_lower.include?("automation") || statement_lower.include?("craft") || statement_lower.include?("practice") || statement_lower.include?("design")
      candidate_id = "ai-disc-#{Digest::SHA256.hexdigest("#{slug}:#{statement}")[0..9]}"
      generated_ai_discovery << {
        "id" => candidate_id,
        "title" => "Developer Agency & Tooling: #{guest_name}",
        "kind" => "ai_discovery",
        "speaker" => guest_name,
        "statement" => statement,
        "rationale" => "Informs modern developer tooling and agent orchestration",
        "sources" => [{ "slug" => slug, "speaker" => guest_name, "title" => interview_title }],
        "feeds_task" => "TASK-236",
        "status" => status_lookup[candidate_id] || "proposed"
      }
    end
  end

  # 3. Topic Clusters for Long-Form Articles & Research
  topics = data["topics"] || interview_meta["topics"] || []
  topics.each do |t|
    norm_t = t.to_s.strip.downcase
    topic_clusters[norm_t] << { slug: slug, speaker: guest_name, title: interview_title }
  end
end

# 4. Synthesize Playlists (Groupings >= 3 interviews)
generated_playlists = []
conference_clusters.each do |conf, items|
  next if items.size < 2 || conf == "Community Archive"
  conf_slug = conf.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/^-+|-+$/, "")
  candidate_id = "playlist-#{conf_slug}"
  
  generated_playlists << {
    "id" => candidate_id,
    "title" => "#{conf} Archive: Masters of Software Engineering",
    "kind" => "playlist",
    "rationale" => "#{items.size} curated historical interviews from #{conf}",
    "sources" => items.uniq { |x| x[:slug] },
    "feeds_task" => "TASK-258",
    "status" => status_lookup[candidate_id] || "proposed"
  }
end

# 5. Synthesize Curated Long-Form Articles from Key Topic Clusters
key_article_themes = [
  {
    topic: "software craftsmanship",
    title: "The Oral History of Software Craftsmanship in Chicago (2009-2016)",
    rationale: "Synthesizes SCNA, SCMC, and 8th Light engineering culture roots",
    feeds: "TASK-237"
  },
  {
    topic: "testing",
    title: "From TDD to Verification Gates: How Testing Philosophy Evolved",
    rationale: "Examines test-driven design insights across Ruby, Clojure, and JVM practitioners",
    feeds: "TASK-237"
  },
  {
    topic: "architecture",
    title: "The Distributed Systems Crucible: Monolith Modernization in Practice",
    rationale: "Synthesizes architecture lessons from GOTO Conference and RailsConf veterans",
    feeds: "TASK-237"
  },
  {
    topic: "community",
    title: "Building Developer Communities That Last: Lessons from 100+ User Group Leaders",
    rationale: "Distills community leadership patterns from UGtastic archive",
    feeds: "TASK-237"
  }
]

generated_articles = []
key_article_themes.each do |theme|
  theme_slug = theme[:topic].downcase.gsub(/[^a-z0-9]+/, "-")
  candidate_id = "article-#{theme_slug}"
  matching_sources = topic_clusters.select { |k, _| k.include?(theme[:topic]) }.values.flatten.uniq { |x| x[:slug] }
  
  generated_articles << {
    "id" => candidate_id,
    "title" => theme[:title],
    "kind" => "article",
    "rationale" => theme[:rationale],
    "sources" => matching_sources.first(8),
    "feeds_task" => theme[:feeds],
    "status" => status_lookup[candidate_id] || "proposed"
  }
end

# 6. Synthesize Research Threads
generated_research_threads = [
  {
    "id" => "research-concurrency-models",
    "title" => "Concurrency Paradigms: Actor Model vs CSP vs Deterministic State Replay",
    "kind" => "research_thread",
    "topic" => "Concurrency & Distributed State",
    "rationale" => "Comparing Erlang/Elixir, Clojure STM, and Go channels across interview dialogues",
    "sources" => topic_clusters.select { |k, _| k.include?("concurrency") || k.include?("clojure") || k.include?("erlang") }.values.flatten.first(5),
    "feeds_task" => "TASK-257",
    "status" => status_lookup["research-concurrency-models"] || "proposed"
  },
  {
    "id" => "research-sociotechnical-systems",
    "title" => "Sociotechnical Conway's Law: How Team Boundaries Dictate Production Incidents",
    "kind" => "research_thread",
    "topic" => "Team Topologies & Enablement",
    "rationale" => "Examining organizational friction and engineering culture across 10 years of interviews",
    "sources" => topic_clusters.select { |k, _| k.include?("culture") || k.include?("team") || k.include?("organization") }.values.flatten.first(5),
    "feeds_task" => "TASK-257",
    "status" => status_lookup["research-sociotechnical-systems"] || "proposed"
  }
]

# Construct Output Object
output_payload = {
  "generated_at" => Time.now.iso8601,
  "articles" => generated_articles,
  "playlists" => generated_playlists,
  "shorts" => generated_shorts.first(40),
  "linkedin_durable_wisdom" => generated_durable_wisdom.first(30),
  "ai_discovery" => generated_ai_discovery.first(25),
  "research_threads" => generated_research_threads
}

File.write(OUTPUT_FILE, YAML.dump(output_payload))

puts "✅ Generated Content Opportunities Backlog:"
puts "   • Articles         : #{output_payload['articles'].size}"
puts "   • Playlists        : #{output_payload['playlists'].size}"
puts "   • Shorts           : #{output_payload['shorts'].size}"
puts "   • Durable Wisdom   : #{output_payload['linkedin_durable_wisdom'].size}"
puts "   • AI Discovery     : #{output_payload['ai_discovery'].size}"
puts "   • Research Threads : #{output_payload['research_threads'].size}"
puts "   • Target File      : #{OUTPUT_FILE}"
