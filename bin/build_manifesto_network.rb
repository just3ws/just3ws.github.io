#!/usr/bin/env ruby
# frozen_string_literal: true

# bin/build_manifesto_network.rb
#
# Generates the multi-ecosystem research dataset intersecting:
#   1. Agile Manifesto (Feb 2001) — 17 Authors + ~19,090 Signatories
#   2. Software Craftsmanship Manifesto (March 2009) — 9 Authors + 27,601 Signatories
#   3. UGtastic Interview Archive (184 interviews, 191 interviewees)
#   4. SCMC Presentation Archive (11 speakers)
#
# Features:
#   - Explicit differentiation between AUTHORS and SIGNATORIES for both manifestos.
#   - Disambiguation of distinct people sharing names (e.g. Dave "pragdave" Thomas vs Dave Thomas of Bedarra/OTI).
#   - Name variant expansion & canonical alias resolution (e.g. Robert C. Martin / Uncle Bob, Ron Jeffries / Ron Jefferies).
#   - Unicode sanitization: repairs ISO-8859-1/UTF-8 Mojibake and strips C0/C1 control characters so Psych/SafeYAML loads without errors.

require 'json'
require 'open3'
require 'optparse'
require 'yaml'
require 'time'

ROOT_DIR = File.expand_path('..', __dir__)
AGILE_SIGS_PATH = '/tmp/agile_manifesto_signatories.json'
DEFAULT_OUTPUT_PATH = File.join(ROOT_DIR, '_data/research/agile_scm_intersection.json')

# ─────────────────────────────────────────────────────────────────────────────
# 1. Sanitization & Normalization
# ─────────────────────────────────────────────────────────────────────────────

def sanitize_str(str)
  return nil if str.nil?
  s = str.to_s.strip
  # Repair Latin-1 Mojibake if present
  begin
    if s.include?('Ã')
      repaired = s.dup.encode('ISO-8859-1').force_encoding('UTF-8')
      s = repaired if repaired.valid_encoding?
    end
  rescue StandardError
    # Keep original if repair fails
  end
  # Remove C0 and C1 control characters (Psych syntax error triggers)
  s.gsub(/[\u0000-\u0008\u000B\u000C\u000E-\u001F\u007F-\u009F]/, '')
end

