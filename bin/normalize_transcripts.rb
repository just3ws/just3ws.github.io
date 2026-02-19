#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require "optparse"
require "pathname"

ROOT = Pathname(__dir__).join("..").expand_path
TRANSCRIPTS_DIR = ROOT.join("_data", "transcripts")

TEXT_NORMALIZATION_RULES = [
  [/\b(?:u|y|e)[a-z-]{0,10}tastic\.com\b/i, "ugtastic.com"],
  [/\b(?:u|y|e)[a-z-]{0,10}tastic\b/i, "UGtastic"],
  [/\bhugh[ -]+tastic\b/i, "UGtastic"],
  [/\bu[ -]?task\b/i, "UGtastic"],
  [/\bug[\s._-]*tastic\b/i, "UGtastic"],
  [/\b(?:you|yu)g[\s._-]*tastic\b/i, "UGtastic"],
  [/\bug[\s._-]*l[\s._-]*st\b/i, "UGl.st"],
  [/\bcraftmanship\b/i, "craftsmanship"],
  [/\bsoft[ -]?ware craftsmanship\b/i, "Software craftsmanship"],
  [/\bchipy\b/i, "ChiPy"],
  [/\bscna\b/i, "SCNA"],
  [/\bGoToConf(?:erence)?(\d{4})\b/i, "GOTO Conf \\1"],
  [/\bGoToConf(?:erence)?\b/i, "GOTO Conf"],
  [/\bUGtastic\.com\b/, "ugtastic.com"]
].freeze

def clean_transcript_text(text)
  cleaned = text.to_s.dup
  cleaned.gsub!(/\r\n?/, "\n")
  cleaned.gsub!(/[ \t]+$/, "")
  cleaned.gsub!(/\n{3,}/, "\n\n")
  cleaned.strip!

  TEXT_NORMALIZATION_RULES.each do |pattern, replacement|
    cleaned.gsub!(pattern, replacement)
  end

  cleaned
end

options = { apply: false }
OptionParser.new do |opts|
  opts.banner = "Usage: bin/normalize_transcripts.rb [--apply]"
  opts.on("--apply", "Write normalized transcript content") { options[:apply] = true }
end.parse!

paths = Dir.glob(TRANSCRIPTS_DIR.join("*.yml").to_s).sort
changed = []

paths.each do |path|
  payload = YAML.safe_load(File.read(path), permitted_classes: [Date, Time], aliases: true) || {}
  original = payload["content"].to_s
  normalized = clean_transcript_text(original)
  next if normalized == original

  changed << path
  next unless options[:apply]

  payload["content"] = normalized
  File.write(path, payload.to_yaml)
end

puts "transcript_files=#{paths.size}"
puts "changed=#{changed.size}"
changed.first(40).each { |path| puts " - #{Pathname(path).relative_path_from(ROOT)}" }
puts "mode=#{options[:apply] ? 'apply' : 'dry-run'}"
