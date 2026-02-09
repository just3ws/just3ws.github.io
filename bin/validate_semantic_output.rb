#!/usr/bin/env ruby

ROOT = File.expand_path('..', __dir__)
SITE_DIR = File.join(ROOT, '_site')

def read(path)
  File.read(path)
end

def match_count(text, regex)
  text.scan(regex).size
end

errors = []
checked = 0

Dir.glob(File.join(SITE_DIR, '**', '*.html')).sort.each do |path|
  relative = path.sub("#{SITE_DIR}/", '')
  next if relative.start_with?('AGENTS.')
  next if relative == 'resume-minimal.html' || relative == 'resume-minimal/index.html'

  html = read(path)
  checked += 1

  errors << "#{relative} missing html[lang]" unless html.match?(/<html[^>]+lang=["'][^"']+["']/i)
  errors << "#{relative} missing skip-link" unless html.match?(/<a[^>]+class=["'][^"']*\bskip-link\b[^"']*["']/i)
  errors << "#{relative} missing main target id=\"main-content\"" unless html.match?(/<main[^>]+id=["']main-content["']/i)

  main_count = match_count(html, /<main\b/i)
  errors << "#{relative} expected exactly one <main>, found #{main_count}" unless main_count == 1

  h1_count = match_count(html, /<h1\b/i)
  errors << "#{relative} expected exactly one <h1>, found #{h1_count}" unless h1_count == 1

  html.scan(/<img\b[^>]*>/i).each do |img_tag|
    errors << "#{relative} has <img> missing alt attribute" unless img_tag.match?(/\balt=["'][^"']*["']/i)
  end

  html.scan(/<nav\b[^>]*>/i).each do |nav_tag|
    next if nav_tag.match?(/\baria-label=["'][^"']+["']/i)
    next if nav_tag.match?(/\baria-labelledby=["'][^"']+["']/i)

    errors << "#{relative} has <nav> without aria-label/aria-labelledby"
  end
end

index_html = read(File.join(SITE_DIR, 'index.html'))
unless index_html.match?(/<script[^>]+type=["']application\/ld\+json["'][^>]*>.*"@type"\s*:\s*"Person".*<\/script>/mi)
  errors << 'index.html missing Person JSON-LD'
end

home_html_path = File.join(SITE_DIR, 'home', 'index.html')
if File.file?(home_html_path)
  home_html = read(home_html_path)
  if home_html.match?(/<script[^>]+type=["']application\/ld\+json["'][^>]*>.*"@type"\s*:\s*"Person".*<\/script>/mi)
    errors << 'home/index.html should not expose Person JSON-LD'
  end
end

Dir.glob(File.join(SITE_DIR, 'videos', '**', 'index.html')).sort.each do |path|
  relative = path.sub("#{SITE_DIR}/", '')
  next if relative == 'videos/index.html'
  html = read(path)
  unless html.match?(/<script[^>]+type=["']application\/ld\+json["'][^>]*>.*"@type"\s*:\s*"VideoObject".*<\/script>/mi)
    errors << "#{relative} missing VideoObject JSON-LD"
  end
end

Dir.glob(File.join(SITE_DIR, '[0-9][0-9][0-9][0-9]', '**', '*.html')).sort.each do |path|
  relative = path.sub("#{SITE_DIR}/", '')
  html = read(path)
  unless html.match?(/<script[^>]+type=["']application\/ld\+json["'][^>]*>.*"@type"\s*:\s*"Article".*<\/script>/mi)
    errors << "#{relative} missing Article JSON-LD"
  end
end

if errors.empty?
  puts "Semantic output validation passed (checked=#{checked})."
  exit 0
end

warn 'Semantic output validation failed:'
errors.each { |error| warn "  - #{error}" }
exit 1
