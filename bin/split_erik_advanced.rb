#!/usr/bin/env ruby
require 'yaml'

FILE_PATH = "_data/transcripts/erik-meijer-creator-reactive-framework-general.yml"
data = YAML.load_file(FILE_PATH, permitted_classes: [Date, Time], aliases: true)

# Identify the problematic turns: turn 29 and 30.
# Let's just collect all text from turn 29 onwards and re-parse.
text_to_parse = ""
(29..30).each do |i|
  text_to_parse += " " + data["turns"][i]["text"] if data["turns"][i]
end

# We know the conversation starts with S1 (Erik) talking about the Rx grammar/state machine.
# Let's define the precise M1 (Mike) interjections as split points.
m1_prompts = [
  "Well, is it kind of like if, if you start to use the word protocol, it becomes kind of rust, and it becomes dogmatic.",
  "Because protocol is very formal, and it's like, everybody has to do it exactly this way, and if you don't do it this way, you're not, you're not reactive.",
  "That's the next thing you're going to say, this isn't rust ful, this isn't reactive.",
  "and one of the things i think about that's interesting for as a is more of a i i'm a business developer",
  "and like when you say yes exactly and when you say logging you know that goes there to die",
  "yeah then why do you do it",
  "and well in a way it's thinking about what my relationship is to the application",
  "yes that's that's that's how i just processed it now",
  "uh to take a step back a little bit",
  "okay if i'm if i have some pet language and i'm looking at i'm very interested in this reactive stuff",
  "okay well thank you very much for taking the time to stay with me",
  "and you said it's on codeplex",
  "okay and learn rx is is the place",
  "okay perfect Thank you. so much okay that's my edit point"
]

# We will build a regex from these prompts
regex_str = "(" + m1_prompts.map { |p| Regexp.escape(p) }.join('|') + ")"
regex = Regexp.new(regex_str, Regexp::IGNORECASE)

parts = text_to_parse.split(regex)

new_turns = []

# parts[0] is S1
new_turns << { "speaker" => "S1", "text" => parts[0].strip } if parts[0] && !parts[0].strip.empty?

i = 1
while i < parts.length
  # parts[i] is the matched M1 prompt
  # parts[i+1] is the S1 response
  
  m1_text = parts[i].strip
  
  # Sometimes the prompt is part of a larger M1 thought, but we'll just treat the matched string as the start of M1's turn
  # Actually, if there is trailing text in parts[i+1], it's S1. Wait, what if parts[i+1] has S1 text, but also some M1 text before the next split?
  # The split function consumes the delimiter.
  # So parts[i] IS the delimiter (M1).
  # parts[i+1] is everything UP TO the next delimiter. This means parts[i+1] is entirely S1.
  
  new_turns << { "speaker" => "M1", "text" => m1_text }
  new_turns << { "speaker" => "S1", "text" => parts[i+1].strip } if parts[i+1] && !parts[i+1].strip.empty?
  i += 2
end

# Remove turns 29 and 30
data["turns"].slice!(29..30)

# Insert the new turns
data["turns"].insert(29, *new_turns)

# Clean up any consecutive turns by the same speaker
merged_turns = []
data["turns"].each do |turn|
  if merged_turns.any? && merged_turns.last["speaker"] == turn["speaker"]
    merged_turns.last["text"] += " " + turn["text"]
  else
    merged_turns << turn
  end
end

data["turns"] = merged_turns

File.write(FILE_PATH, data.to_yaml)
puts "Successfully split and merged the monolithic block."
