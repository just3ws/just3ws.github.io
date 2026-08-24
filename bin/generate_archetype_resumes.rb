#!/usr/bin/env ruby
# frozen_string_literal: true

require 'yaml'
require 'fileutils'

ROOT_DIR = File.expand_path('..', __dir__)
DATA_DIR = File.join(ROOT_DIR, '_data', 'resume')
RESUMES_DIR = File.join(ROOT_DIR, 'resumes')
EXPORTS_DIR = File.join(ROOT_DIR, 'exports', 'resumes')

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

puts "Generating #{archetypes.length} tailored archetype resumes under resumes/ and exports/resumes/...\n\n"

archetypes.each do |key, config|
  slug = config['file_slug']
  target_file = File.join(RESUMES_DIR, "#{slug}.md")
  export_file = File.join(EXPORTS_DIR, "#{slug}.md")
  
  front_matter = [
    "---",
    "layout: archetype-resume",
    "body_class: ats-resume",
    "title: #{config['title'].inspect}",
    "description: #{config['summary'][0..150].strip.inspect}",
    "permalink: /resumes/#{slug}/",
    "sitemap: false",
    "robots: noindex,nofollow",
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
  
  config['featured_positions'].each do |entry|
    pos = positions[entry['id']]
    next unless pos
    
    comp_name = pos.dig('company', 'name') || pos['company']
    loc = pos.dig('company', 'location')
    dates = "#{pos['start_date']} - #{pos['end_date'] || 'Present'}"
    
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
  end
  
  if config['selected_projects'] && !config['selected_projects'].empty?
    lines << "---"
    lines << ""
    lines << "## Selected Production Projects"
    lines << ""
    config['selected_projects'].each do |proj_entry|
      proj = positions[proj_entry['id']]
      next unless proj
      proj_name = proj.dig('company', 'name') || proj['company'] || proj['title']
      dates = "#{proj['start_date']} - #{proj['end_date'] || 'Present'}"
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
    end
  end
  
  if config['additional_experience'] && !config['additional_experience'].empty?
    lines << "---"
    lines << ""
    lines << "## Additional Experience"
    lines << ""
    config['additional_experience'].each do |add_entry|
      pos = positions[add_entry['id']]
      next unless pos
      comp_name = pos.dig('company', 'name') || pos['company']
      dates = "#{pos['start_date']} - #{pos['end_date'] || 'Present'}"
      summary_text = pos['summary'] || ""
      lines << "- **#{pos['title']}**, #{comp_name} (#{dates}): #{summary_text.strip}"
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
  File.write(export_file, raw_content)
  puts "  ✅ Generated: resumes/#{slug}.md (HTML page) and exports/resumes/#{slug}.md (Raw MD)"
end

puts "\nAll archetype resumes generated successfully."
