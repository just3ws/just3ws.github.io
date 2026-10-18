#!/usr/bin/env ruby
# frozen_string_literal: true

# ---
# name: build_ecosystem_datalake.rb
# domain: data
# purpose: Harvest GitHub metadata, local git histories, and historical artifacts across Mike Hall organizations into a unified SQLite and JSONL datalake
# usage: ruby bin/build_ecosystem_datalake.rb [options]
# ---

require 'json'
require 'yaml'
require 'sqlite3'
require 'open3'
require 'fileutils'
require 'time'
require 'optparse'

ROOT ||= File.expand_path('..', __dir__)
LAKE_DIR = File.join(ROOT, 'lake', 'ecosystem')
DB_PATH = File.join(LAKE_DIR, 'ecosystem.db')
JSONL_PATH = File.join(LAKE_DIR, 'ecosystem.jsonl')
MANIFEST_PATH = File.join(LAKE_DIR, 'ecosystem_manifest.json')

ORGANIZATIONS = %w[just3ws ugtastic wwworkremote phalanxduel].freeze

LOCAL_REPOSITORIES = {
  'just3ws/just3ws.github.io' => ROOT,
  'just3ws/ccs' => '/Users/mike/github.com/just3ws/ccs',
  'just3ws/dehum' => '/Users/mike/github.com/just3ws/dehum',
  'just3ws/hallway' => '/Users/mike/github.com/just3ws/hallway',
  'just3ws/bastion' => '/Users/mike/github.com/just3ws/bastion',
  'just3ws/uglst-geosrv' => '/Users/mike/github.com/just3ws/uglst-geosrv',
  'wwworkremote/wwworkremote' => '/Users/mike/github.com/wwworkremote/wwworkremote',
  'phalanxduel/game' => '/Users/mike/github.com/phalanxduel/game',
  'just3ws/zdots' => '/Users/mike/.config/zsh',
  'just3ws/vdots' => '/Users/mike/.config/nvim',
  'just3ws/my' => '/Users/mike/my'
}.freeze

HISTORICAL_ARTIFACTS = [
  {
    'id' => 'ccc-printable-schedule-photo',
    'initiative' => 'Chicago Code Camp',
    'title' => 'Printable Conference Schedule Matrix Photo Artifact',
    'era' => '2010 - 2012',
    'artifact_type' => 'photo',
    'source_repo' => 'just3ws/just3ws.github.io',
    'file_path' => 'assets/images/portfolio/chicago-code-camp-print-schedule.jpg',
    'description' => 'Original printout of the 9-track conference schedule matrix across 5 session blocks produced by Mike Hall custom scheduling tool.',
    'canonical_url' => 'https://pbs.twimg.com/media/ChTAjcZWkAAHftd.jpg',
    'provenance_details' => {
      'tweet_media' => 'https://pbs.twimg.com/media/ChTAjcZWkAAHftd.jpg',
      'hashtag_archive' => 'https://www.sotwe.com/hashtag/ChicagoCodeCamp',
      'resolution' => '1200x920'
    }
  },
  {
    'id' => 'ccc-printable-schedule-haml',
    'initiative' => 'Chicago Code Camp',
    'title' => 'Printable Schedule View Generator Code',
    'era' => '2010 - 2012',
    'artifact_type' => 'code',
    'source_repo' => 'just3ws/ccs',
    'file_path' => 'app/views/schedules/printable.html.haml',
    'description' => 'Original Haml view rendering the printable table matrix with rooms and time slots.',
    'canonical_url' => 'https://github.com/just3ws/ccs',
    'provenance_details' => {
      'framework' => 'Ruby on Rails',
      'controller' => 'schedules_controller.rb',
      'action' => 'printable'
    }
  },
  {
    'id' => 'ugtastic-footer-provenance',
    'initiative' => 'UGtastic',
    'title' => 'UGtastic Official Brand Social Footer Template',
    'era' => '2011 - 2015',
    'artifact_type' => 'code',
    'source_repo' => 'lake/witc/corpus.db',
    'file_path' => 'consolidated/whoistechcmty/_unsorted/pending/ugtastic/app/views/layouts/_footer.html.haml',
    'description' => 'Original footer template explicitly establishing @ugtastic, github.com/ugtastic, and soundcloud.com/ugtastic.',
    'canonical_url' => 'https://twitter.com/ugtastic',
    'provenance_details' => {
      'corpus_record' => 'consolidated/whoistechcmty/_unsorted/pending/ugtastic/app/views/layouts/_footer.html.haml'
    }
  },
  {
    'id' => 'patreon-founding-vision',
    'initiative' => 'WHOIS Tech Community',
    'title' => 'Patreon Founding Vision and Tools for Everything Manifesto',
    'era' => '2011 - Present',
    'artifact_type' => 'document',
    'source_repo' => 'just3ws/just3ws.github.io',
    'file_path' => '_data/patreon_campaign.yml',
    'description' => 'Canonical founding statement written by Mike Hall for the WHOIS Tech Community Patreon campaign.',
    'canonical_url' => 'https://www.patreon.com/whoistechcmty',
    'provenance_details' => {
      'tagline' => 'Tools for everything',
      'channel' => '@whoistechcmty'
    }
  }
].freeze

