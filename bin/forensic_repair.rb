#!/usr/bin/env ruby
# frozen_string_literal: true

# bin/forensic_repair.rb — Automated Forensic Repair for Transcript Validation Failures

require 'yaml'
require 'time'
require 'fileutils'

class ForensicRepair
  TRANSCRIPTS_DIR = "_data/transcripts"
  MAX_TURN_CHARS = 3000

  def initialize(target_id = nil)
    @target_id = target_id
  end

  def run
    files = if @target_id
      [File.join(TRANSCRIPTS_DIR, "#{@target_id}.yml")]
    else
      Dir.glob(File.join(TRANSCRIPTS_DIR, "*.yml")).sort
    end

    repaired = 0
    failed_still = 0

    files.each do |path|
      next unless File.exist?(path)
      id = File.basename(path, ".yml")
      data = YAML.load_file(path, permitted_classes: [Date, Time], aliases: true) rescue next
      next unless data["validation_error"]

      backup_data = Marshal.load(Marshal.dump(data))

      puts "🔧 Repairing: #{id}"
      puts "   Original error: #{data['validation_error']}"

      modified = false

      # 1. Split Long Turns (>3000 chars) & Collapsed Monologues
      if data["turns"]
        new_turns = []
        data["turns"].each do |turn|
          if turn["text"].to_s.length > MAX_TURN_CHARS
            splits = split_long_turn(turn["text"], turn["speaker"])
            new_turns.concat(splits)
            modified = true
          else
            new_turns << turn
          end
        end
        data["turns"] = new_turns if modified
      end

      # 2. Fix Interviewer Overload / Collapsed Single Turn
      if data["turns"] && (data["turns"].size <= 3 || m1_ratio(data["turns"]) >= 0.80)
        text_blob = data["turns"].map { |t| t["text"] }.join(" ")
        restructured = parse_dialogue_turns(text_blob)
        if restructured.size > 1 && m1_ratio(restructured) < 0.60
          data["turns"] = restructured
          modified = true
        end
      end

      if modified
        data.delete("validation_error")
        File.write(path, data.to_yaml)

        # Run validate module
        output = `ruby bin/archive/modules/validate.rb #{id} --force 2>&1`
        if $?.success?
          puts "   ✅ REPAIRED & VALIDATED!"
          repaired += 1
        else
          File.write(path, backup_data.to_yaml)
          puts "   ⚠️ STILL FAILING: #{output.strip}"
          failed_still += 1
        end
      else
        puts "   ⏭️ No automated rule matched, requires manual/diarization pass"
      end
    end

    puts "\n--- FORENSIC REPAIR SUMMARY ---"
    puts "Repaired & Validated: #{repaired}"
    puts "Still Failing:       #{failed_still}"
  end

  private

  def m1_ratio(turns)
    m1_words = turns.select { |t| t["speaker"] == "M1" }.map { |t| word_count(t["text"]) }.sum
    total = turns.map { |t| word_count(t["text"]) }.sum
    return 0.0 if total.zero?
    m1_words.to_f / total
  end

  def word_count(text)
    text.to_s.split(/\s+/).reject(&:empty?).size
  end

  def split_long_turn(text, speaker)
    return [{ "speaker" => speaker, "text" => text }] if text.length <= MAX_TURN_CHARS

    sentences = text.scan(/.*?(?:[.!?]+(?:\s+|\z)|\n+)/)
    sentences = [text] if sentences.empty?

    chunks = []
    current = ""
    current_speaker = speaker

    sentences.each do |s|
      s_clean = s.strip
      # Check if long turn contains internal speaker transitions (Host question vs Guest answer)
      if s_clean.match?(/\A(?:so\s+how\s+does\b|how\s+can\b|where\s+can\b|okay\s+great\b|well\s+thanks?\b|what\s+about\b)/i) && speaker == "S1"
        chunks << { "speaker" => current_speaker, "text" => current.strip } unless current.empty?
        chunks << { "speaker" => "M1", "text" => s_clean }
        current = ""
        current_speaker = "M1"
        next
      elsif s_clean.match?(/\A(?:sure\s+yeah\b|yeah\s+so\b|well\s+we\b|my\s+name\b)/i) && current_speaker == "M1"
        chunks << { "speaker" => "M1", "text" => current.strip } unless current.empty?
        current = s_clean
        current_speaker = "S1"
        next
      end

      if (current + " " + s_clean).length > MAX_TURN_CHARS && !current.empty?
        chunks << { "speaker" => current_speaker, "text" => current.strip }
        current = s_clean
      else
        current = current.empty? ? s_clean : current + " " + s_clean
      end
    end

    chunks << { "speaker" => current_speaker, "text" => current.strip } unless current.empty?
    chunks.reject { |c| c["text"].empty? }
  end

  def parse_dialogue_turns(text)
    sentences = text.scan(/.*?[.!?](?:\s+|\z)/)
    turns = []
    current_speaker = "M1"
    current_text = ""

    sentences.each_with_index do |s, idx|
      s_clean = s.strip

      # Mike Hall host heuristics: intros, location framing, questions, sign-offs
      is_mike_hall_intro = s_clean.match?(/\A(?:hi,?\s+i'm\s+mike\s+(?:hall\s+)?with\s+ugtastic|i'm\s+mike|welcome\s+to|here\s+at\s+goto|here\s+at\s+railsconf|standing\s+here\s+with)/i)
      is_mike_hall_outro = s_clean.match?(/(?:thank\s+you\s+for\s+taking\s+the\s+time|appreciate\s+you\s+taking\s+the\s+time|thanks\s+for\s+speaking\s+with\s+me|ugtastic\.com)/i)
      
      s1_trigger = s_clean.match?(/\A(?:well\b|the\s+differences\b|yeah\b|absolutely\b|sure\b|so\s+the\b|our\b|my\b|i\s+(?:think|spent|was|did|work|started|came)\b)/i) && current_text.length > 50
      m1_trigger = (is_mike_hall_intro || is_mike_hall_outro || s_clean.match?(/\A(?:hi\b|welcome\b|so\s+so\b|right\b|tell\s+me\b|what\b|how\b|can\s+you\b|is\s+there\b|thanks?\b)/i)) && current_speaker == "S1"

      if is_mike_hall_intro
        turns << { "speaker" => "S1", "text" => current_text.strip } unless current_text.empty?
        current_speaker = "M1"
        current_text = s_clean
      elsif current_speaker == "M1" && (s1_trigger || s.include?("?"))
        current_text += " " + s_clean
        turns << { "speaker" => "M1", "text" => current_text.strip }
        current_speaker = "S1"
        current_text = ""
      elsif current_speaker == "S1" && m1_trigger
        turns << { "speaker" => "S1", "text" => current_text.strip } unless current_text.empty?
        current_speaker = "M1"
        current_text = s_clean
      else
        current_text = current_text.empty? ? s_clean : current_text + " " + s_clean
      end
    end

    turns << { "speaker" => current_speaker, "text" => current_text.strip } unless current_text.strip.empty?
    
    merged = []
    turns.each do |t|
      next if t["text"].empty?
      if merged.any? && merged.last["speaker"] == t["speaker"]
        merged.last["text"] += " " + t["text"]
      else
        merged << t
      end
    end
    merged
  end
end

target_id = ARGV[0]
ForensicRepair.new(target_id).run
