#!/usr/bin/env ruby
require 'set'

ROOT = File.expand_path('..', __dir__)
SITE_DIR = File.join(ROOT, '_site')
CANONICAL_PREFIX = 'https://www.just3ws.com'

def read(path)
  File.read(path)
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
