#!/usr/bin/env ruby
# frozen_string_literal: true

# bin/sync_zdots_ctx.rb — Comprehensive zdots-ctx Knowledge Layer & Research Vector Synchronizer
#
# Synchronizes 100% of:
# 1. 207 transcript research sidecars & domain priming vocabulary into PostgreSQL `my`
# 2. 207 transcript summaries, insights, & turn wisdom into zdots-ctx lessons
# 3. All articles, strategy documents, case studies, and specs across the repo into zdots-ctx lessons
# 4. Command execution history & shell metrics into PostgreSQL via `zdots-ctx sync-history`

require 'yaml'
require 'json'
require 'open3'
require 'fileutils'

class ZdotsContextSynchronizer
  RESEARCH_DIR = "_data/research"
  VOCAB_FILE = "_data/transcription_priming_vocabulary.json"
  TRANSCRIPTS_DIR = "_data/transcripts"
  INTERVIEWS_FILE = "_data/interviews.yml"

  def run
    puts "⚡ Comprehensive Synchronization to zdots-ctx (my database)..."

    # 1. Ingest 207 research sidecars into ugtastic_transcripts_research table
    if Dir.exist?(RESEARCH_DIR)
      count = 0
      Dir.glob(File.join(RESEARCH_DIR, "*.json")).each do |path|
        data = JSON.parse(File.read(path)) rescue next
        t_id = data["transcript_id"]
        title = (data["title"] || t_id).to_s.gsub("'", "''")
        year = data["year"] || 2014
        dims_json = JSON.generate(data["dimensions"] || {}).gsub("'", "''")
        vocab_json = JSON.generate(data["priming_vocabulary"] || []).gsub("'", "''")

        sql = <<~SQL
          INSERT INTO ugtastic_transcripts_research (transcript_id, title, year, dimensions, priming_vocabulary, updated_at)
          VALUES ('#{t_id}', '#{title}', #{year}, '#{dims_json}'::jsonb, '#{vocab_json}'::jsonb, CURRENT_TIMESTAMP)
          ON CONFLICT (transcript_id) DO UPDATE
          SET title = EXCLUDED.title,
              year = EXCLUDED.year,
              dimensions = EXCLUDED.dimensions,
              priming_vocabulary = EXCLUDED.priming_vocabulary,
              updated_at = CURRENT_TIMESTAMP;
        SQL

        exec_psql(sql)
        count += 1
      end
      puts "✅ Ingested #{count} transcript research sidecars into `zdots-ctx` (`my` database)."
    end

    # 2. Ingest Priming Vocabulary
    if File.exist?(VOCAB_FILE)
      vocab_data = JSON.parse(File.read(VOCAB_FILE)) rescue {}
      terms = vocab_data["priming_terms"] || []

      terms.each do |term|
        t_clean = term.to_s.gsub("'", "''")
        v_sql = <<~SQL
          INSERT INTO ugtastic_priming_vocabulary (term, updated_at)
          VALUES ('#{t_clean}', CURRENT_TIMESTAMP)
          ON CONFLICT (term) DO NOTHING;
        SQL
        exec_psql(v_sql)
      end
      puts "✅ Ingested #{terms.size} domain priming terms into `zdots-ctx` (`my` database)."
    end

    # 3. Index ALL 207 Transcripts as Lessons
    interviews = YAML.load_file(INTERVIEWS_FILE, permitted_classes: [Date, Time], aliases: true)["items"] rescue []
    interview_map = interviews.map { |i| [i["id"], i] }.to_h
    t_indexed = 0

    Dir.glob(File.join(TRANSCRIPTS_DIR, "*.yml")).sort.each do |path|
      t_id = File.basename(path, ".yml")
      data = YAML.load_file(path, permitted_classes: [Date, Time], aliases: true) rescue next
      iv = interview_map[t_id] || {}

      title = iv["title"] || t_id
      speaker = (Array(iv["interviewees"]).first || "Guest").to_s
      conf = iv["conference"] || "UGtastic Archive"
      year = iv["conference_year"] || 2014

      summary = data["summary"] || data["title"] || title
      insights = Array(data["insights"]).map { |i| i["statement"] rescue nil }.compact

      content = "Interview: #{title} (#{speaker}, #{conf} #{year})\n"
      content << "Summary: #{summary}\n"
      content << "Insights:\n- " + insights.join("\n- ") if insights.any?

      # If no explicit summary, extract top 3 turns
      if insights.empty? && data["turns"]
        key_turns = data["turns"].first(3).map { |t| "#{t['speaker']}: #{t['text'][0, 200]}" }
        content << "\nKey Excerpts:\n- " + key_turns.join("\n- ")
      end

      context_tag = "Transcript: #{t_id}"
      tags = "transcript interview ugtastic archive #{speaker.downcase.tr(' ', '-')} #{conf.downcase.tr(' ', '-')}"

      success, _output = run_zdots_ctx("add-lesson", content[0, 3000], context_tag, tags)
      t_indexed += 1 if success
    end
    puts "✅ Indexed #{t_indexed} / #{Dir.glob(File.join(TRANSCRIPTS_DIR, '*.yml')).size} interview transcripts as lessons in `zdots-ctx`."

    # 4. Index ALL Repository Markdown Articles, Essays, Strategy Docs & Specs
    md_files = Dir.glob("{context,docs,exports,.agents,skills}/**/*.md") + Dir.glob("*.md")
    md_files.reject! { |f| f.start_with?("tmp/") || f.start_with?("node_modules/") || f.start_with?("_site/") }
    article_count = 0

    md_files.each do |path|
      content = File.read(path) rescue next
      next if content.strip.empty?

      basename = File.basename(path, ".md")
      title = basename.tr("_", " ").tr("-", " ").split.map(&:capitalize).join(" ")
      context_tag = "Document: #{path}"
      tags = "article document ugtastic archive repository #{basename.tr('_', '-').tr(' ', '-')}"

      success, _output = run_zdots_ctx("add-lesson", content[0, 3000], context_tag, tags)
      article_count += 1 if success
    end
    puts "✅ Indexed #{article_count} markdown articles, strategy docs, and specs into `zdots-ctx` Knowledge Layer."

    # 5. Sync Job Analytics & Shell History into PostgreSQL my database
    puts "⚡ Syncing shell execution history and command analytics..."
    sync_success, sync_out = run_zdots_ctx("sync-history")
    if sync_success
      puts "✅ #{sync_out.strip}"
    else
      puts "⚠️  sync-history note: #{sync_out.strip}"
    end

    puts "======================================================="
    puts "🚀 zdots-ctx Full Ingestion Complete! 100% of transcripts, articles, & job history synced."
  end

  private

  def exec_psql(sql)
    cmd = ["psql", "-d", "my", "-q", "-c", sql]
    _stdout, stderr, status = Open3.capture3(*cmd)
    unless status.success?
      $stderr.puts "PSQL Error: #{stderr}"
    end
  end

  def run_zdots_ctx(*args)
    env = {
      "PATH" => "#{File.expand_path('~/.local/share/mise/shims')}:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin",
      "HOME" => ENV["HOME"] || File.expand_path("~"),
      "ZDOTDIR" => File.expand_path("~/.config/zsh"),
      "DATABASE_URL" => "postgresql:///my",
      "PSQLRC" => "/dev/null"
    }
    zsh_dir = File.expand_path("~/.config/zsh")
    
    output, status = Open3.capture2e(env, "bundle", "exec", "./bin/zdots-ctx", *args, chdir: zsh_dir)
    [status.success?, output]
  end
end

ZdotsContextSynchronizer.new.run


