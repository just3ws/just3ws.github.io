#!/usr/bin/env ruby

require "yaml"
require "date"
require "optparse"
require_relative "../src/generators/core/yaml_io"

ROOT = File.expand_path("..", __dir__)
ASSETS_PATH = File.join(ROOT, "_data", "video_assets.yml")
INTERVIEWS_PATH = File.join(ROOT, "_data", "interviews.yml")
TRANSCRIPTS_DIR = File.join(ROOT, "_data", "transcripts")

TOPIC_RULES = [
  ["developer-education-and-learning", "developer education and learning", [/\b(learn|learning|teaching|education|apprentice|apprenticeship|mentoring)\b/i]],
  ["conference-speaking-and-presentation-skills", "conference speaking and presentation skills", [/\b(conference|talk|presentation|speaker|slides|audience|panel)\b/i]],
  ["community-building-and-user-group-organizing", "community building and user-group organizing", [/\b(user\s*group|meetup|community|organizer|organizing|sponsor)\b/i]],
  ["software-craftsmanship-and-practice", "software craftsmanship and practice", [/\b(craftsmanship|craft|xp|agile|quality|pairing|refactor)\b/i]],
  ["ruby-and-rails-practice", "ruby and rails practice", [/\b(ruby|rails|windy\s*city\s*rails)\b/i]],
  ["clojure-and-functional-programming", "clojure and functional programming", [/\b(clojure|functional|lisp|koans?)\b/i]],
  ["web-development-and-frontend-practice", "web development and frontend practice", [/\b(web|javascript|css|html|frontend|browser)\b/i]],
  ["dotnet-and-altnet-practice", ".NET and alt.net practice", [/\b(\.net|dotnet|alt\.net|c#|f#)\b/i]],
  ["open-source-and-project-maintenance", "open source and project maintenance", [/\b(open\s*source|github|project|maintain|contributor)\b/i]],
  ["career-growth-and-technical-leadership", "career growth and technical leadership", [/\b(career|leadership|manager|hiring|team|culture)\b/i]],
  ["podcasting-and-community-media", "podcasting and community media", [/\b(podcast|video|interview|recording|media)\b/i]]
].freeze

TAG_RULES = [
  ["clojure", /\bclojure\b/i],
  ["ruby", /\bruby\b/i],
  ["rails", /\brails\b/i],
  ["agile", /\bagile\b/i],
  ["xp", /\bxp\b/i],
  ["software-craftsmanship", /\bcraftsmanship\b/i],
  ["testing", /\b(test|testing|tdd|bdd)\b/i],
  ["devops", /\b(devops|ci\/cd|deployment|pipeline)\b/i],
  ["conference", /\bconference\b/i],
  ["community", /\b(user\s*group|meetup|community)\b/i],
  ["podcast", /\bpodcast\b/i],
  ["open-source", /\bopen\s*source\b/i],
  ["leadership", /\bleadership\b/i],
  ["career", /\bcareer\b/i],
  ["web", /\bweb\b/i],
  ["javascript", /\bjavascript\b/i],
  ["python", /\bpython\b/i],
  ["dotnet", /\b(\.net|dotnet|c#|f#)\b/i]
].freeze

TAG_LABELS = {
  "clojure" => "Clojure",
  "ruby" => "Ruby",
  "rails" => "Rails",
  "agile" => "Agile methods",
  "xp" => "Extreme Programming",
  "software-craftsmanship" => "software craftsmanship",
  "testing" => "testing practice",
  "devops" => "delivery workflows",
  "conference" => "conference speaking",
  "community" => "community building",
  "podcast" => "technical media",
  "open-source" => "open source",
  "leadership" => "technical leadership",
  "career" => "career growth",
  "web" => "web development",
  "javascript" => "JavaScript",
  "python" => "Python",
  "dotnet" => ".NET"
}.freeze

CONFERENCE_TOPIC_FALLBACK = {
  "SCNA" => ["software-craftsmanship-and-practice", "software craftsmanship and practice"],
  "WindyCityRails" => ["ruby-and-rails-practice", "ruby and rails practice"],
  "ChicagoWebConf" => ["web-development-and-frontend-practice", "web development and frontend practice"]
}.freeze

CONFERENCE_TAGS = {
  "SCNA" => ["scna", "software-craftsmanship-north-america"],
  "WindyCityRails" => ["windy-city-rails", "chicago-ruby"],
  "ChicagoWebConf" => ["chicago-web-conf", "web-community"]
}.freeze

def normalize(value)
  value.to_s.gsub(/\s+/, " ").strip
end

def slugify(value)
  normalize(value)
    .downcase
    .gsub(/['’]/, "")
    .gsub(/[^a-z0-9]+/, "-")
    .gsub(/\A-+|-+\z/, "")
end

def canonical_conference_label(code)
  return "Software Craftsmanship North America" if code == "SCNA"
  return "WindyCityRails" if code == "WindyCityRails"
  return "ChicagoWebConf" if code == "ChicagoWebConf"

  code
end

def choose_topic(transcript_text:, conference:, community:, existing_topic:)
  normalized_existing = normalize(existing_topic)
  if !normalized_existing.empty? && normalized_existing.casecmp("general") != 0
    return [slugify(normalized_existing), normalized_existing.downcase]
  end

  best = nil
  best_score = 0
  TOPIC_RULES.each do |slug, text, patterns|
    score = patterns.sum { |pattern| transcript_text.scan(pattern).length }
    next if score <= best_score

    best_score = score
    best = [slug, text]
  end

  return best if best

  conf_fallback = CONFERENCE_TOPIC_FALLBACK[conference]
  return conf_fallback if conf_fallback

  normalized_community = normalize(community)
  if !normalized_community.empty? && normalized_community.casecmp("general") != 0
    return ["#{slugify(normalized_community)}-community-story", "#{normalized_community} community story"]
  end

  ["developer-community-and-career-conversations", "developer community and career conversations"]
end

def build_title(current_title:, interviewees:, conference:, conference_year:, community:)
  title = normalize(current_title)
  names = interviewees.map { |item| normalize(item) }.reject(&:empty?)
  return title if names.empty?

  names_text = names.join(" & ")

  looks_generic = title.empty? || title == names_text || title.casecmp(names.first).zero? || !title.match?(/interview|talk|conversation|community|conference/i)
  return title unless looks_generic

  if !normalize(conference).empty? && conference_year
    "Interview with #{names_text} at #{canonical_conference_label(conference)} #{conference_year}"
  elsif !normalize(community).empty? && normalize(community).casecmp("general") != 0
    "Interview with #{names_text} from #{normalize(community)}"
  else
    "Interview with #{names_text}"
  end
end

def build_description(interviewees:, conference:, conference_year:, community:, topic_text:, transcript_content:)
  names = interviewees.map { |item| normalize(item) }.reject(&:empty?)
  names_text = names.empty? ? "the guest" : names.join(" & ")

  context = if !normalize(conference).empty? && conference_year
              "at #{canonical_conference_label(conference)} #{conference_year}"
            elsif !normalize(community).empty? && normalize(community).casecmp("general") != 0
              "with the #{normalize(community)} community"
            else
              ""
            end

  description = "Interview with #{names_text}"
  description << " #{context}" unless context.empty?
  description << " on #{topic_text}."

  themes = transcript_themes(transcript_content)
  if themes.any?
    description << " Themes include #{themes.join(', ')}."
  elsif !normalize(conference).empty?
    description << " The conversation captures practical lessons shared at the event."
  elsif !normalize(community).empty? && normalize(community).casecmp("general") != 0
    description << " The conversation focuses on practical lessons for local community organizers and contributors."
  else
    description << " The conversation focuses on practical software development experience and community lessons."
  end

  normalize(description)
end

def transcript_themes(transcript_text, max_items: 3)
  counts = {}
  TAG_RULES.each do |tag, pattern|
    count = transcript_text.scan(pattern).length
    next if count < 2
    next unless TAG_LABELS.key?(tag)
    next if %w[community conference].include?(tag)

    counts[tag] = count
  end

  counts
    .sort_by { |tag, count| [-count, tag] }
    .first(max_items)
    .map { |tag, _| TAG_LABELS[tag] }
end

def derive_tags(existing_tags:, interviewees:, conference:, conference_year:, community:, topic_slug:, transcript_text:)
  tags = Array(existing_tags).map { |tag| slugify(tag) }.reject(&:empty?)

  tags << "ugtastic"
  tags << "interview"
  tags.concat(interviewees.map { |name| slugify(name) }.reject(&:empty?))

  conf = normalize(conference)
  if !conf.empty?
    tags << "conference"
    tags.concat(CONFERENCE_TAGS.fetch(conf, [slugify(conf)]))
    tags << "#{slugify(conf)}-#{conference_year}" if conference_year
  end

  comm = normalize(community)
  if !comm.empty? && comm.casecmp("general") != 0
    tags << "community"
    tags << slugify(comm)
  end

  TAG_RULES.each do |tag, pattern|
    match_count = transcript_text.scan(pattern).length
    tags << tag if match_count >= 2
  end

  tags << topic_slug unless topic_slug.empty?

  tags
    .map { |tag| slugify(tag) }
    .reject(&:empty?)
    .uniq
    .first(14)
end

options = { apply: false }
OptionParser.new do |parser|
  parser.banner = "Usage: ruby bin/enrich_transcript_metadata.rb [--apply]"
  parser.on("--apply", "Write changes to _data/interviews.yml and _data/video_assets.yml") { options[:apply] = true }
end.parse!

assets_data = Generators::Core::YamlIo.load(ASSETS_PATH)
interviews_data = Generators::Core::YamlIo.load(INTERVIEWS_PATH)
assets = assets_data["items"] || []
interviews = interviews_data["items"] || []
interview_by_id = interviews.each_with_object({}) { |row, memo| memo[row["id"]] = row }

metrics = {
  scanned_transcript_assets: 0,
  assets_updated: 0,
  interviews_updated: 0,
  title_updates: 0,
  description_updates: 0,
  topic_updates: 0,
  tags_updates: 0,
  interview_topic_updates: 0,
  interview_community_updates: 0
}

def description_needs_refresh?(description)
  text = normalize(description).downcase
  return true if text.empty?
  return true if text.length < 80
  return true if text.include?("highlights include ")
  return true if text.include?("highlights include i'm")
  return true if text.include?("highlights include hi")
  return true if text.include?("ugtastic.com")
  return true if text.include?("user groups with lots to say")

  false
end

assets.each do |asset|
  transcript_id = normalize(asset["transcript_id"])
  next if transcript_id.empty?

  transcript_path = File.join(TRANSCRIPTS_DIR, "#{transcript_id}.yml")
  next unless File.exist?(transcript_path)

  transcript_data = Generators::Core::YamlIo.load(transcript_path)
  transcript_text = normalize(transcript_data["content"])
  next if transcript_text.empty?

  interview_id = normalize(asset["interview_id"])
  interview = interview_by_id[interview_id]
  next unless interview

  metrics[:scanned_transcript_assets] += 1

  interviewees = Array(interview["interviewees"]).map { |name| normalize(name) }.reject(&:empty?)
  if interviewees.empty?
    fallback = normalize(interview["title"])
    interviewees = [fallback] unless fallback.empty?
  end

  conference = normalize(interview["conference"])
  conference_year = interview["conference_year"]
  community = normalize(interview["community"])

  topic_slug, topic_text = choose_topic(
    transcript_text: transcript_text,
    conference: conference,
    community: community,
    existing_topic: interview["topic"]
  )

  asset_changed = false
  interview_changed = false

  improved_title = build_title(
    current_title: asset["title"],
    interviewees: interviewees,
    conference: conference,
    conference_year: conference_year,
    community: community
  )
  if normalize(improved_title) != normalize(asset["title"])
    asset["title"] = improved_title
    metrics[:title_updates] += 1
    asset_changed = true
  end

  if description_needs_refresh?(asset["description"])
    regenerated_description = build_description(
      interviewees: interviewees,
      conference: conference,
      conference_year: conference_year,
      community: community,
      topic_text: topic_text,
      transcript_content: transcript_text
    )
    if normalize(regenerated_description) != normalize(asset["description"])
      asset["description"] = regenerated_description
      metrics[:description_updates] += 1
      asset_changed = true
    end
  end

  if normalize(asset["topic"]).empty?
    asset["topic"] = topic_slug
    metrics[:topic_updates] += 1
    asset_changed = true
  end

  new_tags = derive_tags(
    existing_tags: asset["tags"],
    interviewees: interviewees,
    conference: conference,
    conference_year: conference_year,
    community: community,
    topic_slug: topic_slug,
    transcript_text: transcript_text
  )

  if new_tags != Array(asset["tags"])
    asset["tags"] = new_tags
    metrics[:tags_updates] += 1
    asset_changed = true
  end

  if normalize(interview["topic"]).empty?
    interview["topic"] = topic_text
    metrics[:interview_topic_updates] += 1
    interview_changed = true
  end

  if normalize(interview["community"]).empty? && conference.empty?
    interview["community"] = "General"
    metrics[:interview_community_updates] += 1
    interview_changed = true
  end

  metrics[:assets_updated] += 1 if asset_changed
  metrics[:interviews_updated] += 1 if interview_changed
end

if options[:apply]
  Generators::Core::YamlIo.dump(ASSETS_PATH, assets_data)
  Generators::Core::YamlIo.dump(INTERVIEWS_PATH, interviews_data)
  puts "Applied transcript metadata enrichment."
else
  puts "Dry-run only. Re-run with --apply to persist changes."
end

metrics.each { |key, value| puts "#{key}=#{value}" }
