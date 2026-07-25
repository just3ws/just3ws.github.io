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

      # 1. Fix Long Turns (>3000 chars)
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

  def split_long_turn(text, speaker)
    return [{ "speaker" => speaker, "text" => text }] if text.length <= MAX_TURN_CHARS

    # Sentence boundary split
    sentences = text.scan(/.*?(?:[.!?]+(?:\s+|\z)|\n+)/)
    sentences = [text] if sentences.empty?

    chunks = []
    current = ""

    sentences.each do |s|
      if (current + s).length > MAX_TURN_CHARS && !current.empty?
        chunks << current.strip
        current = s
      else
        current += s
      end
    end
    chunks << current.strip unless current.empty?

    chunks.map { |c| { "speaker" => speaker, "text" => c } }
  end
end

target_id = ARGV[0]
ForensicRepair.new(target_id).run
