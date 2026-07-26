#!/usr/bin/env ruby
# frozen_string_literal: true

# bin/zdots_ai_researcher.rb — zdots AI Platform Research Automator
#
# Leverages zdots-ask, zdots-ctx, and zdots-search to perform AI-augmented
# deep context gathering across Mike's personal OS platform.

require 'json'
require 'open3'
require 'optparse'

class ZdotsAIResearcher
  def initialize(options)
    @options = options
  end

  def run
    puts "🤖 zdots AI Platform Research Automator"
    puts "======================================================="

    query = @options[:query] || "Software Craftsmanship North America SCNA history"
    puts "Target Query: #{query}"
    puts "Mode:         #{@options[:use_ai] ? 'zdots-ask (LLM Inference + Context)' : 'zdots-ctx (Vector Database Lookup)'}"
    puts "-------------------------------------------------------"

    if @options[:use_ai]
      puts "🚀 Running zdots-ask AI inference..."
      cmd = ["zdots-ask", "--context", "ruby", "Analyze historical engineering context and key insights for: #{query}"]
      stdout, stderr, status = Open3.capture3(*cmd)
      if status.success?
        puts stdout
      else
        puts "⚠️ zdots-ask Notice: #{stderr.strip.empty? ? 'Fallback to vector lookup' : stderr}"
        run_vector_query(query)
      end
    else
      run_vector_query(query)
    end

    puts "======================================================="
  end

  private

  def run_vector_query(q)
    puts "🔍 Querying zdots-ctx PostgreSQL vector context..."
    cmd = ["zdots-ctx", "query", q]
    stdout, stderr, status = Open3.capture3(*cmd)
    if status.success?
      puts stdout
    else
      puts "⚠️ zdots-ctx Notice: #{stderr}"
    end
  end
end

options = { query: nil, use_ai: false }

OptionParser.new do |opts|
  opts.banner = "Usage: ruby bin/zdots_ai_researcher.rb [options]"

  opts.on("--query Q", String, "Query topic or interviewee name") do |q|
    options[:query] = q
  end

  opts.on("--ai", "Use zdots-ask LLM inference engine") do
    options[:use_ai] = true
  end
end.parse!

ZdotsAIResearcher.new(options).run
