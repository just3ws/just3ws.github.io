#!/usr/bin/env ruby
# frozen_string_literal: true

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

positions = {}
Dir.glob(File.join(DATA_DIR, 'positions', '*.yml')).each do |pos_file|
  data = YAML.load_file(pos_file)
  next unless data
  id = data['id'] || File.basename(pos_file, '.yml')
  positions[id] = data
end

linkedin_display = profile['contact']['linkedin']['url'].sub(%r{\Ahttps?://(www\.)?}, '')

# Browsers derive the "Print to PDF" filename from <title>. Keep it plain:
# leads with the candidate's name and avoids characters FAT32/NTFS forbid
# or that just look sloppy in a saved filename (parens, slashes, ampersands).
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
  lines << profile['location']['display'] if profile['location']
  lines << ""
  lines << "- Email: [#{profile['contact']['email']}](mailto:#{profile['contact']['email']})"
  lines << "- Phone: [#{profile['contact']['phone']}](tel:#{profile['contact']['phone_tel']})"
  lines << "- Website: [#{profile['contact']['website']['display']}](#{profile['contact']['website']['url']})"
  lines << "- LinkedIn: [#{linkedin_display}](#{profile['contact']['linkedin']['url']})"
  lines << "- GitHub: [#{profile['contact']['github']['display']}](#{profile['contact']['github']['url']})"
  lines << ""
  lines << "---"
  lines << ""
  lines << "## Professional Summary"
  lines << ""
  lines << config['summary']
  lines << ""
  lines << "---"
  lines << ""
  lines << "## Core Competencies & Skills"
  lines << ""
  lines << config['core_skills'].join(", ")
  lines << ""
  lines << "---"
  lines << ""
  lines << "## Experience & Leadership"
  lines << ""
  
  featured_positions_data = []
  config['featured_positions'].each do |entry|
    pos = positions[entry['id']]
    next unless pos
    
    comp_name = pos.dig('company', 'name') || pos['company']
    loc = pos.dig('company', 'location')
    dates = "#{human_date(pos['start_date'])} - #{human_date(pos['end_date'])}"

    lines << "### #{pos['title']} at #{comp_name}"
    lines << ""
    lines << "**#{dates}**#{loc ? " | #{loc}" : ""}"
    lines << ""

    if entry['focus']
      lines << "**Target Focus:** #{entry['focus']}"
      lines << ""
    elsif pos['summary']
      lines << pos['summary']
      lines << ""
    end

    if pos['highlights'] && !pos['highlights'].empty?
      lines << "**Key Outcomes:**"
      pos['highlights'].each do |h|
        text = h.is_a?(Hash) ? h['text'] : h.to_s
        label = h.is_a?(Hash) ? h['label'] : nil
        lines << "- #{text}#{label ? " [#{label}]" : ""}"
      end
      lines << ""
    end

    featured_positions_data << {
      'id'         => entry['id'],
      'title'      => pos['title'],
      'company'    => comp_name,
      'location'   => loc,
      'dates'      => dates,
      'focus'      => entry['focus'] || pos['summary'],
      'highlights' => (pos['highlights'] || []).map { |h| h.is_a?(Hash) ? h['text'] : h.to_s }
    }
  end
  
  selected_projects_data = []
  if config['selected_projects'] && !config['selected_projects'].empty?
    lines << "---"
    lines << ""
    lines << "## Selected Production Projects"
    lines << ""
    config['selected_projects'].each do |proj_entry|
      proj = positions[proj_entry['id']]
      next unless proj
      proj_name = proj.dig('company', 'name') || proj['company'] || proj['title']
      dates = "#{human_date(proj['start_date'])} - #{human_date(proj['end_date'])}"
      lines << "### #{proj['title']} (#{proj_name})"
      lines << "**#{dates}**"
      lines << ""
      lines << proj['summary'] if proj['summary']
      lines << ""
      if proj['highlights']
        proj['highlights'].each do |h|
          text = h.is_a?(Hash) ? h['text'] : h.to_s
          lines << "- #{text}"
        end
        lines << ""
      end
      selected_projects_data << {
        'id'         => proj_entry['id'],
        'title'      => proj['title'],
        'dates'      => dates,
        'summary'    => proj['summary'],
        'highlights' => (proj['highlights'] || []).map { |h| h.is_a?(Hash) ? h['text'] : h.to_s }
      }
    end
  end
  
  additional_experience_data = []
  if config['additional_experience'] && !config['additional_experience'].empty?
    lines << "---"
    lines << ""
    lines << "## Additional Experience"
    lines << ""
    config['additional_experience'].each do |add_entry|
      pos = positions[add_entry['id']]
      next unless pos
      comp_name = pos.dig('company', 'name') || pos['company']
      dates = "#{human_date(pos['start_date'])} - #{human_date(pos['end_date'])}"
      summary_text = pos['summary'] || ""
      lines << "- **#{pos['title']}**, #{comp_name} (#{dates}): #{summary_text.strip}"
      additional_experience_data << {
        'id'      => add_entry['id'],
        'title'   => pos['title'],
        'company' => comp_name,
        'dates'   => dates,
        'summary' => summary_text.strip
      }
    end
    lines << ""
  end
  
  if ats['earlier_experience']
    earlier = ats['earlier_experience']
    lines << "---"
    lines << ""
    lines << "## #{earlier['title']}"
    lines << ""
    lines << "**#{earlier['dates']}**"
    lines << ""
    lines << earlier['summary']
    lines << ""
    earlier['items'].each do |item|
      lines << "- **#{item['label']}**: #{item['summary']}"
    end
    lines << ""
  end
  
  wrap_markdown = lambda do |source_lines, width = 88|
    source_lines.flat_map do |line|
      next [line] if line.empty? || line.match?(/^\#{1,6}\s/) || line.match?(/^\*\*[^:]+:\*\*\s*$/)

      prefix = line.start_with?('- ') ? '- ' : ''
      text = prefix.empty? ? line : line.delete_prefix(prefix)
      wrapped = text.scan(/.{1,#{width - prefix.length}}(?:\s+|\z)/).map(&:strip)
      wrapped = [text] if wrapped.empty?
      [prefix + wrapped.first] + wrapped.drop(1).map { |part| (' ' * prefix.length) + part }
    end
  end

  lines = wrap_markdown.call(lines)
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
    'summary'               => config['summary'],
    'core_skills'           => config['core_skills'],
    'experience'            => featured_positions_data,
    'projects'              => selected_projects_data,
    'additional_experience' => additional_experience_data,
    'earlier_experience'    => ats['earlier_experience']
  }
  File.write(export_json, JSON.pretty_generate(json_data))

  # ── Plaintext export ──────────────────────────────────────────────────────────
  sep  = "=" * 80
  dash = "-" * 80
  wrap = ->(text, width = 80) {
    text.to_s.gsub(/(.{1,#{width}})(\s+|\Z)/, "\\1\n").rstrip
  }

  txt_lines = []
  txt_lines << profile['name'].upcase
  txt_lines << config['title']
  txt_lines << profile.dig('location', 'display').to_s
  txt_lines << ""
  txt_lines << "Email:    #{profile['contact']['email']}"
  txt_lines << "Phone:    #{profile['contact']['phone']}"
  txt_lines << "Website:  #{profile['contact']['website']['url']}"
  txt_lines << "LinkedIn: #{profile['contact']['linkedin']['url']}"
  txt_lines << "GitHub:   #{profile['contact']['github']['url']}"
  txt_lines << ""
  txt_lines << sep
  txt_lines << "PROFESSIONAL SUMMARY"
  txt_lines << sep
  txt_lines << wrap.call(config['summary'], 76)
  txt_lines << ""
  txt_lines << sep
  txt_lines << "CORE SKILLS"
  txt_lines << sep
  txt_lines << wrap.call(config['core_skills'].join(", "))
  txt_lines << ""
  txt_lines << sep
  txt_lines << "EXPERIENCE"
  txt_lines << sep

  featured_positions_data.each do |pos|
    txt_lines << dash
    txt_lines << pos['title'].upcase
    txt_lines << "#{pos['company']}#{pos['location'] ? " | #{pos['location']}" : ""}"
    txt_lines << pos['dates']
    txt_lines << ""
    txt_lines << wrap.call(pos['focus']) if pos['focus']
    txt_lines << ""
    if pos['highlights'] && !pos['highlights'].empty?
      txt_lines << "Key Outcomes:"
      pos['highlights'].each do |h|
        txt_lines << "  * #{wrap.call(h, 76).gsub("\n", "\n    ")}"
        txt_lines << ""
      end
    end
    txt_lines << ""
  end

  unless additional_experience_data.empty?
    txt_lines << dash
    txt_lines << "ADDITIONAL EXPERIENCE"
    txt_lines << dash
    additional_experience_data.each do |e|
      txt_lines << wrap.call("* #{e['title']} | #{e['company']} (#{e['dates']})", 80)
      txt_lines << "  #{wrap.call(e['summary'], 76).gsub("\n", "\n  ")}" unless e['summary'].to_s.empty?
      txt_lines << ""
    end
    txt_lines << ""
  end

  if ats['earlier_experience']
    earlier = ats['earlier_experience']
    txt_lines << dash
    txt_lines << earlier['title'].upcase
    txt_lines << earlier['dates']
    txt_lines << ""
    txt_lines << wrap.call(earlier['summary'])
    earlier['items'].each do |item|
      txt_lines << "* #{item['label']}: #{wrap.call(item['summary'], 45).gsub("\n", "\n  ")}"
      txt_lines << ""
    end
    txt_lines << ""
  end

  txt_lines << sep
  File.write(export_txt, txt_lines.join("\n"))

  puts "  ✅ Generated: resumes/#{slug}.md | exports/resumes/#{slug}.{md,json,txt}"
end

# ── Generate ATS Import-Optimized Resume (HTML & TXT) ─────────────────────────
puts "\nGenerating ATS-first import resume (optimized strictly for ATS parseability)..."

ats_html_path = File.join(EXPORTS_DIR, 'ats-import-resume.html')
ats_txt_path  = File.join(EXPORTS_DIR, 'ats-import-resume.txt')

systems_config = archetypes['staff_systems_architect'] || archetypes['principal_systems_architect']
summary_text = systems_config['summary'].strip
skills_text = systems_config['core_skills'].join(', ')

# Build featured positions for ATS
ats_positions_html = []
systems_config['featured_positions'].each do |entry|
  pos = positions[entry['id']]
  next unless pos

  comp_name = pos.dig('company', 'name') || pos['company']
  loc = pos.dig('company', 'location')
  dates = "#{human_date(pos['start_date'])} - #{human_date(pos['end_date'])}"
  bullets = (pos['highlights'] || []).map do |h|
    text = h.is_a?(Hash) ? h['text'] : h.to_s
    "<li>#{text}</li>"
  end.join("\n      ")

  summary_p = entry['focus'] || pos['summary']

  ats_positions_html << <<~HTML
    <div class="job-entry">
      <div class="job-title">#{pos['title'].upcase}</div>
      <div class="job-company">#{comp_name}</div>
      <div class="job-meta">#{loc ? "#{loc} | " : ""}#{dates}</div>
      #{summary_p ? "<p class=\"job-summary\">#{summary_p}</p>" : ""}
      <ul class="job-bullets">
        #{bullets}
      </ul>
    </div>
  HTML
end

# Build additional experience for ATS
ats_additional_html = []
(systems_config['additional_experience'] || []).each do |entry|
  pos = positions[entry['id']]
  next unless pos
  comp_name = pos.dig('company', 'name') || pos['company']
  dates = "#{human_date(pos['start_date'])} - #{human_date(pos['end_date'])}"
  summary_text_entry = pos['summary'] || entry['summary'] || ""

  ats_additional_html << <<~HTML
    <div class="additional-entry">
      <strong>#{pos['title']}</strong> | #{comp_name} (#{dates})
      #{summary_text_entry.empty? ? "" : "<br>#{summary_text_entry}"}
    </div>
  HTML
end

# Build earlier experience for ATS
ats_earlier_html = []
if ats['earlier_experience']
  earlier = ats['earlier_experience']
  ats_earlier_html << "<p>#{earlier['summary']}</p>"
  earlier['items'].each do |item|
    ats_earlier_html << "<div class=\"additional-entry\"><strong>#{item['label']}:</strong> #{item['summary']}</div>"
  end
end

ats_document_html = <<~HTML
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>#{profile['name']} - Resume (ATS Import)</title>
  <style>
    @page {
      size: letter;
      margin: 0.45in;
    }
    *, *::before, *::after {
      box-sizing: border-box;
      margin: 0;
      padding: 0;
    }
    body {
      font-family: Arial, Helvetica, "Nimbus Sans L", sans-serif;
      font-size: 9.5pt;
      line-height: 1.35;
      color: #000000;
      background: #ffffff;
      padding: 0.25in;
      max-width: 8.5in;
      margin: 0 auto;
    }
    .candidate-header {
      margin-bottom: 10pt;
      padding-bottom: 6pt;
      border-bottom: 1.5px solid #000000;
    }
    h1.candidate-name {
      font-size: 18pt;
      font-weight: bold;
      text-transform: uppercase;
      letter-spacing: 0.5pt;
      margin-bottom: 2pt;
    }
    .candidate-title {
      font-size: 11pt;
      font-weight: bold;
      margin-bottom: 4pt;
    }
    .contact-line {
      font-size: 9pt;
      line-height: 1.4;
      color: #111111;
    }
    .contact-line a {
      color: #000000;
      text-decoration: none;
    }
    h2.section-heading {
      font-size: 10.5pt;
      font-weight: bold;
      text-transform: uppercase;
      border-bottom: 1px solid #000000;
      margin-top: 12pt;
      margin-bottom: 5pt;
      padding-bottom: 1pt;
      letter-spacing: 0.5pt;
    }
    p {
      margin-bottom: 5pt;
      font-size: 9.5pt;
    }
    .skills-block {
      margin-bottom: 6pt;
      font-size: 9.5pt;
      line-height: 1.35;
    }
    .job-entry {
      margin-bottom: 9pt;
      page-break-inside: avoid;
    }
    .job-title {
      font-size: 10pt;
      font-weight: bold;
      text-transform: uppercase;
    }
    .job-company {
      font-size: 9.5pt;
      font-weight: bold;
    }
    .job-meta {
      font-size: 9pt;
      color: #222222;
      margin-bottom: 2pt;
    }
    .job-summary {
      font-size: 9.5pt;
      margin-bottom: 3pt;
    }
    ul.job-bullets {
      margin: 2pt 0 5pt 16pt;
      padding: 0;
    }
    ul.job-bullets li {
      font-size: 9pt;
      line-height: 1.35;
      margin-bottom: 2pt;
    }
    .additional-entry {
      margin-bottom: 4pt;
      font-size: 9pt;
      line-height: 1.35;
    }
  </style>
</head>
<body>
  <header class="candidate-header">
    <h1 class="candidate-name">#{profile['name']}</h1>
    <div class="candidate-title">#{systems_config['title']}</div>
    <div class="contact-line">
      #{profile.dig('location', 'display')} &nbsp;|&nbsp;
      Email: <a href="mailto:#{profile['contact']['email']}">#{profile['contact']['email']}</a> &nbsp;|&nbsp;
      Phone: #{profile['contact']['phone']} &nbsp;|&nbsp;
      Website: #{profile['contact']['website']['url']} &nbsp;|&nbsp;
      LinkedIn: #{profile['contact']['linkedin']['url']} &nbsp;|&nbsp;
      GitHub: #{profile['contact']['github']['url']}
    </div>
  </header>

  <section>
    <h2 class="section-heading">PROFESSIONAL SUMMARY</h2>
    <p>#{summary_text}</p>
  </section>

  <section>
    <h2 class="section-heading">CORE SKILLS</h2>
    <p class="skills-block">#{skills_text}</p>
  </section>

  <section>
    <h2 class="section-heading">EXPERIENCE</h2>
    #{ats_positions_html.join("\n")}
  </section>

  <section>
    <h2 class="section-heading">ADDITIONAL EXPERIENCE</h2>
    #{ats_additional_html.join("\n")}
  </section>

  <section>
    <h2 class="section-heading">EARLIER EXPERIENCE</h2>
    #{ats_earlier_html.join("\n")}
  </section>
</body>
</html>
HTML

File.write(ats_html_path, ats_document_html)

# Also write the dedicated ATS plaintext file
systems_txt_src = File.join(EXPORTS_DIR, "#{systems_config['file_slug']}.txt")
if File.exist?(systems_txt_src)
  FileUtils.cp(systems_txt_src, ats_txt_path)
end

puts "  ✅ Generated: exports/resumes/ats-import-resume.html"
puts "  ✅ Generated: exports/resumes/ats-import-resume.txt"

puts "\nAll archetype resumes generated successfully."
