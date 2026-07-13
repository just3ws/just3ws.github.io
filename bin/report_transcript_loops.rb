#!/usr/bin/env ruby
require 'yaml'
require 'date'
require 'time'
require 'json'
require 'fileutils'
require_relative '../src/generators/archive_state'
require_relative 'lib/transcript_sanity'

ROOT = File.expand_path('..', __dir__)
TRANSCRIPTS_DIR = File.join(ROOT, '_data', 'transcripts')
QUEUE_PATH = File.join(ROOT, '_data', 'transcript_retranscribe_queue.yml')
JSON_REPORT = File.join(ROOT, 'tmp', 'transcript-loop-report.json')
MD_REPORT = File.join(ROOT, 'tmp', 'transcript-loop-report.md')

rows = []
parse_errors = []
Dir.glob(File.join(TRANSCRIPTS_DIR, '*.yml')).sort.each do |path|
  transcript_state = Generators::ArchiveState.for_path(path)
  if transcript_state.invalid?
    parse_errors << {
      'transcript_id' => transcript_state.id,
      'file' => transcript_state.path.to_s.sub(ROOT + '/', ''),
      'error' => transcript_state.load_error
    }
    next
  end

  text = transcript_state.text
  next if text.strip.empty?

  # Shared scorer (bin/lib/transcript_sanity.rb) — the same definition the
  # staging gate uses, so "flagged as looping" and "refused promotion" agree.
  s = TranscriptSanity.loop_score(text)
  next if s.nil? || s['score'] < 6.0

  rows << s.merge(
    'transcript_id' => File.basename(path, '.yml'),
    'file' => path.sub(ROOT + '/', '')
  )
end

rows.sort_by! { |row| [-row['score'], row['transcript_id']] }

FileUtils.mkdir_p(File.join(ROOT, 'tmp'))

report = {
  'generated_at' => Time.now.utc.iso8601,
  'candidate_count' => rows.size,
  'parse_error_count' => parse_errors.size,
  'parse_errors' => parse_errors,
  'candidates' => rows
}
File.write(JSON_REPORT, JSON.pretty_generate(report) + "\n")

md = []
md << '# Transcript Loop Report'
md << ''
md << "- Generated at: #{report['generated_at']}"
md << "- Candidate count: #{rows.size}"
md << "- Parse errors: #{parse_errors.size}"
md << ''
md << '| Priority | Transcript ID | Score | Severity | Notes |'
md << '|---|---|---:|---|---|'
rows.each_with_index do |row, idx|
  md << "| #{idx + 1} | `#{row['transcript_id']}` | #{row['score']} | #{row['severity']} | #{row['reasons'].join('; ')} |"
end
if parse_errors.any?
  md << ''
  md << '## Parse Errors'
  md << ''
  md << '| Transcript ID | File | Error |'
  md << '|---|---|---|'
  parse_errors.each do |error|
    md << "| `#{error['transcript_id']}` | `#{error['file']}` | #{error['error']} |"
  end
end
File.write(MD_REPORT, md.join("\n") + "\n")

queue = {
  'generated_at' => report['generated_at'],
  'source' => 'bin/report_transcript_loops.rb',
  'items' => rows.each_with_index.map do |row, idx|
    {
      'priority' => idx + 1,
      'transcript_id' => row['transcript_id'],
      'severity' => row['severity'],
      'score' => row['score'],
      'file' => row['file'],
      'reason' => row['reasons'].join('; ')
    }
  end
}
File.write(QUEUE_PATH, queue.to_yaml)

puts "Wrote #{JSON_REPORT}"
puts "Wrote #{MD_REPORT}"
puts "Wrote #{QUEUE_PATH}"
puts "Candidates: #{rows.size}"
warn "Transcript YAML parse errors: #{parse_errors.size}" if parse_errors.any?
