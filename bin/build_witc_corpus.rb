#!/usr/bin/env ruby
# frozen_string_literal: true

# Build a local, provenance-preserving SQLite corpus from the WITC archive.
# The database follows ~/my/lib/archive_search.py's documents + FTS5 contract.

require "date"
require "digest"
require "fileutils"
require "json"
require "optparse"
require "pathname"
require "sqlite3"
require "time"

DEFAULT_SOURCE = ENV.fetch("WITC_CORPUS_DIR", "")
DEFAULT_OUTPUT = File.expand_path("../lake/witc/corpus.db", __dir__)
TEXT_EXTENSIONS = %w[md markdown txt srt ttml vtt json jsonl yml yaml xml html htm erb haml slim feature rb rake gemspec builder jbuilder py js jsx ts tsx coffee css scss less sh zsh vim].freeze
EXCLUDED_DIRS = %w[.git .svn .hg node_modules vendor bundle tmp cache caches log logs public assets build dist coverage .bundle .sass-cache private secrets credentials _backup backup].freeze
EXCLUDED_BASENAMES = %w[.env .s3cfg .bash_history .rediscli_history .rdebugrc].freeze
EXCLUDED_EXTENSIONS = %w[key pem p12 pfx crt cer asc secret secrets credentials credential].freeze
MAX_BYTES = 2 * 1024 * 1024
SENSITIVE_CONTENT = /(?:license_key|api[_-]?key|secret[_-]?key|private[_-]?key|password|access[_-]?token|client[_-]?secret)\s*[:=]/i

options = { source: DEFAULT_SOURCE, output: DEFAULT_OUTPUT, apply: false, limit: nil }
OptionParser.new do |opts|
  opts.banner = "Usage: bin/build_witc_corpus.rb [--dry-run|--apply] [options]"
  opts.on("--source PATH", "WITC archive root") { |v| options[:source] = v }
  opts.on("--output PATH", "SQLite output path") { |v| options[:output] = v }
  opts.on("--apply", "Build/replace the generated database") { options[:apply] = true }
  opts.on("--dry-run", "Scan and report without writing (default)") { options[:apply] = false }
  opts.on("--limit N", Integer, "Stop after N eligible files") { |v| options[:limit] = v }
  opts.on_tail("-h", "--help", "Show help") { puts opts; exit }
end.parse!

abort "Set WITC_CORPUS_DIR or pass --source PATH" if options[:source].to_s.empty?
source = File.expand_path(options[:source])
abort "Source directory not found: #{source}" unless Dir.exist?(source)

def excluded?(path, root)
  relative = Pathname.new(path).relative_path_from(Pathname.new(root)).to_s
  parts = relative.split(File::SEPARATOR)
  basename = File.basename(path).downcase
  ext = File.extname(path).delete_prefix(".").downcase
  parts.any? { |part| EXCLUDED_DIRS.include?(part.downcase) } ||
    EXCLUDED_BASENAMES.include?(basename) || EXCLUDED_EXTENSIONS.include?(ext) ||
    basename.match?(%r{(^|[._-])(secret|credential|password|token|private|key)([._-]|$)})
end

def source_kind(path)
  ext = File.extname(path).delete_prefix(".").downcase
  return "transcript" if %w[srt ttml vtt].include?(ext)
  return "metadata" if %w[json jsonl yml yaml xml].include?(ext)
  return "documentation" if %w[md markdown txt html htm].include?(ext)
  "source"
end

def project_identity(path, root)
  current = File.dirname(path)
  root = File.expand_path(root)
  while current.start_with?(root)
    return Pathname.new(current).relative_path_from(Pathname.new(root)).to_s if Dir.exist?(File.join(current, ".git")) || current == root
    current = File.dirname(current)
  end
  "."
end

def temporal_metadata(path, root)
  relative = Pathname.new(path).relative_path_from(Pathname.new(root)).to_s
  dates = relative.scan(/(?:19|20)\d{2}[-_.](?:0[1-9]|1[0-2])[-_.](?:0[1-9]|[12]\d|3[01])/).filter_map do |d|
    Date.parse(d.tr("_.", "--")).iso8601 rescue nil
  end
  mtime = File.mtime(path).utc
  { "date_candidates" => dates.uniq, "file_mtime" => mtime.iso8601, "primary_time" => dates.first || mtime.iso8601, "primary_time_kind" => dates.empty? ? "file_mtime" : "path_date_candidate" }
end

def stable_id(relative, digest)
  Digest::SHA256.hexdigest("witc\0#{relative}\0#{digest}")[0, 32]
end

