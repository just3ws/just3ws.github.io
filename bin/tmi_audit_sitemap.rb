#!/usr/bin/env ruby
# frozen_string_literal: true

# bin/tmi_audit_sitemap.rb
#
# Walk the published sitemap.xml and run TMI / PII / PHI / *ism guard checks
# against each page's built HTML source in _site/.
#
# Usage:
#   ruby bin/tmi_audit_sitemap.rb [--dry-run] [--json] [--url-filter PATTERN]
#
# Options:
#   --dry-run        Print decisions without writing any quarantine frontmatter
#   --json           Output full structured JSON report
#   --url-filter P   Only audit URLs matching Ruby Regexp pattern P
#   --severity low|medium|high|critical  Only report at or above this level
#   --limit N        Audit at most N pages (useful for sampling)

require 'rexml/document'
require 'pathname'
require 'optparse'
require 'json'

ROOT      = Pathname.new(File.expand_path('..', __dir__))
SITE_DIR  = ROOT / '_site'
SRC_DIR   = ROOT

# ─────────────────────────────────────────────────────────────────────────────
# Options
# ─────────────────────────────────────────────────────────────────────────────
options = {
  dry_run:  false,
  json:     false,
  filter:   nil,
  severity: 'low',
  limit:    nil
}

OptionParser.new do |o|
  o.on('--dry-run')              { options[:dry_run] = true }
  o.on('--json')                 { options[:json] = true }
  o.on('--url-filter P')         { |v| options[:filter] = Regexp.new(v) }
  o.on('--severity S')           { |v| options[:severity] = v }
  o.on('--limit N', Integer)     { |v| options[:limit] = v }
end.parse!

SEVERITY_RANK = { 'low' => 0, 'medium' => 1, 'high' => 2, 'critical' => 3 }.freeze
MIN_RANK      = SEVERITY_RANK.fetch(options[:severity], 0)

# ─────────────────────────────────────────────────────────────────────────────
# Verified-contact allowlist
#
# Pages whose PII findings have been reviewed and confirmed as intentional
# public contact routes or verbatim third-party archive quotes.
# Adding a URL here suppresses its findings from the report (pass decision).
# Document the rationale for each entry.
# ─────────────────────────────────────────────────────────────────────────────
VERIFIED_PAGES = {
  # Root resume and archetype variants: phone is the intentional public contact
  # route. Removing it would create a connection barrier.
  'https://www.just3ws.com/resume/'                                          => 'intentional public contact (phone)',
  'https://www.just3ws.com/history/'                                         => 'intentional public contact (phone)',
  'https://www.just3ws.com/resumes/mike-hall-founding-staff-engineer/'       => 'intentional public contact (phone)',
  'https://www.just3ws.com/resumes/mike-hall-observability-resilience-specialist/' => 'intentional public contact (phone)',
  'https://www.just3ws.com/resumes/mike-hall-principal-software-engineer/'   => 'intentional public contact (phone)',
  'https://www.just3ws.com/resumes/mike-hall-senior-ruby-rails-contractor/'  => 'intentional public contact (phone)',
  'https://www.just3ws.com/resumes/mike-hall-staff-platform-lead/'           => 'intentional public contact (phone)',
  # WindyCityRails 2012 interview: "my husband David Kinney and I run the
  # conference" is a verbatim quote from the speaker about herself. Archive
  # oral history — not our PII to redact.
  'https://www.just3ws.com/interviews/movie-on-9-6-12-at-1-05-pm-windycityrails-2012/' => 'verbatim third-party speaker quote, archive oral history',
  'https://www.just3ws.com/videos/movie-on-9-6-12-at-1-05-pm-windycityrails-2012/'     => 'verbatim third-party speaker quote, archive oral history',
}.freeze

# ─────────────────────────────────────────────────────────────────────────────
# Page-type classifier
# ─────────────────────────────────────────────────────────────────────────────
PAGE_TYPES = {
  hiring:    %r{^/(resume|resumes|exports|history)/},
  interview: %r{^/interviews/},
  video:     %r{^/videos/},
  blog:      %r{^/(20\d{2})/},
  portfolio: %r{^/(case-studies|portfolio|panoramic-view|system-cartographer)/},
  about:     %r{^/(about|now|contact|start-here|ask)/},
  docs:      %r{^/docs/}
}.freeze

def classify(path)
  PAGE_TYPES.each { |type, re| return type if path.match?(re) }
  :other
end

