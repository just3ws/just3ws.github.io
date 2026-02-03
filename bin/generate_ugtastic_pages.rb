#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'
require 'date'

root = File.expand_path('..', __dir__)
data_path = File.join(root, '_data', 'ugtastic.yml')
conf_path = File.join(root, '_data', 'ugtastic_conferences.yml')

ugtastic = YAML.safe_load(File.read(data_path), permitted_classes: [Time, Date], aliases: true)
confs = YAML.safe_load(File.read(conf_path), permitted_classes: [Date], aliases: true)['conferences']
conf_map = confs.each_with_object({}) { |c, h| h[c['slug']] = c }

base_dir = File.join(root, 'ugtastic', 'videos')
FileUtils.mkdir_p(base_dir)

ugtastic['items'].each do |item|
  id = item['id'].to_s
  title = item['title'] || 'UGtastic Interview'
  topic = item['topic'] || title
  conf = item['conference'] ? conf_map[item['conference']] : nil
  prefix = conf ? conf['name'] : (item['community'] || nil)
  parent_name = nil
  parent_url = nil
  if conf
    parent_name = conf['name']
    parent_url = "/ugtastic/conferences/#{conf['slug']}/"
  elsif item['community']
    parent_name = item['community']
    parent_url = "/ugtastic/communities/#{item['community_slug'] || item['community'].downcase.gsub(/[^a-z0-9]+/, '-').gsub(/(^-|-$)/, '')}/"
  end
  display_title = prefix ? "#{prefix} / #{title}" : title

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
    f.puts "  {% assign item = site.data.ugtastic.items | where: \"id\", \"#{id}\" | first %}"
    f.puts "  <header>"
    f.puts "    <h1>{{ item.topic | default: item.title }}</h1>"
    f.puts "  </header>"
    f.puts ""
    f.puts "  {% if item %}"
    f.puts "    <div class=\"video video-detail\">"
    f.puts "      {% assign thumb = item.thumbnail_local | default: item.thumbnail %}"
    f.puts "      {% assign embed = item.embed_url | default: 'https://player.vimeo.com/video/' | append: item.id %}"
    f.puts "      {% if embed %}"
    f.puts "        <div class=\"video-embed\">"
    f.puts "          <iframe src=\"{{ embed }}\" width=\"640\" height=\"360\" frameborder=\"0\" allow=\"autoplay; fullscreen; picture-in-picture; clipboard-write; encrypted-media; web-share\" referrerpolicy=\"strict-origin-when-cross-origin\" title=\"{{ item.title }}\"></iframe>"
    f.puts "        </div>"
    f.puts "      {% endif %}"
    f.puts "      <div class=\"video-body\">"
    f.puts "        <div class=\"video-title\">{{ item.topic | default: item.title }}</div>"
    f.puts "        {% if item.interviewees and item.interviewees.size > 0 %}"
    f.puts "          <div class=\\\"video-subtitle\\\">{% if item.interviewees.size == 1 %}Interviewee{% else %}Interviewees{% endif %}: {{ item.interviewees | join: ', ' }}</div>"
    f.puts "        {% endif %}"
    f.puts "        <div class=\"video-meta\">{% if item.duration_minutes %}Duration: {{ item.duration_minutes | round }} min · {% endif %}Uploaded: {{ item.created | date: \"%b %d, %Y\" }}</div>"
    f.puts "        <div class=\"video-meta\">"
    f.puts "          {% if item.conference %}"
    f.puts "            {% assign conf = site.data.ugtastic_conferences.conferences | where: \"slug\", item.conference | first %}"
    f.puts "            {% if conf %}<a href=\"/ugtastic/conferences/{{ conf.slug }}/\">{{ conf.name }}</a>{% endif %}"
    f.puts "          {% elsif item.community %}"
    f.puts "            {% assign comm = site.data.ugtastic_communities.communities | where: \"slug\", item.community | first %}"
    f.puts "            {% if comm %}<a href=\"/ugtastic/communities/{{ comm.slug }}/\">{{ comm.name }}</a>{% endif %}"
    f.puts "          {% endif %}"
    f.puts "          {% if item.interviewers and item.interviewers.size > 0 %}"
    f.puts "            {% if item.conference or item.community %} · {% endif %}"
    f.puts "            {% if item.interviewers.size == 1 %}Interviewer{% else %}Interviewers{% endif %}: {{ item.interviewers | join: ', ' }}"
    f.puts "          {% endif %}"
    f.puts "          {% if item.interviewees and item.interviewees.size > 0 %}"
    f.puts "            · {% if item.interviewees.size == 1 %}Interviewee{% else %}Interviewees{% endif %}: {{ item.interviewees | join: ', ' }}"
    f.puts "          {% endif %}"
    f.puts "        </div>"
    f.puts "        <div class=\"video-actions\"><a class=\"video-button\" href=\"{{ item.link }}\">Watch on Vimeo</a></div>"
    f.puts "        {% if item.tags and item.tags.size > 0 %}"
    f.puts "          <div class=\"video-tags\">"
    f.puts "            {% for tag in item.tags %}<span class=\"tag\">{{ tag }}</span>{% endfor %}"
    f.puts "          </div>"
    f.puts "        {% endif %}"
    f.puts "        {% if item.description %}"
    f.puts "          <div class=\"video-description\"><span class=\"video-description-label\">Vimeo description:</span> {{ item.description }}</div>"
    f.puts "        {% endif %}"
    f.puts "      </div>"
    f.puts "    </div>"
    f.puts "  {% endif %}"
    f.puts ""
    f.puts "  <section class=\\\"transcript\\\">"
    f.puts "    <h2>Transcript</h2>"
    f.puts "    {% if item.transcript %}"
    f.puts "      <div class=\\\"video-transcript\\\">{{ item.transcript }}</div>"
    f.puts "    {% else %}"
    f.puts "      <p>Transcript coming soon.</p>"
    f.puts "    {% endif %}"
    f.puts "  </section>"
    f.puts "</article>"
  end
end

puts "Generated #{ugtastic['items'].size} video pages in #{base_dir}"
