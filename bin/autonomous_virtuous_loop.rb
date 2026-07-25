#!/usr/bin/env ruby
# frozen_string_literal: true

# bin/autonomous_virtuous_loop.rb — Continuous Autonomous Archive Pipeline Loop
#
# Runs the full virtuous loop hands-free:
# 1. Seeds domain terminology into zdots-ctx
# 2. Automatically repairs forensic backlog validation failures
# 3. Backfills theme song boundary sidecars
# 4. Indexes 100% of enriched transcripts into the zdots-ctx pgvector store
# 5. Audits data integrity post-pass
#
# Usage:
#   ruby bin/autonomous_virtuous_loop.rb --once
#   ruby bin/autonomous_virtuous_loop.rb --daemon --interval 300

require 'optparse'
require 'yaml'
require 'fileutils'

class AutonomousVirtuousLoop
  attr_reader :options

  def initialize(options = {})
    @options = options
  end

  def run
    puts "======================================================="
    puts "🔄 STARTING AUTONOMOUS VIRTUOUS ARCHIVE LOOP"
    puts "======================================================="

    loop do
      timestamp = Time.now.strftime("%Y-%m-%d %H:%M:%S")
      puts "\n[#{timestamp}] --- Executing Pipeline Pass ---"

      # Step 1: Seed Context Engine & Domain Vocabulary
      puts "🌱 Step 1: Seeding Domain Vocabulary..."
      run_cmd("./bin/transcript_ops.rb --seed-context")

      # Step 2: Automated Forensic Repairs
      puts "🔧 Step 2: Running Automated Forensic Repairs..."
      system("ruby bin/forensic_repair.rb")

      # Step 3: Theme Song Boundary Backfill
      puts "🎵 Step 3: Backfilling Theme Song Boundaries..."
      run_cmd("./bin/transcript_ops.rb --backfill-boundaries")

      # Step 4: Vector RAG Indexing
      puts "⚡ Step 4: Indexing Enriched Transcripts into zdots-ctx (pgvector)..."
      run_cmd("./bin/transcript_ops.rb --index-enriched")

      # Step 5: Data Integrity Validation
      puts "🧪 Step 5: Validating Data Integrity & Schema..."
      valid = system("bundle exec rake validate:data_uniqueness validate:data_integrity")

      if valid
        puts "✅ [#{Time.now.strftime('%H:%M:%S')}] Pass completed successfully with 0 errors!"
      else
        puts "⚠️ [#{Time.now.strftime('%H:%M:%S')}] Pass completed with validation warnings."
      end

      # Print current archive status report
      puts "\n📊 Current Archive Status:"
      system("./bin/transcript_ops.rb --status")

      break unless options[:daemon]

      interval = options[:interval] || 300
      puts "\n😴 Sleeping for #{interval} seconds before next autonomous pass (Ctrl+C to stop)..."
      sleep interval
    end
  end

  private

  def run_cmd(cmd)
    output = `#{cmd} 2>&1`
    puts output.strip.lines.map { |l| "   #{l}" }.join unless output.empty?
  end
end

options = { daemon: false, interval: 300 }
OptionParser.new do |opts|
  opts.banner = "Usage: ruby bin/autonomous_virtuous_loop.rb [options]"
  opts.on("-d", "--daemon", "Run continuously as a background loop") { options[:daemon] = true }
  opts.on("-o", "--once", "Run a single pass and exit") { options[:daemon] = false }
  opts.on("-i", "--interval SECONDS", Integer, "Polling interval in seconds for daemon mode") { |v| options[:interval] = v }
end.parse!

AutonomousVirtuousLoop.new(options).run
