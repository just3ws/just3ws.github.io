#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "optparse"
require_relative "lib/corpus_metrics"

options = {format: "json", output: nil}
OptionParser.new do |parser|
  parser.banner = "Usage: ruby bin/corpus_metrics.rb --config path.yml [--format json|markdown] [--output path]"
  parser.on("-c", "--config PATH", "Corpus configuration YAML or JSON") { |value| options[:config] = value }
  parser.on("-f", "--format FORMAT", %w[json markdown], "Output format (default: json)") { |value| options[:format] = value }
  parser.on("-o", "--output PATH", "Write output to a file instead of stdout") { |value| options[:output] = value }
end.parse!

abort "Missing --config. See --help." unless options[:config]

begin
  report = CorpusMetrics.build(CorpusMetrics.configuration(options[:config]))
  output = options[:format] == "markdown" ? CorpusMetrics.markdown(report) : JSON.pretty_generate(report) + "\n"
  if options[:output]
    File.write(options[:output], output)
    puts "Wrote #{options[:format]} corpus report to #{options[:output]}"
  else
    puts output
  end
rescue CorpusMetrics::Error => e
  warn "Corpus metrics failed: #{e.message}"
  exit 1
end