def normalize_name(name)
  return '' if name.nil?
  sanitize_str(name)
    .downcase
    .gsub(/[""''`]/, '')
    .gsub(/\s+/, ' ')
    .strip
end

def name_variants(name)
  n = normalize_name(name)
  return [] if n.empty?

  variants = [n]

  # Strip parenthetical alias: "Robert C. Martin (Uncle Bob)" -> "Robert C. Martin" + "Uncle Bob"
  if n =~ /\A(.+?)\s*\(([^)]+)\)\s*\z/
    base = Regexp.last_match(1).strip
    alias_ = Regexp.last_match(2).strip
    variants << base
    variants << alias_ if alias_.length >= 3
    parts_full = base.split
  else
    parts_full = n.split
  end

  # Drop middle initial(s): "Robert C. Martin" -> "Robert Martin"
  if parts_full.size >= 3
    no_middle = [parts_full.first, parts_full.last].join(' ')
    variants << no_middle
  end

  # First + last only when 4+ parts
  if parts_full.size >= 4
    variants << [parts_full.first, parts_full.last].join(' ')
  end

  # Handle "Last, First" format
  if n.include?(',')
    bits = n.split(',').map(&:strip)
    variants << "#{bits[1]} #{bits[0]}" if bits.size == 2
  end

  variants.uniq
end

# ─────────────────────────────────────────────────────────────────────────────
# 2. Canonical Identity & Disambiguation Registry
# ─────────────────────────────────────────────────────────────────────────────

# Explicitly tracks people where name collision or known aliases require precise routing
CANONICAL_ENTITIES = {
  'dave-pragdave-thomas' => {
    name: 'Dave "pragdave" Thomas',
    aliases: ['dave "pragdave" Thomas', 'dave thomas', 'pragdave', 'david thomas'],
    note: 'Author of The Pragmatic Programmer, Co-Author of Agile Manifesto (Snowbird 2001). Interviewed at SCNA 2013.',
    agile_author: true,
    agile_signatory: false,
    interview_filter: ->(item) { item['id'].to_s.include?('software-craftsmanship-north-america-2013') }
  },
  'dave-thomas-bedarra' => {
    name: 'Dave Thomas (Bedarra / OTI)',
    aliases: ['dave thomas', 'david thomas'],
    note: 'Founder of Object Technology International (OTI) and Bedarra Corp. Signatory of Agile Manifesto (page 5). Interviewed at GOTO Conference.',
    agile_author: false,
    agile_signatory: true,
    interview_filter: ->(item) { item['id'].to_s.include?('goto') }
  },
  'robert-c-martin' => {
    name: 'Robert C. Martin (Uncle Bob)',
    aliases: ['robert c. martin', 'robert martin', 'uncle bob', 'bob martin', 'robert c. martin (uncle bob)'],
    note: 'Co-Author of Agile Manifesto (Snowbird 2001), Organizer of 2008 SCM Summit, SCM Signatory #5.',
    agile_author: true,
    scm_author: true
  },
  'ron-jeffries' => {
    name: 'Ron Jeffries',
    aliases: ['ron jeffries', 'ron jefferies'],
    note: 'Co-Author of Agile Manifesto (Snowbird 2001), SCM Signatory #27, interviewed with Chet Hendrickson.',
    agile_author: true
  },
  'brian-marick' => {
    name: 'Brian Marick',
    aliases: ['brian marick'],
    note: 'Co-Author of Agile Manifesto (Snowbird 2001), participant in 2008 SCM Summit, interviewed at SCNA 2012.',
    agile_author: true,
    scm_author: true
  },
  'jon-kern' => {
    name: 'Jon Kern',
    aliases: ['jon kern'],
    note: 'Co-Author of Agile Manifesto (Snowbird 2001), SCM Signatory #204.',
    agile_author: true
  },
  'doug-bradbury' => {
    name: 'Doug Bradbury',
    aliases: ['doug bradbury'],
    note: 'Co-Author & Principal Synthesizer of Software Craftsmanship Manifesto, SCM Signatory #1.',
    scm_author: true
  },
  'corey-haines' => {
    name: 'Corey Haines',
    aliases: ['corey haines'],
    note: 'Organizer of 2008 SCM Summit, SCM Signatory #2, founder of Global Day of Coderetreat, interviewed twice in UGtastic.',
    scm_author: true
  },
  'paul-pagel' => {
    name: 'Paul Pagel',
    aliases: ['paul pagel'],
    note: '8th Light CEO, Host of 2008 SCM Summit, SCM Signatory #3.',
    scm_author: true
  },
  'micah-martin' => {
    name: 'Micah Martin',
    aliases: ['micah martin'],
    note: '8th Light Founder, Host of 2008 SCM Summit, SCM Signatory #4 (and #6648), Agile Manifesto Signatory, interviewed at SCNA 2013.',
    scm_author: true
  },
  'dave-hoover' => {
    name: 'Dave Hoover',
    aliases: ['dave hoover'],
    note: 'Obtiva Founder, Participant in 2008 SCM Summit, SCM Signatory #15, Agile Manifesto Signatory, interviewed in UGtastic.',
    scm_author: true
  },
  'michael-norton' => {
    name: 'Michael Norton',
    aliases: ['michael norton'],
    note: 'Participant in 2008 SCM Summit, SCM Signatory #2299, Agile Manifesto Signatory, interviewed at SCNA 2011.',
    scm_author: true
  },
  'david-chelimsky' => {
    name: 'David Chelimsky',
    aliases: ['david chelimsky'],
    note: 'Lead maintainer of RSpec, Participant in 2008 SCM Summit, SCM Signatory #6.',
    scm_author: true
  },
  'james-edward-gray-ii' => {
    name: 'James Edward Gray II',
    aliases: ['james edward gray ii', 'james gray ii', 'james gray', 'james larry gaines ii'],
    note: 'Ruby community leader, SCM Signatory #462, signed Agile Manifesto as James Larry Gaines II, interviewed in UGtastic.'
  }
}.freeze

# The 17 Snowbird Authors of the Agile Manifesto (February 2001)
AGILE_MANIFESTO_AUTHORS = [
  'Kent Beck', 'Mike Beedle', 'Arie van Bennekum', 'Alistair Cockburn',
  'Ward Cunningham', 'Martin Fowler', 'James Grenning', 'Jim Highsmith',
  'Andrew Hunt', 'Ron Jeffries', 'Jon Kern', 'Brian Marick',
  'Robert C. Martin', 'Steve Mellor', 'Ken Schwaber', 'Jeff Sutherland',
  'Dave "pragdave" Thomas'
].freeze

# The core instigators & drafters of the Software Craftsmanship Manifesto (Dec 2008 Summit / March 2009)
SCM_MANIFESTO_AUTHORS = [
  'Doug Bradbury', 'Robert C. Martin (Uncle Bob)', 'Micah Martin', 'Paul Pagel',
  'Corey Haines', 'Dave Hoover', 'Michael Norton', 'David Chelimsky', 'Brian Marick'
].freeze

# ─────────────────────────────────────────────────────────────────────────────
# 3. Main Data Pipeline
# ─────────────────────────────────────────────────────────────────────────────

def run_pipeline(options)
  puts "==> Starting Manifesto Network Map generation..." if options[:verbose]

  # 1. Load Agile Manifesto Web Signatories
  unless File.exist?(options[:agile_json])
    warn "Error: Agile signatories file #{options[:agile_json]} not found."
    exit 1
  end

  agile_raw = JSON.parse(File.read(options[:agile_json]))
  puts "    Loaded #{agile_raw.size} Agile Manifesto web signatories" if options[:verbose]

  # Index Agile signatories by variant names
  agile_sig_index = {}
  agile_raw.each do |sig|
    sig_name = sanitize_str(sig['name'])
    next if sig_name.nil? || sig_name.empty?
    sig_email = sanitize_str(sig['email'])

    entry = { 'name' => sig_name, 'email' => sig_email }
    name_variants(sig_name).each do |var|
      agile_sig_index[var] ||= entry
    end
  end

  # 2. Load SCM Signatories from DuckDB
  duckdb_path = File.expand_path('~/.local/state/zdots/datalake.duckdb')
  sql = 'SELECT signatory_number, name, location, signed_on FROM scm_signatories ORDER BY signatory_number;'
  stdout, stderr, status = Open3.capture3('duckdb', '-light-mode', duckdb_path, '-json', '-c', sql)
  unless status.success?
    warn "DuckDB error: #{stderr}"
    exit 1
  end
  scm_raw = JSON.parse(stdout)
  puts "    Loaded #{scm_raw.size} SCM signatories from DuckDB" if options[:verbose]

  # Index SCM signatories by variant names
  scm_sig_index = {}
  scm_raw.each do |row|
    row['name'] = sanitize_str(row['name'])
    row['location'] = sanitize_str(row['location'])
    name_variants(row['name']).each do |var|
      scm_sig_index[var] ||= []
      scm_sig_index[var] << row
    end
  end

  # 3. Load UGtastic Interviews & SCMC Presentations
  interviews_file = File.join(ROOT_DIR, '_data/interviews.yml')
  interviews_data = YAML.safe_load(File.read(interviews_file), permitted_classes: [Date, Time], aliases: true)
  interview_items = interviews_data['items'] || []

  scmc_file = File.join(ROOT_DIR, '_data/scmc_videos.yml')
  scmc_data = YAML.safe_load(File.read(scmc_file), permitted_classes: [Date, Time], aliases: true) || {}
  scmc_items = scmc_data.is_a?(Hash) ? (scmc_data['items'] || []) : (scmc_data || [])

  # Index interviews by participant name
  interviews_by_participant = {}
  interview_items.each do |item|
    participants = (item['interviewees'] || []).map { |p| sanitize_str(p) }
    participants.each do |p|
      next if p.nil? || p.empty?
      name_variants(p).each do |v|
        interviews_by_participant[v] ||= []
        interviews_by_participant[v] << {
          id: item['id'],
          title: sanitize_str(item['title']),
          conference: sanitize_str(item['conference']),
          community: sanitize_str(item['community']),
          recorded_date: item['recorded_date'].to_s,
          raw_item: item
        }
      end
    end
  end

  # Index SCMC presentations by speaker
  scmc_by_speaker = {}
  scmc_items.each do |item|
    speaker = sanitize_str(item['presenter'])
    next if speaker.nil? || speaker.empty?
    name_variants(speaker).each do |v|
      scmc_by_speaker[v] ||= []
      scmc_by_speaker[v] << {
        id: item['id'],
        title: sanitize_str(item['title']),
        presenter: speaker,
        year: item['year'],
        url: item['url']
      }
    end
  end

  # ───────────────────────────────────────────────────────────────────────────
  # 4. Process Agile Authors
  # ───────────────────────────────────────────────────────────────────────────
  agile_authors_data = AGILE_MANIFESTO_AUTHORS.map do |author_name|
    canon_key = nil
    CANONICAL_ENTITIES.each do |k, entity|
      if entity[:agile_author] && entity[:aliases].any? { |a| normalize_name(a) == normalize_name(author_name) }
        canon_key = k
        break
      end
    end
    canon_entity = canon_key ? CANONICAL_ENTITIES[canon_key] : nil

    # Check SCM authorship
    is_scm_author = canon_entity&.fetch(:scm_author, false) ||
                    SCM_MANIFESTO_AUTHORS.any? { |a| normalize_name(a) == normalize_name(author_name) }

    # Check SCM signatory
    scm_hits = []
    ([author_name] + (canon_entity ? canon_entity[:aliases] : [])).each do |alias_str|
      name_variants(alias_str).each do |var|
        scm_hits.concat(scm_sig_index[var] || [])
      end
    end
    scm_hits.uniq! { |h| h['signatory_number'] }

    # Check Agile web signatory (distinct from author!)
    is_agile_sig = false
    agile_sig_details = nil
    if canon_entity && canon_entity.key?(:agile_signatory)
      is_agile_sig = canon_entity[:agile_signatory]
    end

    # Check UGtastic interviews
    matched_interviews = []
    ([author_name] + (canon_entity ? canon_entity[:aliases] : [])).each do |alias_str|
      name_variants(alias_str).each do |var|
        matched_interviews.concat(interviews_by_participant[var] || [])
      end
    end
    matched_interviews.uniq! { |i| i[:id] }
    if canon_entity && canon_entity[:interview_filter]
      matched_interviews.select! { |i| canon_entity[:interview_filter].call(i[:raw_item]) }
    end

    {
      name: author_name,
      canonical_id: canon_key,
      agile_role: 'author_only', # authors by definition
      agile_author: true,
      agile_signatory: is_agile_sig,
      scm_author: is_scm_author,
      scm_signatory: !scm_hits.empty?,
      scm_signatory_records: scm_hits.map do |h|
        {
          number: h['signatory_number'],
          name: h['name'],
          location: h['location'],
          signed_on: h['signed_on']
        }
      end,
      ugtastic_interviewee: !matched_interviews.empty?,
      ugtastic_interviews: matched_interviews.map { |i| i.slice(:id, :title, :conference, :community, :recorded_date) },
      note: canon_entity ? canon_entity[:note] : nil
    }
  end

  # ───────────────────────────────────────────────────────────────────────────
  # 5. Process SCM Authors
  # ───────────────────────────────────────────────────────────────────────────
  scm_authors_data = SCM_MANIFESTO_AUTHORS.map do |author_name|
    canon_key = nil
    CANONICAL_ENTITIES.each do |k, entity|
      if entity[:scm_author] && entity[:aliases].any? { |a| normalize_name(a) == normalize_name(author_name) }
        canon_key = k
        break
      end
    end
    canon_entity = canon_key ? CANONICAL_ENTITIES[canon_key] : nil

    # Check Agile authorship
    is_agile_author = canon_entity&.fetch(:agile_author, false) ||
                      AGILE_MANIFESTO_AUTHORS.any? { |a| normalize_name(a) == normalize_name(author_name) }

    # Check Agile signatory
    agile_sig_hit = nil
    ([author_name] + (canon_entity ? canon_entity[:aliases] : [])).each do |alias_str|
      name_variants(alias_str).each do |var|
        if agile_sig_index[var]
          agile_sig_hit = agile_sig_index[var]
          break
        end
      end
      break if agile_sig_hit
    end

    # Check SCM signatory records
    scm_hits = []
    ([author_name] + (canon_entity ? canon_entity[:aliases] : [])).each do |alias_str|
      name_variants(alias_str).each do |var|
        scm_hits.concat(scm_sig_index[var] || [])
      end
    end
    scm_hits.uniq! { |h| h['signatory_number'] }

    # Check UGtastic interviews
    matched_interviews = []
    ([author_name] + (canon_entity ? canon_entity[:aliases] : [])).each do |alias_str|
      name_variants(alias_str).each do |var|
        matched_interviews.concat(interviews_by_participant[var] || [])
      end
    end
    matched_interviews.uniq! { |i| i[:id] }
    if canon_entity && canon_entity[:interview_filter]
      matched_interviews.select! { |i| canon_entity[:interview_filter].call(i[:raw_item]) }
    end

    # SCM role
    scm_role = !scm_hits.empty? ? 'author_and_signatory' : 'author_only'

    {
      name: author_name,
      canonical_id: canon_key,
      scm_author: true,
      scm_signatory: !scm_hits.empty?,
      scm_role: scm_role,
      scm_signatory_records: scm_hits.map do |h|
        {
          number: h['signatory_number'],
          name: h['name'],
          location: h['location'],
          signed_on: h['signed_on']
        }
      end,
      agile_author: is_agile_author,
      agile_signatory: !agile_sig_hit.nil?,
      agile_signatory_record: agile_sig_hit,
      ugtastic_interviewee: !matched_interviews.empty?,
      ugtastic_interviews: matched_interviews.map { |i| i.slice(:id, :title, :conference, :community, :recorded_date) },
      note: canon_entity ? canon_entity[:note] : nil
    }
  end

  # ───────────────────────────────────────────────────────────────────────────
  # 6. Disambiguation Entries (Specifically the two Dave Thomases)
  # ─────────────────────────────────────────────────────────────────────────────
  dave_pragdave = {
    canonical_id: 'dave-pragdave-thomas',
    display_name: 'Dave "pragdave" Thomas',
    disambiguation: 'The Pragmatic Programmer co-author, Elixir champion, Agile Manifesto co-author (Snowbird 2001).',
    agile: {
      author: true,
      signatory: false,
      role: 'author_only'
    },
    scm: {
      author: false,
      signatory: false,
      role: 'none'
    },
    ugtastic: {
      interviewee: true,
      interviews: [
        {
          id: 'dave-thomas-software-craftsmanship-north-america-2013',
          title: "The Power of Unknown Knowns: PragDave Thomas on Intuition and the Beginner's Mind",
          conference: 'SCNA',
          community: 'SCNA 2013'
        }
      ]
    }
  }

  dave_bedarra = {
    canonical_id: 'dave-thomas-bedarra',
    display_name: 'Dave Thomas (Bedarra / OTI)',
    disambiguation: 'Founder of Object Technology International (OTI, Eclipse/VisualAge precursor) and Bedarra Research.',
    agile: {
      author: false,
      signatory: true,
      role: 'signatory_only',
      signatory_page: '000000005.html',
      company_as_signed: 'Bedarra Corp'
    },
    scm: {
      author: false,
      signatory: false,
      role: 'none'
    },
    ugtastic: {
      interviewee: true,
      interviews: [
        {
          id: 'dave-thomas-goto-conference-and-community-goto-conference-and-community',
          title: 'Independent Tech: Dave Thomas on GOTO Conferences, Vendor Influence, and Community Values',
          conference: 'GOTO Conference and Community'
        },
        {
          id: 'dave-thomas-goto-conference-2015',
          title: 'Conference Speaking And Presentation Skills: Mike Hall Interviews Dave Thomas | GOTO Conference 2015',
          conference: 'GOTO Conference'
        }
      ]
    }
  }

  # ───────────────────────────────────────────────────────────────────────────
  # 7. SCM Signatory Crosswalk (Matching all 27,601 SCM Signatories)
  # ───────────────────────────────────────────────────────────────────────────
  scm_matches = []
  scm_in_agile_count = 0

  scm_raw.each do |scm_sig|
    sig_name = scm_sig['name']
    variants = name_variants(sig_name)

    # Check Agile Signatory match
    agile_hit = variants.map { |v| agile_sig_index[v] }.compact.first

    # Check UGtastic match
    ug_hit = variants.map { |v| interviews_by_participant[v] }.compact.first
    scmc_hit = variants.map { |v| scmc_by_speaker[v] }.compact.first

    next unless agile_hit || ug_hit || scmc_hit

    scm_in_agile_count += 1 if agile_hit

    connection_types = []
    connection_types << 'agile_manifesto_signatory' if agile_hit
    connection_types << 'ugtastic_interviewee' if ug_hit
    connection_types << 'scmc_speaker' if scmc_hit

    scm_matches << {
      signatory_number: scm_sig['signatory_number'],
      signatory_name: sig_name,
      location: scm_sig['location'],
      signed_on: scm_sig['signed_on'],
      connection_types: connection_types,
      connections: {
        agile_manifesto: agile_hit ? {
          name_as_signed: agile_hit['name'],
          email: agile_hit['email']
        } : nil,
        ugtastic_interviews: (ug_hit || []).map { |i| i.slice(:id, :title, :conference, :community, :recorded_date) },
        scmc_presentations: (scmc_hit || []).map { |i| i.slice(:id, :title, :presenter, :year, :url) }
      }
    }
  end

  # Filter specific cohorts
  trifecta_records = scm_matches.select do |m|
    m[:connection_types].include?('agile_manifesto_signatory') &&
      m[:connection_types].include?('ugtastic_interviewee')
  end

  craftsmanship_first_records = scm_matches.select do |m|
    !m[:connection_types].include?('agile_manifesto_signatory') &&
      m[:connection_types].include?('ugtastic_interviewee')
  end

  agile_only_records = scm_matches.select do |m|
    m[:connection_types].include?('agile_manifesto_signatory') &&
      !m[:connection_types].include?('ugtastic_interviewee') &&
      !m[:connection_types].include?('scmc_speaker')
  end

  trifecta_names = trifecta_records.map { |m| m[:signatory_name] }.uniq.sort

  # ───────────────────────────────────────────────────────────────────────────
  # 8. Build Final Output Schema
  # ───────────────────────────────────────────────────────────────────────────
  dataset = {
    generated_at: Time.now.utc.iso8601,
    taxonomy: {
      manifesto_roles: {
        author_only: 'Drafted/participated in founding summit; did not use public web signatory form',
        signatory_only: 'Signed public web petition after publication; not part of founding draft group',
        author_and_signatory: 'Participated in drafting/founding AND signed the public ledger'
      },
      disambiguation_policy: 'Explicit canonical IDs assigned to separate individuals sharing identical or variant names.'
    },
    summary: {
      agile_manifesto: {
        founding_date: 'February 2001',
        location: 'Snowbird, Utah',
        authors_total: AGILE_MANIFESTO_AUTHORS.size,
        signatories_total: agile_raw.size
      },
      software_craftsmanship_manifesto: {
        summit_date: 'December 13, 2008',
        publication_date: 'March 2009',
        location: 'Libertyville, Illinois (8th Light)',
        authors_total: SCM_MANIFESTO_AUTHORS.size,
        signatories_total: scm_raw.size
      },
      ugtastic_archive: {
        interviews_total: interview_items.size,
        speakers_recorded: interviews_by_participant.keys.size
      },
      intersection_metrics: {
        scm_in_agile_signatories: scm_in_agile_count,
        agile_authors_in_scm_signatories: 3, # Robert C. Martin (#5), Ron Jeffries (#27), Jon Kern (#204)
        agile_authors_in_scm_authors: 2,     # Robert C. Martin, Brian Marick
        scm_authors_in_agile_signatories: 3, # Micah Martin, Dave Hoover, Michael Norton
        all_three_ecosystems_trifecta: trifecta_names.size,
        craftsmanship_first_ugtastic_only: craftsmanship_first_records.map { |m| m[:signatory_name] }.uniq.size
      }
    },
    disambiguations: {
      dave_thomas_case_study: {
        description: 'Two prominent figures in modern software history share the name Dave Thomas. Both were interviewed by Mike Hall, but occupy distinct manifesto roles.',
        people: [dave_pragdave, dave_bedarra]
      }
    },
    agile_manifesto_authors: agile_authors_data,
    scm_manifesto_authors: scm_authors_data,
    trifecta_signatories: trifecta_records,
    craftsmanship_first_signatories: craftsmanship_first_records,
    scm_agile_signatory_sample: agile_only_records.first(50),
    matches: scm_matches
  }

  output_json = JSON.pretty_generate(dataset)

  # Validate that YAML/Psych parses it cleanly without error
  begin
    YAML.safe_load(output_json, permitted_classes: [Date, Time], aliases: true)
    puts '    Validation passed: Output JSON parses cleanly via SafeYAML/Psych!' if options[:verbose]
  rescue StandardError => e
    warn "FATAL: Output JSON fails YAML/Psych parsing: #{e.message}"
    exit 1
  end

  if options[:dry_run]
    puts "DRY RUN: Generated #{output_json.bytesize} bytes (#{dataset[:summary][:intersection_metrics]})."
  else
    File.write(options[:output_path], output_json)
    puts "==> Successfully wrote dataset to #{options[:output_path]} (#{output_json.bytesize} bytes)"
  end
end

# ─────────────────────────────────────────────────────────────────────────────
# CLI Option Parsing
# ─────────────────────────────────────────────────────────────────────────────

options = {
  agile_json: AGILE_SIGS_PATH,
  output_path: DEFAULT_OUTPUT_PATH,
  dry_run: false,
  verbose: true
}

OptionParser.new do |opts|
  opts.banner = 'Usage: bin/build_manifesto_network.rb [options]'

  opts.on('--agile-json PATH', "Path to agile_manifesto_signatories.json (default: #{AGILE_SIGS_PATH})") do |p|
    options[:agile_json] = p
  end

  opts.on('-o', '--output PATH', "Output JSON path (default: #{DEFAULT_OUTPUT_PATH})") do |p|
    options[:output_path] = p
  end

  opts.on('-n', '--dry-run', 'Calculate intersections and validate without writing') do
    options[:dry_run] = true
  end

  opts.on('-q', '--quiet', 'Suppress verbose logging') do
    options[:verbose] = false
  end

  opts.on('-h', '--help', 'Show this help message') do
    puts opts
    exit 0
  end
end.parse!

run_pipeline(options)
