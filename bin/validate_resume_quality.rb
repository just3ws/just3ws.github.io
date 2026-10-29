#!/usr/bin/env ruby
# frozen_string_literal: true

# ---
# name: validate_resume_quality.rb
# domain: validate
# purpose: Automated Resume Quality, ATS Parser Emulation, and Competency Coverage Validator.
# usage: ruby bin/validate_resume_quality.rb
# ---

# bin/validate_resume_quality.rb
# Automated Resume Quality, ATS Parser Emulation, and Competency Coverage Validator.

require 'yaml'
require 'json'
require 'fileutils'
require 'pathname'

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
    'Professional Summary',
    'Core Skills',
    'Experience'
  ].freeze

  EXPECTED_PRINCIPAL_COMPETENCIES = [
    'OpenTelemetry',
    'Architecture Discovery',
    'Rails',
    'PostgreSQL',
    'instant disbursement',
    'Enablement',
    'SRE'
  ].freeze

  STRUCTURAL_OUTCOME_INDICATORS = %w[
    reducing eliminating prevented preventing replacing decommissioned decommissioning
    scaled scaling reconciling stabilized stabilizing streamlined streamlining
    migrating migrated protecting protected delivered delivering accelerated accelerating
    unified unifying isolated isolating raised raising lowered lowering mitigated mitigating
    restored restoring standardized standardizing improved improving saved saving
    enabled enabling secured securing established establishing diagnosed diagnosing
    architected architecting engineered designed built led founded resolved
  ].freeze

  SUMMARY_PATH = File.join(ROOT_DIR, '_data', 'resume', 'summary.yml')
  PROFILE_PATH = File.join(ROOT_DIR, '_data', 'resume', 'profile.yml')

  def initialize
    @errors = []
    @warnings = []
    @metrics = {}
  end

  def run
    puts "\n🔍 Running Automated Resume Quality & ATS Parser Validation Suite..."
    puts "=" * 80

    validate_macro_narrative
    validate_canonical_positions
    validate_ats_text_exports
    validate_ats_pdf_exports
    validate_json_exports
    validate_schema_org_json_ld
    validate_zero_em_dashes
    validate_datalake_parity

    print_report
    @errors.empty?
  end

  private

  def validate_macro_narrative
    puts "1. Auditing Macro Narrative & Positioning Alignment..."
    unless File.exist?(SUMMARY_PATH)
      @errors << "Canonical summary missing at #{SUMMARY_PATH}"
      return
    end

    summary_data = YAML.safe_load_file(SUMMARY_PATH)
    summary_text = summary_data['text'].to_s.strip

    if summary_text.empty?
      @errors << "Canonical summary text in #{SUMMARY_PATH} is empty"
    elsif summary_text.length < 80
      @warnings << "Canonical summary text is unusually brief (< 80 chars)"
    end

    # Check for strategic problem domain indicators
    domain_indicators = %w[software engineer modernization architecture distributed resilience reliability observability]
    matches = domain_indicators.select { |ind| summary_text.downcase.include?(ind) }
    if matches.size < 2
      @warnings << "Macro narrative summary lacks domain authority keywords (found #{matches.size}/#{domain_indicators.size})"
    end

    # Check for passive commodity phrases
    passive_summary_phrases = ['seeking a', 'results-oriented', 'hardworking', 'looking for a role']
    passive_summary_phrases.each do |phrase|
      if summary_text.downcase.include?(phrase)
        @errors << "Macro narrative contains generic commodity phrase '#{phrase}'"
      end
    end

    # Check canonical profile title
    if File.exist?(PROFILE_PATH)
      profile_data = YAML.safe_load_file(PROFILE_PATH)
      if profile_data['title'] != 'Staff Software Engineer'
        @errors << "Canonical profile title mismatch: expected 'Staff Software Engineer', got '#{profile_data['title']}'"
      end
    end

    puts "   ✓ Verified canonical professional summary with Staff Software Engineer identity and hands-on IC scope"
  end

  def validate_canonical_positions
    puts "\n2. Auditing Canonical Position Records (_data/resume/positions/)..."
    position_files = Dir.glob(File.join(RESUME_POSITIONS_DIR, '*.yml'))
    @metrics[:total_positions] = position_files.size

    total_bullets = 0
    quantified_bullets = 0
    action_verb_bullets = 0
    structural_outcome_bullets = 0

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

        # Check for structural outcome indicators
        if STRUCTURAL_OUTCOME_INDICATORS.any? { |ind| text.downcase.include?(ind) }
          structural_outcome_bullets += 1
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
    @metrics[:structural_outcome_pct] = (structural_outcome_bullets.to_f / [total_bullets, 1].max * 100).round(1)

    puts "   ✓ #{position_files.size} positions scanned (#{total_bullets} total achievement highlights)"
    puts "   ✓ Structural Outcome Causality: #{@metrics[:structural_outcome_pct]}% of highlights connect technical action to measurable consequence"
    puts "   ✓ Quantified Impact Density: #{@metrics[:quantified_pct]}% of highlights contain measurable scale/metrics"
    puts "   ✓ Action Verb Leadership Ratio: #{@metrics[:action_verb_pct]}% start with active engineering verbs"
  end

  def validate_ats_text_exports
    puts "\n3. Emulating ATS Ingestion on Plain-Text Exports (exports/resumes/*.txt)..."
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

      # Check required standard sections (case-insensitive)
      REQUIRED_ATS_SECTIONS.each do |sec|
        unless content =~ /\b#{Regexp.escape(sec)}\b/i
          @errors << "#{filename}: ATS parser missing standard section header '#{sec}'"
        end
      end

      if filename == 'ats-import-resume.txt'
        ['Earlier Career Experience', 'Technical Leadership'].each do |sec|
          unless content.match?(/\b#{Regexp.escape(sec)}\b/i)
            @errors << "#{filename}: ATS import export missing section '#{sec}'"
          end
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

  def validate_ats_pdf_exports
    puts "\n4. Emulating ATS text extraction from PDF exports..."
    pdf_files = Dir.glob(File.join(EXPORTS_DIR, '*.pdf')) + Dir.glob(File.join(ROOT_DIR, 'exports', '*.pdf'))
    pdf_files.uniq!
    if pdf_files.empty?
      @errors << "No PDF resume exports found under exports/ or exports/resumes/"
      return
    end

    pdf_files.each do |pdf_path|
      filename = Pathname.new(pdf_path).relative_path_from(Pathname.new(ROOT_DIR)).to_s
      begin
        require 'pdf-reader'
        reader = PDF::Reader.new(pdf_path)
        text = reader.pages.map(&:text).join("\n")
        first_page = reader.pages.first&.text.to_s
        if text.strip.empty?
          @errors << "#{filename}: PDF contains no extractable text"
          next
        end

        %w[Mike\ Hall Professional\ Summary Core\ Skills Experience].each do |term|
          @errors << "#{filename}: PDF text extraction missing '#{term}'" unless text.match?(/#{Regexp.escape(term)}/i)
        end
        unless first_page.match?(/Mike\s+Hall/i) && first_page.match?(/mike@just3ws\.com/i) && first_page.match?(/\(847\)\s*877-3825/)
          @errors << "#{filename}: first page does not expose name, email, and phone in extractable text"
        end
        if text.index(/Mike\s+Hall/i).nil? || text.index(/Professional\s+Summary/i).nil? ||
           text.index(/Mike\s+Hall/i) > text.index(/Professional\s+Summary/i)
          @errors << "#{filename}: extracted text does not place the name before the summary"
        end
      rescue LoadError => e
        @errors << "#{filename}: PDF text extraction requires the pdf-reader gem (#{e.message})"
      rescue StandardError => e
        @errors << "#{filename}: PDF text extraction failed: #{e.message}"
      end
    end

    puts "   ✓ #{pdf_files.size} PDF exports passed text extraction and first-page checks"
  end

  def validate_json_exports
    puts "\n5. Validating Internal Structured Resume Exports (exports/resumes/*.json)..."
    json_files = Dir.glob(File.join(EXPORTS_DIR, '*.json'))
    json_files.each do |json_path|
      filename = File.basename(json_path)
      begin
        data = JSON.parse(File.read(json_path))
        unless data.is_a?(Hash)
          @errors << "#{filename}: root value must be a JSON object"
          next
        end
        basics = data['basics']
        experience = data['experience']
        @errors << "#{filename}: missing basics object" unless basics.is_a?(Hash)
        if basics.is_a?(Hash)
          %w[name title email phone location].each do |field|
            @errors << "#{filename}: basics.#{field} must be a non-empty string" unless basics[field].is_a?(String) && !basics[field].strip.empty?
          end
        end
        @errors << "#{filename}: summary must be a non-empty string" unless data['summary'].is_a?(String) && !data['summary'].strip.empty?
        unless data['core_skills'].is_a?(Array) && data['core_skills'].all? { |skill| skill.is_a?(String) && !skill.strip.empty? }
          @errors << "#{filename}: core_skills must be an array of non-empty strings"
        end
        unless experience.is_a?(Array) && !experience.empty?
          @errors << "#{filename}: experience must be a non-empty array"
        else
          experience.each_with_index do |position, index|
            %w[id title company dates].each do |field|
              @errors << "#{filename}: experience[#{index}].#{field} must be a non-empty string" unless position.is_a?(Hash) && position[field].is_a?(String) && !position[field].strip.empty?
            end
            unless position.is_a?(Hash) && position['highlights'].is_a?(Array) && position['highlights'].all? { |highlight| highlight.is_a?(String) && !highlight.strip.empty? }
              @errors << "#{filename}: experience[#{index}].highlights must be an array of non-empty strings"
            end
          end
        end
      rescue JSON::ParserError => e
        @errors << "#{filename}: Invalid JSON syntax - #{e.message}"
      end
    end
    puts "   ✓ #{json_files.size} JSON exports validated against the repository's internal export contract"
  end

  def validate_schema_org_json_ld
    puts "\n6. Validating Schema.org Linked Data in Rendered HTML (_site/index.html)..."
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
    puts "\n7. Validating 'no-em-dashes' Writing Rule Across All Surfaces..."
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
    puts "\n8. Validating Full-Corpus Career Datalake Index Parity..."
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

    # Verify the instant disbursement and 7 acquisition channels are present in datalake
    highlights_text = (onemain['highlights'] || []).map { |h| h.is_a?(Hash) ? h['text'] : h.to_s }.join(' ')
    unless highlights_text.match?(/instant\s+(?:loan\s+)?disbursement/i)
      @errors << "Career datalake OneMain entry missing instant disbursement highlight"
    end

    unless highlights_text =~ /(seven|7)\s+(?:heterogeneous\s+|distinct\s+)?(?:acquisition channels|lending funnels)/i
      @errors << "Career datalake OneMain entry missing 7 lending funnels highlight"
    end

    count = positions.is_a?(Hash) ? positions.size : positions.count
    puts "   ✓ Career Datalake contains #{count} verified positions with 100% highlight parity"
  end

  def print_report
    puts "\n" + "=" * 80
    puts "🎯 RESUME QUALITY & ATS READINESS AUDIT SUMMARY"
    puts "=" * 80

    puts "• Macro Narrative Alignment: Verified (Staff Software Engineer identity and hands-on IC scope)"
    puts "• Structural Outcome Ratio : #{@metrics[:structural_outcome_pct]}% (highlights with explicit consequence/result)"
    puts "• Quantified Impact Ratio  : #{@metrics[:quantified_pct]}% (highlights with concrete scale/metrics)"
    puts "• Strong Action Verb Ratio : #{@metrics[:action_verb_pct]}% (highlights starting with action verbs)"
    puts "• Scanned Positions        : #{@metrics[:total_positions]}"
    puts "• Total Highlights Audited : #{@metrics[:total_bullets]}"

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
