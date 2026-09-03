#!/usr/bin/env ruby
# frozen_string_literal: true

# Query the local WITC SQLite corpus built by bin/build_witc_corpus.rb.

require "json"
require "optparse"
require "sqlite3"
require "time"

ROOT = File.expand_path("..", __dir__)
DEFAULT_DB = ENV.fetch("WITC_CORPUS_DB", File.join(ROOT, "lake", "witc", "corpus.db"))
options = { db: DEFAULT_DB, limit: 20, json: false, corpus: "witc" }
OptionParser.new do |opts|
  opts.banner = "Usage: bin/query_witc_corpus.rb [options]"
  opts.on("-s", "--search QUERY", "Full-text search WITC records") { |v| options[:search] = v }
  opts.on("--stats", "Show corpus statistics") { options[:stats] = true }
  opts.on("--source PATH", "Filter by relative source path") { |v| options[:source] = v }
  opts.on("--kind KIND", "Filter by source kind") { |v| options[:kind] = v }
  opts.on("--since DATE", "Include records from this ISO date") { |v| options[:since] = Time.parse(v).to_f }
  opts.on("--until DATE", "Include records through this ISO date") { |v| options[:until] = Time.parse(v).to_f + 86_399 }
  opts.on("-l", "--limit N", Integer, "Bound results (default: 20, maximum: 100)") { |v| options[:limit] = [[v, 1].max, 100].min }
  opts.on("--db PATH", "SQLite corpus path") { |v| options[:db] = v }
  opts.on("--corpus NAME", "Corpus to query: witc (default) or all") { |v| options[:corpus] = v }
  opts.on("-j", "--json", "Emit JSON") { options[:json] = true }
  opts.on_tail("-h", "--help", "Show help") { puts opts; exit }
end.parse!

abort "Corpus not found: #{options[:db]}\nBuild it with: bin/build_witc_corpus.rb --apply" unless File.file?(options[:db])
db = SQLite3::Database.new(options[:db])
db.results_as_hash = true

if options[:stats]
  result = {
    "corpus" => "witc", "database" => options[:db],
    "documents" => db.get_first_value("SELECT COUNT(*) FROM documents"),
    "threads" => db.get_first_value("SELECT COUNT(*) FROM threads"),
    "by_kind" => db.execute("SELECT source_kind, COUNT(*) AS count FROM documents GROUP BY source_kind ORDER BY source_kind").to_h { |r| [r["source_kind"], r["count"]] },
    "time_range" => db.get_first_row("SELECT MIN(datetime(created_at, 'unixepoch')) AS first, MAX(datetime(created_at, 'unixepoch')) AS last FROM documents")
  }
else
  query = options[:search].to_s.strip
  if query.empty?
    rows = db.execute("SELECT d.* FROM documents d ORDER BY d.created_at DESC LIMIT ?", options[:limit])
  else
    fts_query = query.match?(/[^\p{Alnum}_\s]/) ? query.split.map { |term| %Q{"#{term.gsub('"', '""')}"} }.join(" AND ") : query
    where = ["documents_fts MATCH ?"]
    params = [fts_query]
    if options[:source]
      where << "d.source_path LIKE ?"
      params << "%#{options[:source]}%"
    end
    if options[:kind]
      where << "d.source_kind = ?"
      params << options[:kind]
    end
    if options[:since]
      where << "d.created_at >= ?"
      params << options[:since]
    end
    if options[:until]
      where << "d.created_at <= ?"
      params << options[:until]
    end
    rows = db.execute("SELECT d.id, substr(d.content, 1, 1600) AS content, d.created_at, d.thread_id, d.source_path, d.project, d.source_kind, d.file_mtime, d.time_kind, d.sha256, d.byte_size FROM documents_fts f JOIN documents d ON d.id = f.doc_ref WHERE #{where.join(' AND ')} ORDER BY bm25(documents_fts), d.created_at LIMIT ?", params + [options[:limit]])
  end
  witc_result = { "corpus" => options[:corpus], "query" => options[:search], "count" => rows.size, "records" => rows.map { |row| row.merge("created_at_iso" => Time.at(row["created_at"]).utc.iso8601) } }
  if options[:corpus] == "all"
    career = JSON.parse(File.read(File.join(ROOT, "career_datalake.json")))
    q = options[:search].to_s.downcase
    publications = career.fetch("publications_and_writings", []).select { |p| JSON.generate(p).downcase.include?(q) }
    interviews = career.fetch("oral_history_corpus", []).select { |i| JSON.generate(i).downcase.include?(q) }
    witc_result["career"] = { "publication_count" => publications.size, "publications" => publications.first(options[:limit]), "interview_count" => interviews.size, "interviews" => interviews.first(options[:limit]) }
  end
  result = witc_result
end

puts JSON.pretty_generate(result)