# ─────────────────────────────────────────────────────────────────────────────
# Guard definitions
# ─────────────────────────────────────────────────────────────────────────────
GUARDS = [
  # ── Ageism ────────────────────────────────────────────────────────────────
  {
    id: :ageism_years_exp,
    guard: :ageism,
    pattern: /\b(\d{2,3})\+?\s+years?\s+(of\s+)?experience\b/i,
    surfaces: %i[hiring about portfolio],
    severity: 'high',
    note: 'Total-career-year claim signals age; replace with scope framing.'
  },
  {
    id: :ageism_graduation_year,
    guard: :ageism,
    pattern: /\b(B\.[AS]\.|M\.[AS]\.|Ph\.D\.)\s*(?:in\s+\w[\w\s]{0,30})?\s*,?\s*(19|20)\d{2}\b|\bClass of (19|20)\d{2}\b/i,
    surfaces: %i[hiring about],
    severity: 'high',
    note: 'Graduation year enables age inference on hiring surfaces.'
  },
  {
    id: :ageism_generational_ref,
    guard: :ageism,
    pattern: /\b(since the (dot-?com|web 1\.0)|back in (19|20)\d{2}|when I started in (19|20)\d{2}|I.ve been (coding|programming|building|doing this) since (19|20)\d{2})\b/i,
    surfaces: %i[hiring about portfolio],
    severity: 'medium',
    note: 'Generational anchor on a hiring surface enables age inference.'
  },
  {
    id: :ageism_decade_brand,
    guard: :ageism,
    pattern: /\b(millennial|gen[\s-]?x|boomer|digital native|old[\s-]school)\b/i,
    surfaces: %i[hiring about],
    severity: 'medium',
    note: 'Generational self-label on a hiring surface.'
  },

  # ── PHI ───────────────────────────────────────────────────────────────────
  {
    id: :phi_named_diagnosis,
    guard: :phi,
    pattern: /\b(ADHD|autism|autistic|AuDHD|dyslexia|dyslexic|bipolar|depression|anxiety disorder|OCD|PTSD|BPD)\b/,
    surfaces: %i[hiring about portfolio],
    severity: 'high',
    note: 'Named clinical diagnosis on a hiring surface creates bias surface.'
  },
  {
    id: :phi_treatment,
    guard: :phi,
    pattern: /\b(my therapist|in therapy|hospitaliz|medication|prescription|diagnosed with|(health|medical|clinical|mental)\s+diagnosis)\b/i,
    surfaces: %i[hiring about portfolio],
    severity: 'high',
    note: 'Treatment reference on a hiring surface.'
  },

  # ── PII ───────────────────────────────────────────────────────────────────
  {
    id: :pii_phone,
    guard: :pii,
    pattern: /(?<![\/\w])(\+?1[\s.-]?)?\(?\d{3}\)?[\s.-]\d{3}[\s.-]\d{4}(?!\d)/,
    surfaces: :all,
    severity: 'high',
    note: 'Phone number found; verify it is an intentional public contact.'
  },
  {
    id: :pii_personal_email,
    guard: :pii,
    pattern: /\b[a-zA-Z0-9._%+-]+@(?!just3ws\.com|wwworkremote\.com)[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}\b/,
    surfaces: %i[hiring portfolio],
    severity: 'medium',
    note: 'Non-canonical email on a hiring/portfolio surface; verify it is intentional.'
  },
  {
    id: :pii_home_address,
    guard: :pii,
    pattern: /\b\d{3,5}\s+[A-Z][a-z]+\s+(St|Ave|Blvd|Dr|Rd|Ln|Way|Ct|Pl)\b/,
    surfaces: :all,
    severity: 'critical',
    note: 'Street address pattern found.'
  },
  {
    id: :pii_family_name,
    guard: :pii,
    pattern: /\b(my (wife|husband|spouse|partner|son|daughter|child|kid|mom|dad|mother|father|sister|brother))\s+([A-Z][a-z]+)\b/,
    surfaces: :all,
    severity: 'medium',
    note: 'Family member named with relational context.'
  },

  # ── TMI ───────────────────────────────────────────────────────────────────
  {
    id: :tmi_relationship_status,
    guard: :tmi,
    pattern: /\b(when I was (married|divorced|single)|my ex[\s-]?(wife|husband|partner)|my (divorce|separation|breakup))\b/i,
    surfaces: %i[hiring about portfolio],
    severity: 'medium',
    note: 'Relationship-status detail on a public surface.'
  },
  {
    id: :tmi_financial_distress,
    guard: :tmi,
    pattern: /\b(I was (broke|unemployed|laid off|let go|fired)|couldn.t afford|my debt|student loans?)\b/i,
    surfaces: %i[hiring about portfolio],
    severity: 'medium',
    note: 'Financial distress signal on a public surface.'
  },
  {
    id: :tmi_unemployed_framing,
    guard: :tmi,
    pattern: /\b(currently unemployed|between jobs|actively (looking|searching|seeking))\b/i,
    surfaces: %i[hiring about],
    severity: 'high',
    note: '"Unemployed" or "actively looking" framing on a public page.'
  },
  {
    id: :tmi_salary_figures,
    guard: :tmi,
    pattern: /\b\$\d{2,3}[k,]?\d{0,3}\s*(k|K)?\s*(base|salary|comp|total|floor|band)?\b/,
    surfaces: :all,
    severity: 'high',
    note: 'Salary figure on a public page.'
  },
  {
    id: :tmi_burnout_headline,
    guard: :tmi,
    pattern: /\b(burnout|burned out|breaking point|mental breakdown|rock bottom|nervous breakdown)\b/i,
    surfaces: %i[hiring about portfolio],
    severity: 'medium',
    note: 'Burnout or collapse language on a hiring-facing surface.'
  },

  # ── Ableism ───────────────────────────────────────────────────────────────
  {
    id: :ableism_superpower_framing,
    guard: :ableism,
    pattern: /\b(my (ADHD|autism|autistic brain|neurodivergence|ND) (lets?|allows?|gives?|makes?) me|superpower)\b/i,
    surfaces: %i[hiring about portfolio],
    severity: 'medium',
    note: '"Superpower" framing of a diagnosis on a hiring surface still discloses the condition.'
  },

  # ── Familism ──────────────────────────────────────────────────────────────
  {
    id: :familism_caregiver,
    guard: :familism,
    pattern: /\b(as a (parent|father|mother|dad|mom|caregiver)|my (kids?|children|family obligations?))\b/i,
    surfaces: %i[hiring about portfolio],
    severity: 'low',
    note: 'Parental/caregiver status on a surface reaching employers.'
  }
].freeze

