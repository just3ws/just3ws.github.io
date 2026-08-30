#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'net/http'
require 'uri'
require_relative 'lib/youtube_client'

$stdout.sync = true

class VideoUploader
  def initialize
    @client = YouTubeClient.new
    @client.fetch_access_token!
  end

  def upload(file_path, snippet_payload)
    unless File.exist?(file_path)
      raise "Video file not found: #{file_path}"
    end

    file_size = File.size(file_path)
    puts "🎬 [Upload] Starting resumable upload for: #{File.basename(file_path)} (#{file_size / (1024 * 1024)} MB)"

    # Step 0: Ensure fresh OAuth access token
    @client.fetch_access_token!

    # Step 1: Initiate resumable upload session
    init_uri = URI("https://www.googleapis.com/upload/youtube/v3/videos?uploadType=resumable&part=snippet,status")
    http = Net::HTTP.new(init_uri.host, init_uri.port)
    http.use_ssl = true

    init_req = Net::HTTP::Post.new(init_uri)
    init_req["Authorization"] = "Bearer #{@client.access_token}"
    init_req["Content-Type"] = "application/json; charset=UTF-8"
    init_req["X-Upload-Content-Length"] = file_size.to_s
    init_req["X-Upload-Content-Type"] = "video/mp4"
    init_req.body = JSON.generate(snippet_payload)

    init_res = http.request(init_req)

    unless init_res.is_a?(Net::HTTPSuccess) || init_res.code == "200" || init_res.code == "201"
      raise "Failed to initialize upload session (#{init_res.code}): #{init_res.body}"
    end

    location = init_res["Location"]
    raise "No upload location returned in response headers" unless location

    puts "🚀 [Upload] Session initialized. Uploading file binary stream..."

    # Step 2: Upload binary content with retry handling
    retries = 0
    max_retries = 3

    begin
      upload_uri = URI(location)
      upload_http = Net::HTTP.new(upload_uri.host, upload_uri.port)
      upload_http.use_ssl = true
      upload_http.open_timeout = 60
      upload_http.read_timeout = 1800 # 30 minutes timeout for 500MB+ files

      upload_req = Net::HTTP::Put.new(upload_uri)
      upload_req["Content-Type"] = "video/mp4"
      upload_req["Content-Length"] = file_size.to_s
      
      File.open(file_path, 'rb') do |file|
        upload_req.body_stream = file
        upload_res = upload_http.request(upload_req)

        if upload_res.is_a?(Net::HTTPSuccess) || upload_res.code == "200" || upload_res.code == "201"
          data = JSON.parse(upload_res.body)
          new_video_id = data["id"]
          puts "✅ [Success] Video uploaded successfully! Video ID: #{new_video_id}"
          puts "   Link: https://youtu.be/#{new_video_id}"
          return data
        else
          raise "Upload failed (#{upload_res.code}): #{upload_res.body}"
        end
      end
    rescue OpenSSL::SSL::SSLError, Errno::ECONNRESET, Errno::EPIPE, Net::ReadTimeout => e
      retries += 1
      if retries <= max_retries
        puts "⚠️ [Retry #{retries}/#{max_retries}] Network glitch (#{e.class}: #{e.message}). Retrying binary transfer in 5s..."
        sleep 5
        retry
      else
        raise e
      end
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  uploader = VideoUploader.new

  queue = [
    {
      file: "/Volumes/Dock_1TB/WITC/BUCKET/WebVision/WHOIS Tech Community - 171 - WHOIS Tech Community - 171 - Jason Cranford Teague.mp4",
      transcript_id: "interview-with-jason-cranford-teague-general",
      payload: {
        "snippet" => {
          "title" => "Jason Cranford Teague on Web Design and Digital Typography | WebVisions 2013",
          "description" => <<~DESC.strip,
            Hi, it's Mike with UGtastic! In this conversation recorded on-site at WebVisions 2013, I sit down with Jason Cranford Teague to discuss web design and digital typography.

            Jason Cranford Teague discusses the evolution of digital design, fluid typography, and the bridge between traditional design principles and modern web standards.

            Recorded during the 2009–2015 software craftsmanship and developer community movements, this archival interview captures early ideas, debates, and community organizing in real time.

            ---
            🏛️ ORAL HISTORY RECORD:
            • Series: UGtastic Technical Conversation Archive (2009–2015)
            • Location: WebVisions 2013
            • Guest: Jason Cranford Teague (Author & Web Design Practitioner)
            • Interviewer: Mike Hall (UGtastic / https://www.just3ws.com)

            ⏱️ CHAPTERS:
            00:00 - Introduction & Context

            📖 FULL INTERACTIVE TRANSCRIPT & AUDIO:
            https://www.just3ws.com/interviews/interview-with-jason-cranford-teague-general/

            🏷️ TOPICS: Software Craftsmanship, Programming, Architecture, Jason Cranford Teague, WebVisions

            Restored and preserved by Mike Hall (https://www.just3ws.com)
          DESC
          "tags" => ["Software Craftsmanship", "Programming", "Architecture", "Jason Cranford Teague", "WebVisions", "Web Design"],
          "categoryId" => "28",
          "defaultLanguage" => "en"
        },
        "status" => {
          "privacyStatus" => "public",
          "selfDeclaredMadeForKids" => false,
          "embeddable" => true
        }
      }
    },
    {
      file: "/Volumes/Dock_1TB/WITC/BUCKET/WebVision/WHOIS Tech Community - 176 - WHOIS Tech Community - 176 - Jennifer Jones.mp4",
      transcript_id: "interview-with-jennifer-jones-general",
      payload: {
        "snippet" => {
          "title" => "Jennifer Jones on Technical Community and Event Organizing | WebVisions 2013",
          "description" => <<~DESC.strip,
            Hi, it's Mike with UGtastic! In this conversation recorded on-site at WebVisions 2013, I sit down with Jennifer Jones to discuss technical community and event organizing.

            Jennifer Jones shares insights on grassroots tech community organizing, fostering welcoming environments for developers and designers, and the logistics of sustaining regional technology conferences.

            Recorded during the 2009–2015 software craftsmanship and developer community movements, this archival interview captures early ideas, debates, and community organizing in real time.

            ---
            🏛️ ORAL HISTORY RECORD:
            • Series: UGtastic Technical Conversation Archive (2009–2015)
            • Location: WebVisions 2013
            • Guest: Jennifer Jones (Community & Event Organizer)
            • Interviewer: Mike Hall (UGtastic / https://www.just3ws.com)

            ⏱️ CHAPTERS:
            00:00 - Introduction & Context

            📖 FULL INTERACTIVE TRANSCRIPT & AUDIO:
            https://www.just3ws.com/interviews/interview-with-jennifer-jones-general/

            🏷️ TOPICS: Software Craftsmanship, Programming, Architecture, Jennifer Jones, WebVisions

            Restored and preserved by Mike Hall (https://www.just3ws.com)
          DESC
          "tags" => ["Software Craftsmanship", "Programming", "Architecture", "Jennifer Jones", "WebVisions", "Community Organizing"],
          "categoryId" => "28",
          "defaultLanguage" => "en"
        },
        "status" => {
          "privacyStatus" => "public",
          "selfDeclaredMadeForKids" => false,
          "embeddable" => true
        }
      }
    }
  ]

  queue.each do |item|
    puts "\n======================================================="
    puts "Uploading: #{item[:payload]['snippet']['title']}"
    res = uploader.upload(item[:file], item[:payload])
    puts "Result: #{res['id']}"
  end
end
