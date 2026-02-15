#!/usr/bin/env ruby

require "yaml"
require "date"
require "optparse"
require_relative "../src/generators/core/yaml_io"

ROOT = File.expand_path("..", __dir__)
ASSETS_PATH = File.join(ROOT, "_data", "video_assets.yml")
INTERVIEWS_PATH = File.join(ROOT, "_data", "interviews.yml")

TOPIC_RULES = [
  ["ruby-and-rails-practice", "ruby and rails practice", [/\b(ruby|rails|activerecord|rubinius|puma)\b/i]],
  ["web-development-and-frontend-practice", "web development and frontend practice", [/\b(web|frontend|html5|javascript|jquery|browser)\b/i]],
  ["security-and-application-risk", "security and application risk", [/\b(security|injection|sql|xss|vulnerability)\b/i]],
  ["conference-speaking-and-presentation-skills", "conference speaking and presentation skills", [/\b(conference|talk|speaker|keynote|presentation|panel)\b/i]],
  ["developer-tools-and-architecture", "developer tools and architecture", [/\b(architecture|tool|framework|library|performance)\b/i]],
  ["career-growth-and-technical-leadership", "career growth and technical leadership", [/\b(career|leadership|team|hiring|manager|culture)\b/i]],
  ["community-building-and-user-group-organizing", "community building and user-group organizing", [/\b(community|user\s*group|meetup|organizer|sponsor)\b/i]],
  ["software-craftsmanship-and-practice", "software craftsmanship and practice", [/\b(craftsmanship|agile|xp|quality|testing|refactoring)\b/i]],
  ["open-source-and-project-maintenance", "open source and project maintenance", [/\b(open\s*source|maintain|github|project)\b/i]],
  ["dotnet-and-altnet-practice", ".NET and alt.net practice", [/\b(\.net|dotnet|c#|f#|alt\.net)\b/i]]
].freeze

TAG_RULES = [
  ["ruby", /\bruby\b/i],
  ["rails", /\brails\b/i],
  ["javascript", /\bjavascript\b/i],
  ["web", /\bweb\b/i],
  ["html5", /\bhtml\s*5|html5\b/i],
  ["security", /\bsecurity|injection|xss|vulnerability\b/i],
  ["testing", /\btesting|tdd|bdd\b/i],
  ["architecture", /\barchitecture\b/i],
  ["performance", /\bperformance\b/i],
  ["community", /\bcommunity|user\s*group|meetup\b/i],
  ["conference", /\bconference|keynote|talk|speaker\b/i],
  ["open-source", /\bopen\s*source\b/i],
  ["dotnet", /\b(\.net|dotnet|c#|f#)\b/i],
  ["software-craftsmanship", /\bcraftsmanship\b/i],
  ["agile", /\bagile\b/i],
  ["xp", /\bxp\b/i]
].freeze

CONFERENCE_TOPIC_FALLBACK = {
  "RailsConf" => ["ruby-and-rails-practice", "ruby and rails practice"],
  "GOTO Conference" => ["developer-tools-and-architecture", "developer tools and architecture"],
  "SCNA" => ["software-craftsmanship-and-practice", "software craftsmanship and practice"],
  "WindyCityRails" => ["ruby-and-rails-practice", "ruby and rails practice"],
  "ChicagoWebConf" => ["web-development-and-frontend-practice", "web development and frontend practice"],
  "WebVisions" => ["web-development-and-frontend-practice", "web development and frontend practice"]
}.freeze

CONFERENCE_TAGS = {
  "RailsConf" => ["railsconf"],
  "GOTO Conference" => ["goto-conference"],
  "SCNA" => ["scna", "software-craftsmanship-north-america"],
  "WindyCityRails" => ["windy-city-rails"],
  "ChicagoWebConf" => ["chicago-web-conf"],
  "WebVisions" => ["webvisions"]
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

def platform_texts(asset)
  platforms = Array(asset["platforms"])
  titles = platforms.map { |p| normalize(p["title_on_platform"]) }.reject(&:empty?)
  descriptions = platforms.map { |p| normalize(p["description"]) }.reject(&:empty?)
  [titles, descriptions]
end

def best_platform_description(asset)
  _, descriptions = platform_texts(asset)
  descriptions.max_by(&:length)
end

def canonical_conference_label(value)
  conf = normalize(value)
  return "Software Craftsmanship North America" if conf == "SCNA"
  return "RailsConf" if conf == "RailsConf"
  return "GOTO Conference" if conf == "GOTO Conference"

  conf
end

def infer_topic(text_blob, conference, existing_topic)
  current = normalize(existing_topic)
  if !current.empty? && current.casecmp("general") != 0
    current_text = if current.match?(/\A[a-z0-9]+(?:-[a-z0-9]+)+\z/)
                     current.tr("-", " ")
                   else
                     current.downcase
                   end
    return [slugify(current), current_text]
  end

  best = nil
  best_score = 0
  TOPIC_RULES.each do |slug, text, patterns|
    score = patterns.sum { |pattern| text_blob.scan(pattern).length }
    next if score <= best_score

    best_score = score
    best = [slug, text]
  end

  return best if best

  fallback = CONFERENCE_TOPIC_FALLBACK[normalize(conference)]
  return fallback if fallback

  ["developer-community-and-conference-conversations", "developer community and conference conversations"]
end

def sanitize_interviewee_name(name)
  cleaned = normalize(name)
  return "" if cleaned.empty?

  cleaned = cleaned.sub(/\Ainterview with\s+/i, "")
  cleaned = cleaned.sub(/\s+@\s+.+\z/i, "")
  cleaned = cleaned.sub(/\s+-\s+.+\z/i, "")
  cleaned = cleaned.sub(/\s+\b(creator|founder|co-founder|keynote|speaker|author|organizer|team member|co-author)\b.*\z/i, "")

  # Prefer first words for likely person names when string is overloaded.
  if cleaned.split.size > 4
    tokens = cleaned.split
    cleaned = tokens.first(2).join(" ")
  end

  cleaned = cleaned.sub(/\s+\b(Ruby|Rails|JavaScript|HTML5|Web)\z/i, "")

  normalize(cleaned)
end

def extract_name_from_title(title)
  text = normalize(title)
  return "" if text.empty?

  text = text.sub(/\Ainterview with\s+/i, "")
  text = text.sub(/\Ainterview\s+/i, "")
  text = text.sub(/\s+@.+\z/i, "")
  text = text.sub(/\s+\b(at|on|from|for)\b.+\z/i, "")
  text = text.sub(/\s+\b(creator|founder|co-founder|keynote|speaker|author|organizer|team member|co-author)\b.*\z/i, "")
  text = text.gsub(/\s*&\s*.+\z/, "")
  text = text.gsub(/\s+and\s+.+\z/i, "")

  words = text.split
  return "" if words.empty?

  if words.length > 3
    words = words.first(2)
  end
  normalize(words.join(" "))
end

def best_interviewees(interview)
  names = Array(interview && interview["interviewees"]).map { |name| sanitize_interviewee_name(name) }.reject(&:empty?)
  names.reject! { |name| name.match?(/\A(rails|core|team|keynote|speaker|founder|creator|author)\b/i) }
  if names.empty?
    title_name = extract_name_from_title(interview && interview["title"])
    names << title_name unless title_name.empty?
  end
  if names.length > 1
    title_name = extract_name_from_title(interview && interview["title"])
    if !title_name.empty? && !names.include?(title_name)
      names = [title_name]
    end
  end
  names.uniq
end

def generate_title(asset, interview, interviewees)
  current = normalize(asset["title"])
  return current unless current.empty? || current.match?(/\Avimeo-\d+\z/i)

  if interviewees.any?
    conf = normalize(interview && interview["conference"])
    year = interview && interview["conference_year"]
    if !conf.empty? && year
      return "Interview with #{interviewees.join(' & ')} at #{canonical_conference_label(conf)} #{year}"
    end

    community = normalize(interview && interview["community"])
    if !community.empty? && community.casecmp("general") != 0
      return "Interview with #{interviewees.join(' & ')} from #{community}"
    end

    return "Interview with #{interviewees.join(' & ')}"
  end

  platform_title = Array(asset["platforms"]).map { |p| normalize(p["title_on_platform"]) }.find { |t| !t.empty? }
  return platform_title unless platform_title.to_s.empty?

  current.empty? ? asset["id"].to_s.tr("-", " ").split.map(&:capitalize).join(" ") : current
end

def generate_description(asset:, interview:, interviewees:, topic_text:, text_blob:)
  platform_desc = best_platform_description(asset)
  if platform_desc && platform_desc.length >= 80
    return platform_desc
  end

  names_text = interviewees.any? ? interviewees.join(" & ") : normalize(asset["title"])
  conference = normalize(interview && interview["conference"])
  conference_year = interview && interview["conference_year"]
  community = normalize(interview && interview["community"])

  context = if !conference.empty? && conference_year
              "at #{canonical_conference_label(conference)} #{conference_year}"
            elsif !community.empty? && community.casecmp("general") != 0
              "with the #{community} community"
            else
              ""
            end

  sentence = if interview.nil?
               "Talk: #{normalize(asset['title'])}"
             elsif names_text.empty?
               "This interview"
             else
               "Interview with #{names_text}"
             end

  sentence << " #{context}" unless context.empty?
  sentence << " on #{topic_text}."
  sentence << " This recording captures practical lessons and perspective for software teams and technical communities."

  normalize(sentence)
end

def derive_tags(asset:, interview:, interviewees:, topic_slug:, text_blob:)
  tags = Array(asset["tags"]).map { |tag| slugify(tag) }.reject(&:empty?)

  tags << "ugtastic" if normalize(asset["source"]).casecmp("ugtastic").zero? || normalize(interview && interview["interviewer"]).casecmp("Mike Hall").zero?
  tags << "interview" unless normalize(asset["interview_id"]).empty?

  tags.concat(interviewees.map { |name| slugify(name) })

  conference = normalize(interview && interview["conference"])
  conference_year = interview && interview["conference_year"]
  if !conference.empty?
    tags << "conference"
    tags.concat(CONFERENCE_TAGS.fetch(conference, [slugify(conference)]))
    tags << "#{slugify(conference)}-#{conference_year}" if conference_year
  end

  community = normalize(interview && interview["community"])
  if !community.empty? && community.casecmp("general") != 0
    tags << "community"
    tags << slugify(community)
  end

  TAG_RULES.each do |tag, pattern|
    tags << tag if text_blob.match?(pattern)
  end

  tags << topic_slug unless topic_slug.empty?

  banned = %w[keynote speaker team-member core team-member-keynote rails-core]
  tags
    .map { |tag| slugify(tag) }
    .reject(&:empty?)
    .reject { |tag| banned.include?(tag) }
    .uniq
    .first(14)
end

def description_missing_or_weak?(description, has_interview:)
  text = normalize(description)
  return true if text.empty?
  return true if text.length < 80
  return true if text.match?(/\b(interview with .+ rails core .+ keynote)\b/i)
  return true if text.match?(/\b(interview with .+ team member .+ speaker)\b/i)
  return true if text.match?(/\binterview with [a-z .'-]+ ruby at railsconf\b/i)
  return true if text.match?(/\bon [a-z0-9]+(?:-[a-z0-9]+){2,}\./i)
  return true if !has_interview && text.start_with?("Interview with ")

  false
end

options = { apply: false }
OptionParser.new do |parser|
  parser.banner = "Usage: ruby bin/enrich_non_transcript_metadata.rb [--apply]"
  parser.on("--apply", "Write changes to canonical data files") { options[:apply] = true }
end.parse!

assets_data = Generators::Core::YamlIo.load(ASSETS_PATH)
interviews_data = Generators::Core::YamlIo.load(INTERVIEWS_PATH)
assets = assets_data["items"] || []
interviews = interviews_data["items"] || []
interview_by_id = interviews.each_with_object({}) { |row, memo| memo[row["id"]] = row }

metrics = {
  scanned_non_transcript_assets: 0,
  assets_updated: 0,
  interviews_updated: 0,
  title_updates: 0,
  description_updates: 0,
  topic_updates: 0,
  tags_updates: 0,
  interview_topic_updates: 0
}

assets.each do |asset|
  next unless normalize(asset["transcript_id"]).empty?

  metrics[:scanned_non_transcript_assets] += 1
  interview = interview_by_id[normalize(asset["interview_id"])]

  titles, descriptions = platform_texts(asset)
  text_blob_parts = [asset["title"], asset["description"], descriptions.join(" "), titles.join(" ")]
  if interview
    text_blob_parts << interview["title"]
    text_blob_parts << interview["topic"]
    text_blob_parts << interview["conference"]
    text_blob_parts << interview["community"]
  end
  text_blob = normalize(text_blob_parts.compact.join(" "))

  topic_slug, topic_text = infer_topic(text_blob, interview && interview["conference"], asset["topic"] || (interview && interview["topic"]))
  interviewees = best_interviewees(interview)

  asset_changed = false
  interview_changed = false

  new_title = generate_title(asset, interview, interviewees)
  if normalize(new_title) != normalize(asset["title"])
    asset["title"] = new_title
    metrics[:title_updates] += 1
    asset_changed = true
  end

  if description_missing_or_weak?(asset["description"], has_interview: !interview.nil?)
    new_description = generate_description(
      asset: asset,
      interview: interview,
      interviewees: interviewees,
      topic_text: topic_text,
      text_blob: text_blob
    )
    if normalize(new_description) != normalize(asset["description"])
      asset["description"] = new_description
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
    asset: asset,
    interview: interview,
    interviewees: interviewees,
    topic_slug: topic_slug,
    text_blob: text_blob
  )
  if new_tags != Array(asset["tags"])
    asset["tags"] = new_tags
    metrics[:tags_updates] += 1
    asset_changed = true
  end

  if interview
    if normalize(interview["topic"]).empty?
      interview["topic"] = topic_text
      metrics[:interview_topic_updates] += 1
      interview_changed = true
    end

  end

  metrics[:assets_updated] += 1 if asset_changed
  metrics[:interviews_updated] += 1 if interview_changed
end

if options[:apply]
  Generators::Core::YamlIo.dump(ASSETS_PATH, assets_data)
  Generators::Core::YamlIo.dump(INTERVIEWS_PATH, interviews_data)
  puts "Applied non-transcript metadata enrichment."
else
  puts "Dry-run only. Re-run with --apply to persist changes."
end

metrics.each { |key, value| puts "#{key}=#{value}" }
