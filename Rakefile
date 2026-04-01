# frozen_string_literal: true

require 'rake'
require 'fileutils'

desc 'Run the full CI pipeline (build, test, validate)'
task ci: ['build', 'test', 'validate']

desc 'Build the site (generate + jekyll build)'
task build: ['generate:all'] do
  sh 'ruby ./bin/generate_last_modified.rb'
  ENV['JEKYLL_ENV'] = 'production'
  sh 'bundle exec jekyll clean --verbose'
  sh 'bundle exec jekyll build --verbose'
  rm_f '_site/AGENTS.html'
  rm_f '_site/AGENTS.md'
end

desc 'Run RSpec tests'
task :test do
  sh 'bundle exec rspec'
end

desc 'Validate the built site'
task validate: ['validate:all']

namespace :generate do
  desc 'Run all generation scripts (Legacy disk-based scripts are mostly deprecated by plugins)'
  task all: [
    :sync_links,
    :context_summaries,
    :video_completeness,
    :archive_status,
    # :interview_pages,      # Deprecated by InterviewGenerator plugin
    # :video_pages,          # Deprecated by VideoAssetGenerator plugin
    # :taxonomy,             # Deprecated by TaxonomyGenerator plugin
    :topics,
    :interviewees,
    :community_stories,
    :resume_positions
  ]

  task :sync_links do
    sh './bin/sync_interview_asset_links.rb'
  end

  task :context_summaries do
    sh 'ruby ./bin/generate_context_summaries.rb'
  end

  task :video_completeness do
    sh 'ruby ./bin/generate_video_metadata_completeness.rb'
  end

  task :archive_status do
    sh 'ruby ./bin/generate_archive_status.rb'
  end

  task :interview_pages do
    sh './bin/generate_interview_pages.rb'
  end

  task :video_pages do
    sh 'ruby ./bin/generate_video_asset_pages.rb'
  end

  task :taxonomy do
    sh 'ruby ./bin/generate_interview_taxonomy_pages.rb'
  end

  task :topics do
    sh 'ruby ./bin/generate_interview_topics_page.rb'
  end

  task :interviewees do
    sh 'ruby ./bin/generate_interviewees_page.rb'
  end

  task :community_stories do
    sh 'ruby ./bin/generate_community_stories_page.rb'
  end

  task :resume_positions do
    sh 'ruby ./bin/generate_resume_position_pages.rb'
  end

  task :blog_inventory do
    sh 'ruby ./bin/generate_blog_import_inventory.rb'
  end

  task :wayback_pages do
    sh 'ruby ./bin/generate_wayback_pages.rb'
  end

  task :wbm_backlog do
    sh 'ruby ./bin/generate_wbm_asset_backlog.rb'
  end
end

