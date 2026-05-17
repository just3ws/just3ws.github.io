#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'

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

content = data["content"]
if content.nil? || content.strip.empty?
  if data["turns"] && !data["turns"].empty?
    content = data["turns"].map { |t| t["text"] }.join("\n\n")
  else
    puts "No content to structure: #{TRANSCRIPT_PATH}"
    exit 0
  end
end

interview_id = File.basename(TRANSCRIPT_PATH, ".yml")
interviews = YAML.load_file("_data/interviews.yml")["items"]
metadata = interviews.find { |i| i["id"] == interview_id } || {}
guest_name = metadata["interviewees"]&.join(", ") || "Guest"

# --- Focused Mike Markers ---
# Only include things that are ALMOST CERTAINLY Mike
MIKE_MARKERS = [
  /Hi, (?:it's|this is) Mike/i,
  /Hi, (?:it's|this is) Michael/i,
  /I'm (?:sitting|standing) (?:here )?with/i,
  /Welcome to UGtastic/i,
  /Mike (?:Hall )?with UGtastic/i,
  /Thank you (?:very much )?for (?:taking the time|sitting down)/i
]

GUEST_MARKERS = [
  /Thanks for having me/i,
  /Thank you, Mike/i,
  /It's great to be here/i
]

blocks = content.split(/\n+/).map(&:strip).reject(&:empty?)

turns = []
current_speaker = "M1"
current_turn_text = []

blocks.each do |block|
  is_mike = MIKE_MARKERS.any? { |m| block =~ m }
  is_guest = GUEST_MARKERS.any? { |m| block =~ m }

  if is_mike && current_speaker == "S1"
    text = current_turn_text.join("\n\n").strip
    turns << { "speaker" => "S1", "text" => text } unless text.empty?
    current_turn_text = []
    current_speaker = "M1"
  elsif is_guest && current_speaker == "M1"
    text = current_turn_text.join("\n\n").strip
    turns << { "speaker" => "M1", "text" => text } unless text.empty?
    current_turn_text = []
    current_speaker = "S1"
  end

  current_turn_text << block

  # If Mike asks a question, definitely assume Guest responds next
  if current_speaker == "M1" && block.end_with?("?")
    text = current_turn_text.join("\n\n").strip
    turns << { "speaker" => "M1", "text" => text } unless text.empty?
    current_turn_text = []
    current_speaker = "S1"
  # If a block is long and ends in a period, and current is Mike, 
  # it's possible it was a statement, but usually Mike's turns are short.
  elsif current_speaker == "M1" && block.length > 300
    text = current_turn_text.join("\n\n").strip
    turns << { "speaker" => "M1", "text" => text } unless text.empty?
    current_turn_text = []
    current_speaker = "S1"
  end
end

if current_turn_text.any?
  text = current_turn_text.join("\n\n").strip
  turns << { "speaker" => current_speaker, "text" => text } unless text.empty?
end

speaker_map = {
  "M1" => { "name" => "Mike Hall", "role" => "Interviewer, UGtastic" },
  "S1" => { "name" => guest_name, "role" => metadata["topic"] || "Guest" }
}

final_output = data.dup
final_output["speaker_map"] = speaker_map
final_output["turns"] = turns
final_output.delete("content")

File.write(TRANSCRIPT_PATH, final_output.to_yaml)
puts "Successfully structured #{TRANSCRIPT_PATH} via Forensic Heuristics (v3)"
