#!/usr/bin/env ruby
# frozen_string_literal: true

# bin/query_career_datalake.rb
# Fast CLI query interface for CareerOS Datalake.
# Supports querying positions, technology provenance, oral history, case studies, and writings.

require 'json'
require 'optparse'

ROOT = File.expand_path('..', __dir__)
DATALAKE_FILE = File.join(ROOT, 'career_datalake.json')

unless File.exist?(DATALAKE_FILE)
  system("ruby #{File.join(ROOT, 'bin', 'generate_career_datalake.rb')} > /dev/null 2>&1")
end

data = JSON.parse(File.read(DATALAKE_FILE))

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: bin/query_career_datalake.rb [options]"

  opts.on("--tech SKILL", "Query technology provenance and historical usage") do |v|
    options[:tech] = v
  end

  opts.on("--company NAME", "Query deep position details for a company") do |v|
    options[:company] = v
  end

  opts.on("--search QUERY", "Full-text search across positions, posts, and interviews") do |v|
    options[:search] = v
  end

  opts.on("--archetype SLUG", "Retrieve archetype strategy and empathy bridge") do |v|
    options[:archetype] = v
  end

  opts.on("--interviewee NAME", "Search oral history interviews by guest name") do |v|
    options[:interviewee] = v
  end

  opts.on("--era YEARS", "Filter writings and milestones by year range (e.g. 2009-2015)") do |v|
    options[:era] = v
  end

  opts.on("--stats", "Display summary datalake statistics") do
    options[:stats] = true
  end

  opts.on("--json", "Format output as JSON") do
    options[:json] = true
  end
end.parse!

results = {}

if options[:stats]
  results = data["meta"]
elsif options[:tech]
  query = options[:tech].downcase
  matches = data["technology_provenance"].select do |k, v|
    k.downcase.include?(query)
  end
  results = { "technology_matches" => matches }
elsif options[:company]
  query = options[:company].downcase
  matches = data["positions"].select do |k, v|
    k.downcase.include?(query) || (v.dig("company", "name") || "").downcase.include?(query)
  end
  results = { "company_matches" => matches }
elsif options[:archetype]
  query = options[:archetype].downcase
  matches = data["archetypes"].select do |k, v|
    k.downcase.include?(query) || (v["file_slug"] || "").downcase.include?(query) || (v["short_label"] || "").downcase.include?(query)
  end
  results = { "archetype_matches" => matches }
elsif options[:interviewee]
  query = options[:interviewee].downcase
  matches = data["oral_history_corpus"].select do |item|
    (item["interviewee"] || "").downcase.include?(query) || (item["title"] || "").downcase.include?(query)
  end
  results = { "interview_matches" => matches }
elsif options[:era]
  years = options[:era].scan(/\d{4}/).map(&:to_i)
  start_yr = years.first || 2006
  end_yr = years.last || Time.now.year
  post_matches = data["publications_and_writings"].select { |p| (start_yr..end_yr).include?(p["year"]) }
  interview_matches = data["oral_history_corpus"].select { |i| (start_yr..end_yr).include?(i["year"].to_i) }
  results = {
    "era" => "#{start_yr} - #{end_yr}",
    "publications" => post_matches,
    "interviews" => interview_matches
  }
elsif options[:search]
  q = options[:search].downcase
  pos_matches = data["positions"].select do |k, v|
    JSON.generate(v).downcase.include?(q)
  end
  pub_matches = data["publications_and_writings"].select do |p|
    (p["title"] || "").downcase.include?(q) || (p["excerpt"] || "").downcase.include?(q)
  end
  int_matches = data["oral_history_corpus"].select do |i|
    (i["title"] || "").downcase.include?(q) || (i["interviewee"] || "").downcase.include?(q)
  end
  cs_matches = data["case_studies"].select do |k, v|
    JSON.generate(v).downcase.include?(q)
  end
  results = {
    "query" => options[:search],
    "position_hits" => pos_matches.size,
    "positions" => pos_matches,
    "case_study_hits" => cs_matches.size,
    "case_studies" => cs_matches,
    "publication_hits" => pub_matches.size,
    "publications" => pub_matches,
    "interview_hits" => int_matches.size,
    "interviews" => int_matches
  }