namespace :validate do
  desc 'Run all validation scripts'
  task all: [
    :data_uniqueness,
    :data_integrity,
    :audit_transcripts,
    :resources_output,
    :taxonomy_output,
    :archive_surfaces,
    :last_modified_output,
    :repo_hygiene,
    :metadata_completeness,
    :seo_output,
    :public_index_mode,
    :semantic_output,
    :report_seo,
    :htmlproofer
  ]

  task :data_uniqueness do
    sh 'ruby ./bin/validate_data_uniqueness.rb'
  end

  task :data_integrity do
    sh 'ruby ./bin/validate_data_integrity.rb'
  end

  task :audit_transcripts do
    sh 'ruby ./bin/audit_transcripts.rb'
  end

  task :resources_output do
    sh 'ruby ./bin/validate_resources_output.rb'
  end

  task :taxonomy_output do
    sh 'ruby ./bin/validate_taxonomy_output.rb'
  end

  task :archive_surfaces do
    sh 'ruby ./bin/validate_archive_surfaces.rb'
  end

  task :last_modified_output do
    sh 'ruby ./bin/validate_last_modified_output.rb'
  end

  task :repo_hygiene do
    sh 'ruby ./bin/validate_repo_hygiene.rb'
  end

  task :metadata_completeness do
    sh 'ruby ./bin/validate_metadata_completeness_budget.rb'
  end

  task :seo_output do
    sh 'ruby ./bin/validate_seo_output.rb'
  end

  task :public_index_mode do
    sh 'ruby ./bin/validate_public_index_mode.rb'
  end

  task :semantic_output do
    sh 'ruby ./bin/validate_semantic_output.rb'
  end

  task :report_seo do
    sh 'ruby ./bin/report_seo_metadata.rb'
  end

  task :htmlproofer do
    require 'html-proofer'
    options = {
      assume_extension: true,
      disable_external: true,
      ignore_files: [/AGENTS\.html$/, %r{^/backlog/}, %r{^backlog/}],
      ignore_urls: [%r{^https://www\.linkedin\.com/}, %r{^/backlog/}],
    }
    HTMLProofer.check_directory('./_site', options).run
  end
end

namespace :import do
  task :frogsbrain do
    sh 'ruby ./bin/import_frogsbrain_local_snapshots.rb'
  end

  task :ironlanguages do
    sh 'ruby ./bin/import_ironlanguages_local_snapshots.rb'
  end

  task :linkedin do
    sh 'ruby ./bin/import_linkedin_articles.rb'
  end

  task :transcripts do
    sh 'ruby ./bin/import_transcripts_from_outbox.rb'
  end

  task :wayback_blogger do
    sh 'ruby ./bin/import_wayback_blogger_posts.rb'
  end

  task :wayback_ironlanguages do
    sh 'ruby ./bin/import_wayback_ironlanguages_posts.rb'
  end

  task :wayback_wordpress do
    sh 'ruby ./bin/import_wayback_wordpress_posts.rb'
  end

  task :witc_youtube do
    sh 'ruby ./bin/import_witc_missing_youtube_assets.rb'
  end

  task :wordpress do
    sh 'ruby ./bin/import_wordpress_local_snapshots.rb'
  end
end

namespace :transcript do
  task :audit do
    sh 'ruby ./bin/audit_transcripts.rb'
  end

  task :normalize do
    sh 'ruby ./bin/normalize_transcripts.rb'
  end

  task :prepare_staging do
    sh 'ruby ./bin/prepare_transcript_id_staging.rb'
  end

  task :report_loops do
    sh 'ruby ./bin/report_transcript_loops.rb'
  end
end

namespace :maintenance do
  task :apply_ugtastic_context do
    sh 'ruby ./bin/apply_ugtastic_context_to_video_assets.rb'
  end

  task :merge_duplicates do
    sh 'ruby ./bin/merge_duplicate_interview_publications.rb'
  end
end

namespace :report do
  task :legacy_logs do
    sh 'ruby ./bin/report_legacy_domain_logs.rb'
  end

  task :seo do
    sh 'ruby ./bin/report_seo_metadata.rb'
  end
end

namespace :enrich do
  task :non_transcript do
    sh 'ruby ./bin/enrich_non_transcript_metadata.rb'
  end

  task :transcript do
    sh 'ruby ./bin/enrich_transcript_metadata.rb'
  end
end

namespace :extract do
  task :ugtastic do
    sh 'ruby ./bin/extract_ugtastic_context.rb'
  end

  task :wayback do
    sh 'ruby ./bin/extract_wayback_content.rb'
  end
end

namespace :discover do
  task :wayback do
    sh 'ruby ./bin/discover_wayback_posts_from_cdx.rb'
  end
end

namespace :semantic do
  desc 'Generate semantic graph artifacts'
  task :graph do
    sh 'ruby ./bin/visualize_semantic_graph.rb'
  end

  desc 'Generate semantic audit report'
  task :audit do
    sh 'ruby ./bin/semantic_audit.rb'
  end

  desc 'Generate semantic snapshot page'
  task :snapshot do
    sh 'ruby ./bin/generate_semantic_snapshot_page.rb'
  end
end

desc 'Run local development server'
task :server do
  sh './bin/server'
end

desc 'Manage transcripts'
task :transcripts do
  sh './bin/transcripts'
end

desc 'Show deployment status'
task :deploy_status do
  sh './bin/deploy_status'
end

desc 'Run Playwright smoke checks'
task :smoke do
  sh './bin/smoke_playwright.sh'
end

desc 'Print sitemap coverage summary'
task :sitemap do
  sh 'ruby ./bin/visualize_sitemap.rb'
end
