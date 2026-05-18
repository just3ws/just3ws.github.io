#!/usr/bin/env ruby
require 'yaml'

interviews = YAML.load_file("_data/interviews.yml")["items"]
assets = YAML.load_file("_data/video_assets.yml")["items"]

updated_count = 0

interviews.each do |i|
  id = i["id"]
  asset = assets.find { |a| a["id"] == i["video_asset_id"] } || assets.find { |a| a["id"] == id }
  next unless asset

  title = asset["title"].to_s
  desc = asset["description"].to_s
  name = (i["interviewees"] || []).first || "Expert"
  topic = i["topic"] || "Technology"
  
  needs_update = false

  # 1. Optimize Title if it lacks a hook
  unless title.include?(":") || title.include?("|")
    # Capitalize topic nicely
    nice_topic = topic.split.map(&:capitalize).join(' ')
    # Determine context (conference or community)
    context = i["conference"] ? " | #{i["conference"]} #{i["conference_year"]}".strip : ""
    
    new_title = "#{nice_topic}: Mike Hall Interviews #{name}#{context}"
    
    # If the original title was literally just their name or a basic string, replace it entirely.
    asset["title"] = new_title
    i["title"] = new_title
    needs_update = true
  end

  # 2. Enrich Description & Add CTA
  unless desc.include?("just3ws.github.io/interviews/")
    # If it's the very dry default description, punch it up
    if desc.match?(/^Interview with #{Regexp.escape(name)} on/i) || desc.match?(/^Talk: /i)
      new_desc = "Mike Hall interviews #{name} about #{topic}. We dive deep into the ecosystem to extract practical lessons and perspectives for software teams and technical communities."
      asset["description"] = new_desc
    end
    
    # Append the CTA link
    cta = "\n\n🔗 Read the full structured forensic transcript with durable insights at: https://just3ws.github.io/interviews/#{id}"
    asset["description"] = asset["description"].to_s.strip + cta
    needs_update = true
  end

  # Ensure YouTube specific tags are present in the asset
  asset["tags"] ||= []
  ["software engineering", "tech interview", "UGtastic"].each do |t|
    asset["tags"] << t unless asset["tags"].include?(t)
  end

  updated_count += 1 if needs_update
end

File.write("_data/interviews.yml", { "items" => interviews }.to_yaml)
File.write("_data/video_assets.yml", { "items" => assets }.to_yaml)

puts "Successfully applied baseline SEO, Hooks, and CTAs to #{updated_count} items."
