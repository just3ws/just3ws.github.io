#!/usr/bin/env ruby

require "yaml"
require "time"
require "date"

ROOT = File.expand_path("..", __dir__)
REPORT_PATH = File.join(ROOT, "_data", "video_metadata_completeness.yml")

unless File.file?(REPORT_PATH)
  warn "Metadata completeness budget check failed: missing #{REPORT_PATH}"
  exit 1
end

report = YAML.safe_load(File.read(REPORT_PATH), permitted_classes: [Date, Time], aliases: true) || {}
summary = report.fetch("summary", {})

total = summary["total_videos"].to_i
below_70 = summary["score_below_70"].to_i
with_transcript_complete = summary["with_transcript_complete"].to_i
coverage = total.zero? ? 0.0 : (with_transcript_complete.to_f / total * 100.0)

max_below_70 = ENV.fetch("METADATA_MAX_BELOW_70", "260").to_i
min_transcript_coverage = ENV.fetch("METADATA_MIN_TRANSCRIPT_COVERAGE_PCT", "18.0").to_f
mode = ENV.fetch("METADATA_BUDGET_MODE", "warn")

issues = []
issues << "score_below_70=#{below_70} exceeds budget=#{max_below_70}" if below_70 > max_below_70
if coverage < min_transcript_coverage
  issues << format("transcript coverage %.2f%% below budget %.2f%%", coverage, min_transcript_coverage)
end

puts "Metadata completeness budget"
puts "  generated_at=#{report['generated_at']}"
puts "  total_videos=#{total}"
puts "  score_below_70=#{below_70} (budget=#{max_below_70})"
puts format("  transcript_coverage=%.2f%% (budget>=%.2f%%)", coverage, min_transcript_coverage)

if issues.empty?
  puts "Metadata completeness budget passed."
  exit 0
end

if mode == "error"
  warn "Metadata completeness budget failed:"
  issues.each { |issue| warn "  - #{issue}" }
  exit 1
end

warn "Metadata completeness budget warnings:"
issues.each { |issue| warn "  - #{issue}" }
puts "Continuing because METADATA_BUDGET_MODE=#{mode}."
exit 0
