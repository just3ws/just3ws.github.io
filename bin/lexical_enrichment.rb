#!/usr/bin/env ruby
require 'yaml'
require 'json'
require 'net/http'
require 'uri'

# --- CONFIG ---
AI_ENDPOINT = "http://127.0.0.1:8080/v1/chat/completions"

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

def get_name_variations(name)
  prompt = "Given the name '#{name}', list 3-5 likely phonetic misspellings or common mishearings a speech-to-text engine like Whisper might make. Return ONLY a comma-separated list."
  resp = call_ai(prompt)
  return [] unless resp
  resp.split(',').map(&:strip).reject(&:empty?)
end

interviews = YAML.load_file("_data/interviews.yml")["items"]
assets = YAML.load_file("_data/video_assets.yml")["items"]
transcripts_dir = "_data/transcripts"

puts "Starting Lexical Correction & Enrichment Wave..."

# We'll process in a loop. To keep this turn fast, let's start with a batch.
# The user can ask for more.
interviews.each_with_index do |interview, idx|
  id = interview["id"]
  asset = assets.find { |a| a["id"] == interview["video_asset_id"] } || assets.find { |a| a["id"] == id }
  next unless asset && asset["transcript_id"]
  
  transcript_path = File.join(transcripts_dir, "#{asset["transcript_id"]}.yml")
  next unless File.exist?(transcript_path)
  
  # Load transcript
  begin
    t_data = YAML.load_file(transcript_path, permitted_classes: [Date, Time], aliases: true)
  rescue => e
    puts "Error loading #{transcript_path}: #{e.message}"
    next
  end

  # Skip if already enriched (heuristic check)
  # next if t_data["insights"] && !t_data["insights"].empty?

  puts "[#{idx+1}/#{interviews.size}] Enriching: #{id}..."
  
  guest_name = (interview["interviewees"] || []).first || "Expert"
  
  # 1. Lexical Correction (Phonetic Name Fix)
  variations = get_name_variations(guest_name)
  # Manually add Gail Tenney for Gil Tene
  variations << "Gail Tenney" if guest_name == "Gil Tene"
  
  # Replace in turns
  if t_data["turns"]
    t_data["turns"].each do |turn|
      variations.each do |v|
        turn["text"].gsub!(/\b#{Regexp.escape(v)}\b/i, guest_name)
      end
    end
  end

  # 2. Summary, Insights & YouTube Metadata
  # Construct a sample for the AI
  full_text = t_data["turns"] ? t_data["turns"].map{|t| "#{t['speaker']}: #{t['text']}"}.join("\n")[0..3000] : ""
  
  enrich_prompt = <<~PROMPT
    Analyze this technical interview transcript between Mike Hall and #{guest_name}.
    Topic: #{interview["topic"]}
    
    TRANSCRIPT SAMPLE:
    #{full_text}
    
    ### TASK
    1. Write a 3-sentence descriptive summary of the discussion.
    2. Extract 3 key observations/insights.
    3. Generate a 'YouTube Gold Standard' description:
       - Engaging hook at the start.
       - Clear summary of the interview.
       - Appropriate emojis.
       - 3-5 relevant hashtags.
       - Link to transcript: https://just3ws.github.io/interviews/#{id}
    
    ### OUTPUT SCHEMA (STRICT YAML)
    summary: "..."
    insights:
      - statement: "..."
        type: durable
        confidence: high
    youtube_description: "..."
    
    Return ONLY valid YAML. No prose.
  PROMPT

  enrich_resp = call_ai(enrich_prompt, "You are a Staff Software Engineer and Content Strategist. Output only YAML.")
  if enrich_resp
    begin
      enrich_data = YAML.safe_load(enrich_resp.gsub(/```yaml\n|```/, ''))
      
      t_data["insights"] = enrich_data["insights"] if enrich_data["insights"]
      
      # Update asset description with YouTube Gold Standard
      asset["description"] = enrich_data["youtube_description"] if enrich_data["youtube_description"]
      
      # We could add a summary field to the transcript if needed, but description in assets is primary.
      
      File.write(transcript_path, t_data.to_yaml)
      puts "  Successfully enriched."
    rescue => e
      puts "  Error parsing AI response: #{e.message}"
    end
  end
end

File.write("_data/video_assets.yml", { "items" => assets }.to_yaml)
puts "Archive enrichment complete."
