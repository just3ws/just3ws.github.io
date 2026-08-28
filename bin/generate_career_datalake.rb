#!/usr/bin/env ruby
# frozen_string_literal: true

require 'yaml'
require 'json'
require 'time'
require 'date'
require 'fileutils'

ROOT = File.expand_path('..', __dir__)

def safe_yaml_load(content)
  YAML.safe_load(content, permitted_classes: [Date, Time], aliases: true) || {}
rescue StandardError
  {}
end

# 1. Candidate Profile
profile_file = File.join(ROOT, '_data', 'resume', 'profile.yml')
profile_data = File.exist?(profile_file) ? safe_yaml_load(File.read(profile_file)) : {}

engagements_file = File.join(ROOT, '_data', 'engagements.yml')
engagements_data = File.exist?(engagements_file) ? safe_yaml_load(File.read(engagements_file)) : {}

# 2. Positions (All 29 positions)
positions = {}
tech_provenance = Hash.new do |h, k|
  h[k] = {
    "skill" => k,
    "first_seen_year" => 9999,
    "last_seen_year" => 0,
    "roles_used" => [],
    "total_occurrences" => 0
  }
end

Dir.glob(File.join(ROOT, '_data', 'resume', 'positions', '*.yml')).sort.each do |f|
  slug = File.basename(f, '.yml')
  data = safe_yaml_load(File.read(f))
  data["id"] = slug
  positions[slug] = data

  start_yr = (data["start_date"].to_s[0..3].to_i rescue 0)
  end_yr = data["end_date"].to_s == "Present" ? Time.now.year : (data["end_date"].to_s[0..3].to_i rescue start_yr)
  start_yr = 2006 if start_yr == 0
  end_yr = start_yr if end_yr == 0

  Array(data["skills"]).each do |skill|
    entry = tech_provenance[skill]
    entry["first_seen_year"] = [entry["first_seen_year"], start_yr].min
    entry["last_seen_year"] = [entry["last_seen_year"], end_yr].max
    entry["roles_used"] << {
      "company" => data.dig("company", "name") || slug,
      "title" => data["title"],
      "start_date" => data["start_date"].to_s,
      "end_date" => data["end_date"].to_s
    }
    entry["total_occurrences"] += 1
  end
end

# 3. Archetypes
archetypes_file = File.join(ROOT, '_data', 'resume', 'archetypes.yml')
archetypes_data = File.exist?(archetypes_file) ? safe_yaml_load(File.read(archetypes_file)) : {}

# 4. Case Studies
case_studies_file = File.join(ROOT, '_data', 'case_studies.yml')
case_studies_data = File.exist?(case_studies_file) ? safe_yaml_load(File.read(case_studies_file)) : {}

# 5. Articles / Publications (156 posts)
posts = []
Dir.glob(File.join(ROOT, '_posts', '*.*')).sort.each do |f|
  raw = File.read(f)
  frontmatter = {}
  body = ""
  if raw =~ /\A---\s*\n(.*?)\n---\s*\n?(.*)\z/m
    frontmatter = safe_yaml_load($1)
    body = $2 || ""
  end

  date_match = File.basename(f).match(/\A(\d{4}-\d{2}-\d{2})-(.*)\.(html|md)\z/)
  next unless date_match

  date_str = date_match[1]
  slug = date_match[2]
  year = date_str[0..3].to_i

  clean_excerpt = (frontmatter["description"] || frontmatter["excerpt"] || body.gsub(/<[^>]+>/, ' ').gsub(/\s+/, ' ').strip)[0..250]

  posts << {
    "slug" => slug,
    "date" => date_str,
    "year" => year,
    "title" => frontmatter["title"] || slug.tr('-', ' ').capitalize,
    "categories" => Array(frontmatter["categories"]),
    "tags" => Array(frontmatter["tags"]),
    "excerpt" => clean_excerpt,
    "url" => "/#{date_str.tr('-', '/')}/#{slug}/"
  }
end

# 6. Oral History & Interviews (211 videos/transcripts)
interviews_file = File.join(ROOT, '_data', 'interviews.yml')
interviews_raw = File.exist?(interviews_file) ? safe_yaml_load(File.read(interviews_file)) : {}
interviews_items = interviews_raw.is_a?(Hash) ? (interviews_raw["items"] || interviews_raw.values.first) : interviews_raw
interviews_list = Array(interviews_items).map do |item|
  next unless item.is_a?(Hash)
  conf = item["conference"]
  conf_name = conf.is_a?(Hash) ? conf["name"] : conf.to_s
  conf_year = conf.is_a?(Hash) ? conf["year"] : item["year"]

  {
    "id" => item["id"] || item["slug"],
    "title" => item["title"],
    "interviewee" => item["interviewee"] || (item["interviewees"].is_a?(Array) ? item["interviewees"].first : item["interviewees"]),
    "conference" => conf_name,
    "year" => conf_year,
    "primary_platform" => item["primary_platform"],
    "transcript_id" => item["transcript_id"],
    "page_url" => item["page_url"] || "/interviews/#{item['id']}/"
  }
end.compact

# 7. Knowledge Graph
kg_file = File.join(ROOT, '_data', 'knowledge_graph.json')
kg_data = File.exist?(kg_file) ? JSON.parse(File.read(kg_file)) : { "nodes" => [], "links" => [] }

