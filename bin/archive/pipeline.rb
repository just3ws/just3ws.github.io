#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'

# --- PIPELINE CONTROLLER ---
# Usage: ./bin/archive/pipeline.rb [interview_id] [--force] [--stage name]

class ArchivePipeline
  STAGES = %w[ingest normalize structure enrich validate sync]
  
  def initialize(id = nil, options = {})
    @target_id = id
    @options = options
    @stats = { success: 0, failed: 0, skipped: 0 }
  end

  def run
    targets = @target_id ? [@target_id] : all_interview_ids
    puts "🚀 Starting Archive Pipeline for #{targets.size} items..."
    
    targets.each do |id|
      process_item(id)
    end
    
    report_summary
  end

  private

  def process_item(id)
    puts "\n📦 Processing: #{id}"
    context = { id: id, path: "_data/transcripts/#{id}.yml" }
    
    STAGES.each do |stage|
      next if @options[:stage] && @options[:stage] != stage
      
      print "  → Stage: #{stage.ljust(10)}... "
      result = execute_stage(stage, context)
      
      if result[:status] == :success
        puts "✅"
      elsif result[:status] == :skipped
        puts "⏭️ (Already done)"
      else
        puts "❌ ERROR: #{result[:message]}"
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
    # We pass the ID and force flag
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
    puts "\n--- 🏁 Pipeline Summary ---"
    puts "Success: #{@stats[:success]}"
    puts "Failed:  #{@stats[:failed]}"
    puts "Skipped: #{@stats[:skipped]}"
  end
end

id = ARGV.find { |a| !a.start_with?("-") }
options = {
  force: ARGV.include?("--force"),
  stage: ARGV.find { |a| a.start_with?("--stage=") }&.split("=")&.last
}

ArchivePipeline.new(id, options).run
