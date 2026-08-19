#!/usr/bin/env ruby
# frozen_string_literal: true

# bin/audit_prose_humanity.rb
# Grammarly for just3ws: Audits prose for plain language, neuroinclusive readability,
# cognitive load, and AI jargon density across site Markdown and YAML data files.

require 'yaml'
require 'optparse'

# Configurable Jargon and Buzzword Dictionaries
AI_JARGON_TERMS = [
  "arithmetic witness", "arithmetic witnesses", "formal combat assurance",
  "vector execution", "vector promotion", "hyper-scalable", "synergistic",
  "paradigm shift", "disruptive innovation", "thought leadership synergy",
  "holistic framework alignment", "lexical witness", "algorithmic determinism witness"
].freeze

PASSIVE_VOICE_PATTERNS = [
  /\bwas\s+\w+ed\s+by\b/i,
  /\bwere\s+\w+ed\s+by\b/i,
  /\bis\s+being\s+\w+ed\b/i,
  /\bhas\s+been\s+\w+ed\b/i
].freeze

POOR_LINK_TEXT = [
  /\bclick\s+here\b/i,
  /\bread\s+more\b/i,
  /\bthis\s+link\b/i,
  /\blink\b/i
].freeze

class ProseHumanityAuditor
  attr_reader :files, :issues, :stats

  def initialize(files)
    @files = files
    @issues = []
    @stats = { total_files: 0, total_words: 0, total_sentences: 0, jargon_matches: 0, long_sentences: 0 }
  end

  def run!
    @files.each do |file_path|
      next unless File.exist?(file_path)

      @stats[:total_files] += 1
      content = File.read(file_path)

      if file_path.end_with?('.yml', '.yaml')
        audit_yaml_content(file_path, content)
      else
        audit_markdown_content(file_path, content)
      end
    end

    report_results!
  end

  private

  def audit_yaml_content(file_path, content)
    begin
      data = YAML.safe_load(content, permitted_classes: [Date, Time, Symbol], aliases: true)
      extract_strings(data).each do |str|
        check_prose(file_path, str, "YAML Data")
      end
    rescue Psych::SyntaxError => e
      @issues << { file: file_path, line: 1, type: "YAML Syntax Error", msg: e.message }
    end
  end

  def audit_markdown_content(file_path, content)
    lines = content.lines

    # Frontmatter check
    if content.start_with?('---')
      fm_end = lines[1..].index { |l| l.strip == '---' }
      lines = lines[(fm_end + 2)..] if fm_end
    end

    full_text = lines.join
    check_prose(file_path, full_text, "Markdown Document")

    # Header hierarchy check
    headers = lines.map.with_index { |l, idx| [l, idx + 1] }.select { |l, _| l.start_with?('#') }
    prev_level = 0
    headers.each do |h_text, line_num|
      level = h_text.match(/^#+/)[0].length
      if prev_level > 0 && level > prev_level + 1
        @issues << { file: file_path, line: line_num, type: "Header Hierarchy Skip", msg: "Skipped from H#{prev_level} to H#{level}. Use sequential headers for screen readers." }
      end
      prev_level = level
    end

    # Poor link text check
    lines.each_with_index do |line, idx|
      POOR_LINK_TEXT.each do |pattern|
        if line.match?(pattern)
          @issues << { file: file_path, line: idx + 1, type: "Accessibility Link Text", msg: "Vague link text found ('#{line.strip.slice(0, 40)}...'). Use descriptive destination anchor text." }
        end
      end
    end
  end

  def extract_strings(obj)
    strings = []
    case obj
    when Hash
      obj.each_value { |v| strings.concat(extract_strings(v)) }
    when Array
      obj.each { |v| strings.concat(extract_strings(v)) }
    when String
      strings << obj
    end
    strings
  end

  def check_prose(file_path, text, context)
    clean_text = text.gsub(/```.*?```/m, '').gsub(/`.*?`/, '')
    words = clean_text.scan(/\b[a-zA-Z0-9'-]+\b/)
    sentences = clean_text.split(/(?<=[.!?])\s+/)

    @stats[:total_words] += words.size
    @stats[:total_sentences] += sentences.size

    # 1. AI Jargon & Hyper-Clinical Terminology
    AI_JARGON_TERMS.each do |jargon|
      if clean_text.downcase.include?(jargon.downcase)
        @stats[:jargon_matches] += 1
        @issues << { file: file_path, line: 1, type: "AI Jargon / Hyper-Clinical", msg: "Contains over-intellectualized jargon: '#{jargon}'. Rewrite in plain, grounded language." }
      end
    end

    # 2. Sentence Length & Cognitive Load (> 30 words)
    sentences.each do |sentence|
      s_words = sentence.scan(/\b[a-zA-Z0-9'-]+\b/)
      if s_words.size > 30
        @stats[:long_sentences] += 1
        snippet = s_words.first(8).join(' ') + '...'
        @issues << { file: file_path, line: 1, type: "High Cognitive Load", msg: "Sentence too long (#{s_words.size} words): '#{snippet}'. Split into sentences under 20-25 words." }
      end
    end

    # 3. Passive Voice Detection
    sentences.each do |sentence|
      PASSIVE_VOICE_PATTERNS.each do |pattern|
        if sentence.match?(pattern)
          snippet = sentence.strip.slice(0, 50) + '...'
          @issues << { file: file_path, line: 1, type: "Passive Voice", msg: "Passive voice detected: '#{snippet}'. Use active voice ('Subject performed action')." }
          break
        end
      end
    end
  end

  def calculate_readability_metrics
    return { flesch_kincaid: 0.0, avg_words_per_sentence: 0.0 } if @stats[:total_sentences].zero?

    avg_wps = @stats[:total_words].to_f / @stats[:total_sentences]
    # Simple Flesch-Kincaid Grade Level approximation
    fk_grade = (0.39 * avg_wps) + 5.0
    { flesch_kincaid: fk_grade.round(1), avg_words_per_sentence: avg_wps.round(1) }
  end

  def report_results!
    metrics = calculate_readability_metrics

    puts "\n=========================================================="
    puts " 📖 Grammarly for just3ws: Prose Humanity & Readability Audit"
    puts "=========================================================="
    puts " Files Audited           : #{@stats[:total_files]}"
    puts " Total Words            : #{@stats[:total_words]}"
    puts " Total Sentences        : #{@stats[:total_sentences]}"
    puts " Avg Words / Sentence   : #{metrics[:avg_words_per_sentence]} (Target: < 20.0)"
    puts " Flesch-Kincaid Grade   : ~#{metrics[:flesch_kincaid]} (Target: 8.0 - 12.0)"
    puts " AI Jargon Matches      : #{@stats[:jargon_matches]} (Target: 0)"
    puts " Long Sentences (>30w)  : #{@stats[:long_sentences]}"
    puts " Total Issues Found     : #{@issues.size}"
    puts "==========================================================\n"

    if @issues.any?
      puts "⚠️  Prose Humanity Issues Detected:"
      @issues.first(25).each do |issue|
        puts "  - [#{issue[:type]}] #{issue[:file]}:#{issue[:line]} -> #{issue[:msg]}"
      end
      puts "\n  (...and #{@issues.size - 25} more)" if @issues.size > 25
      exit 1
    else
      puts "✅ Prose Humanity & Neuroinclusive Readability Audit PASSED cleanly!"
      exit 0
    end
  end
end

# CLI Option Parsing
files_to_audit = []
OptionParser.new do |opts|
  opts.banner = "Usage: bin/audit_prose_humanity.rb [options] [files...]"
  opts.on("-h", "--help", "Prints this help") do
    puts opts
    exit
  end
end.parse!

if ARGV.empty?
  # Default paths to audit
  files_to_audit = Dir.glob("{_data/*.yml,case-studies/*.md,case-studies/*.html,docs/**/*.md,exports/briefs/**/*.md,README.md}")
else
  files_to_audit = ARGV
end

ProseHumanityAuditor.new(files_to_audit).run!