files = []
skipped = Hash.new(0)
Dir.glob(File.join(source, "**", "*"), File::FNM_DOTMATCH).sort.each do |path|
  next unless File.file?(path)
  if excluded?(path, source)
    skipped[:excluded] += 1
    next
  end
  ext = File.extname(path).delete_prefix(".").downcase
  unless TEXT_EXTENSIONS.include?(ext)
    skipped[:unsupported] += 1
    next
  end
  if File.size(path) > MAX_BYTES
    skipped[:too_large] += 1
    next
  end
  relative = Pathname.new(path).relative_path_from(Pathname.new(source)).to_s
  digest = Digest::SHA256.file(path).hexdigest
  content = File.binread(path).force_encoding("UTF-8").encode("UTF-8", invalid: :replace, undef: :replace, replace: "�")
  if content.match?(SENSITIVE_CONTENT)
    skipped[:sensitive_content] += 1
    next
  end
  next if content.strip.empty?
  temporal = temporal_metadata(path, source)
  project = project_identity(path, source)
  files << { "id" => stable_id(relative, digest), "thread_id" => Digest::SHA256.hexdigest("thread\0#{project}")[0, 32], "path" => relative, "project" => project, "kind" => source_kind(path), "extension" => ext, "bytes" => File.size(path), "sha256" => digest, "content" => content, "temporal" => temporal }
  break if options[:limit] && files.size >= options[:limit]
end

dates = files.map { |f| f.dig("temporal", "date_candidates") }.flatten.sort
puts JSON.pretty_generate({ source: source, output: options[:output], scanned_records: files.size, skipped: skipped, by_kind: files.group_by { |f| f["kind"] }.transform_values(&:size), date_range: dates.empty? ? nil : [dates.first, dates.last], mode: options[:apply] ? "apply" : "dry-run" })
exit 0 unless options[:apply]

FileUtils.mkdir_p(File.dirname(options[:output]))
tmp = "#{options[:output]}.tmp-#{$$}"
FileUtils.rm_f(tmp)
db = SQLite3::Database.new(tmp)
db.execute_batch <<~SQL
  PRAGMA journal_mode = DELETE;
  CREATE TABLE corpus_metadata (key TEXT PRIMARY KEY, value TEXT NOT NULL);
  CREATE TABLE threads (id TEXT PRIMARY KEY, title TEXT NOT NULL, source_root TEXT NOT NULL);
  CREATE TABLE documents (id TEXT PRIMARY KEY, content TEXT NOT NULL, created_at REAL NOT NULL, author TEXT, thread_id TEXT NOT NULL, source_path TEXT NOT NULL, project TEXT NOT NULL, source_kind TEXT NOT NULL, file_mtime TEXT NOT NULL, time_kind TEXT NOT NULL, sha256 TEXT NOT NULL, byte_size INTEGER NOT NULL, provenance_json TEXT NOT NULL);
  CREATE VIRTUAL TABLE documents_fts USING fts5(content, doc_ref UNINDEXED, tokenize='porter unicode61');
  CREATE INDEX documents_thread_idx ON documents(thread_id);
  CREATE INDEX documents_time_idx ON documents(created_at);
SQL

meta = { "schema_version" => "1.0", "corpus" => "witc", "generated_at" => Time.now.utc.iso8601, "source_root_name" => File.basename(source), "source_root" => "configured-at-build-time", "record_count" => files.size, "max_file_bytes" => MAX_BYTES, "excluded_dirs" => EXCLUDED_DIRS, "excluded_extensions" => EXCLUDED_EXTENSIONS }
db.transaction do
  meta.each { |key, value| db.execute("INSERT INTO corpus_metadata(key,value) VALUES (?,?)", [key, JSON.generate(value)]) }
  files.group_by { |f| f["thread_id"] }.each { |thread_id, group| db.execute("INSERT INTO threads VALUES (?,?,?)", [thread_id, group.first["project"], "configured-at-build-time"]) }
  files.each do |f|
    db.execute("INSERT INTO documents VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)", [f["id"], f["content"], Time.parse(f.dig("temporal", "primary_time")).to_f, nil, f["thread_id"], f["path"], f["project"], f["kind"], f.dig("temporal", "file_mtime"), f.dig("temporal", "primary_time_kind"), f["sha256"], f["bytes"], JSON.generate(f["temporal"])])
    db.execute("INSERT INTO documents_fts(content, doc_ref) VALUES (?,?)", [f["content"], f["id"]])
  end
end
db.close
File.rename(tmp, options[:output])
puts "Wrote #{options[:output]} (#{files.size} documents)"