# 8. Git Chronology & Architectural Epochs
git_epochs = [
  {
    "epoch" => "2006 - 2008",
    "theme" => "Early Web & Microsoft/Enterprise Runtimes",
    "description" => "Early technical writing on NAT/STUN traversal, schema insight, ASP.NET, SQL Server, and full-stack web architectures."
  },
  {
    "epoch" => "2009 - 2015",
    "theme" => "Software Craftsmanship, Community Infrastructure & Ruby on Rails",
    "description" => "Co-founded Chicago Code Camp, hosted 200+ UGtastic interviews across RailsConf, GOTO, and SCNA, engineered high-velocity Rails, PHP, Java, and Vertica systems at Groupon and Obtiva."
  },
  {
    "epoch" => "2016 - 2020",
    "theme" => "High-Scale CRM & Cloud Platforms",
    "description" => "Modernized high-coupling CRM systems at ActiveCampaign, executed zero-downtime database and Rails upgrades at SK Holdings, and led platform consulting at Tandem."
  },
  {
    "epoch" => "2021 - 2026",
    "theme" => "Enterprise Observability, Distributed Monolith Modernization & OTel",
    "description" => "Founded enterprise OpenTelemetry Working Group at OneMain Financial, built the Enterprise Trace connecting Rails, MuleSoft, and IBM Mainframes; served as Interim Architecture & Operational Risk Lead at EMR-Bear."
  },
  {
    "epoch" => "2026 - Present",
    "theme" => "Local AI Orchestration, Deterministic Runtimes & CareerOS",
    "description" => "Architected Phalanx Duel (deterministic rules engine, append-only ledger), WWWorkRemote (pgvector, 4-stage prompt defense), and local AI runtime with llama.cpp and whisper.cpp."
  }
]

# Master Datalake Hash
datalake = {
  "meta" => {
    "generated_at" => Time.now.utc.iso8601,
    "version" => "1.0.0",
    "author" => "Mike Hall",
    "canonical_site" => "https://www.just3ws.com",
    "localhost_site" => "https://just3ws.localhost",
    "endpoints" => {
      "json_manifest" => "https://just3ws.localhost/career_datalake.json",
      "jsonl_stream" => "https://just3ws.localhost/career_datalake.jsonl",
      "resume_json" => "https://just3ws.localhost/resume.json",
      "exports_resume_md" => "https://just3ws.localhost/exports/resume.md",
      "exports_history_md" => "https://just3ws.localhost/exports/history.md",
      "exports_portfolio_md" => "https://just3ws.localhost/exports/portfolio.md",
      "strategy_guide" => "https://just3ws.localhost/reports/archetype-reader-profiles/"
    },
    "stats" => {
      "total_positions" => positions.size,
      "total_archetypes" => archetypes_data.size,
      "total_articles" => posts.size,
      "total_interviews" => interviews_list.size,
      "total_knowledge_graph_nodes" => kg_data["nodes"]&.size || 0,
      "total_technologies_tracked" => tech_provenance.size
    }
  },
  "candidate_profile" => profile_data,
  "availability" => engagements_data.dig("status") || {},
  "archetypes" => archetypes_data,
  "positions" => positions,
  "case_studies" => case_studies_data,
  "technology_provenance" => tech_provenance.sort_by { |k, v| -v["total_occurrences"] }.to_h,
  "publications_and_writings" => posts,
  "oral_history_corpus" => interviews_list,
  "knowledge_graph" => {
    "node_count" => kg_data["nodes"]&.size || 0,
    "link_count" => kg_data["links"]&.size || 0,
    "nodes" => kg_data["nodes"] || [],
    "links" => kg_data["links"] || []
  },
  "git_chronology_and_milestones" => git_epochs
}

# Write master JSON files
json_out = File.join(ROOT, 'career_datalake.json')
File.write(json_out, JSON.pretty_generate(datalake))
puts "✅ Generated #{json_out} (#{File.size(json_out)} bytes)"

# Write exports copies
export_json = File.join(ROOT, 'exports', 'career_datalake.json')
File.write(export_json, JSON.pretty_generate(datalake))
puts "✅ Generated #{export_json}"

# Write JSONL format (line-delimited entities for fast streaming/vector ingest)
jsonl_out = File.join(ROOT, 'career_datalake.jsonl')
File.open(jsonl_out, 'w') do |f|
  f.puts JSON.generate({ "type" => "meta", "data" => datalake["meta"] })
  f.puts JSON.generate({ "type" => "profile", "data" => datalake["candidate_profile"] })
  datalake["archetypes"].each { |k, v| f.puts JSON.generate({ "type" => "archetype", "id" => k, "data" => v }) }
  datalake["positions"].each { |k, v| f.puts JSON.generate({ "type" => "position", "id" => k, "data" => v }) }
  datalake["case_studies"].each { |k, v| f.puts JSON.generate({ "type" => "case_study", "id" => k, "data" => v }) }
  datalake["technology_provenance"].each { |k, v| f.puts JSON.generate({ "type" => "technology", "name" => k, "data" => v }) }
  datalake["publications_and_writings"].each { |p| f.puts JSON.generate({ "type" => "publication", "id" => p["slug"], "data" => p }) }
  datalake["oral_history_corpus"].each { |i| f.puts JSON.generate({ "type" => "interview", "id" => i["id"], "data" => i }) }
  datalake["git_chronology_and_milestones"].each { |m| f.puts JSON.generate({ "type" => "epoch_milestone", "data" => m }) }
end
puts "✅ Generated #{jsonl_out} (#{File.size(jsonl_out)} bytes)"

export_jsonl = File.join(ROOT, 'exports', 'career_datalake.jsonl')
FileUtils.cp(jsonl_out, export_jsonl)
puts "✅ Generated #{export_jsonl}"
