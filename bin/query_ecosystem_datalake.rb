#!/usr/bin/env ruby
# frozen_string_literal: true

# ---
# name: query_ecosystem_datalake.rb
# domain: lake
# purpose: Fast query interface for the ecosystem datalake via SQLite3 FTS5, DuckDB, and timeline
# usage: ruby bin/query_ecosystem_datalake.rb [options]
# ---

require 'optparse'
require_relative 'lib/ecosystem_datalake'

# Backward-compatible query wrapper
class EcosystemDatalakeQuery
  def initialize(db_path = EcosystemDatalake::DB_PATH)
    @lake = EcosystemDatalake.new(db_path)
    unless File.file?(db_path)
      @lake.build!(verbose: false)
    end
  end

  def stats
    manifest = File.file?(EcosystemDatalake::MANIFEST_PATH) ? JSON.parse(File.read(EcosystemDatalake::MANIFEST_PATH)) : {}
    repo_counts = @lake.db.execute('SELECT organization, count(*) as count FROM repositories GROUP BY organization ORDER BY count DESC')
    commit_counts = @lake.db.execute('SELECT repo_name, count(*) as count FROM commits GROUP BY repo_name ORDER BY count DESC')
    artifact_count = @lake.db.get_first_value('SELECT count(*) FROM historical_artifacts')

    {
      'generated_at' => manifest['generated_at'],
      'total_repositories' => manifest['metrics'] ? manifest['metrics']['repositories_indexed'] : repo_counts.sum { |r| r['count'] },
      'total_commits' => manifest['metrics'] ? manifest['metrics']['commits_indexed'] : commit_counts.sum { |c| c['count'] },
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
    @lake.db.execute(query, [term, limit])
  end

  def execute_sql(sql)
    @lake.db.execute(sql)
  end

  def timeline(era: nil, limit: 50)
    @lake.query_timeline(era: era, limit: limit)
  end

  def execute_duckdb(sql)
    @lake.query_duckdb(sql)
  end
end

if __FILE__ == $PROGRAM_NAME
  options = {}
  OptionParser.new do |opts|
  opts.banner = 'Usage: ruby bin/query_ecosystem_datalake.rb [options]'

  opts.on('-s', '--search TERM', 'Full-text search using SQLite FTS5') do |v|
    options[:search] = v
  end

  opts.on('-t', '--timeline [ERA]', 'Query chronological timeline events (optional era filter)') do |v|
    options[:timeline] = v || true
  end

  opts.on('--stats', 'Display summary statistics and breakdowns') do
    options[:stats] = true
  end

  opts.on('--duckdb SQL', 'Execute analytical SQL query using DuckDB') do |v|
    options[:duckdb] = v
  end

  opts.on('--sql SQL', 'Execute raw SQLite3 query') do |v|
    options[:sql] = v
  end

  opts.on('-l', '--limit N', Integer, 'Result limit (default 20)') do |v|
    options[:limit] = v
  end

  opts.on('-j', '--json', 'Output results as JSON') do
    options[:json] = true
  end

  opts.on('-h', '--help', 'Show this help') do
    puts opts
    exit 0
  end
end.parse!

querier = EcosystemDatalakeQuery.new
limit = options[:limit] || 25

if options[:stats]
  stats = querier.stats
  if options[:json]
    puts JSON.pretty_generate(stats)
  else
    puts "=== Ecosystem Datalake Summary ==="
    puts "Total Repositories: #{stats['total_repositories']}"
    puts "Total Commits:      #{stats['total_commits']}"
    puts "Total Artifacts:    #{stats['total_artifacts']}"
    puts "\nRepositories by Organization:"
    stats['by_organization'].each do |row|
      puts "  %-15s %4d repos" % [row['organization'], row['count']]
    end
    puts "\nTop Repositories by Commit Activity:"
    stats['top_repos_by_commits'].each do |row|
      puts "  %-32s %5d commits" % [row['repo_name'], row['count']]
    end
  end

elsif options[:timeline]
  era_filter = options[:timeline] == true ? nil : options[:timeline]
  events = querier.timeline(era: era_filter, limit: limit)
  if options[:json]
    puts JSON.pretty_generate(events)
  else
    puts "=== Ecosystem Timeline Chronology #{era_filter ? "(Filter: #{era_filter})" : ''} ==="
    events.each do |e|
      puts "[#{e['event_date']}] (#{e['era']}) #{e['title']}"
      puts "  Initiative: #{e['initiative']} | Type: #{e['event_type']} | Repo: #{e['repo_full_name']}"
      puts "  #{e['description']}\n\n"
    end
  end

elsif options[:duckdb]
  result = querier.execute_duckdb(options[:duckdb])
  puts result

elsif options[:search]
  results = querier.search(options[:search], limit)
  if options[:json]
    puts JSON.pretty_generate(results)
  else
    puts "Search results for: '#{options[:search]}' (#{results.size} matches)"
    results.each_with_index do |row, idx|
      puts "\n#{idx + 1}. [#{row['entity_type'].upcase}] #{row['title']}"
      puts "   Initiative/Repo: #{row['repo_or_initiative']}"
      puts "   Snippet: #{row['snippet']}" if row['snippet']
    end
  end

elsif options[:sql]
  results = querier.execute_sql(options[:sql])
  if options[:json]
    puts JSON.pretty_generate(results)
  else
    puts JSON.pretty_generate(results)
  end

else
  puts "No action specified. Try --stats, --timeline, --search, or --help."
end
end
