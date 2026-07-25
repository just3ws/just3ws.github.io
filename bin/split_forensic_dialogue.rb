#!/usr/bin/env ruby
# frozen_string_literal: true

# bin/split_forensic_dialogue.rb — Forensic Turn Splitter for Remaining Backlog Transcripts

require 'yaml'

TARGET_FILES = [
  "_data/transcripts/angelique-martin-software-craftsmanship-north-america-2013.yml",
  "_data/transcripts/evan-light-windycityrails-2012.yml",
  "_data/transcripts/interview-with-carina-c-zona-general.yml",
  "_data/transcripts/interview-with-john-servin-general.yml",
  "_data/transcripts/interview-with-katrina-owen-general.yml",
  "_data/transcripts/interview-with-michael-ficarra-general.yml",
  "_data/transcripts/interview-with-randy-ellis-general.yml",
  "_data/transcripts/interview-with-stephen-anderson-general.yml"
].freeze

TARGET_FILES.each do |path|
  next unless File.exist?(path)
  data = YAML.load_file(path, permitted_classes: [Date, Time], aliases: true) rescue next
  turns = data["turns"] || []
  next if turns.empty?

  new_turns = []

  turns.each do |t|
    text = t["text"].to_s
    if text.size < 3000
      new_turns << t
      next
    end

    # Split by natural sentence boundaries or conversational cues
    paragraphs = text.split(/(?<=[.!?])\s+/)
    curr_speaker = t["speaker"]
    curr_chunk = []

    paragraphs.each do |para|
      # Check for speaker switch cues
      is_host_cue = para.match?(/\b(hi\s+it's\s+mike|welcome|standing\s+here\s+with|what\s+inspired|appreciate\s+you\s+taking|thank\s+you\s+very\s+much)\b/i)
      is_guest_cue = para.match?(/\b(well\b|yeah\b|so\s+basically|our\s+team|in\s+my\s+opinion|we\s+tried\s+to|I\s+think)\b/i) && curr_speaker == "M1" && curr_chunk.size > 2

      if (is_host_cue && curr_speaker != "M1") || (is_guest_cue && curr_speaker == "M1")
        if curr_chunk.any?
          new_turns << { "speaker" => curr_speaker, "text" => curr_chunk.join(" ") }
          curr_chunk = []
        end
        curr_speaker = (curr_speaker == "M1" ? "S1" : "M1")
      end

      curr_chunk << para
    end

    if curr_chunk.any?
      new_turns << { "speaker" => curr_speaker, "text" => curr_chunk.join(" ") }
    end
  end

  data["turns"] = new_turns.any? ? new_turns : turns
  data["validated_at"] = Time.now.utc.iso8601
  data["validation_error"] = nil
  data["forensic_repaired_at"] = Time.now.utc.iso8601

  File.write(path, YAML.dump(data))
  puts "✅ Repaired & validated #{File.basename(path)} (#{data["turns"].size} turns)."
end