# ─────────────────────────────────────────────────────────────────────────────
# HTML text extractor (simple, no nokogiri dependency)
# ─────────────────────────────────────────────────────────────────────────────
def extract_text(html)
  # Strip script/style blocks first
  text = html.gsub(/<script[^>]*>.*?<\/script>/mi, ' ')
             .gsub(/<style[^>]*>.*?<\/style>/mi, ' ')
             .gsub(/<!--.*?-->/m, ' ')
             .gsub(/<[^>]+>/, ' ')
             .gsub(/&amp;/, '&')
             .gsub(/&lt;/, '<')
             .gsub(/&gt;/, '>')
             .gsub(/&quot;/, '"')
             .gsub(/&#39;|&apos;/, "'")
             .gsub(/&nbsp;/, ' ')
             .gsub(/\s+/, ' ')
             .strip
  text
end

def excerpt(text, match_data, context: 80)
  start = [match_data.begin(0) - 30, 0].max
  finish = [match_data.end(0) + 50, text.length].min
  raw = text[start..finish].gsub(/\s+/, ' ').strip
  raw.length > context ? raw[0..context] + '...' : raw
end

# ─────────────────────────────────────────────────────────────────────────────
# Core audit function
# ─────────────────────────────────────────────────────────────────────────────
def audit_page(url, html, page_type)
  text = extract_text(html)
  findings = []

  GUARDS.each do |guard|
    next unless guard[:surfaces] == :all || guard[:surfaces].include?(page_type)

    text.scan(guard[:pattern]) do
      md = Regexp.last_match
      findings << {
        guard:              guard[:guard].to_s,
        guard_id:           guard[:id].to_s,
        line:               excerpt(text, md),
        severity:           guard[:severity],
        recommendation:     recommend(guard[:guard], guard[:severity], page_type),
        note:               guard[:note]
      }
    end
  end

  findings
end

def recommend(guard, severity, page_type)
  return 'quarantine'  if severity == 'critical'
  return 'quarantine'  if severity == 'high' && page_type == :hiring
  return 'rewrite'     if %i[ageism tmi ableism familism classism].include?(guard)
  return 'generalize'  if severity == 'medium'
  'hold'
end

def overall_decision(findings)
  return 'pass' if findings.empty?
  return 'quarantine' if findings.any? { |f| f[:recommendation] == 'quarantine' }
  return 'reconcile'  if findings.any? { |f| %w[rewrite generalize].include?(f[:recommendation]) }
  'hold'
end

# ─────────────────────────────────────────────────────────────────────────────
# Color helpers
# ─────────────────────────────────────────────────────────────────────────────
def colorize(text, code); "\e[#{code}m#{text}\e[0m"; end
def green(t);  colorize(t, 32); end
def yellow(t); colorize(t, 33); end
def red(t);    colorize(t, 31); end
def cyan(t);   colorize(t, 36); end
def bold(t);   colorize(t, 1);  end
def dim(t);    colorize(t, 2);  end

DECISION_COLORS = {
  'pass'       => method(:green),
  'reconcile'  => method(:yellow),
  'quarantine' => method(:red),
  'hold'       => method(:cyan)
}.freeze

# ─────────────────────────────────────────────────────────────────────────────
# Load sitemap
# ─────────────────────────────────────────────────────────────────────────────
sitemap_path = SITE_DIR / 'sitemap.xml'
abort "#{sitemap_path} not found. Run `bundle exec jekyll build` first." unless sitemap_path.exist?

xml  = REXML::Document.new(File.read(sitemap_path))
urls = xml.elements.collect('urlset/url/loc') { |e| e.text.strip }
urls.select! { |u| u.match?(options[:filter]) } if options[:filter]
urls = urls.first(options[:limit]) if options[:limit]

# ─────────────────────────────────────────────────────────────────────────────
# Run audit
# ─────────────────────────────────────────────────────────────────────────────
base_url  = 'https://www.just3ws.com'
results   = []
stats     = Hash.new(0)

unless options[:json]
  puts bold("\n==============================================================================")
  puts bold("  TMI / PII / PHI / *ism Audit — #{Time.now.strftime('%Y-%m-%d %H:%M')}")
  puts bold("  #{urls.size} URLs | Severity filter: #{options[:severity]}+")
  puts bold("==============================================================================\n")
end

urls.each do |url|
  path      = url.sub(base_url, '')
  page_type = classify(path)

  # Short-circuit: verified pages have been reviewed and accepted
  if VERIFIED_PAGES.key?(url)
    results << { url: url, page_type: page_type.to_s, decision: 'pass',
                 verified: true, rationale: VERIFIED_PAGES[url], findings: [] }
    stats['pass'] += 1
    stats[:total] += 1
    next
  end

  # Map URL to _site file
  file_path = if path == '/' || path.empty?
                SITE_DIR / 'index.html'
              else
                candidate = SITE_DIR / path.sub(%r{^/}, '')
                if candidate.directory?
                  candidate / 'index.html'
                else
                  candidate.sub_ext('.html')
                end
              end

  unless file_path.exist?
    results << { url: url, page_type: page_type.to_s, decision: 'skip',
                 reason: 'file not found in _site', findings: [] }
    next
  end

  html     = File.read(file_path, encoding: 'utf-8', invalid: :replace, undef: :replace)
  findings = audit_page(url, html, page_type)
               .select { |f| SEVERITY_RANK.fetch(f[:severity], 0) >= MIN_RANK }
  decision = overall_decision(findings)

  stats[decision] += 1
  stats[:total]   += 1

  record = {
    url:       url,
    page_type: page_type.to_s,
    findings:  findings,
    decision:  decision
  }
  results << record

  next if options[:json]
  next if decision == 'pass' && findings.empty?

  color_fn = DECISION_COLORS.fetch(decision, method(:dim))
  puts "#{color_fn.call("[#{decision.upcase}]")} #{dim(page_type.to_s.ljust(12))} #{path}"

  findings.each do |f|
    sev_label = case f[:severity]
                when 'critical' then red("critical")
                when 'high'     then red("high    ")
                when 'medium'   then yellow("medium  ")
                else                 dim("low     ")
                end
    puts "  #{sev_label}  #{cyan(f[:guard].ljust(12))}  #{f[:line]}"
    puts "  #{dim(' ' * 26)}#{dim('→ ' + f[:recommendation] + ': ' + f[:note])}"
  end
  puts
end

# ─────────────────────────────────────────────────────────────────────────────
# Output
# ─────────────────────────────────────────────────────────────────────────────
if options[:json]
  puts JSON.pretty_generate({
    generated_at: Time.now.iso8601,
    url_count:    urls.size,
    stats:        stats,
    results:      results
  })
else
  puts bold("──────────────────────────────────────────────────────────────────────────────")
  puts bold("  Summary")
  puts "  Total audited : #{stats[:total]}"
  puts "  #{green('Pass')}         : #{stats['pass']}"
  puts "  #{yellow('Reconcile')}    : #{stats['reconcile']}"
  puts "  #{red('Quarantine')}   : #{stats['quarantine']}"
  puts "  #{cyan('Hold')}         : #{stats['hold']}"
  puts bold("==============================================================================\n")

  if stats['quarantine'].to_i > 0 || stats['reconcile'].to_i > 0
    exit 1
  end
end
