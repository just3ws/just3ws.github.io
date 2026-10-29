#!/usr/bin/env ruby
# frozen_string_literal: true

# ---
# name: generate_archetype_resumes.rb
# domain: data
# purpose: Generate Archetype Resumes utility for the just3ws platform
# usage: ruby bin/generate_archetype_resumes.rb
# ---

require 'yaml'
require 'json'
require 'fileutils'
require 'time'
require_relative '../lib/date_display'

ROOT_DIR = File.expand_path('..', __dir__)
DATA_DIR = File.join(ROOT_DIR, '_data', 'resume')
RESUMES_DIR = File.join(ROOT_DIR, 'resumes')
EXPORTS_DIR = File.join(ROOT_DIR, 'exports', 'resumes')

def human_date(value)
  DateDisplay.human(value)
end

FileUtils.mkdir_p(RESUMES_DIR)
FileUtils.mkdir_p(EXPORTS_DIR)

profile = YAML.load_file(File.join(DATA_DIR, 'profile.yml'))
archetypes = YAML.load_file(File.join(DATA_DIR, 'archetypes.yml'))
ats = YAML.load_file(File.join(DATA_DIR, 'ats.yml'))
summary_yml = YAML.load_file(File.join(DATA_DIR, 'summary.yml'))
skills_yml = YAML.load_file(File.join(DATA_DIR, 'skills.yml'))
leadership_yml = YAML.load_file(File.join(DATA_DIR, 'leadership.yml'))

positions = {}
Dir.glob(File.join(DATA_DIR, 'positions', '*.yml')).each do |pos_file|
  data = YAML.load_file(pos_file)
  next unless data
  id = data['id'] || File.basename(pos_file, '.yml')
  positions[id] = data
end

