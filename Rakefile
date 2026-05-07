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
    :export_parity,
    :report_seo,
    :htmlproofer
  ]

  task :export_parity do
    sh 'ruby ./bin/validate_exports.rb'
  end

  task :data_uniqueness do
    sh 'ruby ./bin/validate_data_uniqueness.rb'
  end

  task :data_integrity do
    sh 'ruby ./bin/validate_data.rb'
  end

  task :audit_transcripts => 'transcript:audit'

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
  desc 'Audit transcripts for missing files or content'
  task :audit do
    require_relative 'src/generators/archive_manager'
    auditor = Generators::ArchiveManager::TranscriptAuditor.new(Dir.pwd)
    report = auditor.run
    
    puts "Transcript Audit"
    puts "assets_total=#{report[:assets_total]}"
    puts "assets_with_transcript_id=#{report[:assets_with_transcript_id]}"
    puts "unique_transcript_ids_used=#{report[:unique_transcript_ids_used]}"
    puts "transcript_files=#{report[:transcript_files_count]}"
    puts "missing_transcript_files=#{report[:missing_files].size}"
    puts "missing_transcript_content=#{report[:missing_content].size}"
    puts "invalid_transcript_files=#{report[:invalid_files].size}"
    puts "orphan_transcript_files=#{report[:orphan_files].size}"
    puts "duplicate_transcript_id_usage=#{report[:duplicate_usage].size}"

    unless report[:missing_files].empty?
      puts "\nMissing transcript files:"
      report[:missing_files].each { |f| puts "  - asset=#{f[:asset_id]} transcript_id=#{f[:transcript_id]}" }
    end

    if report[:missing_files].empty? && report[:missing_content].empty? && report[:invalid_files].empty?
      puts "\nTranscript audit passed."
    else
      warn "\nTranscript audit failed."
      exit 1
    end
  end

  desc 'Normalize transcript text (use APPLY=true to save changes)'
  task :normalize do
    require_relative 'src/generators/archive_manager'
    apply = ENV['APPLY'] == 'true'
    transcripts_dir = File.join(Dir.pwd, "_data", "transcripts")
    paths = Dir.glob(File.join(transcripts_dir, "*.yml")).sort
    changed = []

    paths.each do |path|
      payload = YAML.safe_load(File.read(path), permitted_classes: [Date, Time], aliases: true) || {}
      original = payload["content"].to_s
      normalized = Generators::ArchiveManager.normalize_transcript(original)
      next if normalized == original

      changed << path
      if apply
        payload["content"] = normalized
        File.write(path, payload.to_yaml)
      end
    end

    puts "transcript_files=#{paths.size}"
    puts "changed=#{changed.size}"
    changed.first(20).each { |path| puts " - #{Pathname.new(path).relative_path_from(Dir.pwd)}" }
    puts "mode=#{apply ? 'apply' : 'dry-run'}"
  end

  task :prepare_staging do
    sh 'ruby ./bin/prepare_transcript_id_staging.rb'
  end

  task :report_loops do
    sh 'ruby ./bin/report_transcript_loops.rb'
  end

  desc 'Process a transcript using OpenAI (slug: interview slug, apply: save changes)'
  task :process, [:slug] do |_t, args|
    require_relative 'src/generators/transcript_processor'
    slug = args[:slug]
    apply = ENV['APPLY'] == 'true'

    abort "Usage: rake transcript:process[slug] (APPLY=true to save)" unless slug

    # 1. Load data
    interview = YAML.safe_load(File.read('_data/interviews.yml'), permitted_classes: [Date, Time], aliases: true)['items'].find { |i| i['id'] == slug }
    abort "Interview not found: #{slug}" unless interview

    video_asset = YAML.safe_load(File.read('_data/video_assets.yml'), permitted_classes: [Date, Time], aliases: true)['items'].find { |v| v['id'] == interview['video_asset_id'] }
    abort "Video asset not found for: #{slug}" unless video_asset

    transcript_id = video_asset['transcript_id']
    transcript_path = "_data/transcripts/#{transcript_id}.yml"
    abort "Transcript file not found: #{transcript_path}" unless File.exist?(transcript_path)

    transcript_payload = YAML.safe_load(File.read(transcript_path), permitted_classes: [Date, Time], aliases: true)
    content = transcript_payload['content']

    # 2. Process
    puts "Processing #{slug} (transcript: #{transcript_id})..."
    processor = Generators::TranscriptProcessor.new
    result = processor.process(content, interview)

    if result['error']
      puts "Error processing transcript: #{result['error']}"
      puts result['raw_response'] if result['raw_response']
      exit 1
    end

    # 3. Output/Apply
    if apply
      puts "Applying changes to #{transcript_path}..."
      # Preserve existing keys but update/add turns, speaker_map, and insights
      transcript_payload['speaker_map'] = result['speaker_map']
      transcript_payload['turns'] = result['turns']
      transcript_payload['insights'] = result['insights']
      # We keep 'content' for now as a fallback/historical record
      File.write(transcript_path, transcript_payload.to_yaml)
      puts "Done."
    else
      puts "\n--- DRY RUN RESULT ---"
      puts "Speaker Map: #{result['speaker_map']}"
      puts "Turns: #{result['turns']&.size || 0}"
      puts "Insights: #{result['insights']&.size || 0}"
      puts "\nFirst 3 turns:"
      result['turns']&.first(3)&.each { |t| puts "  #{t['speaker']}: #{t['text'][0..100]}..." }
      puts "\nInsights:"
      result['insights']&.each { |i| puts "  - [#{i['type']}] #{i['statement']}" }
      puts "\n(Use APPLY=true to save these changes to the YAML file)"
    end
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

