#!/usr/bin/env ruby
require 'yaml'

loop do
  puts "\n[#{Time.now}] Monitoring transcription pipeline..."
  
  # 1. Start worker if not running
  unless system("pgrep -f 'zdots-ctx worker' > /dev/null")
    puts "Worker not detected, starting..."
    system("cd ~/.config/zsh && bundle exec ./bin/zdots-ctx worker --type transcription < /dev/null > /dev/null 2>&1 &")
  end

  # 2. Stage and Ingest
  puts "Running stage and ingest..."
  system("ruby bin/stage_completed_transcripts.rb")
  system("./bin/transcripts ingest --source-dir tmp/transcript-id-staging --min-confidence 0.9 --auto-commit")

  # 3. Check for progress
  assets = YAML.load_file("_data/video_assets.yml")["items"]
  pending = assets.select { |v| (!v["transcript_id"] || v["transcript_id"].empty?) && v["platforms"]&.any? { |p| p["platform"] == "youtube" && p["asset_id"] } }
  
  if pending.empty?
    puts "100% of YouTube assets have been ingested. Monitoring complete."
    break
  else
    puts "#{pending.size} assets still pending transcription."
  end
  
  sleep 60
end
