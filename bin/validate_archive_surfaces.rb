#!/usr/bin/env ruby

require "yaml"
require "date"
require "set"

ROOT = File.expand_path("..", __dir__)
SITE_DIR = File.join(ROOT, "_site")
INTERVIEWS_PATH = File.join(ROOT, "_data", "interviews.yml")
TOPICS_PATH = File.join(ROOT, "_data", "interview_topics.yml")
PEOPLE_PATH = File.join(ROOT, "_data", "interviewees_index.yml")
STORIES_PATH = File.join(ROOT, "_data", "community_stories.yml")
STATUS_PATH = File.join(ROOT, "_data", "archive_status.yml")

def load_yaml(path)
  YAML.safe_load(File.read(path), permitted_classes: [Date, Time], aliases: true) || {}
end

def blank?(value)
  value.nil? || value.to_s.strip.empty?
end

errors = []

required_data_files = [TOPICS_PATH, PEOPLE_PATH, STORIES_PATH, STATUS_PATH]
required_data_files.each do |path|
  errors << "missing required data file: #{path}" unless File.file?(path)
end

if errors.empty?
  interviews = load_yaml(INTERVIEWS_PATH).fetch("items", [])
  interview_ids = interviews.map { |item| item["id"] }.to_set

  topics = load_yaml(TOPICS_PATH).fetch("items", [])
  topics.each do |topic|
    errors << "topic missing name: #{topic.inspect}" if blank?(topic["topic"])
    Array(topic["sample_interview_ids"]).each do |interview_id|
      errors << "topic #{topic['topic']} references unknown interview_id: #{interview_id}" unless interview_ids.include?(interview_id)
    end
  end

  people = load_yaml(PEOPLE_PATH).fetch("items", [])
  people.each do |person|
    errors << "interviewee entry missing name: #{person.inspect}" if blank?(person["name"])
    Array(person["sample_interview_ids"]).each do |interview_id|
      errors << "interviewee #{person['name']} references unknown interview_id: #{interview_id}" unless interview_ids.include?(interview_id)
    end
  end

  stories = load_yaml(STORIES_PATH).fetch("tracks", [])
  stories.each do |track|
    errors << "story track missing title: #{track.inspect}" if blank?(track["title"])
    if Array(track["interview_ids"]).empty?
      errors << "story track #{track['id'] || '<missing-id>'} has no interview_ids"
    end
    Array(track["interview_ids"]).each do |interview_id|
      errors << "story track #{track['id'] || '<missing-id>'} references unknown interview_id: #{interview_id}" unless interview_ids.include?(interview_id)
    end
  end
end

required_routes = [
  "start-here/index.html",
  "archive-status/index.html",
  "interviews/topics/index.html",
  "interviews/people/index.html",
  "interviews/stories/index.html",
  "work-through-conversations/index.html"
]
required_routes.each do |relative|
  path = File.join(SITE_DIR, relative)
  errors << "missing required route output: _site/#{relative}" unless File.file?(path)
end

if errors.empty?
  puts "Archive surfaces validation passed."
  exit 0
end

warn "Archive surfaces validation failed:"
errors.each { |error| warn "  - #{error}" }
exit 1
