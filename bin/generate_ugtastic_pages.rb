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
  conf = item['conference'] ? conf_map[item['conference']] : nil
  prefix = conf ? conf['name'] : (item['community'] || nil)
  display_title = prefix ? "#{prefix} / #{title}" : title

  dir = File.join(base_dir, id)
  FileUtils.mkdir_p(dir)
  path = File.join(dir, 'index.html')

  File.open(path, 'w') do |f|
    f.puts "---"
    f.puts "layout: minimal"
    f.puts "title: UGtastic — #{display_title}"
    f.puts "description: UGtastic interview with #{title}."
    f.puts "breadcrumb: #{display_title}"
    f.puts "---"
    f.puts ""
    f.puts "<article class=\"page\">"
    f.puts "  {% include breadcrumbs.html %}"
    f.puts "  <header>"
    f.puts "    <h1>#{display_title}</h1>"
    f.puts "  </header>"
    f.puts ""
    f.puts "  {% assign item = site.data.ugtastic.items | where: \"id\", \"#{id}\" | first %}"
    f.puts "  {% if item %}"
    f.puts "    <div class=\"video\">"
    f.puts "      {% if item.thumbnail %}"
    f.puts "        <a class=\"video-thumb\" href=\"{{ item.link }}\">"
    f.puts "          <img src=\"{{ item.thumbnail }}\" alt=\"Thumbnail for {{ item.title }}\">"
    f.puts "        </a>"
    f.puts "      {% endif %}"
    f.puts "      <div class=\"video-body\">"
    f.puts "        <div class=\"video-title\"><a href=\"{{ item.link }}\">{{ item.title }}</a></div>"
    f.puts "        <div class=\"video-meta\">{% if item.duration_minutes %}Duration: {{ item.duration_minutes | round }} min · {% endif %}Uploaded: {{ item.created | date: \"%b %d, %Y\" }}</div>"
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
    f.puts "  <section class=\"transcript\">"
    f.puts "    <h2>Transcript</h2>"
    f.puts "    <p>Transcript coming soon.</p>"
    f.puts "  </section>"
    f.puts "</article>"
  end
end

puts "Generated #{ugtastic['items'].size} video pages in #{base_dir}"
