#!/usr/bin/env ruby
# frozen_string_literal: true

# bin/migrate_vimeo_masters_to_youtube.rb — Vimeo Master MP4 -> YouTube Uploader
#
# Reads _data/vimeo_migration_manifest.yml, matches master MP4s in /Volumes/Dock_1TB/vimeo/videos/,
# prepares rich canonical metadata, uploads via YouTube API v3, and writes returned YouTube IDs
# into _data/video_assets.yml and _data/vimeo_migration_manifest.yml.

require 'yaml'
require 'json'
require 'optparse'
require 'date'
require_relative 'upload_youtube_video'

$stdout.sync = true

class VimeoToYouTubeMigrator
  MANIFEST_PATH = "_data/vimeo_migration_manifest.yml"
  VIDEO_ASSETS_PATH = "_data/video_assets.yml"
  VIMEO_VIDEOS_DIR = "/Volumes/Dock_1TB/vimeo/videos"

  def initialize(options = {})
    @options = options
    @manifest = YAML.load_file(MANIFEST_PATH)
    @video_assets = YAML.load_file(VIDEO_ASSETS_PATH)
    @uploader = VideoUploader.new unless @options[:dry_run]
  end

  def run
    puts "🚀 [Vimeo -> YouTube Migration Runner]"
    puts "================================================================================"

    candidates = discover_upload_candidates
    puts "Found #{candidates.size} matched master video candidate(s) ready for upload."

    if candidates.empty?
      puts "No pending candidates found with local masters on disk."
      return
    end

    candidates.each_with_index do |cand, idx|
      puts "\n--------------------------------------------------------------------------------"
      puts "[#{idx + 1}/#{candidates.size}] Processing: #{cand[:title]}"
      puts "  Asset ID  : #{cand[:asset_id]}"
      puts "  Vimeo ID  : #{cand[:vimeo_id]}"
      puts "  Master MP4: #{cand[:file_path]} (#{cand[:size_mb]} MB)"
      puts "  Captions  : #{cand[:caption_readiness]}"

      if @options[:dry_run]
        puts "  🔍 [Dry Run] Title: #{cand[:payload]['snippet']['title']}"
        puts "  🔍 [Dry Run] Tags : #{cand[:payload]['snippet']['tags'].join(', ')}"
        puts "  🔍 [Dry Run] Privacy: #{cand[:payload]['status']['privacyStatus']}"
      else
        upload_and_record(cand)
      end
    end

    puts "\n================================================================================"
    puts "🏁 Migration run finished."
  end

  private

  CUSTOM_PATTERNS = {
    "mike-hall-introduction-to-aop-with-postsharp" => ["Introduction to AOP with PostSharp"],
    "vimeo-29430473" => ["HTML5 and JavaScript Game Development by Eric Smith"],
    "vimeo-26657739" => ["Enough C To Get Started In F-OSS by Andy Lester - Part 1"],
    "vimeo-26669252" => ["Enough C To Get Started In F-OSS by Andy Lester - Part 2"],
    "vimeo-27889917" => ["Blind SQL Injection by Michael Buselli"],
    "vimeo-37080647" => ["TDD Your JavaScript With Backbone.js"],
    "vimeo-30083598" => ["The \"A\" word", "Uncle\" Bob Martin"],
    "vimeo-32266297" => ["Front End Craftsmanship- Toward a More Meaningful Web w-Billy Whited"],
    "vimeo-38723757" => ["Beginner C++ for Expert Programmers w-Scott Seely"]
  }.freeze

  def discover_upload_candidates
    items = @manifest["items"] || []
    available_files = Dir.glob("#{VIMEO_VIDEOS_DIR}/*.mp4")

    candidates = []

    items.each do |item|
      # Skip already completed
      next if item["migration_state"] == "completed" && item["youtube_id"] && !item["youtube_id"].to_s.empty?

      vid_id = item["vimeo_id"].to_s
      matching_file = available_files.find { |f| f.include?(vid_id) }

      if !matching_file && CUSTOM_PATTERNS[item["asset_id"]]
        matching_file = available_files.find do |f|
          CUSTOM_PATTERNS[item["asset_id"]].any? { |pat| f.include?(pat) }
        end
      end

      next unless matching_file

      size_mb = (File.size(matching_file) / (1024.0 * 1024)).round(1)
      payload = build_youtube_payload(item)

      candidates << {
        asset_id: item["asset_id"],
        vimeo_id: item["vimeo_id"],
        title: item["title"],
        caption_readiness: item["caption_readiness"],
        file_path: matching_file,
        size_mb: size_mb,
        payload: payload,
        manifest_item: item
      }
    end

    candidates
  end

  def build_youtube_payload(item)
    asset_id = item["asset_id"]
    asset_record = (@video_assets["items"] || []).find { |a| a["id"] == asset_id } || {}
    vimeo_platform = (asset_record["platforms"] || []).find { |p| p["platform"] == "vimeo" } || {}

    # Refine title: prefer clean speaker + topic syntax
    title = asset_record["title"] || item["title"]
    if vimeo_platform["title_on_platform"] && !vimeo_platform["title_on_platform"].empty?
      raw_title = vimeo_platform["title_on_platform"]
      if raw_title.include?("w/") || raw_title.include?("w-")
        title = "#{raw_title} | UGtastic Archive"
      elsif !title.include?("|")
        title = "#{title} | UGtastic Archive"
      end
    end

    # Explicit override mappings for SCMC and special presentations
    custom_titles = {
      "vimeo-30083598" => "Uncle Bob Martin: The A Word - Architecture | SCMC 2011",
      "vimeo-26657739" => "Andy Lester: Enough C To Get Started In F/OSS (Part 1) | SCMC 2011",
      "vimeo-26669252" => "Andy Lester: Enough C To Get Started In F/OSS (Part 2) | SCMC 2011",
      "vimeo-27889917" => "Michael Buselli: Blind SQL Injection Attacks & Defense | SCMC 2011",
      "vimeo-29430473" => "Eric Smith: HTML5 Canvas and JavaScript Game Development | SCMC 2011",
      "vimeo-32266297" => "Billy Whited: Front End Craftsmanship - Toward a More Meaningful Web | SCMC 2011",
      "vimeo-37080647" => "Mike Jansen: TDD Your JavaScript With Backbone.js | SCMC 2012",
      "vimeo-38723757" => "Scott Seely: Beginner C++ for Expert Programmers | SCMC 2012",
      "mike-hall-introduction-to-aop-with-postsharp" => "Mike Hall: Introduction to AOP with PostSharp | Chicago Code Camp 2009"
    }

    title = custom_titles[asset_id] if custom_titles[asset_id]

    description_text = vimeo_platform["description"] || asset_record["description"] || "Archival technical presentation from the UGtastic and Software Craftsmanship community archive."
    transcript_id = asset_record["transcript_id"] || item["transcript_id"]

    event_name = asset_record["event"]
    event_name ||= "Software Craftsmanship McHenry County (SCMC)" if asset_id.start_with?("vimeo-")
    event_name ||= "Chicago Code Camp 2009" if asset_id.include?("chicago-code-camp") || asset_id.include?("postsharp")
    event_name ||= "UGtastic Archive"

    speaker_name = asset_record["speaker"]
    if speaker_name.nil? || speaker_name.empty? || speaker_name == "Guest"
      speaker_name = title[/^([^:]+):/, 1] || title[/w[\/-]([A-Za-z\s]+)/, 1] || "Community Speaker"
    end

    description = <<~DESC.strip
      #{title}

      #{description_text}

      Recorded during the 2009–2015 software craftsmanship and developer community movements, this archival interview captures early ideas, debates, and community organizing in real time.

      ---
      🏛️ ORAL HISTORY RECORD:
      • Series: UGtastic Technical Conversation Archive (2009–2015)
      • Speaker: #{speaker_name}
      • Event: #{event_name}
      • Interviewer / Host: Mike Hall (UGtastic / https://www.just3ws.com)

      ⏱️ CHAPTERS:
      00:00 - Introduction & Context

      📖 FULL INTERACTIVE TRANSCRIPT & AUDIO:
      https://www.just3ws.com/interviews/#{transcript_id || asset_id}/

      🏷️ TOPICS: Software Craftsmanship, Programming, Architecture, #{speaker_name}, UGtastic

      Restored and preserved by Mike Hall (https://www.just3ws.com)
    DESC

    tags = (asset_record["tags"] || ["Software Craftsmanship", "Programming", "Architecture", "UGtastic"]).dup
    tags << asset_record["speaker"] if asset_record["speaker"] && !asset_record["speaker"].empty?
    tags.uniq!

    privacy = @options[:privacy] || "public"

    {
      "snippet" => {
        "title" => title[0..99], # YouTube 100-char title limit
        "description" => description,
        "tags" => tags[0..20],
        "categoryId" => "28", # Science & Technology
        "defaultLanguage" => "en"
      },
      "status" => {
        "privacyStatus" => privacy,
        "selfDeclaredMadeForKids" => false,
        "embeddable" => true
      }
    }
  end

  def upload_and_record(candidate)
    asset_id = candidate[:asset_id]
    res = @uploader.upload(candidate[:file_path], candidate[:payload])
    new_youtube_id = res["id"]

    unless new_youtube_id && !new_youtube_id.empty?
      raise "No YouTube ID returned for #{asset_id}"
    end

    puts "📝 Updating local metadata for #{asset_id} with YouTube ID: #{new_youtube_id}..."

    # 1. Update manifest item
    candidate[:manifest_item]["youtube_id"] = new_youtube_id
    candidate[:manifest_item]["migration_state"] = "completed"
    candidate[:manifest_item]["primary_platform"] = "youtube"
    File.write(MANIFEST_PATH, YAML.dump(@manifest))

    # 2. Update _data/video_assets.yml
    asset_record = (@video_assets["items"] || []).find { |a| a["id"] == asset_id }
    if asset_record
      asset_record["primary_platform"] = "youtube"
      asset_record["platforms"] ||= []
      
      # Remove any existing youtube platform entry if present
      asset_record["platforms"].reject! { |p| p["platform"] == "youtube" }

      # Append fresh youtube platform entry
      asset_record["platforms"] << {
        "platform" => "youtube",
        "asset_id" => new_youtube_id,
        "url" => "https://www.youtube.com/watch?v=#{new_youtube_id}",
        "embed_url" => "https://www.youtube.com/embed/#{new_youtube_id}",
        "title_on_platform" => candidate[:payload]["snippet"]["title"],
        "published_date" => Date.today.to_s,
        "thumbnail" => "https://i.ytimg.com/vi/#{new_youtube_id}/hqdefault.jpg",
        "description" => candidate[:payload]["snippet"]["description"]
      }

      File.write(VIDEO_ASSETS_PATH, YAML.dump(@video_assets))
      puts "✅ [Updated] #{VIDEO_ASSETS_PATH} updated with YouTube ID #{new_youtube_id}"
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  options = { dry_run: false, privacy: "public" }

  OptionParser.new do |opts|
    opts.banner = "Usage: ruby bin/migrate_vimeo_masters_to_youtube.rb [options]"
    opts.on("--dry-run", "Preview metadata payloads without uploading") { options[:dry_run] = true }
    opts.on("--unlisted", "Upload as unlisted rather than public") { options[:privacy] = "unlisted" }
    opts.on("--public", "Upload as public (default)") { options[:privacy] = "public" }
  end.parse!

  migrator = VimeoToYouTubeMigrator.new(options)
  migrator.run
end
