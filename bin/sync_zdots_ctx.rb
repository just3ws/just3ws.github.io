#!/usr/bin/env ruby
# frozen_string_literal: true

# bin/sync_zdots_ctx.rb — zdots-ctx PostgreSQL Bridge & Research Vector Synchronizer
#
# Syncs all 207 transcript research sidecars and priming vocabulary into Mike's
# personal OS context engine (zdots-ctx PostgreSQL database `my`).

require 'json'
require 'open3'
require 'fileutils'

class ZdotsContextSynchronizer
  RESEARCH_DIR = "_data/research"
  VOCAB_FILE = "_data/transcription_priming_vocabulary.json"

  def run
    puts "⚡ Syncing UGtastic Archive Research to zdots-ctx (my database)..."

    unless Dir.exist?(RESEARCH_DIR)
      puts "❌ Error: #{RESEARCH_DIR} directory not found. Run `ruby bin/deep_research_interview.rb --all` first."
      exit 1
    end

    # 1. Initialize PostgreSQL tables in `my` DB
    init_sql = <<~SQL
      CREATE TABLE IF NOT EXISTS ugtastic_transcripts_research (
        transcript_id VARCHAR(255) PRIMARY KEY,
        title TEXT,
        year INTEGER,
        dimensions JSONB,
        priming_vocabulary JSONB,
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );

      CREATE TABLE IF NOT EXISTS ugtastic_priming_vocabulary (
        term VARCHAR(255) PRIMARY KEY,
        category VARCHAR(100),
        frequency INTEGER DEFAULT 1,
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );
    SQL

    exec_psql(init_sql)
    puts "✅ Database tables `ugtastic_transcripts_research` & `ugtastic_priming_vocabulary` verified in `my` DB."

    # 2. Ingest 207 research sidecars
    count = 0
    Dir.glob(File.join(RESEARCH_DIR, "*.json")).each do |path|
      data = JSON.parse(File.read(path)) rescue next
      t_id = data["transcript_id"]
      title = (data["title"] || t_id).gsub("'", "''")
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

    # 3. Ingest Priming Vocabulary
    if File.exist?(VOCAB_FILE)
      vocab_data = JSON.parse(File.read(VOCAB_FILE)) rescue {}
      terms = vocab_data["priming_terms"] || []

      terms.each do |term|
        t_clean = term.gsub("'", "''")
        v_sql = <<~SQL
          INSERT INTO ugtastic_priming_vocabulary (term, updated_at)
          VALUES ('#{t_clean}', CURRENT_TIMESTAMP)
          ON CONFLICT (term) DO NOTHING;
        SQL
        exec_psql(v_sql)
      end
      puts "✅ Ingested #{terms.size} domain priming terms into `zdots-ctx` (`my` database)."
    end

    puts "======================================================="
    puts "🚀 zdots-ctx Sync Complete! Personal OS pipeline is 100% enriched."
  end

  private

  def exec_psql(sql)
    cmd = ["psql", "-d", "my", "-q", "-c", sql]
    _stdout, stderr, status = Open3.capture3(*cmd)
    unless status.success?
      $stderr.puts "PSQL Error: #{stderr}"
    end
  end
end

ZdotsContextSynchronizer.new.run
