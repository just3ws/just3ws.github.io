#!/usr/bin/env ruby
require 'yaml'

def audit
  interviews = YAML.load_file("_data/interviews.yml")["items"]
  assets = YAML.load_file("_data/video_assets.yml")["items"]
  
  puts "--- METADATA AUDIT REPORT ---"
  
  issues = []
  
  interviews.each do |i|
    # Check for placeholder or generic titles
    if i["title"] =~ /^Interview with/i && i["title"].split.size < 4
      issues << "Generic Interview Title: #{i["id"]} (#{i["title"]})"
    end
    
    # Descriptions are usually in video_assets
    asset = assets.find { |a| a["id"] == i["video_asset_id"] }
    if asset
      desc = asset["description"] || ""
      if desc.strip.empty?
        issues << "Missing Description: Interview #{i["id"]}"
      elsif desc.include?("Join Gary Bernhardt") # Check for the template I saw earlier
        # issues << "Template Description found for #{i["id"]}"
      end
      
      # Check for title mismatch
      if i["title"] != asset["title"]
        # issues << "Title Mismatch: #{i["id"]} (Interview: '#{i["title"]}' vs Asset: '#{asset["title"]}')"
      end
    else
      issues << "Missing Asset Link: Interview #{i["id"]}"
    end
  end
  
  assets.each do |a|
    if (a["description"] || "").include?("Destroy All Software") && a["id"] != "gary-bernhardt-software-craftsmanship-north-america-2012" && a["id"] != "interview-with-gary-bernhardt-creator-destroy-all-software-at-scna-chicago-general"
       issues << "Possible Template Leak: Asset #{a["id"]} contains Gary Bernhardt description text."
    end
    
    if (a["title"] || "").strip.empty?
      issues << "Missing Title: Asset #{a["id"]}"
    end
  end

  if issues.any?
    puts "Found #{issues.size} issues:"
    issues.each { |issue| puts " - #{issue}" }
  else
    puts "No critical metadata issues found."
  end
end

audit
