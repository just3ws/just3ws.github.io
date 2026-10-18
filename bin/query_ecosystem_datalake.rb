#!/usr/bin/env ruby
# frozen_string_literal: true

# ---
# name: query_ecosystem_datalake.rb
# domain: data
# purpose: Fast query interface for the ecosystem datalake via SQLite3 FTS5 or DuckDB
# usage: ruby bin/query_ecosystem_datalake.rb --search <term> OR --stats OR --sql <query>
# ---

require 'sqlite3'
require 'json'
require 'optparse'

ROOT ||= File.expand_path('..', __dir__)
DB_PATH = File.join(ROOT, 'lake', 'ecosystem', 'ecosystem.db')
JSONL_PATH = File.join(ROOT, 'lake', 'ecosystem', 'ecosystem.jsonl')
MANIFEST_PATH = File.join(ROOT, 'lake', 'ecosystem', 'ecosystem_manifest.json')

class EcosystemDatalakeQuery
  def initialize(db_path = DB_PATH)
    unless File.file?(db_path)
      system("ruby #{File.join(ROOT, 'bin', 'build_ecosystem_datalake.rb')}")
    end
    @db = SQLite3::Database.new(db_path)
    @db.results_as_hash = true
  end

  def stats
    manifest = File.file?(MANIFEST_PATH) ? JSON.parse(File.read(MANIFEST_PATH)) : {}
    repo_counts = @db.execute('SELECT organization, count(*) as count FROM repositories GROUP BY organization ORDER BY count DESC')
    commit_counts = @db.execute('SELECT repo_name, count(*) as count FROM commits GROUP BY repo_name ORDER BY count DESC')
    artifact_count = @db.get_first_value('SELECT count(*) FROM historical_artifacts')

    {
      'generated_at' => manifest['generated_at'],
      'total_repositories' => manifest['total_repositories'],
      'total_commits' => manifest['total_commits_indexed'],
      'total_artifacts' => artifact_count,
      'by_organization' => repo_counts,
      'top_repos_by_commits' => commit_counts.first(10)
    }
  end

  def search(term, limit = 20)
    query = <<-SQL
      SELECT entity_type, entity_id, title, repo_or_initiative, snippet(ecosystem_fts, 3, '[', ']', '...', 15) as snippet
      FROM ecosystem_fts
      WHERE ecosystem_fts MATCH ?
      ORDER BY rank
      LIMIT ?;
    SQL

    @db.execute(query, [term, limit])
  end

  def execute_sql(sql)
    @db.execute(sql)
  end
end

if __FILE__ == $PROGRAM_NAME
  options = {}
  parser = OptionParser.new do |opts|
    opts.banner = 'Usage: ruby bin/query_ecosystem_datalake.rb [options]'
    opts.on('-s', '--search TERM', 'Full-text search across organizations, repositories, commits, and artifacts') do |v|
      options[:search] = v
    end
    opts.on('--stats', 'Display summary statistics across the ecosystem') do
      options[:stats] = true
    end
    opts.on('--sql QUERY', 'Execute raw SQL against the SQLite database') do |v|
      options[:sql] = v
    end
    opts.on('-l', '--limit N', Integer, 'Maximum results to return (default: 20)') do |v|
      options[:limit] = v
    end
    opts.on('-j', '--json', 'Output results formatted as JSON') do
      options[:json] = true
    end
    opts.on('-h', '--help', 'Show this help message') do
      puts opts
      exit 0
    end
  end

  parser.parse!

  lake = EcosystemDatalakeQuery.new
  limit = options[:limit] || 20

  if options[:stats]
    res = lake.stats
    if options[:json]
      puts JSON.pretty_generate(res)
    else
      puts "=== Ecosystem Datalake Overview ==="
      puts "Total Repositories: #{res['total_repositories']}"
      puts "Total Commits:      #{res['total_commits']}"
      puts "Total Artifacts:    #{res['total_artifacts']}"
      puts
      puts "Repositories by Organization:"
      res['by_organization'].each do |row|
        puts "  @%-15s %3d repos" % [row['organization'], row['count']]
      end
      puts
      puts "Top Repositories by Indexed Commits:"
      res['top_repos_by_commits'].each do |row|
        puts "  %-35s %4d commits" % [row['repo_name'], row['count']]
      end
    end
    exit 0
  elsif options[:search]
    results = lake.search(options[:search], limit)
    if options[:json]
      puts JSON.pretty_generate(results)
    else
      puts "Search results for: '#{options[:search]}' (#{results.size} matches):"
      puts "------------------------------------------------------------"
      results.each_with_index do |r, i|
        puts "[#{i + 1}] #{r['entity_type'].upcase} | #{r['repo_or_initiative']} | #{r['entity_id']}"
        puts "    Title:   #{r['title']}"
        puts "    Snippet: #{r['snippet']}" if r['snippet']
        puts
      end
    end
    exit 0
  elsif options[:sql]
    results = lake.execute_sql(options[:sql])
    puts JSON.pretty_generate(results)
    exit 0
  else
    puts parser
    exit 1
  end
end
