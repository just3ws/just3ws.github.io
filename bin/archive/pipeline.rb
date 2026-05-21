#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'
require 'logger'

# --- PIPELINE CONTROLLER ---
# Usage: ./bin/archive/pipeline.rb [interview_id] [--force] [--stage name]

class ArchivePipeline
  STAGES = %w[ingest normalize structure enrich validate sync]
  LOG_FILE = "logs/archive_pipeline.log"
  
  def initialize(id = nil, options = {})
    @target_id = id
    @options = options
    @stats = { success: 0, failed: 0, skipped: 0 }
    
    FileUtils.mkdir_p("logs")
    @logger = Logger.new(LOG_FILE, 'daily')
    @logger.level = Logger::INFO
  end

  def run
    if @options[:status]
      report_archive_status
      return
    end
    
    targets = @target_id ? [@target_id] : all_interview_ids
    puts "🚀 Starting Archive Pipeline (ETLT) for #{targets.size} items..."
    @logger.info("Pipeline Start: targets=#{targets.size} stage=#{@options[:stage]}")
    
    targets.each do |id|
      process_item(id)
    end
    
    report_summary
  end

  private

  def report_archive_status
    puts "📊 Archive ETLT Status Report"
    puts "----------------------------"
    
    counts = {
      total: 0,
      normalized: 0,
      structured: 0,
      enriched: 0
    }
    
    all_interview_ids.each do |id|
      path = "_data/transcripts/#{id}.yml"
      counts[:total] += 1
      next unless File.exist?(path)
      
      data = YAML.load_file(path, permitted_classes: [Date, Time], aliases: true) rescue next
      counts[:normalized] += 1 if data["normalized_at"]
      counts[:structured] += 1 if data["turns"] && data["turns"].size > 1
      counts[:enriched] += 1 if data["enriched_at"]
    end
    
    puts "Total Items:   #{counts[:total]}"
    puts "Normalized:    #{counts[:normalized].to_s.ljust(4)} (#{(counts[:normalized].to_f / counts[:total] * 100).round}%)"
    puts "Structured:    #{counts[:structured].to_s.ljust(4)} (#{(counts[:structured].to_f / counts[:total] * 100).round}%)"
    puts "Enriched:      #{counts[:enriched].to_s.ljust(4)} (#{(counts[:enriched].to_f / counts[:total] * 100).round}%)"
  end

  def process_item(id)
    puts "\n📦 Processing: #{id}"
    @logger.info("Processing Item: #{id}")
    
    context = { id: id, path: "_data/transcripts/#{id}.yml" }
    
    STAGES.each do |stage|
      next if @options[:stage] && @options[:stage] != stage
      
      print "  → Stage: #{stage.ljust(10)}... "
      result = execute_stage(stage, context)
      
      if result[:status] == :success
        puts "✅"
        @logger.info("  [#{id}] Stage #{stage}: SUCCESS")
      elsif result[:status] == :skipped
        puts "⏭️ (Already done)"
        @logger.info("  [#{id}] Stage #{stage}: SKIPPED")
        @stats[:skipped] += 1
      else
        puts "❌ ERROR: #{result[:message]}"
        @logger.error("  [#{id}] Stage #{stage}: FAILED - #{result[:message]}")
        @stats[:failed] += 1
        return # Stop pipeline for this item
      end
    end
    @stats[:success] += 1
  end

  def execute_stage(stage, context)
    module_path = "bin/archive/modules/#{stage}.rb"
    unless File.exist?(module_path)
      return { status: :failed, message: "Module not found: #{module_path}" }
    end

    # Run the module as a subprocess for isolation
    cmd = "ruby #{module_path} #{context[:id]}"
    cmd += " --force" if @options[:force]
    
    output = `#{cmd} 2>&1`
    if $?.success?
      if output.include?("SKIPPED")
        { status: :skipped }
      else
        { status: :success }
      end
    else
      { status: :failed, message: output.strip }
    end
  end

  def all_interview_ids
    YAML.load_file("_data/interviews.yml")["items"].map { |i| i["id"] }
  end

  def report_summary
    summary = "\n--- 🏁 Pipeline Summary ---\nSuccess: #{@stats[:success]}\nFailed:  #{@stats[:failed]}\nSkipped: #{@stats[:skipped]}"
    puts summary
    @logger.info("Pipeline Summary: #{summary.gsub("\n", ' ')}")
  end
end

id = ARGV.find { |a| !a.start_with?("-") }
options = {
  force: ARGV.include?("--force"),
  status: ARGV.include?("--status"),
  stage: ARGV.find { |a| a.start_with?("--stage=") }&.split("=")&.last
}

ArchivePipeline.new(id, options).run
