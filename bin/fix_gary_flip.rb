require 'yaml'

path = "_data/transcripts/gary-bernhardt-software-craftsmanship-north-america-2012.yml"
data = YAML.load_file(path, permitted_classes: [Date, Time], aliases: true)

# Identify the turn where the confusion starts
# "And I'm not exactly sure how to couch the question" is Mike Hall (M1)
# It is currently assigned to S1.

turns = data["turns"]
start_fix = false

turns.each_with_index do |turn, i|
  if turn["text"].include?("And I'm not exactly sure how to couch the question")
    start_fix = true
  end
  
  if start_fix
    # Swap M1 and S1
    turn["speaker"] = (turn["speaker"] == "M1" ? "S1" : "M1")
  end
end

# Now handle the long monologue splits manually
# Specifically the part that was merged:
# "So, it was--you--you see, the way you described it was the insular bubble of--and--and not enough cross-pollination. Sure. Yeah. Because that's--that's interesting..."

new_turns = []
turns.each do |turn|
  if turn["speaker"] == "S1" && turn["text"].include?("got excited about them internally")
    # This is Gary's monologue about the Cleveland Ruby community.
    # It contains Mike's interjection at the end.
    text = turn["text"]
    split_marker = "So, it was--you--you see, the way you described it was"
    parts = text.split(split_marker)
    
    if parts.size == 2
      new_turns << { "speaker" => "S1", "text" => parts[0].strip }
      new_turns << { "speaker" => "M1", "text" => split_marker + parts[1].strip }
    else
      new_turns << turn
    end
  elsif turn["speaker"] == "M1" && turn["text"].include?("going to be things that are specific to a group.")
    # This is Gary (S1) but now correctly M1 after our swap above, 
    # but wait, the logic is confusing. Let's just do a clean pass.
    new_turns << turn
  else
    new_turns << turn
  end
end

# Final check: any more interjections merged?
# "What--what--what is it that Python has? The doc units?"
final_turns = []
new_turns.each do |turn|
  if turn["text"].include?("What--what--what is it that Python has?") && turn["speaker"] == "S1"
     parts = turn["text"].split("What--what--what is it that Python has?")
     final_turns << { "speaker" => "S1", "text" => parts[0].strip }
     final_turns << { "speaker" => "M1", "text" => "What--what--what is it that Python has? The doc units?" }
     final_turns << { "speaker" => "S1", "text" => parts[1].sub("The doc units?", "").strip }
  else
     final_turns << turn
  end
end

# Merge consecutive speakers again
merged = []
final_turns.each do |t|
  if merged.any? && merged.last["speaker"] == t["speaker"]
    merged.last["text"] += " " + t["text"]
  else
    merged << t
  end
end

data["turns"] = merged
File.write(path, data.to_yaml)
puts "Gary Bernhardt 2012 speaker flip fixed surgically."
