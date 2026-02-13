#!/usr/bin/env ruby
require 'yaml'
require 'date'
require 'time'
require 'json'
require 'fileutils'

ROOT = File.expand_path('..', __dir__)
TRANSCRIPTS_DIR = File.join(ROOT, '_data', 'transcripts')
QUEUE_PATH = File.join(ROOT, '_data', 'transcript_retranscribe_queue.yml')
JSON_REPORT = File.join(ROOT, 'tmp', 'transcript-loop-report.json')
MD_REPORT = File.join(ROOT, 'tmp', 'transcript-loop-report.md')

def sentence_split(text)
  text.split(/(?<=[.!?])\s+/).map { |s| s.strip.gsub(/\s+/, ' ') }.reject(&:empty?)
end

def tokenize(text)
  text.downcase.scan(/[a-z0-9']+/)
end

rows = []
Dir.glob(File.join(TRANSCRIPTS_DIR, '*.yml')).sort.each do |path|
  parsed = YAML.safe_load(File.read(path), permitted_classes: [Date, Time], aliases: true) || {}
  text = parsed['content'].to_s
  next if text.strip.empty?

  normalized = text.gsub(/\r\n?/, "\n")
  lines = normalized.lines.map(&:strip).reject(&:empty?)
  sentences = sentence_split(normalized)
  words = tokenize(normalized)

  consec_dup = 0
  max_run = 1
  run = 1
  (1...sentences.length).each do |i|
    if sentences[i].downcase == sentences[i - 1].downcase
      consec_dup += 1
      run += 1
      max_run = [max_run, run].max
    else
      run = 1
    end
  end

  line_counts = Hash.new(0)
  lines.each { |line| line_counts[line.downcase] += 1 }
  repeated_lines = line_counts.values.select { |v| v > 1 }.sum { |v| v - 1 }
  line_repeat_ratio = lines.empty? ? 0.0 : repeated_lines.to_f / lines.length

  n = 6
  grams = []
  if words.length >= n
    (0..words.length - n).each { |i| grams << words[i, n].join(' ') }
  end
  gram_counts = Hash.new(0)
  grams.each { |g| gram_counts[g] += 1 }
  repeated_grams = gram_counts.values.select { |v| v > 1 }.sum { |v| v - 1 }
  gram_repeat_ratio = grams.empty? ? 0.0 : repeated_grams.to_f / grams.length

  score = (consec_dup * 3.0) + (max_run > 2 ? 5.0 : 0.0) + (line_repeat_ratio * 20.0) + (gram_repeat_ratio * 30.0)

  next if score < 6.0

  severity = if score >= 150 || max_run >= 20
               'high'
             elsif score >= 35 || max_run >= 6
               'medium'
             else
               'low'
             end

  reasons = []
  reasons << "#{consec_dup} consecutive duplicate sentence pairs" if consec_dup > 0
  reasons << "max repeated sentence run #{max_run}" if max_run > 2
  reasons << format('line repeat ratio %.3f', line_repeat_ratio) if line_repeat_ratio >= 0.15
  reasons << format('6-gram repeat ratio %.3f', gram_repeat_ratio) if gram_repeat_ratio >= 0.20

  rows << {
    'transcript_id' => File.basename(path, '.yml'),
    'file' => path.sub(ROOT + '/', ''),
    'score' => score.round(2),
    'severity' => severity,
    'consecutive_duplicates' => consec_dup,
    'max_sentence_run' => max_run,
    'line_repeat_ratio' => line_repeat_ratio.round(3),
    'ngram_repeat_ratio' => gram_repeat_ratio.round(3),
    'reasons' => reasons
  }
end

rows.sort_by! { |row| [-row['score'], row['transcript_id']] }

FileUtils.mkdir_p(File.join(ROOT, 'tmp'))

report = {
  'generated_at' => Time.now.utc.iso8601,
  'candidate_count' => rows.size,
  'candidates' => rows
}
File.write(JSON_REPORT, JSON.pretty_generate(report) + "\n")

md = []
md << '# Transcript Loop Report'
md << ''
md << "- Generated at: #{report['generated_at']}"
md << "- Candidate count: #{rows.size}"
md << ''
md << '| Priority | Transcript ID | Score | Severity | Notes |'
md << '|---|---|---:|---|---|'
rows.each_with_index do |row, idx|
  md << "| #{idx + 1} | `#{row['transcript_id']}` | #{row['score']} | #{row['severity']} | #{row['reasons'].join('; ')} |"
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
