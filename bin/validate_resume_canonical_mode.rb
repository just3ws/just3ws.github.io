#!/usr/bin/env ruby

ROOT = File.expand_path('..', __dir__)
SITE_DIR = File.join(ROOT, '_site')
CANONICAL_ROOT = 'https://www.just3ws.com/'
CANONICAL_HOME = 'https://www.just3ws.com/home/'
CANONICAL_HOST = 'https://www.just3ws.com'

def read(path)
  File.read(path)
end

def robots_content(html)
  html[/<meta[^>]+name=["']robots["'][^>]+content=["']([^"']+)["']/i, 1]
end

def canonical_href(html)
  html[/<link[^>]+rel=["']canonical["'][^>]*href=["']([^"']+)["']/i, 1]
end

errors = []
indexable = []

Dir.glob(File.join(SITE_DIR, '**', '*.html')).each do |path|
  relative = path.sub("#{SITE_DIR}/", '')
  next if relative.start_with?('AGENTS.')

  html = read(path)
  robots = robots_content(html).to_s.downcase
  canonical = canonical_href(html).to_s

  if canonical.empty?
    errors << "#{relative} missing canonical tag"
  elsif !canonical.start_with?(CANONICAL_HOST)
    errors << "#{relative} canonical must stay on #{CANONICAL_HOST}, found #{canonical}"
  elsif relative == 'index.html' && canonical != CANONICAL_ROOT
    errors << "index.html canonical must be #{CANONICAL_ROOT}, found #{canonical}"
  elsif relative == 'home/index.html' && canonical != CANONICAL_HOME
    errors << "home/index.html canonical must be #{CANONICAL_HOME}, found #{canonical}"
  end

  if robots.include?('index') && !robots.include?('noindex')
    indexable << relative
  end
end

if indexable != ['index.html']
  errors << "resume-canonical violation: expected only index.html to be indexable, found #{indexable.sort.join(', ')}"
end

if errors.empty?
  puts 'Resume canonical mode validation passed.'
  exit 0
end

warn 'Resume canonical mode validation failed:'
errors.each { |error| warn "  - #{error}" }
exit 1
