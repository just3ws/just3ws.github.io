require 'yaml'

path = "_data/transcripts/dave-thomas-goto-conference-2015.yml"
data = YAML.load_file(path, permitted_classes: [Date, Time], aliases: true)

# The turn starts as a monolithic M1.
text = data["turns"].first["text"]

# Split at Dave's first words: "Well, it's great to be with you again, Mike"
split_points = [
  { marker: "Well, it's great to be with you again, Mike", speaker: "S1" },
  { marker: "Well, and one of the things I like about GOTO Conference", speaker: "M1" },
  { marker: "Well, I think that's really the mission we have", speaker: "S1" },
  { marker: "Oh, okay.", speaker: "M1" },
  { marker: "So we try and, we try and involve", speaker: "S1" },
  { marker: "So a little bit of serendipity, you know.", speaker: "M1" },
  { marker: "And, I mean, and just seeing some of the credentials", speaker: "S1" }, # Wait, this is still Mike? 
  { marker: "JavaScript, it's a really broad spectrum.", speaker: "M1" },
  { marker: "Well, I think one of the things that, you know", speaker: "S1" },
  { marker: "Right, yeah.", speaker: "M1" },
  { marker: "And now it's moving more into the mainstream", speaker: "S1" },
  { marker: "Yeah, exactly. Right?", speaker: "M1" },
  { marker: "Yeah, exactly.", speaker: "S1" },
  { marker: "Yeah. Yeah. Yeah. Yeah. Yeah. Yeah. Yeah.", speaker: "M1" }
]

# Let's re-parse completely
full_text = text
turns = []
current_pos = 0

split_points.each do |point|
  idx = full_text.index(point[:marker], current_pos)
  if idx
    # Text before this marker belongs to the PREVIOUS speaker
    prev_text = full_text[current_pos...idx].strip
    if !prev_text.empty?
      # We don't know the first speaker for the very first part? 
      # The first part is always M1.
      speaker = turns.empty? ? "M1" : (turns.last["speaker"] == "M1" ? "S1" : "M1")
      turns << { "speaker" => speaker, "text" => prev_text }
    end
    current_pos = idx
  end
end

# Add the final segment
final_text = full_text[current_pos..-1].strip
if !final_text.empty?
   speaker = turns.last && turns.last["speaker"] == "M1" ? "S1" : "M1"
   turns << { "speaker" => speaker, "text" => final_text }
end

# Merge consecutive speakers if any
merged = []
turns.each do |t|
  if merged.last && merged.last["speaker"] == t["speaker"]
    merged.last["text"] += " " + t["text"]
  else
    merged << t
  end
end

data["turns"] = merged
File.write(path, data.to_yaml)
puts "Repaired Dave Thomas 2015 turns."
