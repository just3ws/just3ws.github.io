#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'

interviews = YAML.load_file("_data/interviews.yml")["items"]
assets = YAML.load_file("_data/video_assets.yml")["items"]
transcripts_dir = "_data/transcripts"

puts "Creating backlog tasks for interviews..."

interviews.each do |interview|
  id = interview["id"]
  asset = assets.find { |a| a["id"] == interview["video_asset_id"] }
  next unless asset && asset["transcript_id"]
  
  t_id = asset["transcript_id"]
  t_path = File.join(transcripts_dir, "#{t_id}.yml")
  next unless File.exist?(t_path)
  
  data = YAML.load_file(t_path)
  is_structured = !!data["turns"]
  
  # Only create tasks for non-structured interviews
  next if is_structured
  
  task_id = "interview-#{id}"
  title = "Archive Forensic Review: #{interview['title']}"
  
  # Check if task already exists
  existing = Dir.glob("backlog/tasks/*#{id}*").first
  next if existing
  
  task_content = <<~TASK
    # #{title}

    ## Metadata
    - **Interview ID**: #{id}
    - **Transcript ID**: #{t_id}
    - **Status**: To Do
    - **Priority**: Medium
    - **Labels**: interview, archive-forensics

    ## Description
    Perform a full archive forensic review on this interview to transform it from a raw transcript into a high-fidelity structured dialogue.

    ## Guidance
    Use the `archive-forensics` skill. This interview is currently in the legacy `content:` format.
    
    1. **Normalize**: Run `./bin/apply_perfect_transcript_rules.rb #{t_path}`
    2. **Structure**: Run `./bin/structure_transcript_heuristics.rb #{t_path}`
    3. **Enrich**: Use the `transcript-conversational-audit` skill for deep semantic analysis and insight extraction.

    ## Acceptance Criteria
    - [ ] Brand name "UGtastic" is perfectly normalized.
    - [ ] Monolithic content is converted into `speaker_map` and `turns`.
    - [ ] Speakers (M1: Mike Hall, S1: #{interview['interviewees']&.join(', ')}) are correctly attributed.
    - [ ] Technical jargon is corrected.
    - [ ] Key engineering insights are extracted.
    - [ ] Site rebuild confirms the "iMessage-style" thread layout is active.
  TASK

  # Find next sequence number
  existing_tasks = Dir.glob("backlog/tasks/task-*.md")
  max_num = existing_tasks.map { |f| File.basename(f).match(/task-(\d+)/)[1].to_i }.max || 0
  new_num = sprintf("%03d", max_num + 1)
  
  filename = "task-#{new_num} - Archive-Forensic-Review-#{id}.md"
  File.write("backlog/tasks/#{filename}", task_content)
  puts "Created: #{filename}"
end
