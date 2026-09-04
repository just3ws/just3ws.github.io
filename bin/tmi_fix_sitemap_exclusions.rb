#!/usr/bin/env ruby
# frozen_string_literal: true

# bin/tmi_fix_sitemap_exclusions.rb
#
# Deterministically finds source files that have `noindex` or `nofollow` in
# their rendered HTML (or are in known-private directories) but lack
# `sitemap: false` in their Jekyll YAML front matter, then adds it.
#
# This is safe to run repeatedly (idempotent).
#
# Usage:
#   ruby bin/tmi_fix_sitemap_exclusions.rb [--dry-run] [--verbose]

require 'pathname'
require 'optparse'

ROOT     = Pathname.new(File.expand_path('..', __dir__))
SITE_DIR = ROOT / '_site'

options = { dry_run: false, verbose: false }
OptionParser.new do |o|
  o.on('--dry-run')  { options[:dry_run] = true }
  o.on('--verbose')  { options[:verbose] = true }
end.parse!

DRY = options[:dry_run]
VBZ = options[:verbose]

def colorize(t, c); "\e[#{c}m#{t}\e[0m"; end
def green(t);  colorize(t, 32); end
def yellow(t); colorize(t, 33); end
def red(t);    colorize(t, 31); end
def cyan(t);   colorize(t, 36); end
def bold(t);   colorize(t, 1);  end

# ─────────────────────────────────────────────────────────────────────────────
# 1. Source files that are known-private by path convention
# ─────────────────────────────────────────────────────────────────────────────
PRIVATE_PATH_PATTERNS = [
  %r{^docs/executive-briefs/},
  %r{^docs/interview-prep/},
  %r{^docs/career-strategy-audhd},
  %r{^exports/briefs/(?!index)},   # individual brief pages, not the hub index
  %r{^exports/reports/},
].freeze

def private_by_path?(rel_path)
  PRIVATE_PATH_PATTERNS.any? { |pat| rel_path.match?(pat) }
end

# ─────────────────────────────────────────────────────────────────────────────
# 2. Find built HTML files that have noindex in <meta name="robots">
# ─────────────────────────────────────────────────────────────────────────────
def noindex_in_html?(html)
  # Match <meta name="robots" content="...noindex...">
  html.match?(%r{<meta[^>]+name=["']robots["'][^>]+content=["'][^"']*noindex}i) ||
    html.match?(%r{<meta[^>]+content=["'][^"']*noindex[^"']*["'][^>]+name=["']robots["']}i)
end

# ─────────────────────────────────────────────────────────────────────────────
# 3. Map a built HTML path back to its Jekyll source file
# ─────────────────────────────────────────────────────────────────────────────
def source_for(built_html_path)
  rel = built_html_path.relative_path_from(SITE_DIR)

  # Candidates in order of likelihood
  candidates = []

  if rel.to_s.end_with?('/index.html')
    base = rel.to_s.sub('/index.html', '')
    candidates << ROOT / "#{base}.md"
    candidates << ROOT / "#{base}.html"
    candidates << ROOT / "#{base}/index.md"
    candidates << ROOT / "#{base}/index.html"
  else
    base = rel.to_s.sub('.html', '')
    candidates << ROOT / "#{base}.md"
    candidates << ROOT / "#{base}.html"
  end

  candidates.find(&:exist?)
end

# ─────────────────────────────────────────────────────────────────────────────
# 4. Parse YAML front matter from a source file
# ─────────────────────────────────────────────────────────────────────────────
def has_front_matter?(content)
  content.start_with?("---\n") || content.start_with?("---\r\n")
end

def sitemap_false_in_fm?(content)
  return false unless has_front_matter?(content)
  # Extract front matter block
  fm = content[/\A---\n(.*?)\n---/m, 1] || content[/\A---\r\n(.*?)\r?\n---/m, 1]
  return false unless fm
  fm.match?(/^sitemap:\s*false/i)
end

# ─────────────────────────────────────────────────────────────────────────────
# 5. Add `sitemap: false` to a source file's front matter (or create one)
# ─────────────────────────────────────────────────────────────────────────────
def patch_source_file(path, verbose: false)
  content = File.read(path, encoding: 'utf-8')

  if has_front_matter?(content)
    # Inject into existing front matter after the opening ---
    patched = content.sub(/(\A---\n)/, "\\1sitemap: false\n")
    puts "  #{yellow('patching')} #{path.relative_path_from(ROOT)}" if verbose
    File.write(path, patched, encoding: 'utf-8')
  else
    # Prepend a new front matter block
    patched = "---\nsitemap: false\n---\n#{content}"
    puts "  #{yellow('prepending FM')} #{path.relative_path_from(ROOT)}" if verbose
    File.write(path, patched, encoding: 'utf-8')
  end
end

# ─────────────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────────────
abort "_site/ does not exist. Run `bundle exec jekyll build` first." unless SITE_DIR.exist?

puts bold("\n==============================================================================")
puts bold("  TMI Sitemap Exclusion Fixer#{DRY ? ' (DRY RUN)' : ''}")
puts bold("==============================================================================\n")

fixed   = []
skipped = []
errors  = []

# Walk all HTML files in _site
built_files = SITE_DIR.glob('**/*.html').sort

built_files.each do |built|
  rel = built.relative_path_from(SITE_DIR).to_s
  html = File.read(built, encoding: 'utf-8', invalid: :replace, undef: :replace)

  has_noindex = noindex_in_html?(html)
  is_private  = private_by_path?(rel)

  next unless has_noindex || is_private

  src = source_for(built)
  unless src
    errors << "#{rel}: noindex in HTML but no source file found"
    puts "  #{red('no source')} #{rel}" if VBZ
    next
  end

  src_content = File.read(src, encoding: 'utf-8', invalid: :replace, undef: :replace)

  if sitemap_false_in_fm?(src_content)
    skipped << src.relative_path_from(ROOT).to_s
    puts "  #{green('already OK')} #{src.relative_path_from(ROOT)}" if VBZ
    next
  end

  reason = []
  reason << 'noindex in HTML' if has_noindex
  reason << 'private path'    if is_private

  if DRY
    puts "  #{cyan('would fix')} #{src.relative_path_from(ROOT)}  [#{reason.join(', ')}]"
  else
    begin
      patch_source_file(src, verbose: VBZ)
      fixed << src.relative_path_from(ROOT).to_s
      puts "  #{green('fixed')} #{src.relative_path_from(ROOT)}  [#{reason.join(', ')}]"
    rescue => e
      errors << "#{src.relative_path_from(ROOT)}: #{e.message}"
      puts "  #{red('error')} #{src.relative_path_from(ROOT)}: #{e.message}"
    end
  end
end

puts bold("\n──────────────────────────────────────────────────────────────────────────────")
puts "  #{DRY ? 'Would fix' : 'Fixed'} : #{fixed.size}"
puts "  Already OK : #{skipped.size}"
puts "  Errors     : #{errors.size}"

if errors.any?
  puts "\n  Errors:"
  errors.each { |e| puts "    #{red(e)}" }
end

puts bold("==============================================================================\n")

unless DRY || fixed.empty?
  puts yellow("  Run `bundle exec jekyll build` to regenerate sitemap.xml with exclusions applied.")
end

exit(errors.any? ? 1 : 0)
