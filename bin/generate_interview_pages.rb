#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'
require 'date'

root = File.expand_path('..', __dir__)
interviews_path = File.join(root, '_data', 'interviews.yml')
assets_path = File.join(root, '_data', 'video_assets.yml')

interviews = YAML.safe_load(File.read(interviews_path), permitted_classes: [Date, Time], aliases: true)['items'] || []
assets = YAML.safe_load(File.read(assets_path), permitted_classes: [Date, Time], aliases: true)['items'] || []
assets_by_id = assets.each_with_object({}) { |a, h| h[a['id']] = a }

def yaml_quote(value)
  str = value.to_s.tr("\n", ' ')
  "\"#{str.gsub('"', '\"')}\""
end

def normalize_interview_subject(value)
  value.to_s.strip
       .sub(/\AInterview with\s+/i, '')
       .sub(/\AInterview\s*[-:]\s+/i, '')
       .gsub(/\s+/, ' ')
       .strip
end

def clamp_meta(text, max_length)
  clean = text.to_s.gsub(/\s+/, ' ').strip
  return clean if clean.length <= max_length

  truncated = clean[0, max_length - 1]
  truncated = truncated.rpartition(' ').first if truncated.include?(' ')
  truncated = clean[0, max_length - 1] if truncated.nil? || truncated.empty?
  "#{truncated}…"
end

def ensure_unique_meta(value, max_length, disambiguator, seen)
  candidate = value
  unless seen[candidate]
    seen[candidate] = true
    return candidate
  end

  suffix = " (#{disambiguator})"
  base_limit = max_length - suffix.length
  base = clamp_meta(value, base_limit)
  base = base.gsub(/…\z/, '').strip
  candidate = "#{base}#{suffix}"
  candidate = clamp_meta(candidate, max_length)

  if seen[candidate]
    fallback = clamp_meta("#{value} #{disambiguator}", max_length)
    candidate = fallback
  end

  seen[candidate] = true
  candidate
end

base_dir = File.join(root, 'interviews')
FileUtils.mkdir_p(base_dir)
seen_titles = {}
seen_descriptions = {}

interviews.each do |interview|
  id = interview['id']
  subject = normalize_interview_subject(interview['title'])
  context_bits = []
  context_bits << interview['conference'].to_s.strip if interview['conference'].to_s.strip != ''
  context_bits << interview['community'].to_s.strip if interview['community'].to_s.strip != ''
  context = context_bits.first(2).join(' · ')

  title_core = +"Interview — #{subject}"
  title_core << " (#{context})" unless context.empty?
  title_meta = clamp_meta(title_core, 70)

  description_parts = []
  description_parts << "Interview with #{subject}"
  topic = interview['topic'].to_s.strip
  description_parts << "Topic: #{topic}" unless topic.empty?

  conference = interview['conference'].to_s.strip
  conference_year = interview['conference_year'].to_s.strip
  unless conference.empty?
    conf_text = conference.dup
    conf_text << " #{conference_year}" unless conference_year.empty?
    description_parts << "Conference: #{conf_text}"
  end

  community = interview['community'].to_s.strip
  description_parts << "Community: #{community}" unless community.empty?

  recorded_date = interview['recorded_date'].to_s.strip
  description_parts << "Recorded: #{recorded_date}" unless recorded_date.empty?

  description_parts << "Interview ID: #{id}"
  description_meta = clamp_meta("#{description_parts.join('. ')}.", 160)
  title_meta = ensure_unique_meta(title_meta, 70, id, seen_titles)
  description_meta = ensure_unique_meta(description_meta, 160, id, seen_descriptions)
  dir = File.join(base_dir, id)
  FileUtils.mkdir_p(dir)
  path = File.join(dir, 'index.html')

  File.open(path, 'w') do |f|
    f.puts '---'
    f.puts 'layout: minimal'
    f.puts "title: #{yaml_quote(title_meta)}"
    f.puts "description: #{yaml_quote(description_meta)}"
    f.puts "breadcrumb: #{yaml_quote(interview['title'])}"
    f.puts 'breadcrumb_parent_name: Interviews'
    f.puts 'breadcrumb_parent_url: /interviews/'
    f.puts '---'
    f.puts ''
    f.puts '<article class="page">'
    f.puts '  {% include breadcrumbs.html %}'
    f.puts "  {% assign interview = site.data.interviews.items | where: \"id\", \"#{id}\" | first %}"
    f.puts '  {% if interview %}'
    f.puts '    <header>'
    f.puts '      <h1>{{ interview.title }}</h1>'
    f.puts '    </header>'
    f.puts '    {% if interview.interviewees and interview.interviewees.size > 0 %}'
    f.puts '      <div class="video-subtitle">Interviewee{% if interview.interviewees.size > 1 %}s{% endif %}: {{ interview.interviewees | join: ", " }}</div>'
    f.puts '    {% endif %}'
    f.puts '    {% if interview.topic %}'
    f.puts '      <div class="video-subtitle">Topic: {{ interview.topic }}</div>'
    f.puts '    {% endif %}'
    f.puts '    <div class="video-meta">'
    f.puts '      {% if interview.conference %}Conference: {{ interview.conference }}{% if interview.conference_year %} {{ interview.conference_year }}{% endif %}{% endif %}'
    f.puts '      {% if interview.community %}{% if interview.conference %} · {% endif %}Community: {{ interview.community }}{% endif %}'
    f.puts '    </div>'
    f.puts ''
    f.puts "    {% assign asset = site.data.video_assets.items | where: \"id\", interview.video_asset_id | first %}"
    f.puts "    {% include video-asset-player.html asset=asset embed_id=\"interview-embed\" %}"
    f.puts '  {% endif %}'
    f.puts '</article>'
  end
end

puts "Generated #{interviews.size} interview pages in #{base_dir}"
