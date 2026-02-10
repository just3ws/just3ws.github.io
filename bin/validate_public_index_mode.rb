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
  html[/<meta[^>]+name=["']robots["'][^>]+content=["']([^"']+)["']/i, 1].to_s.downcase
end

def canonical_href(html)
  html[/<link[^>]+rel=["']canonical["'][^>]*href=["']([^"']+)["']/i, 1].to_s
end

def indexable?(robots)
  robots.include?('index') && !robots.include?('noindex')
end

errors = []
indexable = []

Dir.glob(File.join(SITE_DIR, '**', '*.html')).each do |path|
  relative = path.sub("#{SITE_DIR}/", '')
  next if relative.start_with?('AGENTS.')

  html = read(path)
  robots = robots_content(html)
  canonical = canonical_href(html)

  if canonical.empty?
    errors << "#{relative} missing canonical tag"
  elsif !canonical.start_with?(CANONICAL_HOST)
    errors << "#{relative} canonical must stay on #{CANONICAL_HOST}, found #{canonical}"
  elsif relative == 'index.html' && canonical != CANONICAL_ROOT
    errors << "index.html canonical must be #{CANONICAL_ROOT}, found #{canonical}"
  elsif relative == 'home/index.html' && canonical != CANONICAL_HOME
    errors << "home/index.html canonical must be #{CANONICAL_HOME}, found #{canonical}"
  end

  indexable << relative if indexable?(robots)
end

unless indexable.include?('index.html')
  errors << 'public-index violation: index.html must be indexable'
end

unless indexable.include?('home/index.html')
  errors << 'public-index violation: home/index.html must be indexable'
end

if indexable.empty?
  errors << 'public-index violation: expected at least one indexable page'
end

if errors.empty?
  puts "Public index mode validation passed (indexable=#{indexable.size})."
  exit 0
end

warn 'Public index mode validation failed:'
errors.each { |error| warn "  - #{error}" }
exit 1
