#!/usr/bin/env ruby
# frozen_string_literal: true

require 'open3'

ROOT = File.expand_path('..', __dir__)

GENERATED_PATHS = [
  '_data/archive_status.yml',
  '_data/community_stories.yml',
  '_data/index_summaries.yml',
  '_data/interview_communities.yml',
  '_data/interview_conferences.yml',
  '_data/interview_topics.yml',
  '_data/interviewees_index.yml',
  '_data/interviews.yml',
  '_data/last_modified.yml',
  '_data/video_assets.yml',
  '_data/video_metadata_completeness.yml',
  'resume/positions'
].freeze

def git_diff_names(paths)
  out, status = Open3.capture2(
    'git',
    'diff',
    '--name-only',
    '--',
    *paths,
    chdir: ROOT
  )
  abort 'Unable to inspect generated artifact freshness.' unless status.success?

  out.lines.map(&:strip).reject(&:empty?)
end

changed = git_diff_names(GENERATED_PATHS)

if changed.empty?
  puts 'Generated artifact freshness validation passed.'
  exit 0
end

warn 'Generated artifact freshness validation failed:'
warn '  Run `bundle exec rake build` and commit regenerated tracked artifacts.'
changed.each { |path| warn "  - #{path}" }
exit 1
