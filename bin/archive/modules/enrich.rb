#!/usr/bin/env ruby
require 'yaml'
require 'json'
require 'net/http'
require 'uri'
require 'time'

# --- ENRICH MODULE (Transform) ---
# Generates summaries, topics, and insights via local AI.

id = ARGV[0]
force = ARGV.include?("--force")
path = "_data/transcripts/#{id}.yml"

unless File.exist?(path)
  puts "ERROR: File not found #{path}"
  exit 1
end

data = YAML.load_file(path, permitted_classes: [Date, Time], aliases: true) rescue nil
unless data
  puts "ERROR: YAML parse error for #{id}"
  exit 1
end

# Idempotency check
if data["enriched_at"] && !force
  puts "SKIPPED"
  exit 0
end

# Extract text for AI
text = if data["turns"]
  data["turns"].map { |t| "#{t['speaker']}: #{t['text']}" }.join("\n\n")
else
  data["content"]
end

if text.nil? || text.strip.empty?
  puts "ERROR: No text content found for enrichment"
  exit 1
end

# --- AI CALL ---
prompt = <<~PROMPT
  You are an expert technical editor. Analyze the following technical interview and extract:
  1. A 2-3 sentence executive summary.
  2. 3-5 critical technical insights (statements of durable wisdom).
  3. A list of 3-5 specific technical topics/keywords.

  Output ONLY valid YAML matching this structure:
  summary: "..."
  topics: ["...", "..."]
  insights:
    - statement: "..."
      type: durable
      confidence: high

  TEXT:
  #{text.split(/\s+/).first(1500).join(" ")} # Limit to 1500 words for local AI stability
PROMPT

uri = URI.parse("http://127.0.0.1:8080/v1/chat/completions")
http = Net::HTTP.new(uri.host, uri.port)
http.read_timeout = 600

request = Net::HTTP::Post.new(uri.path, {'Content-Type' => 'application/json'})
request.body = {
  model: "local",
  messages: [
    { role: "system", content: "You are a precise data extraction tool. Output only YAML." },
    { role: "user", content: prompt }
  ],
  temperature: 0.1
}.to_json

begin
  response = http.request(request)
  if response.code == "200"
    result = JSON.parse(response.body)
    yaml_output = result.dig("choices", 0, "message", "content").gsub(/```yaml\n|```/, '').strip
    
    parsed_enrichment = YAML.safe_load(yaml_output)
    if parsed_enrichment && parsed_enrichment["summary"]
      data["summary"] = parsed_enrichment["summary"]
      data["topics"] = parsed_enrichment["topics"]
      data["insights"] = parsed_enrichment["insights"]
      data["enriched_at"] = Time.now.iso8601
      
      File.write(path, data.to_yaml)
      puts "SUCCESS"
    else
      puts "ERROR: AI output missing required fields"
      exit 1
    end
  else
    puts "ERROR: AI server returned #{response.code}"
    exit 1
  end
rescue => e
  puts "ERROR: AI processing failed: #{e.message}"
  exit 1
end
