#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'
require 'date'

root = File.expand_path('..', __dir__)
assets_path = File.join(root, '_data', 'video_assets.yml')
interviews_path = File.join(root, '_data', 'interviews.yml')
conf_path = File.join(root, '_data', 'interview_conferences.yml')
comm_path = File.join(root, '_data', 'interview_communities.yml')

assets = YAML.safe_load(File.read(assets_path), permitted_classes: [Time, Date], aliases: true)['items'] || []
interviews = YAML.safe_load(File.read(interviews_path), permitted_classes: [Time, Date], aliases: true)['items'] || []
confs = YAML.safe_load(File.read(conf_path), permitted_classes: [Date], aliases: true)['conferences']
comms = YAML.safe_load(File.read(comm_path), permitted_classes: [Date], aliases: true)['communities']
conf_by_name = confs.each_with_object({}) { |c, h| h[c['name']] = c }
comm_by_name = comms.each_with_object({}) { |c, h| h[c['name']] = c }
interview_index = interviews.each_with_object({}) { |i, h| h[i['id']] = i }

base_dir = File.join(root, 'ugtastic', 'videos')
FileUtils.mkdir_p(base_dir)

ugtastic_assets = assets.select { |a| a['source'] == 'ugtastic' }

ugtastic_assets.each do |asset|
  id = asset['asset_id'].to_s
  interview = interview_index[asset['interview_id']]
  title = interview && interview['title'] ? interview['title'] : asset['title_on_platform'] || 'UGtastic Interview'
  topic = title
  conf = interview && interview['conference'] ? conf_by_name[interview['conference']] : nil
  comm = interview && interview['community'] ? comm_by_name[interview['community']] : nil
  parent_name = nil
  parent_url = nil
  if conf
    parent_name = conf['name']
    parent_url = "/ugtastic/conferences/#{conf['slug']}/"
  elsif comm
    parent_name = comm['name']
    parent_url = "/ugtastic/communities/#{comm['slug']}/"
  end
  display_title = title

  dir = File.join(base_dir, id)
  FileUtils.mkdir_p(dir)
  path = File.join(dir, 'index.html')

  File.open(path, 'w') do |f|
    f.puts "---"
    f.puts "layout: minimal"
    f.puts "title: UGtastic — #{display_title}"
    f.puts "description: UGtastic interview with #{title}."
    f.puts "breadcrumb: #{topic}"
    f.puts "breadcrumb_parent_name: #{parent_name}" if parent_name
    f.puts "breadcrumb_parent_url: #{parent_url}" if parent_url
    f.puts "---"
    f.puts ""
    f.puts "<article class=\"page\">"
    f.puts "  {% include breadcrumbs.html %}"
    f.puts "  {% assign asset = site.data.video_assets.items | where: \"source\", \"ugtastic\" | where: \"asset_id\", \"#{id}\" | first %}"
    f.puts "  {% assign interview = asset and site.data.interviews.items | where: \"id\", asset.interview_id | first %}"
    f.puts "  {% assign assets = interview and site.data.video_assets.items | where: \"interview_id\", interview.id %}"
    f.puts "  {% assign vimeo = assets | where: \"platform\", \"vimeo\" | first %}"
    f.puts "  {% assign youtube = assets | where: \"platform\", \"youtube\" | first %}"
    f.puts "  {% assign preferred = vimeo | default: youtube %}"
    f.puts "  <header>"
    f.puts "    <h1>{{ interview.title | default: asset.title_on_platform }}</h1>"
    f.puts "  </header>"
    f.puts ""
    f.puts "  {% if preferred %}"
    f.puts "    <div class=\"video video-detail\">"
    f.puts "      {% if preferred.embed_url %}"
    f.puts "        <div class=\"video-embed\">"
    f.puts "          <iframe id=\"interview-embed\" src=\"{{ preferred.embed_url }}\" width=\"640\" height=\"360\" frameborder=\"0\" allow=\"autoplay; fullscreen; picture-in-picture; clipboard-write; encrypted-media; web-share\" referrerpolicy=\"strict-origin-when-cross-origin\" title=\"{{ preferred.title_on_platform }}\"></iframe>"
    f.puts "        </div>"
    f.puts "      {% endif %}"
    f.puts "      <div class=\"video-body\">"
    f.puts "        <div class=\"video-title\">{{ interview.title | default: preferred.title_on_platform }}</div>"
    f.puts "        {% if interview and interview.interviewees and interview.interviewees.size > 0 %}"
    f.puts '          <div class="video-subtitle">{% if interview.interviewees.size == 1 %}Interviewee{% else %}Interviewees{% endif %}: {{ interview.interviewees | join: ", " }}</div>'
    f.puts "        {% endif %}"
    f.puts "        <div class=\"video-meta\">{% if preferred.duration_minutes %}Duration: {{ preferred.duration_minutes | round }} min · {% endif %}Uploaded: {{ preferred.published_date | date: \"%b %d, %Y\" }}</div>"
    f.puts "        <div class=\"video-meta\">"
    f.puts "          {% if interview and interview.conference %}"
    f.puts "            {% assign conf = site.data.interview_conferences.conferences | where: \"name\", interview.conference | first %}"
    f.puts "            {% if conf %}<a href=\"/ugtastic/conferences/{{ conf.slug }}/\">{{ conf.name }}</a>{% endif %}"
    f.puts "          {% elsif interview and interview.community %}"
    f.puts "            {% assign comm = site.data.interview_communities.communities | where: \"name\", interview.community | first %}"
    f.puts "            {% if comm %}<a href=\"/ugtastic/communities/{{ comm.slug }}/\">{{ comm.name }}</a>{% endif %}"
    f.puts "          {% endif %}"
    f.puts "          {% if interview and interview.interviewer %}"
    f.puts "            {% if interview.conference or interview.community %} · {% endif %}"
    f.puts "            Interviewer: <a href=\"/home/\">{{ interview.interviewer }}</a>"
    f.puts "          {% endif %}"
    f.puts "          {% if interview and interview.interviewees and interview.interviewees.size > 0 %}"
    f.puts "            · {% if interview.interviewees.size == 1 %}Interviewee{% else %}Interviewees{% endif %}: {{ interview.interviewees | join: ', ' }}"
    f.puts "          {% endif %}"
    f.puts "        </div>"
    f.puts "        <div class=\"video-actions\">"
    f.puts "          {% if vimeo %}<button class=\"video-button{% if preferred and preferred.platform == 'vimeo' %} primary{% endif %}\" data-embed=\"{{ vimeo.embed_url }}\">Watch Here (Vimeo)</button>{% endif %}"
    f.puts "          {% if youtube %}<button class=\"video-button{% if preferred and preferred.platform == 'youtube' %} primary{% endif %}\" data-embed=\"{{ youtube.embed_url }}\">Watch Here (YouTube)</button>{% endif %}"
    f.puts "        </div>"
    f.puts "        <div class=\"video-actions\">"
    f.puts "          {% if vimeo %}<a class=\"video-button\" href=\"{{ vimeo.url }}\">Watch on Vimeo</a>{% endif %}"
    f.puts "          {% if youtube %}<a class=\"video-button\" href=\"{{ youtube.url }}\">Watch on YouTube</a>{% endif %}"
    f.puts "        </div>"
    f.puts "        {% if preferred.tags and preferred.tags.size > 0 %}"
    f.puts "          <div class=\"video-tags\">"
    f.puts "            {% for tag in preferred.tags %}<span class=\"tag\">{{ tag }}</span>{% endfor %}"
    f.puts "          </div>"
    f.puts "        {% endif %}"
    f.puts "        {% if preferred.description %}"
    f.puts "          <div class=\"video-description\"><span class=\"video-description-label\">Video description:</span> {{ preferred.description }}</div>"
    f.puts "        {% endif %}"
    f.puts "      </div>"
    f.puts "    </div>"
    f.puts "  {% endif %}"
    f.puts ""
    f.puts "  <script>"
    f.puts "    (function() {"
    f.puts "      var embed = document.getElementById(\"interview-embed\");"
    f.puts "      if (!embed) return;"
    f.puts "      var buttons = document.querySelectorAll(\"[data-embed]\");"
    f.puts "      buttons.forEach(function(btn) {"
    f.puts "        btn.addEventListener(\"click\", function() {"
    f.puts "          embed.setAttribute(\"src\", btn.getAttribute(\"data-embed\"));"
    f.puts "        });"
    f.puts "      });"
    f.puts "    })();"
    f.puts "  </script>"
    f.puts ""
    f.puts '  <section class="transcript">'
    f.puts "    <h2>Transcript</h2>"
    f.puts "    {% assign transcript = asset.transcript %}"
    f.puts "    {% if transcript == nil %}"
    f.puts "      {% assign transcript_entry = site.data.transcripts.items | where: \"video_asset_id\", asset.asset_id | first %}"
    f.puts "      {% if transcript_entry %}{% assign transcript = transcript_entry.content %}{% endif %}"
    f.puts "    {% endif %}"
    f.puts "    {% if transcript %}"
    f.puts '      <div class="video-transcript">{{ transcript }}</div>'
    f.puts "    {% else %}"
    f.puts "      <p>Transcript coming soon.</p>"
    f.puts "    {% endif %}"
    f.puts "  </section>"
    f.puts "</article>"
  end
end

puts "Generated #{ugtastic_assets.size} video pages in #{base_dir}"
