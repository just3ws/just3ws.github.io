#!/usr/bin/env ruby
require 'yaml'
require 'json'
require 'net/http'
require 'uri'
require 'fileutils'

# --- CONFIG ---
AI_ENDPOINT = "http://127.0.0.1:8080/v1/chat/completions"
TRANSCRIPTS_DIR = "_data/transcripts"
PROGRESS_FILE = "tmp/enrichment_progress.json"

def call_ai(prompt, system_prompt = "You are a precise technical editor.")
  uri = URI.parse(AI_ENDPOINT)
  http = Net::HTTP.new(uri.host, uri.port)
  http.read_timeout = 600

  request = Net::HTTP::Post.new(uri.path, {'Content-Type' => 'application/json'})
  request.body = {
    model: "local",
    messages: [
      { role: "system", content: system_prompt },
      { role: "user", content: prompt }
    ],
    temperature: 0.1
  }.to_json

  begin
    response = http.request(request)
    if response.code == "200"
      result = JSON.parse(response.body)
      return result.dig("choices", 0, "message", "content").strip
    end
  rescue
  end
  nil
end

# Load data
interviews = YAML.load_file("_data/interviews.yml")["items"]
assets_data = YAML.load_file("_data/video_assets.yml")
assets = assets_data["items"]
progress = File.exist?(PROGRESS_FILE) ? JSON.parse(File.read(PROGRESS_FILE)) : {}

puts "Starting Cerebral Enrichment Pass (v2)..."

interviews.each_with_index do |interview, idx|
  id = interview["id"]
  next if progress[id] == "complete"

  asset = assets.find { |a| a["id"] == interview["video_asset_id"] } || assets.find { |a| a["id"] == id }
  next unless asset && asset["transcript_id"]
  
  transcript_path = File.join(TRANSCRIPTS_DIR, "#{asset["transcript_id"]}.yml")
  next unless File.exist?(transcript_path)
  
  begin
    t_data = YAML.load_file(transcript_path, permitted_classes: [Date, Time], aliases: true)
  rescue => e
    puts "Error loading #{transcript_path}: #{e.message}"
    next
  end

  guest_name = (interview["interviewees"] || []).first || "Expert"
  puts "[#{idx+1}/#{interviews.size}] Processing: #{id} (#{guest_name})..."

  # Extract full text for AI
  turns_text = t_data["turns"] ? t_data["turns"].map{|t| "#{t['speaker']}: #{t['text']}"}.join("\n") : ""
  sample_text = turns_text[0..6000] # More context
  
  enrich_prompt = <<~PROMPT
    ### CONTEXT
    Interviewer: Mike Hall (UGtastic)
    Interviewee: #{guest_name}
    Topic: #{interview["topic"]}
    
    ### TRANSCRIPT SAMPLE
    #{sample_text}
    
    ### TASK
    1.  **Name Correction:** Find any phonetic misspellings of "#{guest_name}" (e.g. if Mike says the name and it's transcribed wrong).
    2.  **Summary:** Write a 3-sentence descriptive summary.
    3.  **Insights:** Extract 3-5 key engineering observations or historical lessons.
    4.  **YouTube Gold Standard:** Generate a high-engagement description:
        - Engaging hook.
        - Detailed summary with emojis.
        - 3-5 relevant hashtags.
        - CTA Link: https://just3ws.github.io/interviews/#{id}
    
    ### OUTPUT SCHEMA (STRICT YAML)
    name_misspellings: ["variant1", "variant2"]
    summary: "..."
    insights:
      - statement: "..."
        type: durable
        confidence: high
    youtube_description: "..."
    
    Return ONLY valid YAML.
  PROMPT

  resp = call_ai(enrich_prompt, "You are a Staff Engineer and Content Strategist. Output only YAML.")
  if resp
    begin
      # Clean up potential markdown formatting
      yaml_text = resp.gsub(/```yaml\n|```/, '').strip
      enrich_data = YAML.safe_load(yaml_text)
      
      # 1. Apply Lexical Name Repairs
      if enrich_data["name_misspellings"] && enrich_data["name_misspellings"].any?
        t_data["turns"]&.each do |turn|
          enrich_data["name_misspellings"].each do |v|
            turn["text"].gsub!(/\b#{Regexp.escape(v)}\b/i, guest_name)
          end
        end
        puts "  Fixed #{enrich_data["name_misspellings"].size} name variants."
      end

      # 2. Update Transcript
      t_data["insights"] = enrich_data["insights"] if enrich_data["insights"]
      
      # 3. Update Asset
      asset["description"] = enrich_data["youtube_description"] if enrich_data["youtube_description"]
      
      # 4. Save
      File.write(transcript_path, t_data.to_yaml)
      progress[id] = "complete"
      File.write(PROGRESS_FILE, progress.to_json)
      
      # Save assets.yml every 10 items to prevent data loss on crash
      if idx % 10 == 0
        File.write("_data/video_assets.yml", assets_data.to_yaml)
      end
      
      puts "  Successfully enriched."
    rescue => e
      puts "  Error: #{e.message}"
      # Log the failed YAML for debugging
      File.write("tmp/failed_#{id}.yml", resp)
    end
  end
end

# Final save
File.write("_data/video_assets.yml", assets_data.to_yaml)
puts "Enrichment pass finished."
