#!/usr/bin/env ruby
# frozen_string_literal: true

# ==============================================================================
# bin/manage_youtube_broadcasts.rb
#
# Automated lifecycle management for YouTube Live Rewatch Broadcasts.
# - Creates scheduled broadcasts with recommended settings (low latency, DVR, auto-start)
# - Binds to active channel stream key
# - Uploads 1080p high-resolution thumbnail
# - Tracks/updates status in obs/curation/sequence-manifest.json
# ==============================================================================

require 'optparse'
require 'json'
require 'time'
require 'net/http'
require 'uri'
require_relative 'lib/youtube_client'

ROOT_DIR = File.expand_path("..", __dir__)
MANIFEST_PATH = File.join(ROOT_DIR, "obs", "curation", "sequence-manifest.json")
THUMBNAIL_DIR = File.join(ROOT_DIR, "obs", "thumbnails")

class YouTubeBroadcastManager
  def initialize
    @client = YouTubeClient.new
    @client.fetch_access_token!
    @http = Net::HTTP.new("www.googleapis.com", 443)
    @http.use_ssl = true
  end

  def get_stream_key_id(name_hint: nil)
    uri = URI("https://www.googleapis.com/youtube/v3/liveStreams?part=snippet,cdn,status&mine=true")
    req = Net::HTTP::Get.new(uri)
    req["Authorization"] = "Bearer #{@client.access_token}"
    res = @http.request(req)
    data = JSON.parse(res.body)
    items = data["items"] || []
    raise "No liveStream found on channel!" if items.empty?

    if name_hint
      stream = items.find { |s| s.dig("snippet", "title").to_s.downcase.include?(name_hint.downcase) }
      return stream["id"] if stream
    end

    items.first["id"]
  end

  def get_or_create_staging_stream
    uri = URI("https://www.googleapis.com/youtube/v3/liveStreams?part=snippet,cdn,status&mine=true")
    req = Net::HTTP::Get.new(uri)
    req["Authorization"] = "Bearer #{@client.access_token}"
    res = @http.request(req)
    data = JSON.parse(res.body)
    items = data["items"] || []

    staging_stream = items.find { |s| s.dig("snippet", "title").to_s.downcase.include?("staging") }
    return staging_stream if staging_stream

    # Create new staging stream
    payload = {
      "snippet" => {
        "title" => "The Sound Above: Staging & Testing Stream Key (Private/Unlisted)"
      },
      "cdn" => {
        "frameRate" => "60fps",
        "ingestionType" => "rtmp",
        "resolution" => "1080p"
      }
    }
    uri_post = URI("https://www.googleapis.com/youtube/v3/liveStreams?part=snippet,cdn,status")
    req_post = Net::HTTP::Post.new(uri_post)
    req_post["Authorization"] = "Bearer #{@client.access_token}"
    req_post["Content-Type"] = "application/json"
    req_post.body = JSON.generate(payload)
    res_post = @http.request(req_post)
    raise "Failed to create staging stream: #{res_post.body}" unless res_post.is_a?(Net::HTTPSuccess)
    JSON.parse(res_post.body)
  end

  def create_staging_broadcast
    staging_stream = get_or_create_staging_stream
    stream_id = staging_stream["id"]
    stream_key = staging_stream.dig("cdn", "ingestionInfo", "streamName")

    title = "The Sound Above — Staging & Dry Run Sandbox"
    description = "Internal testing and staging broadcast for The Sound Above oral history stream. Automated dry run sandbox."
    sched_time = (Time.now + 3600).utc.iso8601

    payload = {
      "snippet" => {
        "title" => title,
        "description" => description,
        "scheduledStartTime" => sched_time
      },
      "status" => {
        "privacyStatus" => "private",
        "selfDeclaredMadeForKids" => false
      },
      "contentDetails" => {
        "enableDvr" => true,
        "enableContentEncryption" => false,
        "enableEmbed" => true,
        "recordFromStart" => true,
        "startWithSlate" => false,
        "latencyPreference" => "low",
        "enableAutoStart" => true,
        "enableAutoStop" => false
      }
    }

    uri = URI("https://www.googleapis.com/youtube/v3/liveBroadcasts?part=snippet,status,contentDetails")
    req = Net::HTTP::Post.new(uri)
    req["Authorization"] = "Bearer #{@client.access_token}"
    req["Content-Type"] = "application/json"
    req.body = JSON.generate(payload)
    res = @http.request(req)
    raise "Failed to create staging broadcast: #{res.body}" unless res.is_a?(Net::HTTPSuccess)
    bc = JSON.parse(res.body)
    bc_id = bc["id"]
    puts "✓ Created Staging Broadcast: #{bc_id} ('#{title}') [privacy: private]"

    # Bind stream
    uri_bind = URI("https://www.googleapis.com/youtube/v3/liveBroadcasts/bind?id=#{bc_id}&part=id,contentDetails,snippet&streamId=#{stream_id}")
    req_bind = Net::HTTP::Post.new(uri_bind)
    req_bind["Authorization"] = "Bearer #{@client.access_token}"
    res_bind = @http.request(req_bind)
    raise "Failed to bind staging broadcast: #{res_bind.body}" unless res_bind.is_a?(Net::HTTPSuccess)
    puts "✓ Bound staging broadcast #{bc_id} to staging stream key #{stream_id}"

    # Sync to local OBS Staging profile if directory exists
    sync_obs_profile_key("The Sound Above - Staging", stream_key)

    puts "\n🎉 Staging Broadcast Ready!"
    puts "   Broadcast ID: #{bc_id}"
    puts "   Studio URL:   https://studio.youtube.com/video/#{bc_id}/livestreaming"
    puts "   Stream Key:   #{stream_key}"
    bc_id
  end

  def sync_obs_profile_key(profile_name, stream_key)
    obs_profile_dir = File.expand_path("~/Library/Application Support/obs-studio/basic/profiles/#{profile_name}")
    return unless Dir.exist?(obs_profile_dir)

    service_file = File.join(obs_profile_dir, "service.json")
    service_data = {
      "type" => "rtmp_common",
      "settings" => {
        "service" => "YouTube - RTMPS",
        "server" => "rtmps://a.rtmps.youtube.com:443/live2",
        "key" => stream_key,
        "bwtest" => false,
        "protocol" => "RTMPS"
      }
    }
    File.write(service_file, JSON.pretty_generate(service_data) + "\n")
    puts "✓ Updated active OBS Profile '#{profile_name}' service.json with stream key"
  end

  def list_broadcasts
    uri = URI("https://www.googleapis.com/youtube/v3/liveBroadcasts?part=snippet,status,contentDetails&mine=true")
    req = Net::HTTP::Get.new(uri)
    req["Authorization"] = "Bearer #{@client.access_token}"
    res = @http.request(req)
    raise "Failed to fetch broadcasts: #{res.body}" unless res.is_a?(Net::HTTPSuccess)
    data = JSON.parse(res.body)
    items = data["items"] || []

    puts "=================================================================="
    puts " 📺 YOUTUBE LIVE BROADCAST STATUS (#{items.size} found)"
    puts "=================================================================="
    items.each do |b|
      puts "ID: #{b['id']} | Status: #{b.dig('status', 'lifeCycleStatus')} | Privacy: #{b.dig('status', 'privacyStatus')}"
      puts "   Title: #{b.dig('snippet', 'title')}"
      puts "   Bound Stream ID: #{b.dig('contentDetails', 'boundStreamId')}"
      puts "   Studio URL: https://studio.youtube.com/video/#{b['id']}/livestreaming"
      puts "------------------------------------------------------------------"
    end
  end

  def create_episode_broadcast(ep_num, privacy: "unlisted", start_time: nil)
    manifest = JSON.parse(File.read(MANIFEST_PATH))
    ep = manifest["episodes"]&.find { |e| e["number"] == ep_num }
    raise "Episode #{ep_num} not found in sequence manifest!" unless ep

    stream_id = get_stream_key_id
    sched_time = (start_time || Time.now + 600).utc.iso8601

    title = "The Sound Above — Episode %02d: %s (%s)" % [ep["number"], ep["title"].split(":").first, ep["interviewee"]]
    description = <<~DESC
      The Sound Above: UGtastic Oral History Rewatch Series (Episode %02d)

      Rewatching: %s (%s, %s)
      Inquiry: "%s"

      Chicago Context: %s

      Canonical Archive & Transcript: https://just3ws.com/interviews/%s/
      Series Mirror: https://just3ws.com/series/the-sound-above/episode-%02d.html
    DESC
    desc_formatted = description % [
      ep["number"],
      ep["interviewee"],
      ep["conference"],
      ep["year"],
      ep["sound_above_inquiry"],
      ep["chicago_context"],
      ep["slug"],
      ep["number"]
    ]

    payload = {
      "snippet" => {
        "title" => title,
        "description" => desc_formatted,
        "scheduledStartTime" => sched_time
      },
      "status" => {
        "privacyStatus" => privacy,
        "selfDeclaredMadeForKids" => false
      },
      "contentDetails" => {
        "enableDvr" => true,
        "enableContentEncryption" => false,
        "enableEmbed" => true,
        "recordFromStart" => true,
        "startWithSlate" => false,
        "latencyPreference" => "low",
        "closedCaptionsType" => "closedCaptionsHttpPost",
        "enableAutoStart" => true,
        "enableAutoStop" => false
      }
    }

    uri = URI("https://www.googleapis.com/youtube/v3/liveBroadcasts?part=snippet,status,contentDetails")
    req = Net::HTTP::Post.new(uri)
    req["Authorization"] = "Bearer #{@client.access_token}"
    req["Content-Type"] = "application/json"
    req.body = JSON.generate(payload)
    res = @http.request(req)

    raise "Failed to create broadcast: #{res.body}" unless res.is_a?(Net::HTTPSuccess)
    data = JSON.parse(res.body)
    bc_id = data["id"]
    puts "✓ Created broadcast: #{bc_id} ('#{title}')"

    # Bind stream
    uri_bind = URI("https://www.googleapis.com/youtube/v3/liveBroadcasts/bind?id=#{bc_id}&part=id,contentDetails,snippet&streamId=#{stream_id}")
    req_bind = Net::HTTP::Post.new(uri_bind)
    req_bind["Authorization"] = "Bearer #{@client.access_token}"
    res_bind = @http.request(req_bind)
    raise "Failed to bind broadcast: #{res_bind.body}" unless res_bind.is_a?(Net::HTTPSuccess)
    puts "✓ Bound broadcast #{bc_id} to stream key #{stream_id}"

    # Upload thumbnail if available
    thumb_path = find_thumbnail_for(ep)
    if thumb_path && File.exist?(thumb_path)
      upload_thumbnail(bc_id, thumb_path)
    else
      puts "ℹ No matching thumbnail file found at #{thumb_path}"
    end

    # Save to manifest
    ep["youtube_broadcast_id"] = bc_id
    File.write(MANIFEST_PATH, JSON.pretty_generate(manifest) + "\n")
    puts "✓ Recorded broadcast ID in #{MANIFEST_PATH}"

    bc_id
  end

  def upload_thumbnail(video_id, image_path)
    image_data = File.read(image_path)
    uri = URI("https://www.googleapis.com/upload/youtube/v3/thumbnails/set?videoId=#{video_id}&uploadType=media")
    req = Net::HTTP::Post.new(uri)
    req["Authorization"] = "Bearer #{@client.access_token}"
    req["Content-Type"] = image_path.end_with?(".png") ? "image/png" : "image/jpeg"
    req["Content-Length"] = image_data.bytesize.to_s
    req.body = image_data

    res = @http.request(req)
    if res.is_a?(Net::HTTPSuccess)
      puts "✓ Uploaded thumbnail #{File.basename(image_path)} to #{video_id}"
    else
      puts "❌ Failed to upload thumbnail: #{res.body}"
    end
  end

  def find_thumbnail_for(ep)
    # Check by episode number or slug
    slug_name = ep["interviewee"].downcase.gsub(/[^a-z0-9]+/, '-')
    [
      File.join(THUMBNAIL_DIR, "episode-%02d-%s-1080p.png" % [ep["number"], slug_name]),
      File.join(THUMBNAIL_DIR, "episode-%02d-1080p.png" % ep["number"])
    ].find { |f| File.exist?(f) } || File.join(THUMBNAIL_DIR, "episode-%02d-%s-1080p.png" % [ep["number"], slug_name])
  end
