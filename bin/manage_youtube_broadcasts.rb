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

  def get_stream_key_id
    uri = URI("https://www.googleapis.com/youtube/v3/liveStreams?part=snippet,cdn,status&mine=true")
    req = Net::HTTP::Get.new(uri)
    req["Authorization"] = "Bearer #{@client.access_token}"
    res = @http.request(req)
    data = JSON.parse(res.body)
    stream = data["items"]&.first
    raise "No liveStream found on channel!" unless stream
    stream["id"]
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

  if options[:thumb_file] && options[:broadcast_id]
    mgr.upload_thumbnail(options[:broadcast_id], options[:thumb_file])
  elsif options[:episode]
    mgr.create_episode_broadcast(options[:episode], privacy: options[:privacy])
  else
    puts opt_parser
  end
end
