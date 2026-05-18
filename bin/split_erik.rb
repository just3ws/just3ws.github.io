#!/usr/bin/env ruby
require 'yaml'

FILE_PATH = "_data/transcripts/erik-meijer-creator-reactive-framework-general.yml"
data = YAML.load_file(FILE_PATH, permitted_classes: [Date, Time], aliases: true)

last_idx = data["turns"].rindex { |t| t["speaker"] == "S1" && t["text"].length > 2000 }

if last_idx
  text = data["turns"][last_idx]["text"]
  
  # Define the exact splits
  split_regex = /(uh to take a step back a little bit.*?or for java again|okay if i'm if i have some pet language.*?underlying principles are|okay well thank you very much for taking the time to stay with me i really appreciate it|and you said it's on codeplex|okay and learn rx is is the place)/i

  parts = text.split(split_regex)
  
  new_turns = []
  
  # parts[0] is S1
  new_turns << { "speaker" => "S1", "text" => parts[0].strip }
  
  # parts[1] is M1, parts[2] is S1...
  i = 1
  while i < parts.length
    new_turns << { "speaker" => "M1", "text" => parts[i].strip }
    new_turns << { "speaker" => "S1", "text" => parts[i+1].strip } if parts[i+1]
    i += 2
  end
  
  # Replace the monolithic turn with the new ones
  data["turns"].delete_at(last_idx)
  data["turns"].insert(last_idx, *new_turns)
  
  File.write(FILE_PATH, data.to_yaml)
  puts "Split completed successfully!"
end
