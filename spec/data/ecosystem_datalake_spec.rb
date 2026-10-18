# frozen_string_literal: true

require 'spec_helper'
require 'json'
require 'sqlite3'
require_relative '../../bin/query_ecosystem_datalake'

RSpec.describe 'Ecosystem Datalake (GitHub Orgs, Repos, Commits, Artifacts)' do
  let(:root_dir) { File.expand_path('../..', __dir__) }
  let(:db_path) { File.join(root_dir, 'lake', 'ecosystem', 'ecosystem.db') }
  let(:jsonl_path) { File.join(root_dir, 'lake', 'ecosystem', 'ecosystem.jsonl') }
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

    it 'creates manifest metadata file' do
      expect(File.exist?(manifest_path)).to be true
      data = JSON.parse(File.read(manifest_path))
      expect(data['total_repositories']).to be >= 50
      expect(data['total_commits_indexed']).to be >= 1000
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

    it 'executes raw SQL queries with strongly typed results' do
      rows = query_tool.execute_sql('SELECT count(*) as total FROM repositories WHERE is_private = 0;')
      expect(rows.first['total']).to be > 0
    end
  end

  describe 'Em Dash Enforcement' do
    it 'contains zero em dashes in builder and query tools' do
      builder = File.read(File.join(root_dir, 'bin', 'build_ecosystem_datalake.rb'))
      query = File.read(File.join(root_dir, 'bin', 'query_ecosystem_datalake.rb'))
      expect(builder).not_to include("\u2014")
      expect(builder).not_to include("\u2013")
      expect(query).not_to include("\u2014")
      expect(query).not_to include("\u2013")
    end
  end
end
