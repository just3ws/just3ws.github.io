#!/usr/bin/env ruby
# frozen_string_literal: true

# ---
# name: generate_legacy_route_map.rb
# domain: data
# purpose: Compiles declarative legacy routes, interviews, interviewees, and post mappings into assets/data/legacy_route_map.json
# usage: ruby bin/generate_legacy_route_map.rb
# ---

require 'yaml'
require 'json'
require 'fileutils'
require 'date'
require 'uri'

ROOT = File.expand_path('..', __dir__)
LEGACY_ROUTES_PATH = File.join(ROOT, '_data', 'legacy_routes.yml')
OUTPUT_PATH = File.join(ROOT, 'assets', 'data', 'legacy_route_map.json')

def normalize_slug(text)
  text.to_s.downcase.strip.gsub(/[^a-z0-9]+/, '-').gsub(/\A-+|-+\z/, '')
end

def derive_post_url(filename, frontmatter)
  return frontmatter['permalink'] if frontmatter['permalink'] && !frontmatter['permalink'].strip.empty?

  basename = File.basename(filename, '.*')
  if basename =~ /\A(\d{4})-(\d{2})-(\d{2})-(.+)\z/
    year = Regexp.last_match(1)
    month = Regexp.last_match(2)
    day = Regexp.last_match(3)
    slug = Regexp.last_match(4)
    "/#{year}/#{month}/#{day}/#{slug}.html"
  else
    "/#{basename}.html"
  end
end

puts '==> Building legacy route map index...'

# 1. Load declarative configuration
legacy_config = YAML.safe_load(File.read(LEGACY_ROUTES_PATH)) || {}
domain_fallbacks = legacy_config['domain_fallbacks'] || {}
exact_routes = legacy_config['exact_routes'] || {}
pattern_rules = legacy_config['pattern_rules'] || []

# 2. Index Interviews
interviews_data = YAML.safe_load(File.read(File.join(ROOT, '_data', 'interviews.yml'))) || {}
interviews_list = interviews_data['items'] || []

interview_map = {}
interviews_list.each do |item|
  id = item['id']
  next unless id

  url = "/interviews/#{id}/"
  title = item['title'] || id
  interviewees = Array(item['interviewees'])

  interview_map[id] = {
    'url' => url,
    'title' => title,
    'interviewees' => interviewees
  }

  # Add stripped numerical prefix key if applicable (e.g. '15-joel-turnbull' -> 'joel-turnbull')
  if id =~ /\A\d+-(.+)\z/
    stripped = Regexp.last_match(1)
    interview_map[stripped] ||= {
      'url' => url,
      'title' => title,
      'interviewees' => interviewees
    }
  end

  # Map interviewee names and slugs
  interviewees.each do |person|
    norm_person = normalize_slug(person)
    next if norm_person.empty?

    interview_map[norm_person] ||= {
      'url' => url,
      'title' => title,
      'interviewees' => interviewees
    }
  end
end
puts "    Indexed #{interview_map.size} interview slug keys from #{interviews_list.size} interviews"

# 3. Index Video Assets (YouTube & Vimeo IDs)
video_assets_data = YAML.safe_load(File.read(File.join(ROOT, '_data', 'video_assets.yml'))) || {}
video_assets_list = video_assets_data['items'] || []

video_map = {}
video_assets_list.each do |asset|
  canonical_url = if asset['interview_id']
                    "/interviews/#{asset['interview_id']}/"
                  elsif asset['episode_id']
                    "/series/the-sound-above/#{asset['episode_id']}/"
                  else
                    "/videos/"
                  end

  title = asset['title'] || asset['id']
  platforms = asset['platforms'] || []

  platforms.each do |p|
    platform_name = p['platform']
    asset_id = p['asset_id']
    next unless asset_id && !asset_id.to_s.strip.empty?

    key = "#{platform_name}:#{asset_id}"
    video_map[key] = {
      'url' => canonical_url,
      'title' => title,
      'platform' => platform_name,
      'asset_id' => asset_id
    }
    # Also key directly by bare asset_id (e.g. YouTube video ID or Vimeo ID)
    video_map[asset_id.to_s.strip] ||= {
      'url' => canonical_url,
      'title' => title,
      'platform' => platform_name,
      'asset_id' => asset_id
    }
  end
