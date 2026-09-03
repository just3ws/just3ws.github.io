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
  txt_lines << wrap.call(config['summary'])
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
      pos['highlights'].each { |h| txt_lines << "  * #{wrap.call(h, 76).gsub("\n", "\n    ")}" }
    end
    txt_lines << ""
  end

  unless additional_experience_data.empty?
    txt_lines << dash
    txt_lines << "ADDITIONAL EXPERIENCE"
    txt_lines << dash
    additional_experience_data.each do |e|
      txt_lines << "* #{e['title']} | #{e['company']} (#{e['dates']})"
      txt_lines << "  #{wrap.call(e['summary'], 76).gsub("\n", "\n  ")}" unless e['summary'].to_s.empty?
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
    earlier['items'].each { |item| txt_lines << "* #{item['label']}: #{item['summary']}" }
    txt_lines << ""
  end

  txt_lines << sep
  File.write(export_txt, txt_lines.join("\n"))

  puts "  ✅ Generated: resumes/#{slug}.md | exports/resumes/#{slug}.{md,json,txt}"
end

puts "\nAll archetype resumes generated successfully."
