#!/usr/bin/env ruby
# frozen_string_literal: true

# bin/transcript_ops.rb — Unified Transcript Operations & Automation CLI
#
# Provides end-to-end automation for archive transcripts:
# - Forensic auditing & validation status
# - Context engine grounding & lesson seeding (zdots-ctx)
# - Non-destructive theme song boundary backfilling
# - Vector RAG indexing into PostgreSQL (my database)
#
# Usage:
#   ./bin/transcript_ops.rb --status
#   ./bin/transcript_ops.rb --seed-context
#   ./bin/transcript_ops.rb --backfill-boundaries
#   ./bin/transcript_ops.rb --index-enriched
#   ./bin/transcript_ops.rb --forensic-audit
#   ./bin/transcript_ops.rb --all

require "yaml"
require "json"
require "open3"
require "optparse"

class TranscriptOps
  ROOT = File.expand_path("..", __dir__)
  ZDOTS_DIR = File.expand_path("~/.config/zsh")

  def initialize(options = {})
    @options = options
  end

  def run
    if @options[:status]
      report_status
    elsif @options[:seed_context]
      seed_context
    elsif @options[:backfill_boundaries]
      backfill_boundaries
    elsif @options[:index_enriched]
      index_enriched
    elsif @options[:forensic_audit]
      run_forensic_audit
    elsif @options[:all]
      run_all
    else
      puts usage
    end
  end

  def report_status
    puts "======================================================="
    puts "  TRANSCRIPT ARCHIVE OPERATIONS & RAG STATUS REPORT"
    puts "======================================================="
    
    files = Dir.glob(File.join(ROOT, "_data", "transcripts", "*.yml"))
    interviews = YAML.load_file(File.join(ROOT, "_data", "interviews.yml"), aliases: true)["items"] rescue []
    video_assets = YAML.load_file(File.join(ROOT, "_data", "video_assets.yml"), aliases: true)["items"] rescue []

    stats = {
      interviews: interviews.size,
      video_assets: video_assets.size,
      transcripts: files.size,
      validated_ok: 0,
      validated_error: 0,
      enriched: 0,
      indexed: 0,
      restructured: 0,
      boundaries: 0
    }

    files.each do |f|
      data = YAML.load_file(f, aliases: true) rescue {}
      if data["validated_at"]
        data["validation_error"] ? stats[:validated_error] += 1 : stats[:validated_ok] += 1
      end
      stats[:enriched] += 1 if data["summary"] && data["insights"]
      stats[:indexed] += 1 if data["indexed_at"] || data["zdots_lesson_id"]
      stats[:restructured] += 1 if data["restructured_at"]
      stats[:boundaries] += 1 if data["boundaries"]
    end

    missing_transcripts = video_assets.select { |va| !va["transcript_id"] || va["transcript_id"].empty? }

    puts "Interviews Count:      #{stats[:interviews]}"
    puts "Video Assets Count:    #{stats[:video_assets]}"
    puts "Transcripts Count:     #{stats[:transcripts]}"
    puts "Assets Missing Trans:  #{missing_transcripts.size}"
    puts "-------------------------------------------------------"
    puts "Validated OK:          #{stats[:validated_ok]} / #{stats[:transcripts]} (#{(stats[:validated_ok].to_f / stats[:transcripts] * 100).round(1)}%)"
    puts "Validation Errors:     #{stats[:validated_error]}"
    puts "Enriched (AI Summary): #{stats[:enriched]} / #{stats[:transcripts]} (#{(stats[:enriched].to_f / stats[:transcripts] * 100).round(1)}%)"
    puts "Vector Indexed (my):   #{stats[:indexed]} / #{stats[:transcripts]} (#{(stats[:indexed].to_f / stats[:transcripts] * 100).round(1)}%)"
    puts "Restructured Dialogue: #{stats[:restructured]} / #{stats[:transcripts]}"
    puts "Boundaries Sidecars:   #{stats[:boundaries]} / #{stats[:transcripts]}"
    puts "======================================================="
  end

  def seed_context
    puts "🌱 Seeding archive domain vocabulary & speaker entities into zdots-ctx..."
    vocab_lesson = <<~LESSON
      UGtastic oral history archive domain terms:
      - ActiveJDBC & ActiveWeb (Igor Polevoy)
      - Clojure & Datomic (Rich Hickey, Stuart Halloway, Dean Wampler)
      - 8th Light (Corey Haines, Micah Martin, Paul Pagel, Eric Smith)
      - SCNA (Software Craftsmanship North America)
      - ChiPy (Chicago Python User Group)
      - WindyCityRails & ChicagoWebConf
      - Rails Core (David Heinemeier Hansson, Aaron Patterson, Rafael França, Carlos Antonio da Silva)
    LESSON

    success, output = run_zdots_ctx("add-lesson", vocab_lesson, "UGtastic Archive Domain Lexicon", "archive ugtastic domain-lexicon transcription")
    if success
      puts "✅ Domain vocabulary successfully seeded into zdots-ctx!"
    else
      puts "❌ Failed to seed context: #{output}"
    end
  end

  def backfill_boundaries
    puts "🎵 Backfilling intro/outro theme song boundary sidecars..."
    cmd = "sh -c 'cd #{ZDOTS_DIR} && bundle exec ./bin/zdots-backfill-boundaries --apply'"
    system(cmd)
  end

  def index_enriched
    puts "⚡ Indexing enriched transcripts into zdots-ctx / my database..."
    system("ruby #{File.join(ROOT, 'bin', 'archive', 'pipeline.rb')} --stage=index")
  end

  def run_forensic_audit
    puts "🔍 Running forensic quality audit..."
    system("ruby #{File.join(ROOT, 'bin', 'final_quality_audit.rb')}")
  end

  def run_all
    seed_context
    puts ""
    backfill_boundaries
    puts ""
    index_enriched
    puts ""
    report_status
  end

  private

  def run_zdots_ctx(*args)
    env = {
      "PATH" => "#{File.expand_path('~/.local/share/mise/shims')}:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin",
      "HOME" => ENV["HOME"] || File.expand_path("~"),
      "ZDOTDIR" => ZDOTS_DIR,
      "DATABASE_URL" => "postgresql:///my",
      "PSQLRC" => "/dev/null"
    }
    
    output, status = Open3.capture2e(env, "bundle", "exec", "./bin/zdots-ctx", *args, chdir: ZDOTS_DIR)
    [status.success?, output]
  end

  def usage
    <<~USAGE
      Usage: ./bin/transcript_ops.rb [options]

      Options:
        --status              Report current archive, forensic, and RAG index status
        --seed-context        Seed domain vocabulary into zdots-ctx / my database
        --backfill-boundaries Run theme-song boundary sidecar backfill (--apply)
        --index-enriched      Index enriched transcripts into zdots-ctx vector DB
        --forensic-audit      Run quality audit for word count drift and overload
        --all                 Execute seed-context, backfill-boundaries, index, and status
    USAGE
  end
end

options = {}
OptionParser.new do |opts|
  opts.on("--status", "Report current pipeline status") { options[:status] = true }
  opts.on("--seed-context", "Seed domain vocabulary into zdots-ctx") { options[:seed_context] = true }
  opts.on("--backfill-boundaries", "Run boundary backfilling") { options[:backfill_boundaries] = true }
  opts.on("--index-enriched", "Index enriched transcripts") { options[:index_enriched] = true }
  opts.on("--forensic-audit", "Run forensic quality audit") { options[:forensic_audit] = true }
  opts.on("--all", "Run full automated maintenance cycle") { options[:all] = true }
end.parse!

TranscriptOps.new(options).run