end

if __FILE__ == $0
  options = { privacy: "unlisted" }
  opt_parser = OptionParser.new do |opts|
    opts.banner = "Usage: bin/manage_youtube_broadcasts.rb [options]"

    opts.on("-e", "--episode NUMBER", Integer, "Episode number to create broadcast for") do |v|
      options[:episode] = v
    end

    opts.on("-s", "--staging", "Create private staging and testing sandbox broadcast") do
      options[:staging] = true
    end

    opts.on("-l", "--list", "List existing live broadcasts and their status") do
      options[:list] = true
    end

    opts.on("-p", "--privacy STATUS", "Privacy status: unlisted, public, private (default: unlisted)") do |v|
      options[:privacy] = v
    end

    opts.on("-t", "--thumbnail FILE", "Upload thumbnail to specific broadcast ID") do |v|
      options[:thumb_file] = v
    end

    opts.on("-b", "--broadcast ID", "Broadcast/Video ID for thumbnail upload") do |v|
      options[:broadcast_id] = v
    end

    opts.on("-h", "--help", "Show help") do
      puts opts
      exit
    end
  end

  opt_parser.parse!

  mgr = YouTubeBroadcastManager.new

  if options[:list]
    mgr.list_broadcasts
  elsif options[:staging]
    mgr.create_staging_broadcast
  elsif options[:thumb_file] && options[:broadcast_id]
    mgr.upload_thumbnail(options[:broadcast_id], options[:thumb_file])
  elsif options[:episode]
    mgr.create_episode_broadcast(options[:episode], privacy: options[:privacy])
  else
    puts opt_parser
  end
end
