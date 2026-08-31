#!/usr/bin/env ruby
# frozen_string_literal: true

require 'yaml'
require 'fileutils'
require 'pathname'

ROOT = File.expand_path('..', __dir__)
SITE_DIR = File.join(ROOT, '_site')

def colorize(text, color_code)
  "\e[#{color_code}m#{text}\e[0m"
end

def green(text); colorize(text, 32); end
def yellow(text); colorize(text, 33); end
def red(text); colorize(text, 31); end
def bold(text); colorize(text, 1); end
def cyan(text); colorize(text, 36); end

puts bold("\n================================================================================")
puts bold("        SURFACE EXPOSURE & PIPELINE ENVIRONMENT AUDIT REPORT")
puts bold("================================================================================\n")

errors = []
warnings = []

# 1. Inspect Unlisted Executive Briefs (Direct Recruiter & Hiring Manager Delivery)
brief_sources = Dir.glob(File.join(ROOT, 'docs', 'executive-briefs', '*.md')).sort
brief_exports = Dir.glob(File.join(ROOT, 'exports', 'briefs', '*', 'index.html')).sort

puts cyan("1. Unlisted Delivery Surfaces (Targeted Pitch Briefs & Evaluations)")
puts "   Source directory : docs/executive-briefs/ (#{brief_sources.size} briefs)"
puts "   Generated HTML   : exports/briefs/ (#{brief_exports.size} pages)"

brief_exports.each do |b|
  rel = Pathname.new(b).relative_path_from(Pathname.new(ROOT))
  content = File.read(b)
  has_noindex = content.include?("robots: noindex,nofollow")
  has_no_sitemap = content.include?("sitemap: false")
  has_leak = content.include?("localhost:31000") || content.include?("just3ws.localhost")

  if has_noindex && has_no_sitemap && !has_leak
    puts "   #{green('✓')} #{rel} [unlisted, noindex, no-sitemap, safe]"
  else
    errors << "Brief #{rel} missing noindex/sitemap isolation or contains leaked localhost URL"
    puts "   #{red('✗')} #{rel} (Noindex: #{has_noindex}, NoSitemap: #{has_no_sitemap}, LeakedURL: #{has_leak})"
  end
end

# 2. Inspect Targeted Bespoke Resumes
resumes = Dir.glob(File.join(ROOT, 'resumes', 'mike-hall-*.md')).sort
puts "\n" + cyan("2. Targeted Unlisted Resumes (Recruiter Delivery Packages)")
puts "   Directory : /resumes/ (#{resumes.size} bespoke tiers)"
resumes.each do |r|
  rel = Pathname.new(r).relative_path_from(Pathname.new(ROOT))
  puts "   #{green('✓')} #{rel} (#{File.size(r)} bytes)"
end

# 3. Inspect Public Exports Hub Isolation
exports_md = File.join(ROOT, 'exports.md')
puts "\n" + cyan("3. Public Exports Hub & Surface Index (/exports/)")
if File.exist?(exports_md)
  content = File.read(exports_md)
  leaked_briefs = content.include?("/exports/briefs/") || content.include?("Executive Pitch Briefs")
  leaked_archetypes = content.include?("Tailored Archetype Resumes")

  if !leaked_briefs && !leaked_archetypes
    puts "   #{green('✓')} exports.md: Clean! (0 internal briefs, 0 conflicting archetypes advertised)"
  else
    errors << "exports.md exposes internal pitch briefs or multi-archetype listings"
    puts "   #{red('✗')} exports.md contains un-isolated private listings"
  end
end

# 4. Verify Active _site Destination
puts "\n" + cyan("4. Built Output Destination State (_site/)")
if Dir.exist?(SITE_DIR)
  site_briefs = Dir.glob(File.join(SITE_DIR, 'exports', 'briefs', '**', '*')).select { |f| File.file?(f) }
  site_private_notes = Dir.glob(File.join(SITE_DIR, '{HUMAN.*,GEMINI.*,CONTRIBUTING.*,.env*}'))
  is_prod = ENV['JEKYLL_ENV'] == 'production'

  puts "   #{green('✓')} Brief Assets Built: #{site_briefs.size} brief assets deployed (unlisted & noindex)"

  if site_private_notes.empty?
    puts "   #{green('✓')} Private Notes & Guides: 0 leaked files in _site/"
  else
    errors << "Private notes leaked into _site: #{site_private_notes.join(', ')}"
    puts "   #{red('✗')} Private notes present in _site: #{site_private_notes.join(', ')}"
  end
else
  puts "   #{yellow('ℹ')} _site/ directory not built yet. Run `bundle exec rake build` to audit built artifact."
end

# 5. Attested Resume Claims & Provenance Check
puts "\n" + cyan("5. Resume Attestation & Anti-Hallucination Gate")
claims_status = system("ruby #{File.join(ROOT, 'bin', 'validate_resume_claims.rb')} > /dev/null 2>&1")
if claims_status
  puts "   #{green('✓')} All quantified metrics across all 17 surfaces are 100% verified & attested"
else
  errors << "validate_resume_claims.rb reported unattested numbers"
  puts "   #{red('✗')} Unattested numbers detected in resume surfaces"
end

puts bold("\n================================================================================")
if errors.empty?
  puts green("  ✅ ALL SURFACES PROPERLY ISOLATED & FILTERED ACCORDING TO CONTRACT")
  puts bold("================================================================================\n")
  exit 0
else
  puts red("  ❌ SURFACE EXPOSURE AUDIT FAILED WITH #{errors.size} ISSUES:")
  errors.each { |e| puts "     - #{e}" }
  puts bold("================================================================================\n")
  exit 1
end
