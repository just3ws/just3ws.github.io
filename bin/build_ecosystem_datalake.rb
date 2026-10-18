#!/usr/bin/env ruby
# frozen_string_literal: true

# ---
# name: build_ecosystem_datalake.rb
# domain: lake
# purpose: Harvest GitHub metadata, local git histories, releases, and historical artifacts into a unified SQLite3, DuckDB, and JSONL datalake
# usage: ruby bin/build_ecosystem_datalake.rb [options]
# ---

require 'optparse'
require_relative 'lib/ecosystem_datalake'

# Backward compatibility aliases
ORGANIZATIONS = EcosystemDatalake::ORGANIZATIONS
LOCAL_REPOSITORIES = EcosystemDatalake::LOCAL_REPOSITORIES
HISTORICAL_ARTIFACTS = EcosystemDatalake::HISTORICAL_ARTIFACTS
DB_PATH = EcosystemDatalake::DB_PATH
JSONL_PATH = EcosystemDatalake::JSONL_PATH
DUCKDB_PATH = EcosystemDatalake::DUCKDB_PATH
MANIFEST_PATH = EcosystemDatalake::MANIFEST_PATH

options = { commit_limit: 500, verbose: false }
OptionParser.new do |opts|
  opts.banner = 'Usage: ruby bin/build_ecosystem_datalake.rb [options]'
  opts.on('-c', '--commit-limit N', Integer, 'Max commits per local repository to index (default 500)') do |v|
    options[:commit_limit] = v
  end
  opts.on('-v', '--verbose', 'Enable verbose output') do
    options[:verbose] = true
  end
  opts.on('-h', '--help', 'Show this help') do
    puts opts
    exit 0
  end
end.parse!

puts '=== Building Ecosystem Datalake ==='
datalake = EcosystemDatalake.new
manifest = datalake.build!(commit_limit: options[:commit_limit], verbose: options[:verbose])

puts "✅ Ecosystem datalake built successfully:"
puts "   Repositories: #{manifest['metrics']['repositories_indexed']}"
puts "   Commits:      #{manifest['metrics']['commits_indexed']}"
puts "   Artifacts:    #{manifest['metrics']['historical_artifacts']}"
puts "   Timeline:     #{manifest['metrics']['timeline_events']} events"
puts "   SQLite DB:    #{manifest['storage']['sqlite_db']} (#{(manifest['storage']['sqlite_size_bytes'] / 1024.0 / 1024.0).round(2)} MB)"
puts "   DuckDB:       #{manifest['storage']['duckdb_file']} (#{(manifest['storage']['duckdb_size_bytes'] / 1024.0 / 1024.0).round(2)} MB)"
puts "   JSONL:        #{manifest['storage']['jsonl_stream']} (#{(manifest['storage']['jsonl_size_bytes'] / 1024.0).round(1)} KB)"
puts "   Manifest:     #{EcosystemDatalake::MANIFEST_PATH}"
