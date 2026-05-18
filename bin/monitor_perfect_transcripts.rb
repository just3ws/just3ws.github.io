#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'

def monitor
  loop do
    puts "--- Checking for new transcripts to perfect ---"
    system("./bin/stage_completed_transcripts.rb")
    system("./bin/transcripts ingest --source-dir tmp/transcript-id-staging --force --auto-commit --skip-validate")
    system("./bin/perfect_transcripts.rb")
    
    # Simple check for any remaining work
    remaining = system("psql \"${DATABASE_URL}\" -X -t -A -q -c \"SELECT 1 FROM jobs WHERE status IN ('pending', 'running') LIMIT 1;\" | grep 1")
    
    break unless remaining
    
    sleep 300
  end
  puts "ALL JOBS COMPLETE."
end

monitor
