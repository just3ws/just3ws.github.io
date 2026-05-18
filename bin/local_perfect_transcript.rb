#!/usr/bin/env ruby
require 'yaml'
require 'json'
require 'net/http'
require 'uri'

TRANSCRIPT_PATH = ARGV[0]
unless TRANSCRIPT_PATH && File.exist?(TRANSCRIPT_PATH)
  puts "Usage: #{$0} <path_to_transcript_yml>"
  exit 1
end

begin
  data = YAML.load_file(TRANSCRIPT_PATH)
rescue => e
  puts "Error loading YAML: #{e.message}"
  exit 1
end

content = data["content"] || ""
if content.empty? && data["turns"]
  puts "Transcript already structured. Use a raw file."
  exit 0
end

interview_id = File.basename(TRANSCRIPT_PATH, ".yml")
begin
  interviews = YAML.load_file("_data/interviews.yml")["items"]
  metadata = interviews.find { |i| i["id"] == interview_id } || {}
rescue
  metadata = {}
end

# Even more concise system prompt to save tokens/memory
SYSTEM_PROMPT = <<~PROMPT
  ### SYSTEM ROLE: ARCHIVE FORENSIC AGENT
  Repair phonetic-heavy 2010-2015 tech transcripts.
  Speakers: M1 (Mike Hall - Interviewer), S1 (Subject).
  Task: Transform raw text into YAML turns.
  Format:
  turns:
    - speaker: M1|S1
      text: "..."
PROMPT

def call_ai(prompt)
  uri = URI.parse("http://127.0.0.1:8080/v1/chat/completions")
  http = Net::HTTP.new(uri.host, uri.port)
  http.read_timeout = 600

  request = Net::HTTP::Post.new(uri.path, {'Content-Type' => 'application/json'})
  request.body = {
    model: "local",
    messages: [
      { role: "system", content: SYSTEM_PROMPT },
      { role: "user", content: prompt }
    ],
    temperature: 0.1
  }.to_json

  begin
    response = http.request(request)
    if response.code == "200"
      result = JSON.parse(response.body)
      return result.dig("choices", 0, "message", "content").gsub(/```yaml\n|```/, '').strip
    else
      puts "AI Server Error: #{response.code}"
      return nil
    end
  rescue => e
    puts "HTTP Error: #{e.message}"
    return nil
  end
end

# Tiny chunks (300 words) to avoid GPU OOM
words = content.split(/\s+/)
chunks = []
current_chunk = []
words.each do |word|
  current_chunk << word
  if current_chunk.size >= 300
    chunks << current_chunk.join(" ")
    current_chunk = []
  end
end
chunks << current_chunk.join(" ") unless current_chunk.empty?

all_turns = []
chunks.each_with_index do |chunk, i|
  puts "Processing chunk #{i+1}/#{chunks.size}..."
  yaml_text = call_ai("YAML turns for this text:\n\n#{chunk}")
  if yaml_text
    begin
      parsed = YAML.safe_load(yaml_text)
      if parsed && parsed["turns"]
        all_turns.concat(parsed["turns"])
      else
        puts "Skipping invalid block."
      end
    rescue => e
      puts "Parse Error."
    end
  end
end

speaker_map = {
  "M1" => { "name" => "Mike Hall", "role" => "Interviewer, UGtastic" },
  "S1" => { "name" => metadata["interviewees"]&.join(", ") || "Subject", "role" => metadata["topic"] || "Guest" }
}

final_output = {
  "speaker_map" => speaker_map,
  "turns" => all_turns,
  "insights" => []
}

if all_turns.any?
  File.write(TRANSCRIPT_PATH, final_output.to_yaml)
  puts "Successfully perfected #{TRANSCRIPT_PATH}"
else
  puts "Failed."
end
