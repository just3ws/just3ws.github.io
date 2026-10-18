# frozen_string_literal: true

require 'spec_helper'
require 'json'
require 'sqlite3'
require_relative '../../bin/query_ecosystem_datalake'

RSpec.describe 'Ecosystem Datalake (GitHub Orgs, Repos, Commits, Artifacts, Timeline)' do
  let(:root_dir) { File.expand_path('../..', __dir__) }
  let(:db_path) { File.join(root_dir, 'lake', 'ecosystem', 'ecosystem.db') }
  let(:jsonl_path) { File.join(root_dir, 'lake', 'ecosystem', 'ecosystem.jsonl') }
  let(:duckdb_path) { File.join(root_dir, 'lake', 'ecosystem', 'ecosystem.duckdb') }
  let(:manifest_path) { File.join(root_dir, 'lake', 'ecosystem', 'ecosystem_manifest.json') }
  let(:query_tool) { EcosystemDatalakeQuery.new(db_path) }

  before(:all) do
    root = File.expand_path('../..', __dir__)
    db = File.join(root, 'lake', 'ecosystem', 'ecosystem.db')
    unless File.file?(db)
      system("ruby #{File.join(root, 'bin', 'build_ecosystem_datalake.rb')} --commit-limit 50")
    end
  end

  describe 'Datalake Artifacts Existence' do
    it 'creates SQLite database file' do
      expect(File.exist?(db_path)).to be true
      expect(File.size(db_path)).to be > 100_000
    end

    it 'creates JSONL stream file' do
      expect(File.exist?(jsonl_path)).to be true
      expect(File.size(jsonl_path)).to be > 50_000
    end

    it 'creates DuckDB database file' do
      expect(File.exist?(duckdb_path)).to be true
      expect(File.size(duckdb_path)).to be > 50_000
    end

    it 'creates manifest metadata file' do
      expect(File.exist?(manifest_path)).to be true
      data = JSON.parse(File.read(manifest_path))
      expect(data['metrics']['repositories_indexed']).to be >= 50
      expect(data['metrics']['commits_indexed']).to be >= 1000
      expect(data['metrics']['timeline_events']).to be >= 50
      expect(data['organizations']).to include('just3ws')
      expect(data['organizations']).to include('wwworkremote')
      expect(data['organizations']).to include('phalanxduel')
    end
  end

  describe 'Ecosystem Query Tool' do
    it 'returns comprehensive ecosystem statistics' do
      stats = query_tool.stats
      expect(stats['total_repositories']).to be >= 50
      expect(stats['total_commits']).to be >= 1000
      expect(stats['total_artifacts']).to be >= 4
      expect(stats['by_organization']).to be_an(Array)
    end

    it 'finds Chicago Code Camp schedule commits and artifacts via FTS' do
      results = query_tool.search('schedule', 10)
      expect(results).not_to be_empty
      repo_names = results.map { |r| r['repo_or_initiative'] }
      expect(repo_names.any? { |n| n.include?('ccs') || n.include?('Chicago Code Camp') }).to be true
    end

    it 'queries chronological timeline events' do
      events = query_tool.timeline(limit: 20)
      expect(events).not_to be_empty
      expect(events.first['event_date']).to be <= events.last['event_date']
      types = events.map { |e| e['event_type'] }
      expect(types).to include('community_milestone')
    end

    it 'executes analytical queries via DuckDB' do
      result = query_tool.execute_duckdb('SELECT count(*) AS total FROM v_timeline;')
      expect(result).to include('total')
    end

    it 'executes raw SQL queries with strongly typed results' do
      rows = query_tool.execute_sql('SELECT count(*) as total FROM repositories WHERE is_private = 0;')
      expect(rows.first['total']).to be > 0
    end
  end

  describe 'Em Dash Enforcement' do
    it 'contains zero em dashes across library, builder, and query tools' do
      lib = File.read(File.join(root_dir, 'bin', 'lib', 'ecosystem_datalake.rb'))
      builder = File.read(File.join(root_dir, 'bin', 'build_ecosystem_datalake.rb'))
      query = File.read(File.join(root_dir, 'bin', 'query_ecosystem_datalake.rb'))
      [lib, builder, query].each do |code|
        expect(code).not_to include("\u2014")
        expect(code).not_to include("\u2013")
      end
    end
  end
end
