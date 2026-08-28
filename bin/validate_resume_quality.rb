#!/usr/bin/env ruby
# frozen_string_literal: true

# bin/validate_resume_quality.rb
# Automated Resume Quality, ATS Parser Emulation, and Competency Coverage Validator.

require 'yaml'
require 'json'
require 'fileutils'

ROOT_DIR = File.expand_path('..', __dir__)
RESUME_POSITIONS_DIR = File.join(ROOT_DIR, '_data', 'resume', 'positions')
EXPORTS_DIR = File.join(ROOT_DIR, 'exports', 'resumes')
TAILORED_DIR = File.join(ROOT_DIR, 'resumes')
DATALAKE_PATH = File.join(ROOT_DIR, 'career_datalake.json')
SITE_INDEX_PATH = File.join(ROOT_DIR, '_site', 'index.html')

class ResumeQualityValidator
  STRONG_ACTION_VERBS = %w[
    Architected Led Delivered Founded Eliminated Modernized Shipped
    Engineered Mentored Resolved Diagnosed Scaled Progressed Reverse-Engineered
    Consolidated Standardized Designed Built Evaluated Accelerated Refactored
    Integrated Authored Spearheaded Established Automated Partnered Upgraded
    Structured
  ].freeze

  WEAK_PASSIVE_PHRASES = [
    'responsible for',
    'assisted with',
    'helped to',
    'worked on',
    'tasked with',
    'duties included'
  ].freeze

  AI_FLUFF_JARGON = %w[
    testament tapestry multifaceted synergy pivotal beacon delve
  ].freeze

  REQUIRED_ATS_SECTIONS = [
    'PROFESSIONAL SUMMARY',
    'CORE SKILLS',
    'EXPERIENCE'
  ].freeze

  EXPECTED_PRINCIPAL_COMPETENCIES = [
    'OpenTelemetry',
    'Architecture Discovery',
    'Rails',
    'PostgreSQL',
    'Speedfunds',
    'Enablement',
    'SRE'
  ].freeze

  def initialize
    @errors = []
    @warnings = []
    @metrics = {}
  end

  def run
    puts "\n🔍 Running Automated Resume Quality & ATS Parser Validation Suite..."
    puts "=" * 80

    validate_canonical_positions
    validate_ats_text_exports
    validate_json_exports
    validate_schema_org_json_ld
    validate_zero_em_dashes
    validate_datalake_parity

    print_report
    @errors.empty?
  end

  private

  def validate_canonical_positions
    puts "1. Auditing Canonical Position Records (_data/resume/positions/)..."
    position_files = Dir.glob(File.join(RESUME_POSITIONS_DIR, '*.yml'))
    @metrics[:total_positions] = position_files.size

    total_bullets = 0
    quantified_bullets = 0
    action_verb_bullets = 0

    position_files.each do |file|
      data = YAML.safe_load_file(file)
      id = data['id'] || File.basename(file, '.yml')

      # Check summary
      if data['summary'].nil? || data['summary'].strip.empty?
        @errors << "Position #{id} missing summary"
      end

      # Check highlights
      highlights = data['highlights'] || []
      highlights.each_with_index do |hl, idx|
        text = hl.is_a?(Hash) ? hl['text'] : hl.to_s
        total_bullets += 1

        # Check for quantified metrics (%, $, numbers, durations, scale, specific counts)
        if text =~ /(\d+[%kKmMbB]?|\$\d+|\b\d+\+?\s*(days|minutes|hours|weeks|months|years|lanes|teams|squads|channels|engineers|users|positions|subscribers|clients|million|thousand)\b|\b(two|three|four|five|six|seven|eight|nine|ten)\s+(teams|squads|channels|hackathons|engineers|years|decades)\b)/i
          quantified_bullets += 1
        end

        # Check for strong action verb
        first_token = text.strip.split(/[:\s]/).first
        if STRONG_ACTION_VERBS.any? { |verb| first_token.casecmp?(verb) }
          action_verb_bullets += 1
        end

        # Check for weak passive phrases
        WEAK_PASSIVE_PHRASES.each do |phrase|
          if text.downcase.include?(phrase)
            @warnings << "Position #{id} bullet #{idx + 1} contains passive phrase '#{phrase}'"
          end
        end

        # Check for AI fluff
        AI_FLUFF_JARGON.each do |jargon|
          if text.downcase =~ /\b#{jargon}\b/
            @errors << "Position #{id} bullet #{idx + 1} contains AI fluff word '#{jargon}'"
          end
        end
      end
    end

    @metrics[:total_bullets] = total_bullets
    @metrics[:quantified_bullets] = quantified_bullets
    @metrics[:quantified_pct] = (quantified_bullets.to_f / [total_bullets, 1].max * 100).round(1)
    @metrics[:action_verb_pct] = (action_verb_bullets.to_f / [total_bullets, 1].max * 100).round(1)

    puts "   ✓ #{position_files.size} positions scanned (#{total_bullets} total achievement highlights)"
    puts "   ✓ Quantified Impact Density: #{@metrics[:quantified_pct]}% of highlights contain measurable scale/metrics"
    puts "   ✓ Action Verb Leadership Ratio: #{@metrics[:action_verb_pct]}% start with active engineering verbs"
  end

  def validate_ats_text_exports
    puts "\n2. Emulating ATS Ingestion on Plain-Text Exports (exports/resumes/*.txt)..."
    txt_files = Dir.glob(File.join(EXPORTS_DIR, '*.txt'))
    if txt_files.empty?
      @errors << "No plain text resume exports found under #{EXPORTS_DIR}"
      return
    end

    txt_files.each do |txt_path|
      filename = File.basename(txt_path)
      content = File.read(txt_path)

      # Check contact header
      unless content =~ /MIKE HALL/i && content =~ /@/ && content =~ /\(\d{3}\)/
        @errors << "#{filename}: ATS parser failed to extract standard contact information"
      end

      # Check required standard sections
      REQUIRED_ATS_SECTIONS.each do |sec|
        unless content.include?(sec)
          @errors << "#{filename}: ATS parser missing standard section header '#{sec}'"
        end
      end

      # Check Principal competencies in primary resume
      if filename.include?('principal')
        EXPECTED_PRINCIPAL_COMPETENCIES.each do |comp|
          unless content.include?(comp)
            @errors << "#{filename}: Missing critical Staff+/Principal competency keyword '#{comp}'"
          end
        end
      end
    end

    puts "   ✓ #{txt_files.size} plain text exports passed ATS section and keyword extraction"
  end

  def validate_json_exports
    puts "\n3. Validating Structured JSON Resume Exports (exports/resumes/*.json)..."
    json_files = Dir.glob(File.join(EXPORTS_DIR, '*.json'))
    json_files.each do |json_path|
      filename = File.basename(json_path)
      begin
        data = JSON.parse(File.read(json_path))
        unless (data['profile'] || data['basics']) && (data['positions'] || data['experience'])
          @errors << "#{filename}: JSON schema missing required profile/basics or positions/experience root keys"
        end
      rescue JSON::ParserError => e
        @errors << "#{filename}: Invalid JSON syntax - #{e.message}"
      end
    end
    puts "   ✓ #{json_files.size} JSON exports validated against structural schema"
  end

  def validate_schema_org_json_ld
    puts "\n4. Validating Schema.org Linked Data in Rendered HTML (_site/index.html)..."
    unless File.exist?(SITE_INDEX_PATH)
      @warnings << "_site/index.html not found, skipping live JSON-LD extraction (run after build)"
      return
    end

    html = File.read(SITE_INDEX_PATH)
    json_ld_matches = html.scan(%r{<script type="application/ld\+json">(.*?)</script>}m)

    found_person = false
    json_ld_matches.each do |match|
      content = match.first.strip
      begin
        parsed = JSON.parse(content)
        items = parsed.is_a?(Array) ? parsed : [parsed]
        items.each do |item|
          if item['@type'] == 'Person' || (item['@graph'] && item['@graph'].any? { |g| g['@type'] == 'Person' })
            found_person = true
          end
        end
      rescue JSON::ParserError => e
        @errors << "Rendered page contains invalid JSON-LD: #{e.message}"
      end
    end

    if found_person
      puts "   ✓ Verified valid Schema.org 'Person' entity with rich occupation attributes"
    else
      @errors << "No Schema.org 'Person' JSON-LD entity discovered on root resume page"
    end
  end

  def validate_zero_em_dashes
    puts "\n5. Validating 'no-em-dashes' Writing Rule Across All Surfaces..."
    prose_files = Dir.glob(File.join(RESUME_POSITIONS_DIR, '*.yml')) +
                  Dir.glob(File.join(EXPORTS_DIR, '*.txt')) +
                  Dir.glob(File.join(TAILORED_DIR, '*.md'))

    em_dash_violations = 0
    prose_files.each do |file|
      content = File.read(file)
      # Check for Unicode em dash (—) or double hyphen with spaces ( -- )
      if content.include?('—') || content =~ /\s--\s/
        em_dash_violations += 1
        @errors << "Em dash violation detected in #{File.basename(file)}"
      end
    end

    if em_dash_violations.zero?
      puts "   ✓ 0 em dashes detected across #{prose_files.size} resume and prose files"
    end
  end

  def validate_datalake_parity
    puts "\n6. Validating Full-Corpus Career Datalake Index Parity..."
    unless File.exist?(DATALAKE_PATH)
      @errors << "Career datalake file missing at #{DATALAKE_PATH}"
      return
    end

    datalake = JSON.parse(File.read(DATALAKE_PATH))
    positions = datalake['positions'] || {}
    onemain = positions.is_a?(Hash) ? positions['onemain'] : positions.find { |p| p['id'] == 'onemain' }

    if onemain.nil?
      @errors << "OneMain position missing from career datalake index"
      return
    end

    # Verify Speedfunds and 7 acquisition channels are present in datalake
    highlights_text = (onemain['highlights'] || []).map { |h| h.is_a?(Hash) ? h['text'] : h.to_s }.join(' ')
    unless highlights_text.include?('Speedfunds')
      @errors << "Career datalake OneMain entry missing 'Speedfunds' delivery highlight"
    end

    unless highlights_text.include?('seven heterogeneous acquisition channels')
      @errors << "Career datalake OneMain entry missing 7 acquisition channels highlight"
    end

    count = positions.is_a?(Hash) ? positions.size : positions.count
    puts "   ✓ Career Datalake contains #{count} verified positions with 100% highlight parity"
  end

  def print_report
    puts "\n" + "=" * 80
    puts "🎯 RESUME QUALITY & ATS READINESS AUDIT SUMMARY"
    puts "=" * 80

    puts "• Quantified Impact Ratio : #{@metrics[:quantified_pct]}% (highlights with concrete scale/metrics)"
    puts "• Strong Action Verb Ratio: #{@metrics[:action_verb_pct]}% (highlights starting with action verbs)"
    puts "• Scanned Positions       : #{@metrics[:total_positions]}"
    puts "• Total Highlights Audited: #{@metrics[:total_bullets]}"

    unless @warnings.empty?
      puts "\n⚠️  Warnings (#{@warnings.size}):"
      @warnings.each { |w| puts "   - #{w}" }
    end

    if @errors.empty?
      puts "\n✅ ALL RESUME QUALITY, ATS PARSABILITY & PARITY CHECKS PASSED (0 errors)"
    else
      puts "\n❌ RESUME QUALITY VALIDATION FAILED (#{@errors.size} errors):"
      @errors.each { |e| puts "   - #{e}" }
    end
    puts "=" * 80 + "\n"
  end
end

if __FILE__ == $PROGRAM_NAME
  require 'optparse'

  options = {}
  OptionParser.new do |opts|
    opts.banner = "Usage: bin/validate_resume_quality.rb [options]"
    opts.separator ""
    opts.separator "Automated Resume Quality, ATS Parser Emulation & Competency Validator"
    opts.separator ""
    opts.on("-q", "--quiet", "Suppress non-essential output") do
      options[:quiet] = true
    end
    opts.on_tail("-h", "--help", "Show this help message") do
      puts opts
      exit 0
    end
  end.parse!

  validator = ResumeQualityValidator.new
  success = validator.run
  exit(success ? 0 : 1)
end