end
puts "    Indexed #{video_map.size} video platform keys across #{video_assets_list.size} assets"

# 4. Index Interviewees
interviewees_data = YAML.safe_load(File.read(File.join(ROOT, '_data', 'interviewees_index.yml'))) || {}
people_list = interviewees_data['items'] || []

people_map = {}
people_list.each do |person|
  slug = person['slug']
  name = person['name']
  next unless slug

  target_url = "/interviews/people/#{slug}/"
  people_map[slug] = {
    'url' => target_url,
    'name' => name,
    'count' => person['count']
  }
  norm_name = normalize_slug(name)
  if !norm_name.empty? && norm_name != slug
    people_map[norm_name] ||= {
      'url' => target_url,
      'name' => name,
      'count' => person['count']
    }
  end
end
puts "    Indexed #{people_map.size} interviewee keys from #{people_list.size} people"

# 5. Index Blog Posts
posts_map = {}
post_files = Dir[File.join(ROOT, '_posts', '*')]
post_files.each do |post_path|
  content = File.read(post_path)
  next unless content =~ /\A(---\s*\n.*?\n?)^(---\s*$\n?)/m

  frontmatter = YAML.safe_load(Regexp.last_match(1)) rescue {}
  next unless frontmatter.is_a?(Hash)

  post_url = derive_post_url(post_path, frontmatter)
  title = frontmatter['title'] || File.basename(post_path)

  # Key by post basename slug
  base_slug = File.basename(post_path, '.*')
  posts_map[base_slug] = { 'url' => post_url, 'title' => title }

  # Strip date prefix and index slash-delimited date paths
  if base_slug =~ /\A(\d{4})-(\d{2})-(\d{2})-(.+)\z/
    year = Regexp.last_match(1)
    month = Regexp.last_match(2)
    day = Regexp.last_match(3)
    title_slug = Regexp.last_match(4)

    posts_map[title_slug] ||= { 'url' => post_url, 'title' => title }
    posts_map["/#{year}/#{month}/#{day}/#{title_slug}"] = { 'url' => post_url, 'title' => title }
    posts_map["#{year}/#{month}/#{day}/#{title_slug}"] = { 'url' => post_url, 'title' => title }
    posts_map["/#{year}/#{month}/#{title_slug}"] ||= { 'url' => post_url, 'title' => title }
  end

  # Index post URL without extension
  clean_url = post_url.sub(/\.html\z/, '')
  posts_map[clean_url] ||= { 'url' => post_url, 'title' => title }
  posts_map[post_url] ||= { 'url' => post_url, 'title' => title }

  # Key by original URL path if present
  orig_url = frontmatter['original_url']
  if orig_url && !orig_url.strip.empty?
    begin
      uri = URI.parse(orig_url)
      orig_path = uri.path
      if orig_path && !orig_path.empty? && orig_path != '/'
        posts_map[orig_path] ||= { 'url' => post_url, 'title' => title }
        orig_base = File.basename(orig_path, '.*')
        posts_map[orig_base] ||= { 'url' => post_url, 'title' => title } unless orig_base.empty?
      end
    rescue URI::InvalidURIError
      # Skip malformed URLs
    end
  end
end
puts "    Indexed #{posts_map.size} post keys from #{post_files.size} posts"

# 6. Assemble Output
payload = {
  'generated_at' => Time.now.utc.iso8601,
  'domain_fallbacks' => domain_fallbacks,
  'exact_routes' => exact_routes,
  'pattern_rules' => pattern_rules,
  'interviews' => interview_map,
  'video_assets' => video_map,
  'interviewees' => people_map,
  'posts' => posts_map
}

FileUtils.mkdir_p(File.dirname(OUTPUT_PATH))
File.write(OUTPUT_PATH, JSON.pretty_generate(payload) + "\n")
puts "==> Wrote legacy route map to #{OUTPUT_PATH} (#{File.size(OUTPUT_PATH)} bytes)"
