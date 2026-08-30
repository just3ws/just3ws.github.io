#!/usr/bin/env ruby
# frozen_string_literal: true

# bin/promote_content_opportunities.rb
# Scans _data/content_opportunities.yml for human-approved candidates (status: approved)
# and promotes them into draft backlog tasks / downstream documentation.
# Safe & Idempotent: Runs only on approved items and updates status to 'promoted'.

require "yaml"
require "json"
require "optparse"
require "fileutils"
require "time"

ROOT_DIR = File.expand_path("..", __dir__)
DATA_FILE = File.join(ROOT_DIR, "_data", "content_opportunities.yml")
BACKLOG_TASKS_DIR = File.join(ROOT_DIR, "backlog", "tasks")

options = {
  dry_run: false,
  verbose: true
}

OptionParser.new do |opts|
  opts.banner = "Usage: ruby bin/promote_content_opportunities.rb [options]"

  opts.on("-d", "--dry-run", "Preview promotions without writing files or modifying YAML") do
    options[:dry_run] = true
  end

  opts.on("-q", "--quiet", "Suppress non-essential output") do
    options[:verbose] = false
  end

  opts.on("--help", "Show help message") do
    puts opts
    exit 0
  end
end.parse!

unless File.exist?(DATA_FILE)
  warn "Error: #{DATA_FILE} does not exist. Run 'bundle exec rake generate:content_opportunities' first."
  exit 1
end

data = YAML.safe_load_file(DATA_FILE, permitted_classes: [Symbol, Time, Date]) || {}
categories = %w[articles playlists shorts linkedin_durable_wisdom ai_discovery research_threads]

approved_items = []
categories.each do |cat|
  items = data[cat] || []
  items.each do |item|
    if item["status"].to_s.downcase == "approved"
      approved_items << { category: cat, item: item }
    end
  end
end

if approved_items.empty?
  puts "ℹ️  No candidates with 'status: approved' found in #{DATA_FILE}."
  puts "   To approve items, edit _data/content_opportunities.yml and set 'status: approved' on desired IDs."
  exit 0
end

puts "🔍 Found #{approved_items.size} approved content candidate(s) ready for promotion:" if options[:verbose]

promoted_count = 0
approved_items.each do |entry|
  cat = entry[:category]
  item = entry[:item]
  item_id = item["id"]
  title = item["title"] || "Untitled Candidate"
  feeds_task = item["feeds_task"] || "Content Pipeline"
  sources = (item["sources"] || []).map { |s| s["slug"] || s[:slug] }.compact.join(", ")

  task_slug = title.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/^-+|-+$/, "")
  task_filename = "task-candidate-#{item_id}.md"
  task_filepath = File.join(BACKLOG_TASKS_DIR, task_filename)

  task_content = <<~MARKDOWN
    ---
    id: PROMOTED-#{item_id.upcase}
    title: "#{title.gsub('"', '\"')}"
    status: To Do
    category: #{cat}
    feeds_task: #{feeds_task}
    sources: [#{sources}]
    created_date: '#{Time.now.strftime("%Y-%m-%d %H:%M")}'
    type: content
    priority: medium
    ---

    ## Description
    <!-- SECTION:DESCRIPTION:BEGIN -->
    #{item['rationale'] || item['statement'] || title}

    **Promoted from Content Opportunity Backlog (#{cat}):**
    - **ID:** `#{item_id}`
    - **Speaker/Topic:** #{item['speaker'] || item['topic'] || 'Archive Corpus'}
    - **Target Task:** #{feeds_task}
    - **Source Interviews:** #{sources}
    <!-- SECTION:DESCRIPTION:END -->

    ## Evidence & Context
    <!-- SECTION:EVIDENCE:BEGIN -->
    #{item['text'] ? "> \"#{item['text']}\"" : (item['statement'] ? "> #{item['statement']}" : '')}

    #{item['lessons_for_now'] ? "**Lessons for Today:** " + item['lessons_for_now'] : ''}
    <!-- SECTION:EVIDENCE:END -->
  MARKDOWN

  if options[:dry_run]
    puts "   [DRY RUN] Would create #{task_filename} for: #{title}" if options[:verbose]
  else
    FileUtils.mkdir_p(BACKLOG_TASKS_DIR)
    File.write(task_filepath, task_content)
    item["status"] = "promoted"
    promoted_count += 1
    puts "   ✅ Created #{task_filepath}" if options[:verbose]
  end
end

unless options[:dry_run]
  File.write(DATA_FILE, YAML.dump(data))
  puts "🎉 Successfully promoted #{promoted_count} content candidate(s) to backlog tasks."
end
