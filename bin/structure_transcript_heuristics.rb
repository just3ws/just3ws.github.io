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

# Extract full text
content = data["content"]
if content.nil? || content.strip.empty?
  if data["turns"] && !data["turns"].empty?
    content = data["turns"].map { |t| t["text"] }.join(" ")
  else
    puts "No content to structure: #{TRANSCRIPT_PATH}"
    exit 0
  end
end

interview_id = File.basename(TRANSCRIPT_PATH, ".yml")
interviews = YAML.load_file("_data/interviews.yml")["items"]
metadata = interviews.find { |i| i["id"] == interview_id } || {}
guest_name = metadata["interviewees"]&.join(", ") || "Guest"

# --- ABBREVIATION PROTECTOR ---
# Protect common periods that aren't end-of-sentence
temp_content = content.gsub(/\balt\.\s*net\b/i, "___ALTDOTNET___")
temp_content.gsub!(/\b\.\s*net\b/i, " ___DOTNET___") # Note the space check

# --- Precise Markers ---
MIKE_MARKERS = [
  /Hi, (?:it's|this is) Mike/i,
  /Hi, (?:it's|this is) Michael/i,
  /I'm (?:sitting|standing) (?:here )?with/i,
  /Welcome to UGtastic/i,
  /Mike (?:Hall )?with UGtastic/i,
  /Thank you (?:very much )?for (?:taking the time|sitting down)/i,
  /Well, thank you (?:very much )?for/i,
  /I (?:really )?appreciate/i,
  /We'll start off with/i,
  /Thanks for taking the time/i
]

GUEST_MARKERS = [
  /Thanks for having me/i,
  /Thank you, Mike/i,
  /It's great to be here/i,
  /Sure, sure\./i
]

# --- Sentence Parser ---
sentences = temp_content.scan(/[^\.!?]+[\.!?]+|\s*[^\.!?]+$/).map(&:strip).reject(&:empty?)

# Restore protected terms
sentences.each do |s|
  s.gsub!("___DOTNET___", ".NET")
  s.gsub!("___ALTDOTNET___", "alt.NET")
end

turns = []
current_speaker = "M1"
current_turn_text = []

def push_turn(turns, speaker, text)
  return if text.nil? || text.strip.empty?
  processed_text = text.strip.gsub(/ {2,}/, " ")
  if turns.last && turns.last["speaker"] == speaker
    turns.last["text"] += " " + processed_text
  else
    turns << { "speaker" => speaker, "text" => processed_text }
  end
end

sentences.each_with_index do |sentence, idx|
  # 1. Detect Speaker Shifts via Explicit Markers
  is_mike_marker = MIKE_MARKERS.any? { |m| sentence =~ m }
  
  if is_mike_marker && current_speaker == "S1"
    push_turn(turns, "S1", current_turn_text.join(" "))
    current_turn_text = []
    current_speaker = "M1"
  end

  # 2. Heuristic: Mike asks a question -> Guest responds
  if current_speaker == "M1" && sentence.end_with?("?")
    current_turn_text << sentence
    push_turn(turns, "M1", current_turn_text.join(" "))
    current_turn_text = []
    current_speaker = "S1"
    next
  end

  # 3. Heuristic: Mike's typical short interjections mid-Guest-monologue
  if current_speaker == "S1" && (sentence.end_with?("?") || sentence.length < 50) && sentence.split.size < 20
     if sentence =~ /^(?:Right|Exactly|Yeah|Sure|Okay|Great)\.?$/i || sentence.end_with?("?")
       push_turn(turns, "S1", current_turn_text.join(" "))
       push_turn(turns, "M1", sentence)
       current_turn_text = []
       next
     end
  end

  current_turn_text << sentence
end

push_turn(turns, current_speaker, current_turn_text.join(" "))

speaker_map = {
  "M1" => { "name" => "Mike Hall", "role" => "Interviewer, UGtastic" },
  "S1" => { "name" => guest_name, "role" => metadata["topic"] || "Guest" }
}

final_output = data.dup
final_output["speaker_map"] = speaker_map
final_output["turns"] = turns
final_output.delete("content")

File.write(TRANSCRIPT_PATH, final_output.to_yaml)
puts "Successfully structured #{TRANSCRIPT_PATH} via Forensic Heuristics v7"
