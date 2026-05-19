#!/usr/bin/env ruby
require 'yaml'

FILE_PATH = "_data/transcripts/dave-thomas-goto-conference-2015.yml"
data = YAML.load_file(FILE_PATH, permitted_classes: [Date, Time], aliases: true)

# The turn starts as monolithic M1. We split it into M1 and S1.
text = data["turns"].first["text"]

# Split at "Well, it's great to be with you again, Mike"
split_point = "Well, it's great to be with you again, Mike"
parts = text.split(split_point, 2)

if parts.size == 2
  new_turns = []
  new_turns << { "speaker" => "M1", "text" => parts[0].strip }
  new_turns << { "speaker" => "S1", "text" => split_point + parts[1].strip }
  
  # Now look for more splits in the new S1 block
  s1_text = new_turns.last["text"]
  # Looking for Mike Hall interjections or questions
  # e.g. "Oh, okay."
  sub_split = "Oh, okay."
  sub_parts = s1_text.split(sub_split, 2)
  if sub_parts.size == 2
    guest_block = sub_parts[0].strip
    mike_interjection = sub_split
    rest_of_guest = sub_parts[1].strip
    
    data["turns"] = []
    data["turns"] << { "speaker" => "M1", "text" => parts[0].strip }
    data["turns"] << { "speaker" => "S1", "text" => guest_block }
    data["turns"] << { "speaker" => "M1", "text" => mike_interjection }
    data["turns"] << { "speaker" => "S1", "text" => rest_of_guest }
    
    File.write(FILE_PATH, data.to_yaml)
    puts "Dave Thomas split successfully."
  end
end
