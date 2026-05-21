#!/usr/bin/env ruby
require 'yaml'
require 'json'
require 'net/http'
require 'uri'
require 'time'

# --- RESTRUCTURE MODULE (High-Fidelity AI) ---
# Safely restores back-and-forth dialogue using local AI.

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

# Check for idempotency: skip if already high-fidelity and not forced
if data["restructured_at"] && !force
  puts "SKIPPED"
  exit 0
end

# Extract full text from turns or content
text = data["turns"] ? data["turns"].map{|t| t["text"]}.join(" ") : data["content"]

if text.nil? || text.strip.empty?
  puts "ERROR: No text content for restructuring"
  exit 1
end

# PRE-PROCESS: Strip common transcript artifacts that break YAML parsing
# e.g. "- Hi, I am Mike" -> "Hi, I am Mike"
text = text.gsub(/^\s*-\s+/, "").gsub(/\n\s*-\s+/, "\n")


# Get Guest Name for AI context
interviews = YAML.load_file("_data/interviews.yml")["items"]
metadata = interviews.find { |i| i["id"] == id } || {}
guest_name = Array(metadata["interviewees"]).first || "the guest"

# --- AI CHUNKING LOGIC ---
# Split into ~500 word chunks to balance context and stability
words = text.split(/\s+/)
chunks = words.each_slice(500).map{|s| s.join(" ")}
all_turns = []

# AI Endpoint
uri = URI.parse("http://127.0.0.1:8080/v1/chat/completions")
http = Net::HTTP.new(uri.host, uri.port)
http.read_timeout = 600

chunks.each_with_index do |chunk, i|
  prompt = <<~PROMPT
    You are an expert technical transcript editor. Break the following interview text into a high-fidelity back-and-forth dialogue.
    
    SPEAKERS:
    - M1: Mike Hall (Interviewer/Host). His turns are usually questions, short prompts, or interjections like "Right", "Exactly", "Okay".
    - S1: #{guest_name} (Technical Guest). His turns are usually long, detailed technical explanations and answers.
    
    TASK:
    Identify every time the speaker changes. If you see a question followed by a detailed answer, split them. 
    Ensure #{guest_name} (S1) is attributed all the detailed technical content.
    
    TEXT:
    #{chunk}
    
    Output ONLY valid YAML matching this structure:
    turns:
      - speaker: M1|S1
        text: "..."
  PROMPT

  request = Net::HTTP::Post.new(uri.path, {'Content-Type' => 'application/json'})
  request.body = {
    model: "local",
    messages: [
      { role: "system", content: "You are a precise data formatter. Output only YAML. No prose." },
      { role: "user", content: prompt }
    ],
    temperature: 0.1
  }.to_json

  begin
    response = http.request(request)
    if response.code == "200"
      result = JSON.parse(response.body)
      yaml_output = result.dig("choices", 0, "message", "content")
      
      # Extract only the turns: block if AI adds fluff
      if yaml_output =~ /turns:\s*\n(.*?)(?:\n\n|\z)/m
        yaml_output = "turns:\n" + $1
      end
      
      # Clean common AI formatting errors
      yaml_output = yaml_output.gsub(/```yaml\n|```/, '').strip
      
      begin
        parsed = YAML.safe_load(yaml_output)
        if parsed && parsed["turns"]
          all_turns.concat(parsed["turns"])
        end
      rescue => e
        # Fallback: JSON parse
        begin
          parsed = JSON.parse(yaml_output)
          if parsed && parsed["turns"]
            all_turns.concat(parsed["turns"])
          end
        rescue
          puts "ERROR: Chunk #{i} parse failed: #{e.message}"
          exit 1
        end
      end
    else
      puts "ERROR: AI server error at chunk #{i}: #{response.code}"
      exit 1
    end
  rescue => e
    puts "ERROR: Chunk #{i} processing failed: #{e.message}"
    exit 1
  end
end

if all_turns.any?
  # Merge consecutive turns by the same speaker
  merged = []
  all_turns.each do |t|
    if merged.any? && merged.last["speaker"] == t["speaker"]
      merged.last["text"] += " " + t["text"]
    else
      merged << t
    end
  end
  
  data["turns"] = merged
  data.delete("content")
  data["restructured_at"] = Time.now.iso8601
  
  File.write(path, data.to_yaml)
  puts "SUCCESS"
else
  puts "ERROR: No turns generated"
  exit 1
end
