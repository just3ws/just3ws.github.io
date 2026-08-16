#!/usr/bin/env ruby
# frozen_string_literal: true

# bin/generate_executive_brief.rb
# Generates a tailored 1-page executive pitch brief for target Principal/Staff roles.

require 'yaml'
require 'json'
require 'fileutils'

ROOT_DIR = File.expand_path('..', __dir__)
DATA_DIR = File.join(ROOT_DIR, '_data', 'resume')
OUTPUT_DIR = File.join(ROOT_DIR, 'tmp', 'executive_briefs')

def load_canonical_data
  profile = YAML.safe_load_file(File.join(DATA_DIR, 'profile.yml'))
  summary = YAML.safe_load_file(File.join(DATA_DIR, 'summary.yml'))
  onemain = YAML.safe_load_file(File.join(DATA_DIR, 'positions', 'onemain.yml'))
  emr_bear = YAML.safe_load_file(File.join(DATA_DIR, 'positions', 'emr-bear.yml'))
  { profile: profile, summary: summary, onemain: onemain, emr_bear: emr_bear }
end

def generate_brief(company_name, role_title)
  data = load_canonical_data
  profile = data[:profile]
  onemain = data[:onemain]
  email = profile.dig('contact', 'email') || 'just3ws@gmail.com'
  location = profile.dig('location', 'display') || 'Chicago, IL'

  brief = <<~MARKDOWN
    # Executive Pitch Brief: #{company_name}
    **Target Role:** #{role_title}
    **Candidate:** #{profile['name']} — #{profile['title']}
    **Contact:** #{email} | #{location}

    ---

    ## Executive Summary
    Principal Systems Cartographer & Platform Architect who discovers, maps, and modernizes complex legacy codepaths, lateral state dependencies, and high-concurrency production systems.

    ## Strategic Alignment for #{company_name}
    - **Platform Risk & System Cartography:** Rapidly builds architectural mental models spanning application codepaths, network dependencies, and security boundaries to unblock engineering teams.
    - **Production Safety Governance:** Establishes explicit release verification gates and decoupling strategies so critical modernization changes proceed safely without business disruption.
    - **Senior IC Technical Leadership:** Drives architecture, telemetry standards, and responsibility realignment across distributed engineering teams without relying on formal authority.

    ## Relevant Case Studies
    1. **OneMain Financial (Associate Director, Staff Engineer):**
       - Architected Acquisition software boundaries and led OpenTelemetry tracing across high-velocity microservices.
       - Restructured developer platform capabilities, reducing delivery friction and preventing production outages.
    2. **EMR-Bear (Development Manager — Contract):**
       - Executed 90-day system discovery and operational risk cartography for a multi-tenant SaaS platform serving 130+ clinics following a founder exit.
       - Governed release safety across 36+ pending updates while preserving HIPAA compliance boundaries.

    ## Relevant Technical Interviews & Writing
    - [Software Craftsmanship & Distributed Media](https://just3ws.localhost/interviews/)
    - [Multi-Format Resume Package](https://just3ws.localhost/exports/)

    ---
    *Generated via `bin/generate_executive_brief.rb` for target application positioning.*
  MARKDOWN

  FileUtils.mkdir_p(OUTPUT_DIR)
  filename = "brief_#{company_name.downcase.gsub(/[^a-z0-9]/, '_')}.md"
  out_path = File.join(OUTPUT_DIR, filename)
  File.write(out_path, brief)

  puts "✅ Executive Brief generated successfully:"
  puts "   - #{out_path}"
end

if ARGV.include?('--help') || ARGV.include?('-h')
  puts "Usage: ruby bin/generate_executive_brief.rb [COMPANY_NAME] [ROLE_TITLE]"
  puts ""
  puts "Generates a tailored 1-page executive pitch brief for target Staff/Principal Engineer roles."
  puts ""
  puts "Examples:"
  puts "  ruby bin/generate_executive_brief.rb Stripe \"Principal Software Engineer\""
  puts "  ruby bin/generate_executive_brief.rb Datadog \"Staff Platform Architect\""
  exit 0
end

if ARGV.empty?
  generate_brief("Target Company", "Principal Software Engineer")
else
  company = ARGV[0]
  role = ARGV[1] || "Principal Software Engineer"
  generate_brief(company, role)
end
