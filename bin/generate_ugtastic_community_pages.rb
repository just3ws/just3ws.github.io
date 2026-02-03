#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'
require 'date'

root = File.expand_path('..', __dir__)
communities_path = File.join(root, '_data', 'ugtastic_communities.yml')

communities = YAML.safe_load(File.read(communities_path), permitted_classes: [Date], aliases: true)['communities']

base_dir = File.join(root, 'ugtastic', 'communities')
FileUtils.mkdir_p(base_dir)

communities.each do |comm|
  slug = comm['slug']
  name = comm['name']
  desc = comm['description']
  dir = File.join(base_dir, slug)
  FileUtils.mkdir_p(dir)
  path = File.join(dir, 'index.html')

  File.open(path, 'w') do |f|
    f.puts '---'
    f.puts 'layout: minimal'
    f.puts "title: UGtastic — #{name}"
    f.puts "description: UGtastic community interviews from #{name}."
    f.puts "community: #{slug}"
    f.puts "breadcrumb: #{name}"
    f.puts '---'
    f.puts ''
    f.puts '<article class="page">'
    f.puts '  {% include breadcrumbs.html %}'
    f.puts "  <header>"
    f.puts "    <h1>#{name}</h1>"
    f.puts "    <p>#{desc}</p>"
    f.puts '  </header>'
    f.puts ''
    f.puts '  {% assign items = site.data.ugtastic.items | where: "community", page.community %}'
    f.puts '  {% for item in items %}'
    f.puts '    {% include video-card.html item=item %}'
    f.puts '  {% endfor %}'
    f.puts '</article>'
  end
end

puts "Generated #{communities.size} community pages in #{base_dir}"