else
  results = {
    "summary" => "CareerOS Datalake Query Engine",
    "usage" => "Pass --tech, --company, --search, --archetype, --interviewee, --era, or --stats",
    "stats" => data["meta"]["stats"]
  }
end

if options[:json]
  puts JSON.pretty_generate(results)
else
  # Human-readable formatted terminal output
  puts "================================================================================"
  puts " 🔍 CAREEROS DATALAKE QUERY ENGINE"
  puts "================================================================================"
  if results["stats"]
    puts "Total Positions Tracked   : #{results['stats']['total_positions']}"
    puts "Total Archetypes          : #{results['stats']['total_archetypes']}"
    puts "Total Articles (2006-2026): #{results['stats']['total_articles']}"
    puts "Total Oral History Videos : #{results['stats']['total_interviews']}"
    puts "Knowledge Graph Entities  : #{results['stats']['total_knowledge_graph_nodes']}"
    puts "Technologies in Matrix    : #{results['stats']['total_technologies_tracked']}"
  elsif results["technology_matches"]
    results["technology_matches"].each do |k, v|
      puts "\n🛠️  TECHNOLOGY: #{k}"
      puts "   Active Era    : #{v['first_seen_year']} - #{v['last_seen_year'] == Time.now.year ? 'Present' : v['last_seen_year']}"
      puts "   Total Contexts: #{v['total_occurrences']} roles"
      puts "   Roles Used In :"
      v["roles_used"].each do |r|
        puts "     - #{r['company']} (#{r['title']}, #{r['start_date']} - #{r['end_date']})"
      end
    end
  elsif results["company_matches"]
    results["company_matches"].each do |k, v|
      puts "\n🏢 COMPANY: #{v.dig('company', 'name') || k} (#{v['title']})"
      puts "   Tenure : #{v['start_date']} - #{v['end_date']} [Type: #{v['type']}]"
      puts "   Summary: #{v['summary']}"
      if v["skills"]
        puts "   Skills : #{v['skills'].join(', ')}"
      end
      if v["highlights"]
        puts "   Highlights:"
        v["highlights"].each { |h| puts "     * #{h['text']}" }
      end
    end
  elsif results["archetype_matches"]
    results["archetype_matches"].each do |k, v|
      puts "\n🎯 ARCHETYPE: #{v['title']}"
      puts "   Slug       : #{v['file_slug']}"
      puts "   Target Tier: #{v['target_tier']}"
      puts "   Core Skills: #{v['core_skills']&.join('; ')}"
      puts "   Summary    : #{v['summary']}"
    end
  elsif results["interview_matches"]
    puts "Found #{results['interview_matches'].size} matching interviews:"
    results["interview_matches"].first(10).each do |i|
      puts "  - [#{i['year']}] #{i['title']} (Guest: #{i['interviewee']}, Conf: #{i['conference']})"
    end
  elsif results["query"]
    puts "Search Query: '#{results['query']}'"
    puts "Hits: Positions=#{results['position_hits']}, CaseStudies=#{results['case_study_hits']}, Articles=#{results['publication_hits']}, Interviews=#{results['interview_hits']}"
    if results["positions"].any?
      puts "\nPositions:"
      results["positions"].each { |k, v| puts "  * #{v.dig('company', 'name')} - #{v['title']}" }
    end
    if results["case_studies"].any?
      puts "\nCase Studies:"
      results["case_studies"].each { |k, v| puts "  * #{v['title'] || k}" }
    end
    if results["publications"].any?
      puts "\nPublications (Top 5):"
      results["publications"].first(5).each { |p| puts "  * [#{p['date']}] #{p['title']}" }
    end
    if results["interviews"].any?
      puts "\nInterviews (Top 5):"
      results["interviews"].first(5).each { |i| puts "  * [#{i['year']}] #{i['title']}" }
    end
  else
    puts JSON.pretty_generate(results)
  end
  puts "================================================================================"
end