def setup_database(db)
  db.execute('PRAGMA journal_mode = WAL;')
  db.execute('PRAGMA synchronous = NORMAL;')

  db.execute <<-SQL
    CREATE TABLE IF NOT EXISTS organizations (
      id INTEGER PRIMARY KEY,
      login TEXT UNIQUE NOT NULL,
      name TEXT,
      description TEXT,
      url TEXT,
      public_repos INTEGER DEFAULT 0,
      created_at TEXT,
      avatar_url TEXT
    );
  SQL

  db.execute <<-SQL
    CREATE TABLE IF NOT EXISTS repositories (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      organization TEXT NOT NULL,
      name TEXT NOT NULL,
      full_name TEXT UNIQUE NOT NULL,
      description TEXT,
      url TEXT,
      primary_language TEXT,
      is_private INTEGER DEFAULT 0,
      is_archived INTEGER DEFAULT 0,
      created_at TEXT,
      updated_at TEXT,
      pushed_at TEXT,
      local_path TEXT,
      commit_count INTEGER DEFAULT 0
    );
  SQL

  db.execute <<-SQL
    CREATE TABLE IF NOT EXISTS commits (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      repo_name TEXT NOT NULL,
      sha TEXT NOT NULL,
      author_name TEXT,
      author_email TEXT,
      committed_at TEXT NOT NULL,
      message TEXT,
      files_changed INTEGER DEFAULT 0,
      additions INTEGER DEFAULT 0,
      deletions INTEGER DEFAULT 0,
      UNIQUE(repo_name, sha)
    );
  SQL

  db.execute <<-SQL
    CREATE TABLE IF NOT EXISTS historical_artifacts (
      id TEXT PRIMARY KEY,
      initiative TEXT NOT NULL,
      title TEXT NOT NULL,
      era TEXT NOT NULL,
      artifact_type TEXT NOT NULL,
      source_repo TEXT,
      file_path TEXT,
      description TEXT,
      canonical_url TEXT,
      provenance_details TEXT
    );
  SQL

  db.execute <<-SQL
    CREATE VIRTUAL TABLE IF NOT EXISTS ecosystem_fts USING fts5(
      entity_type UNINDEXED,
      entity_id UNINDEXED,
      title,
      content,
      repo_or_initiative
    );
  SQL
end

def fetch_organization_data(org_login)
  out, status = Open3.capture2("gh api orgs/#{org_login} 2>/dev/null")
  if status.success?
    JSON.parse(out) rescue nil
  else
    # Fallback to user endpoint if user account (e.g. just3ws)
    out2, status2 = Open3.capture2("gh api users/#{org_login} 2>/dev/null")
    JSON.parse(out2) rescue nil if status2.success?
  end
end

def fetch_organization_repos(org_login)
  cmd = "gh repo list #{org_login} --limit 100 --json name,description,isPrivate,isArchived,createdAt,updatedAt,pushedAt,url,primaryLanguage"
  out, status = Open3.capture2(cmd)
  if status.success?
    JSON.parse(out) rescue []
  else
    []
  end
end

