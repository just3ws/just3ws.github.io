#!/usr/bin/env ruby
require 'fileutils'
require_relative '../src/generators/core/meta'
require_relative '../src/generators/core/text'
require_relative '../src/generators/core/yaml_io'

root = File.expand_path('..', __dir__)
interviews_path = File.join(root, '_data', 'interviews.yml')

interviews = Generators::Core::YamlIo.load(interviews_path, key: 'items')

base_dir = File.join(root, 'interviews')
FileUtils.mkdir_p(base_dir)
seen_titles = {}
seen_descriptions = {}

interviews.each do |interview|
  id = interview['id']
  subject = Generators::Core::Text.normalize_subject(interview['title'])
  context_bits = []
  context_bits << interview['conference'].to_s.strip if interview['conference'].to_s.strip != ''
  context_bits << interview['community'].to_s.strip if interview['community'].to_s.strip != ''
  context = context_bits.first(2).join(' · ')

  title_core = +"Interview Archive — #{subject}"
  title_core << " (#{context})" unless context.empty?
  title_meta = Generators::Core::Meta.clamp(title_core, 70)

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
  description_meta = Generators::Core::Meta.clamp("#{description_parts.join('. ')}.", 160)
  description_meta = Generators::Core::Meta.ensure_min_length(
    description_meta,
    70,
    "Part of Mike Hall's software engineering interview archive."
  )
  description_meta = Generators::Core::Meta.clamp(description_meta, 160)
  title_meta = Generators::Core::Meta.ensure_unique(title_meta, 70, id, seen_titles)
  description_meta = Generators::Core::Meta.ensure_unique(description_meta, 160, id, seen_descriptions)
  dir = File.join(base_dir, id)
  FileUtils.mkdir_p(dir)
  path = File.join(dir, 'index.html')

  File.open(path, 'w') do |f|
    f.puts '---'
    f.puts 'layout: minimal'
    f.puts "title: #{Generators::Core::Text.yaml_quote(title_meta)}"
    f.puts "description: #{Generators::Core::Text.yaml_quote(description_meta)}"
    f.puts "breadcrumb: #{Generators::Core::Text.yaml_quote(interview['title'])}"
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
    f.puts '      {% if interview.conference %}'
    f.puts '        Conference:'
    f.puts '        {% assign conference_candidates = site.data.interview_conferences.conferences | where: "conference", interview.conference %}'
    f.puts '        {% assign conference_entry = conference_candidates | where: "year", interview.conference_year | first %}'
    f.puts '        {% if conference_entry %}'
    f.puts '          <a href="/interviews/conferences/{{ conference_entry.slug }}/">{{ interview.conference }}{% if interview.conference_year %} {{ interview.conference_year }}{% endif %}</a>'
    f.puts '        {% else %}'
    f.puts '          {{ interview.conference }}{% if interview.conference_year %} {{ interview.conference_year }}{% endif %}'
    f.puts '        {% endif %}'
    f.puts '      {% endif %}'
    f.puts '      {% if interview.community %}{% if interview.conference %} · {% endif %}Community: {{ interview.community }}{% endif %}'
    f.puts '    </div>'
    f.puts ''
    f.puts '    {% assign related_entry = site.data.interview_related_videos.items | where: "interview_id", interview.id | first %}'
    f.puts '    {% assign conference_related = site.data.interview_related_videos.conference_playlists | where: "conference", interview.conference | where: "conference_year", interview.conference_year %}'
    f.puts '    {% if (related_entry and related_entry.links and related_entry.links.size > 0) or (conference_related and conference_related.size > 0) %}'
    f.puts '      <section class="related-content">'
    f.puts '        <h2>Related Conference Videos</h2>'
    f.puts '        {% if related_entry and related_entry.links and related_entry.links.size > 0 %}'
    f.puts '          {% for link in related_entry.links %}'
    f.puts '            <div class="video-meta">Related: <a href="{{ link.url }}">{{ link.label }}</a>{% if link.kind %} · Type: {{ link.kind }}{% endif %}</div>'
    f.puts '            {% if link.embed_url %}'
    f.puts '              <div class="video-embed">'
    f.puts '                <iframe src="{{ link.embed_url }}" width="640" height="360" frameborder="0" allow="autoplay; fullscreen; picture-in-picture; clipboard-write; encrypted-media; web-share" referrerpolicy="strict-origin-when-cross-origin" title="{{ link.label }}"></iframe>'
    f.puts '              </div>'
    f.puts '            {% endif %}'
    f.puts '          {% endfor %}'
    f.puts '        {% endif %}'
    f.puts '        {% if conference_related and conference_related.size > 0 %}'
    f.puts '          {% for group in conference_related %}'
    f.puts '            {% for link in group.links %}'
    f.puts '              <div class="video-meta">Official playlist: <a href="{{ link.url }}">{{ link.label }}</a>{% if link.kind %} · Type: {{ link.kind }}{% endif %}</div>'
    f.puts '            {% endfor %}'
    f.puts '          {% endfor %}'
    f.puts '        {% endif %}'
    f.puts '      </section>'
    f.puts '    {% endif %}'
    f.puts ''
    f.puts "    {% assign asset = site.data.video_assets.items | where: \"id\", interview.video_asset_id | first %}"
    f.puts "    {% include json-ld-interview.html interview=interview asset=asset %}"
    f.puts "    {% include video-asset-player.html asset=asset embed_id=\"interview-embed\" %}"
    f.puts '  {% endif %}'
    f.puts '</article>'
  end
end

puts "Generated #{interviews.size} interview pages in #{base_dir}"
