#!/usr/bin/env ruby
require 'yaml'
require 'date'
require 'open-uri'
require 'fileutils'

root = File.expand_path('..', __dir__)
assets_path = File.join(root, '_data', 'video_assets.yml')
thumbnails_dir = File.join(root, 'assets', 'vimeo', 'thumbs', 'ugtastic')
FileUtils.mkdir_p(thumbnails_dir)

assets = YAML.safe_load(File.read(assets_path), permitted_classes: [Time, Date], aliases: true)['items'] || []
items = assets.select { |a| a['source'] == 'ugtastic' }

items.each do |item|
  vimeo = (item['platforms'] || []).find { |p| p['platform'] == 'vimeo' } || (item['platforms'] || []).first
  next unless vimeo && vimeo['thumbnail']
  id = vimeo['asset_id'].to_s
  local_rel = "/assets/vimeo/thumbs/ugtastic/#{id}.jpg"
  local_path = File.join(thumbnails_dir, "#{id}.jpg")

  if File.exist?(local_path)
    vimeo['thumbnail_local'] = local_rel
    item['thumbnail_local'] = local_rel if item['thumbnail_local'].nil? || item['thumbnail_local'].empty?
    next
  end

  begin
    URI.open(vimeo['thumbnail']) do |io|
      File.open(local_path, 'wb') { |f| f.write(io.read) }
    end
    vimeo['thumbnail_local'] = local_rel
    item['thumbnail_local'] = local_rel if item['thumbnail_local'].nil? || item['thumbnail_local'].empty?
  rescue => e
    warn "Failed to download thumbnail for #{id}: #{e.message}"
  end
end

File.write(assets_path, { 'items' => assets }.to_yaml)

puts "Downloaded thumbnails to #{thumbnails_dir}"
