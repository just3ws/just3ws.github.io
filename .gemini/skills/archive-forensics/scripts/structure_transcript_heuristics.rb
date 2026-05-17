#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'

TRANSCRIPT_PATH = ARGV[0]
unless TRANSCRIPT_PATH && File.exist?(TRANSCRIPT_PATH)
  puts "Usage: #{$0} <path_to_transcript_yml>"
  exit 1
end

data = YAML.load_file(TRANSCRIPT_PATH)
content = data["content"] || ""

if content.empty? && data["turns"]
  puts "Already structured."
  exit 0
end

interview_id = File.basename(TRANSCRIPT_PATH, ".yml")
interviews = YAML.load_file("_data/interviews.yml")["items"]
metadata = interviews.find { |i| i["id"] == interview_id } || {}

guest_name = metadata["interviewees"]&.join(", ") || "Guest"

# --- Heuristic Segmentation ---
# We look for markers where Mike (M1) or the Guest (S1) typically start speaking.
# 1. Mike's intro: "Hi, it's Mike", "I'm sitting here with"
# 2. Back-channeling that usually ends a turn: "Right.", "Okay.", "Yeah.", "Sure."
# 3. Question markers: "So, ...?", "Can you tell me...?"

# Simple approach: split by typical Mike-isms
parts = content.split(/(Hi, it's Mike with UGtastic|Thank you for sitting down with me|Thanks for having me|So, can you tell us|Right\.|Okay\.|Yeah\.)/)

turns = []
current_speaker = "M1" # Start with Mike usually

parts.each do |part|
  next if part.strip.empty?
  
  # Heuristic for speaker change
  if part =~ /Hi, it's Mike|Thank you for sitting down|So, can you tell/
    current_speaker = "M1"
  elsif part =~ /Thanks for having me/
    current_speaker = "S1"
  end
  
  # If we have a sequence of M1, S1, M1, S1...
  # If the current part is just a back-channel, we might flip
  if part == "Right." || part == "Okay." || part == "Yeah."
     # These can be M1 confirming or S1 agreeing. 
     # For now, keep current.
  end

  turns << { "speaker" => current_speaker, "text" => part.strip }
  
  # Toggle for next part if it's long text (likely the other person responding)
  if part.length > 200
    current_speaker = (current_speaker == "M1" ? "S1" : "M1")
  end
end

speaker_map = {
  "M1" => { "name" => "Mike Hall", "role" => "Interviewer, UGtastic" },
  "S1" => { "name" => guest_name, "role" => metadata["topic"] || "Guest" }
}

final_output = {
  "speaker_map" => speaker_map,
  "turns" => turns,
  "insights" => []
}

File.write(TRANSCRIPT_PATH, final_output.to_yaml)
puts "Successfully structured #{TRANSCRIPT_PATH} via Heuristics"
