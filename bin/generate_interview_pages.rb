#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'
require 'date'

root = File.expand_path('..', __dir__)
interviews_path = File.join(root, '_data', 'interviews.yml')
assets_path = File.join(root, '_data', 'video_assets.yml')

interviews = YAML.safe_load(File.read(interviews_path), permitted_classes: [Date, Time], aliases: true)['items'] || []
assets = YAML.safe_load(File.read(assets_path), permitted_classes: [Date, Time], aliases: true)['items'] || []
assets_by_interview = assets.group_by { |a| a['interview_id'] }

base_dir = File.join(root, 'interviews')
FileUtils.mkdir_p(base_dir)

interviews.each do |interview|
  id = interview['id']
  dir = File.join(base_dir, id)
  FileUtils.mkdir_p(dir)
  path = File.join(dir, 'index.html')

  File.open(path, 'w') do |f|
    f.puts '---'
    f.puts 'layout: minimal'
    f.puts "title: Interview — #{interview['title']}"
    f.puts "description: Interview with #{interview['title']}."
    f.puts "breadcrumb: #{interview['title']}"
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
    f.puts "    {% assign assets = site.data.video_assets.items | where: \"interview_id\", \"#{id}\" %}"
    f.puts '    {% assign vimeo = assets | where: "platform", "vimeo" | first %}'
    f.puts '    {% assign youtube = assets | where: "platform", "youtube" | first %}'
    f.puts '    {% assign preferred = vimeo | default: youtube %}'
    f.puts ''
    f.puts '    {% if preferred %}'
    f.puts '      <div class="video video-detail">'
    f.puts '        <div class="video-embed">'
    f.puts '          <iframe id="interview-embed" src="{{ preferred.embed_url }}" width="640" height="360" frameborder="0" allow="autoplay; fullscreen; picture-in-picture; clipboard-write; encrypted-media; web-share" referrerpolicy="strict-origin-when-cross-origin" title="{{ interview.title }}"></iframe>'
    f.puts '        </div>'
    f.puts '        <div class="video-actions">'
    f.puts '          {% if vimeo %}<button class="video-button{% if preferred and preferred.platform == \'vimeo\' %} primary{% endif %}" data-embed="{{ vimeo.embed_url }}">Watch Here (Vimeo)</button>{% endif %}'
    f.puts '          {% if youtube %}<button class="video-button{% if preferred and preferred.platform == \'youtube\' %} primary{% endif %}" data-embed="{{ youtube.embed_url }}">Watch Here (YouTube)</button>{% endif %}'
    f.puts '        </div>'
    f.puts '        <div class="video-actions">'
    f.puts '          {% if vimeo %}<a class="video-button" href="{{ vimeo.url }}">View on Vimeo</a>{% endif %}'
    f.puts '          {% if youtube %}<a class="video-button" href="{{ youtube.url }}">View on YouTube</a>{% endif %}'
    f.puts '        </div>'
    f.puts '      </div>'
    f.puts '    {% endif %}'
    f.puts ''
    f.puts '    {% if assets.size > 0 %}'
    f.puts '      <section>'
    f.puts '        <h2>Published Assets</h2>'
    f.puts '        <ul>'
    f.puts '          {% for asset in assets %}'
    f.puts '            <li>{{ asset.platform | capitalize }}: <a href="{{ asset.url }}">{{ asset.title_on_platform }}</a></li>'
    f.puts '          {% endfor %}'
    f.puts '        </ul>'
    f.puts '      </section>'
    f.puts '    {% endif %}'
    f.puts ''
    f.puts '    <section class="transcript">'
    f.puts '      <h2>Transcript</h2>'
    f.puts '      {% assign transcript = nil %}'
    f.puts '      {% if preferred and preferred.transcript %}{% assign transcript = preferred.transcript %}{% endif %}'
    f.puts '      {% if transcript == nil and preferred %}'
    f.puts '        {% assign transcript_entry = site.data.transcripts.items | where: "video_asset_id", preferred.asset_id | first %}'
    f.puts '        {% if transcript_entry %}{% assign transcript = transcript_entry.content %}{% endif %}'
    f.puts '      {% endif %}'
    f.puts '      {% if transcript %}'
    f.puts '        <div class="video-transcript">{{ transcript }}</div>'
    f.puts '      {% else %}'
    f.puts '        <p>Transcript coming soon.</p>'
    f.puts '      {% endif %}'
    f.puts '    </section>'
    f.puts ''
    f.puts '    <script>'
    f.puts '      (function() {' 
    f.puts '        var embed = document.getElementById(\"interview-embed\");'
    f.puts '        if (!embed) return;'
    f.puts '        var buttons = document.querySelectorAll(\"[data-embed]\");'
    f.puts '        buttons.forEach(function(btn) {'
    f.puts '          btn.addEventListener(\"click\", function() {'
    f.puts '            embed.setAttribute(\"src\", btn.getAttribute(\"data-embed\"));'
    f.puts '          });'
    f.puts '        });'
    f.puts '      })();'
    f.puts '    </script>'
    f.puts '  {% endif %}'
    f.puts '</article>'
  end
end

puts "Generated #{interviews.size} interview pages in #{base_dir}"