def harvest_commits(repo_full_name, local_path, limit = 500)
  return [] unless Dir.exist?(local_path) && (Dir.exist?(File.join(local_path, '.git')) || File.file?(File.join(local_path, '.git')))

  # Format: HASH%x1fAUTHOR%x1fEMAIL%x1fDATE%x1fSUBJECT
  cmd = "git -C \"#{local_path}\" log -n #{limit} --pretty=format:\"%H%x1f%an%x1f%ae%x1f%aI%x1f%s\""
  out, status = Open3.capture2(cmd)
  return [] unless status.success?

  commits = []
  out.each_line do |line|
    line = line.strip
    next if line.empty?
    parts = line.split("\x1f")
    next unless parts.size >= 5

    commits << {
      'repo_name' => repo_full_name,
      'sha' => parts[0],
      'author_name' => parts[1],
      'author_email' => parts[2],
      'committed_at' => parts[3],
      'message' => parts[4]
    }
  end
  commits
end

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

FileUtils.mkdir_p(LAKE_DIR)

# Open SQLite DB
db = SQLite3::Database.new(DB_PATH)
setup_database(db)

# Prepare JSONL writer
jsonl_file = File.open(JSONL_PATH, 'w')

puts '==> Building Ecosystem Datalake across organizations & local repositories...'

total_repos = 0
total_commits = 0
org_summaries = {}

# 1. Harvest Organizations & Repositories
ORGANIZATIONS.each do |org|
  puts "    Querying organization: @#{org}"
  org_info = fetch_organization_data(org)
  if org_info
    db.execute(
      'INSERT OR REPLACE INTO organizations (id, login, name, description, url, public_repos, created_at, avatar_url) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
      [
        org_info['id'],
        org_info['login'],
        org_info['name'] || org_info['login'],
        org_info['description'],
        org_info['html_url'],
        org_info['public_repos'] || 0,
        org_info['created_at'],
        org_info['avatar_url']
      ]
    )

    jsonl_file.puts(JSON.generate({
      'type' => 'organization',
      'id' => org_info['login'],
      'name' => org_info['name'],
      'description' => org_info['description'],
      'url' => org_info['html_url'],
      'public_repos' => org_info['public_repos'],
      'created_at' => org_info['created_at']
    }))
  end

  repos = fetch_organization_repos(org)
  org_summaries[org] = repos.size
  puts "      Found #{repos.size} repositories"

  repos.each do |repo|
    total_repos += 1
    full_name = "#{org}/#{repo['name']}"
    local_path = LOCAL_REPOSITORIES[full_name]

    # Count commits if local
    commit_count = 0
    if local_path && Dir.exist?(local_path)
      count_out, _ = Open3.capture2("git -C \"#{local_path}\" rev-list --count HEAD 2>/dev/null")
      commit_count = count_out.strip.to_i rescue 0
    end

    db.execute(
      'INSERT OR REPLACE INTO repositories (organization, name, full_name, description, url, primary_language, is_private, is_archived, created_at, updated_at, pushed_at, local_path, commit_count) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        org,
        repo['name'],
        full_name,
        repo['description'],
        repo['url'],
        repo.dig('primaryLanguage', 'name') || '',
        repo['isPrivate'] ? 1 : 0,
        repo['isArchived'] ? 1 : 0,
        repo['createdAt'],
        repo['updatedAt'],
        repo['pushedAt'],
        local_path,
        commit_count
      ]
    )

    jsonl_file.puts(JSON.generate({
      'type' => 'repository',
      'id' => full_name,
      'org' => org,
      'name' => repo['name'],
      'description' => repo['description'],
      'url' => repo['url'],
      'language' => repo.dig('primaryLanguage', 'name') || '',
      'is_private' => repo['isPrivate'],
      'is_archived' => repo['isArchived'],
      'created_at' => repo['createdAt'],
      'pushed_at' => repo['pushedAt'],
      'commit_count' => commit_count
    }))

    # Index in FTS
    db.execute(
      'INSERT INTO ecosystem_fts (entity_type, entity_id, title, content, repo_or_initiative) VALUES (?, ?, ?, ?, ?)',
      [
        'repository',
        full_name,
        full_name,
        "#{repo['name']} #{repo['description']} #{repo.dig('primaryLanguage', 'name')}",
        org
      ]
    )
  end
end