linkedin_display = profile['contact']['linkedin']['url'].sub(%r{\Ahttps?://(www\.)?}, '')

def filename_safe_title(name, title)
  clean = title.to_s
                .gsub('&', 'and')
                .gsub(%r{[\\/]}, ' - ')
                .gsub(/[()]/, '')
                .gsub(/[:*?"<>|]/, '')
                .gsub(/\s{2,}/, ' ')
                .strip
  full = "#{name} - #{clean}"
  return full if full.length <= 68

  full[0...68].sub(/\s+\S*\z/, '').sub(/[\s\-,]+\z/, '')
end

puts "Generating #{archetypes.length} tailored archetype resumes under resumes/ and exports/resumes/...\n\n"

archetypes.each do |key, config|
  slug = config['file_slug']
  target_file = File.join(RESUMES_DIR, "#{slug}.md")
  export_md   = File.join(EXPORTS_DIR, "#{slug}.md")
  export_json = File.join(EXPORTS_DIR, "#{slug}.json")
  export_txt  = File.join(EXPORTS_DIR, "#{slug}.txt")

  front_matter = [
    "---",
    "layout: archetype-resume",
    "body_class: ats-resume",
    "archetype_key: #{key}",
    "title: #{filename_safe_title(profile['name'], config['title']).inspect}",
    "description: #{config['summary'].strip.inspect}",
    "canonical_url: https://www.just3ws.com/resumes/#{slug}/",
    "permalink: /resumes/#{slug}/",
    "sitemap: true",
    "robots: index,follow",
    "---",
    ""
  ]

  lines = []
  lines << "# #{profile['name']}"
  lines << ""
  lines << "**#{config['title']}**"
  lines << "#{profile['location']['display']} | [#{profile['contact']['email']}](mailto:#{profile['contact']['email']}) | #{profile['contact']['phone']} | [#{profile['contact']['website']['display']}](#{profile['contact']['website']['url']}) | [#{linkedin_display}](#{profile['contact']['linkedin']['url']}) | [#{profile['contact']['github']['display']}](#{profile['contact']['github']['url']})"
  lines << ""
  lines << "## Professional Summary"
  lines << ""
  lines << config['summary'].to_s.strip
  lines << ""
  lines << "## Core Skills"
  lines << ""
  lines << config['core_skills'].join(", ")
  lines << ""
  lines << "## Experience"
  lines << ""

  featured_positions_data = []
  Array(config['featured_positions']).each do |entry|
    pos = positions[entry['id']]
    next unless pos

    comp_name = pos.dig('company', 'name') || pos['company']
    loc = pos.dig('company', 'location')
    dates = "#{human_date(pos['start_date'])} - #{human_date(pos['end_date'])}"

    lines << "### #{pos['title']}"
    lines << "**#{comp_name}**#{loc ? " | #{loc}" : ""} | #{dates}"
    lines << ""

    focus_text = (entry['focus'] || pos['summary']).to_s.strip
    unless focus_text.empty?
      lines << focus_text
      lines << ""
    end

    if pos['highlights'] && !pos['highlights'].empty?
      lines << "**Key Outcomes:**"
      pos['highlights'].each do |h|
        text = (h.is_a?(Hash) ? h['text'] : h.to_s).strip
        lines << "- #{text}"
      end
      lines << ""
    end

    featured_positions_data << {
      'id'         => entry['id'],
      'title'      => pos['title'],
      'company'    => comp_name,
      'location'   => loc,
      'dates'      => dates,
      'focus'      => focus_text,
      'highlights' => (pos['highlights'] || []).map { |h| (h.is_a?(Hash) ? h['text'] : h.to_s).strip }
    }
  end

  additional_experience_data = []
  if config['additional_experience'] && !config['additional_experience'].empty?
    lines << "## Earlier Career Experience"
    lines << ""
    config['additional_experience'].each do |add_entry|
      pos = positions[add_entry['id']]
      next unless pos
      comp_name = pos.dig('company', 'name') || pos['company']
      loc = pos.dig('company', 'location')
      dates = "#{human_date(pos['start_date'])} - #{human_date(pos['end_date'])}"
      summary_text = (add_entry['summary'] || pos['summary'] || "").to_s.strip
      lines << "- **#{pos['title']}** | **#{comp_name}**#{loc ? " | #{loc}" : ""} | #{dates}: #{summary_text}"
      additional_experience_data << {
        'id'       => add_entry['id'],
        'title'    => pos['title'],
        'company'  => comp_name,
        'location' => loc,
        'dates'    => dates,
        'summary'  => summary_text
      }
    end
    lines << ""
  end

  if leadership_yml && Array(leadership_yml['items']).any?
    lines << "## #{leadership_yml['title'] || 'Technical Leadership & Community'}"
    lines << ""
    Array(leadership_yml['items']).each do |item|
      lines << "- #{item}"
    end
    lines << ""
  end

  raw_content = lines.join("\n")
  html_page_content = (front_matter + lines).join("\n")
  File.write(target_file, html_page_content)
  File.write(export_md, raw_content)

  # ── JSON export ───────────────────────────────────────────────────────────────
  json_data = {
    'meta' => {
      'generated_at' => Time.now.utc.iso8601,
      'archetype'    => key,
      'slug'         => slug,
      'target_tier'  => config['target_tier']
    },
    'basics' => {
      'name'     => profile['name'],
      'title'    => config['title'],
      'location' => profile.dig('location', 'display'),
      'email'    => profile['contact']['email'],
      'phone'    => profile['contact']['phone'],
      'website'  => profile['contact']['website']['url'],
      'linkedin' => profile['contact']['linkedin']['url'],
      'github'   => profile['contact']['github']['url']
    },
    'summary'               => config['summary'].to_s.strip,
    'core_skills'           => config['core_skills'],
    'experience'            => featured_positions_data,
    'additional_experience' => additional_experience_data,
    'leadership'            => leadership_yml ? leadership_yml['items'] : []
  }
  File.write(export_json, JSON.pretty_generate(json_data))

  # ── Plaintext export (Simple, single-column, Title Case, zero ASCII banners) ──
  txt_lines = []
  txt_lines << profile['name']
  txt_lines << config['title']
  txt_lines << profile.dig('location', 'display').to_s
  txt_lines << "Email: #{profile['contact']['email']}"
  txt_lines << "Phone: #{profile['contact']['phone']}"
  txt_lines << "Website: #{profile['contact']['website']['url']}"
  txt_lines << "LinkedIn: #{profile['contact']['linkedin']['url']}"
  txt_lines << "GitHub: #{profile['contact']['github']['url']}"
  txt_lines << ""
  txt_lines << "Professional Summary"
  txt_lines << ""
  txt_lines << config['summary'].to_s.strip
  txt_lines << ""
  txt_lines << "Core Skills"
  txt_lines << ""
  txt_lines << config['core_skills'].join(", ")
  txt_lines << ""
  txt_lines << "Experience"
  txt_lines << ""

  featured_positions_data.each do |pos|
    txt_lines << pos['title']
    txt_lines << "#{pos['company']}#{pos['location'] ? " | #{pos['location']}" : ""} | #{pos['dates']}"
    txt_lines << ""
    txt_lines << pos['focus'] unless pos['focus'].to_s.empty?
    txt_lines << ""
    if pos['highlights'] && !pos['highlights'].empty?
      txt_lines << "Key Outcomes:"
      pos['highlights'].each do |h|
        txt_lines << "- #{h}"
      end
      txt_lines << ""
    end
  end

  unless additional_experience_data.empty?
    txt_lines << "Earlier Career Experience"
    txt_lines << ""
    additional_experience_data.each do |e|
      txt_lines << "- #{e['title']} | #{e['company']}#{e['location'] ? " | #{e['location']}" : ""} | #{e['dates']}: #{e['summary']}"
    end
    txt_lines << ""
  end

  if leadership_yml && Array(leadership_yml['items']).any?
    txt_lines << (leadership_yml['title'] || "Technical Leadership & Community")
    txt_lines << ""
    Array(leadership_yml['items']).each do |item|
      txt_lines << "- #{item}"
    end
    txt_lines << ""
  end

  File.write(export_txt, txt_lines.join("\n"))

  puts "  ✅ Generated: resumes/#{slug}.md | exports/resumes/#{slug}.{md,json,txt}"
end

# ── Generate ATS Import-Optimized Resume (HTML & TXT) ─────────────────────────
puts "\nGenerating ATS-first import resume (optimized strictly for ATS parseability)..."

ats_html_path = File.join(EXPORTS_DIR, 'ats-import-resume.html')
ats_txt_path  = File.join(EXPORTS_DIR, 'ats-import-resume.txt')

canonical_summary = summary_yml['text'].to_s.strip
skills_categories = Array(skills_yml['categories'])

ats_skills_html = skills_categories.map do |cat|
  "<li><strong>#{cat['name']}:</strong> #{Array(cat['items']).join(', ')}</li>"
end.join("\n      ")

ats_positions_html = []
ats_positions_txt = []

Array(ats['positions']).each do |entry|
  pos = positions[entry['id']]
  next unless pos

  comp_name = pos.dig('company', 'name') || pos['company']
  loc = pos.dig('company', 'location')
  dates = "#{human_date(pos['start_date'])} - #{human_date(pos['end_date'])}"
  summary_p = pos['summary'].to_s.strip

  bullets_html = (pos['highlights'] || []).map do |h|
    text = (h.is_a?(Hash) ? h['text'] : h.to_s).strip
    if text.include?(': ')
      lead, rest = text.split(': ', 2)
      "<li><strong>#{lead}:</strong> #{rest}</li>"
    else
      "<li>#{text}</li>"
    end
  end.join("\n        ")

  ats_positions_html << <<~HTML
    <div class="job-entry">
      <h3 class="job-title">#{pos['title']}</h3>
      <p class="job-meta"><strong>#{comp_name}</strong>#{loc ? " | #{loc}" : ""} | #{dates}</p>
      #{summary_p.empty? ? "" : "<p class=\"job-summary\">#{summary_p}</p>"}
      <ul class="job-bullets">
        #{bullets_html}
      </ul>
    </div>
  HTML

  ats_positions_txt << pos['title']
  ats_positions_txt << "#{comp_name}#{loc ? " | #{loc}" : ""} | #{dates}"
  ats_positions_txt << ""
  ats_positions_txt << summary_p unless summary_p.empty?
  ats_positions_txt << ""
  if pos['highlights'] && !pos['highlights'].empty?
    ats_positions_txt << "Key Outcomes:"
    pos['highlights'].each do |h|
      text = (h.is_a?(Hash) ? h['text'] : h.to_s).strip
      ats_positions_txt << "- #{text}"
    end
    ats_positions_txt << ""
  end
end

ats_additional_html = []
ats_additional_txt = []
Array(ats.dig('additional_experience', 'items')).each do |entry|
  pos = positions[entry['id']]
  next unless pos
  comp_name = pos.dig('company', 'name') || pos['company']
  loc = pos.dig('company', 'location')
  dates = "#{human_date(pos['start_date'])} - #{human_date(pos['end_date'])}"
  summary_text_entry = (entry['summary'] || pos['summary'] || "").to_s.strip

  ats_additional_html << <<~HTML
    <li><strong>#{pos['title']}</strong> | <strong>#{comp_name}</strong>#{loc ? " | #{loc}" : ""} | #{dates}: #{summary_text_entry}</li>
  HTML
  ats_additional_txt << "- #{pos['title']} | #{comp_name}#{loc ? " | #{loc}" : ""} | #{dates}: #{summary_text_entry}"
end

ats_leadership_html = Array(leadership_yml['items']).map { |item| "<li>#{item}</li>" }.join("\n      ")
ats_leadership_txt = Array(leadership_yml['items']).map { |item| "- #{item}" }

ats_document_html = <<~HTML
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>#{profile['name']} - #{profile['title']} Resume</title>
  <style>
    @page {
      size: letter;
      margin: 0.45in;
    }
    *, *::before, *::after {
      box-sizing: border-box;
      margin: 0;
      padding: 0;
      letter-spacing: normal;
      text-transform: none;
    }
    body {
      font-family: Arial, Helvetica, sans-serif;
      font-size: 9.5pt;
      line-height: 1.35;
      color: #000000;
      background: #ffffff;
      padding: 0.2in;
      max-width: 8.5in;
      margin: 0 auto;
    }
    .candidate-header {
      margin-bottom: 10pt;
      padding-bottom: 6pt;
      border-bottom: 1px solid #000000;
    }
    h1.candidate-name {
      font-size: 16pt;
      font-weight: bold;
      margin-bottom: 2pt;
    }
    .candidate-title {
      font-size: 11pt;
      font-weight: bold;
      margin-bottom: 3pt;
    }
    .contact-line {
      font-size: 9pt;
      line-height: 1.4;
      color: #111111;
      margin-bottom: 1pt;
    }
    .contact-line a {
      color: #000000;
      text-decoration: none;
    }
    h2.section-heading {
      font-size: 11pt;
      font-weight: bold;
      border-bottom: 1px solid #000000;
      margin-top: 10pt;
      margin-bottom: 5pt;
      padding-bottom: 2pt;
    }
    p {
      margin-bottom: 4pt;
      font-size: 9.5pt;
    }
    .job-entry {
      margin-bottom: 8pt;
    }
    h3.job-title {
      font-size: 10pt;
      font-weight: bold;
      margin-bottom: 1pt;
    }
    p.job-meta {
      font-size: 9pt;
      color: #111111;
      margin-bottom: 3pt;
    }
    p.job-summary {
      font-size: 9pt;
      margin-bottom: 3pt;
    }
    ul.job-bullets {
      margin: 2pt 0 5pt 15pt;
      padding: 0;
      list-style-type: disc;
    }
    ul.job-bullets li {
      font-size: 9pt;
      line-height: 1.32;
      margin-bottom: 2.5pt;
    }
  </style>
</head>
<body>
  <header class="candidate-header">
    <h1 class="candidate-name">#{profile['name']}</h1>
    <p class="candidate-title">#{profile['title']}</p>
    <address>
      <p class="contact-line">Location: #{profile.dig('location', 'display')}</p>
      <p class="contact-line">Email: <a href="mailto:#{profile['contact']['email']}">#{profile['contact']['email']}</a></p>
      <p class="contact-line">Phone: #{profile['contact']['phone']}</p>
      <p class="contact-line">Website: <a href="#{profile['contact']['website']['url']}">#{profile['contact']['website']['url']}</a></p>
      <p class="contact-line">LinkedIn: <a href="#{profile['contact']['linkedin']['url']}">#{profile['contact']['linkedin']['url']}</a></p>
      <p class="contact-line">GitHub: <a href="#{profile['contact']['github']['url']}">#{profile['contact']['github']['url']}</a></p>
    </address>
  </header>

  <section>
    <h2 class="section-heading">Professional Summary</h2>
    <p>#{canonical_summary}</p>
  </section>

  <section>
    <h2 class="section-heading">Core Skills</h2>
    <ul class="job-bullets">
      #{ats_skills_html}
    </ul>
  </section>

  <section>
    <h2 class="section-heading">Experience</h2>
    #{ats_positions_html.join("\n")}
  </section>

  <section>
    <h2 class="section-heading">#{ats.dig('additional_experience', 'title') || 'Earlier Career Experience'}</h2>
    <ul class="job-bullets">
      #{ats_additional_html.join("\n      ")}
    </ul>
  </section>

  <section>
    <h2 class="section-heading">#{leadership_yml['title'] || 'Technical Leadership & Community'}</h2>
    <ul class="job-bullets">
      #{ats_leadership_html}
    </ul>
  </section>
</body>
</html>
HTML

File.write(ats_html_path, ats_document_html)

ats_txt_lines = []
ats_txt_lines << profile['name']
ats_txt_lines << profile['title']
ats_txt_lines << profile.dig('location', 'display').to_s
ats_txt_lines << "Email: #{profile['contact']['email']}"
ats_txt_lines << "Phone: #{profile['contact']['phone']}"
ats_txt_lines << "Website: #{profile['contact']['website']['url']}"
ats_txt_lines << "LinkedIn: #{profile['contact']['linkedin']['url']}"
ats_txt_lines << "GitHub: #{profile['contact']['github']['url']}"
ats_txt_lines << ""
ats_txt_lines << "Professional Summary"
ats_txt_lines << ""
ats_txt_lines << canonical_summary
ats_txt_lines << ""
ats_txt_lines << "Core Skills"
ats_txt_lines << ""
skills_categories.each do |cat|
  ats_txt_lines << "- #{cat['name']}: #{Array(cat['items']).join(', ')}"
end
ats_txt_lines << ""
ats_txt_lines << "Experience"
ats_txt_lines << ""
ats_txt_lines.concat(ats_positions_txt)
ats_txt_lines << (ats.dig('additional_experience', 'title') || "Earlier Career Experience")
ats_txt_lines << ""
ats_txt_lines.concat(ats_additional_txt)
ats_txt_lines << ""
ats_txt_lines << (leadership_yml['title'] || "Technical Leadership & Community")
ats_txt_lines << ""
ats_txt_lines.concat(ats_leadership_txt)

File.write(ats_txt_path, ats_txt_lines.join("\n") + "\n")

puts "  ✅ Generated: exports/resumes/ats-import-resume.html"
puts "  ✅ Generated: exports/resumes/ats-import-resume.txt"

puts "\nAll archetype resumes generated successfully."