namespace :audit do
  desc 'Prepare an audit prompt for ChatGPT'
  task :prepare, [:slug] do |_t, args|
    slug = args[:slug]
    abort "Usage: rake audit:prepare[slug]" unless slug
    sh "ruby bin/prepare_audit_prompt.rb #{slug}"
  end

  desc 'Ingest an audit result from the inbox'
  task :ingest, [:slug] do |_t, args|
    slug = args[:slug]
    abort "Usage: rake audit:ingest[slug]" unless slug
    inbox_file = "backlog/audit/inbox/#{slug}.yml"
    abort "Error: No file found at #{inbox_file}" unless File.exist?(inbox_file)
    sh "ruby bin/ingest_audit.rb #{slug} #{inbox_file}"
  end

  desc 'Prepare the next wave of interviews for audit'
  task :prepare_wave do
    require 'yaml'
    # Find next "To Do" canonical reviews from Backlog.md
    backlog = File.read('Backlog.md')
    tasks = backlog.scan(/\| \[task-\d+\]\(.*?\) \| Canonical Review \((.*?)\) \| To Do \|/).flatten
    
    # Map of specific task names to their actual slugs to handle the messy ones
    slug_overrides = {
      'Dickinson & Beehler' => 'interview-with-david-dickinson-and-ross-beehler-general',
      'Dave Thomas' => 'dave-thomas-goto-conference-and-community-goto-conference-and-community',
      'Gil Tene' => 'interview-with-gil-tene-azul-cto-javaone-rock-star-goto-chicago-2-general',
      'Chris Whitaker' => 'interview-with-chris-whitaker-general',
      'Dean Wampler' => 'interview-with-dean-wampler-general',
      'Zinni, Buda, Howe' => 'interview-with-anthony-zinni-and-jon-buda-and-shay-howe-general',
      'Giles Bowkett - Rails' => 'interview-with-giles-bowkett-rails'
    }
    
    video_assets = YAML.safe_load(File.read('_data/video_assets.yml'), permitted_classes: [Date, Time], aliases: true)
    
    valid_slugs = []
    
    tasks.each do |task_name|
      break if valid_slugs.size >= 5
      
      clean_name = task_name.sub(/ - Duplicate/, '').strip
      
      # Try exact override, or "first-last-general", or "interview-with-first-last-general"
      base_slug = clean_name.downcase.gsub(/[^a-z0-9]+/, '-')
      slug_candidates = [
        slug_overrides[clean_name],
        "#{base_slug}-general",
        "interview-with-#{base_slug}-general",
        "interview-with-#{base_slug}"
      ].compact
      
      # Find first candidate that has a valid asset mapping and transcript
      matched_slug = nil
      slug_candidates.each do |candidate|
        asset = video_assets['items'].find { |v| v['interview_id'] == candidate || v['id'] == candidate }
        if asset && asset['transcript_id']
          transcript_path = "_data/transcripts/#{asset['transcript_id']}.yml"
          if File.exist?(transcript_path)
            matched_slug = candidate
            break
          end
        end
      end
      
      valid_slugs << matched_slug if matched_slug
    end
    
    if valid_slugs.empty?
      puts "No more 'To Do' tasks found that have existing transcript files."
      exit 0
    end
    
    puts "Preparing Wave 5: #{valid_slugs.join(', ')}"
    
    valid_slugs.each do |slug|
      begin
        sh "ruby bin/prepare_audit_prompt.rb #{slug}"
      rescue => e
        puts "Skipping #{slug}: #{e.message}"
      end
    end
    puts "\nWave 5 Prepared in backlog/audit/outbox/"
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