# 2. Harvest Commits for Local Repositories
puts '    Harvesting commit histories from local repositories...'
LOCAL_REPOSITORIES.each do |repo_full_name, local_path|
  next unless Dir.exist?(local_path)

  commits = harvest_commits(repo_full_name, local_path, options[:commit_limit])
  puts "      Indexed #{commits.size} commits from #{repo_full_name}"

  db.transaction do
    commits.each do |c|
      total_commits += 1
      db.execute(
        'INSERT OR IGNORE INTO commits (repo_name, sha, author_name, author_email, committed_at, message) VALUES (?, ?, ?, ?, ?, ?)',
        [
          c['repo_name'],
          c['sha'],
          c['author_name'],
          c['author_email'],
          c['committed_at'],
          c['message']
        ]
      )

      jsonl_file.puts(JSON.generate({
        'type' => 'commit',
        'repo' => c['repo_name'],
        'sha' => c['sha'],
        'author' => c['author_name'],
        'committed_at' => c['committed_at'],
        'message' => c['message']
      }))

      # Index in FTS
      db.execute(
        'INSERT INTO ecosystem_fts (entity_type, entity_id, title, content, repo_or_initiative) VALUES (?, ?, ?, ?, ?)',
        [
          'commit',
          "#{c['repo_name']}@#{c['sha'][0..7]}",
          c['message'],
          "#{c['sha']} #{c['author_name']} #{c['committed_at']} #{c['message']}",
          c['repo_name']
        ]
      )
    end
  end
end

# 3. Index Historical Artifacts
puts '    Indexing historical artifacts...'
HISTORICAL_ARTIFACTS.each do |art|
  db.execute(
    'INSERT OR REPLACE INTO historical_artifacts (id, initiative, title, era, artifact_type, source_repo, file_path, description, canonical_url, provenance_details) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
    [
      art['id'],
      art['initiative'],
      art['title'],
      art['era'],
      art['artifact_type'],
      art['source_repo'],
      art['file_path'],
      art['description'],
      art['canonical_url'],
      JSON.generate(art['provenance_details'])
    ]
  )

  jsonl_file.puts(JSON.generate({
    'type' => 'artifact',
    'id' => art['id'],
    'initiative' => art['initiative'],
    'title' => art['title'],
    'era' => art['era'],
    'artifact_type' => art['artifact_type'],
    'file_path' => art['file_path'],
    'description' => art['description'],
    'canonical_url' => art['canonical_url'],
    'provenance' => art['provenance_details']
  }))

  # Index in FTS
  db.execute(
    'INSERT INTO ecosystem_fts (entity_type, entity_id, title, content, repo_or_initiative) VALUES (?, ?, ?, ?, ?)',
    [
      'artifact',
      art['id'],
      art['title'],
      "#{art['description']} #{art['file_path']} #{art['initiative']} #{art['era']}",
      art['initiative']
    ]
  )
end

jsonl_file.close
db.close

# 4. Generate Manifest
manifest = {
  'generated_at' => Time.now.utc.iso8601,
  'organizations' => ORGANIZATIONS,
  'organization_counts' => org_summaries,
  'total_repositories' => total_repos,
  'total_commits_indexed' => total_commits,
  'total_artifacts' => HISTORICAL_ARTIFACTS.size,
  'sqlite_database' => 'lake/ecosystem/ecosystem.db',
  'jsonl_stream' => 'lake/ecosystem/ecosystem.jsonl',
  'schema' => {
    'organizations' => %w[id login name description url public_repos created_at avatar_url],
    'repositories' => %w[id organization name full_name description url primary_language is_private is_archived created_at updated_at pushed_at local_path commit_count],
    'commits' => %w[id repo_name sha author_name author_email committed_at message files_changed additions deletions],
    'historical_artifacts' => %w[id initiative title era artifact_type source_repo file_path description canonical_url provenance_details]
  }
}

File.write(MANIFEST_PATH, JSON.pretty_generate(manifest) + "\n")

puts "==> Ecosystem Datalake successfully compiled!"
puts "    SQLite Database: #{DB_PATH} (#{File.size(DB_PATH)} bytes)"
puts "    JSONL Stream:    #{JSONL_PATH} (#{File.size(JSONL_PATH)} bytes)"
puts "    Manifest:        #{MANIFEST_PATH}"
