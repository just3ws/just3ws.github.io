#!/usr/bin/env ruby
require 'set'

ROOT = File.expand_path('..', __dir__)
SITE_DIR = File.join(ROOT, '_site')
CANONICAL_PREFIX = 'https://www.just3ws.com'

def read(path)
  File.read(path, encoding: 'UTF-8')
end

def noindex?(html)
  html.match?(/<meta[^>]+name=["']robots["'][^>]+content=["'][^"']*noindex/i)
end

def canonical_href(html)
  html[/<link[^>]+rel=["']canonical["'][^>]*href=["']([^"']+)["']/i, 1]
end

errors = []
checked_indexable = 0
checked_noindex = 0

html_files = Dir.glob(File.join(SITE_DIR, '**', '*.html'))
html_files.each do |path|
  relative = path.sub("#{SITE_DIR}/", '')
  next if relative.start_with?('AGENTS.')
  next if relative.start_with?('backlog/')

  html = read(path)
  canonical = canonical_href(html)

  if noindex?(html)
    checked_noindex += 1
    if relative == 'resume-minimal.html' || relative == 'resume-minimal/index.html'
      errors << "#{relative} is redirect-like but missing canonical tag" if canonical.nil?
    end
    next
  end

  checked_indexable += 1
  if canonical.nil? || canonical.empty?
    errors << "#{relative} missing canonical tag"
    next
  end
  unless canonical.start_with?(CANONICAL_PREFIX)
    errors << "#{relative} has non-canonical-host href: #{canonical}"
  end

  # SEO Best Practice 1: Every indexable page must have exactly one <h1> tag
  h1_count = html.scan(/<h1[\s>]/i).size
  if h1_count == 0
    errors << "#{relative} has zero <h1> tags"
  elsif h1_count > 1
    errors << "#{relative} has multiple (#{h1_count}) <h1> tags"
  end

  # SEO Best Practice 2: All <img> tags must have an alt attribute
  html.scan(/<img\s+[^>]*>/i).each do |img_tag|
    unless img_tag.match?(/alt=["']/i) || img_tag.match?(/role=["']presentation["']/i) || img_tag.match?(/aria-hidden=["']true["']/i)
      errors << "#{relative} has image missing alt attribute: #{img_tag[0..60]}"
    end
  end
end

sitemap_path = File.join(SITE_DIR, 'sitemap.xml')
if File.file?(sitemap_path)
  sitemap = read(sitemap_path)
  ['resume-minimal.html', 'resume-minimal/'].each do |disallowed|
    if sitemap.include?(disallowed)
      errors << "sitemap includes redirect/noindex path: #{disallowed}"
    end
  end
else
  errors << 'missing sitemap.xml'
end

if errors.empty?
  puts "SEO output validation passed (indexable=#{checked_indexable}, noindex=#{checked_noindex})."
  exit 0
end

warn 'SEO output validation failed:'
errors.each { |error| warn "  - #{error}" }
exit 1
