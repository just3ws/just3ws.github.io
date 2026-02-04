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
  next unless item['thumbnail']
  id = item['asset_id'].to_s
  local_rel = "/assets/vimeo/thumbs/ugtastic/#{id}.jpg"
  local_path = File.join(thumbnails_dir, "#{id}.jpg")

  if File.exist?(local_path)
    item['thumbnail_local'] = local_rel
    next
  end

  begin
    URI.open(item['thumbnail']) do |io|
      File.open(local_path, 'wb') { |f| f.write(io.read) }
    end
    item['thumbnail_local'] = local_rel
  rescue => e
    warn "Failed to download thumbnail for #{id}: #{e.message}"
  end
end

File.write(assets_path, { 'items' => assets }.to_yaml)

puts "Downloaded thumbnails to #{thumbnails_dir}"
