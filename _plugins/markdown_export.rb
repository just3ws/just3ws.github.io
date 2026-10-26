# frozen_string_literal: true

require 'jekyll'
require 'fileutils'
require_relative '../lib/date_display'

module Jekyll
  class MarkdownExportGenerator < Generator
    safe true
    priority :highest

    EXPORT_CONFIG = {
      '/' => { file: 'resume', data_key: 'resume' },
      '/portfolio/' => { file: 'portfolio', data_key: 'portfolio' },
      '/history/' => { file: 'history', data_key: 'history' }
    }.freeze

    def generate(site)
      EXPORT_CONFIG.each do |url, config|
        page = site.pages.find { |p| p.url == url }
        markdown_content = render_markdown(page, site, config[:data_key])

        # Write to source directory
        src_dir = File.join(site.source, "exports")
        FileUtils.mkdir_p(src_dir)
        src_file = File.join(src_dir, "#{config[:file]}.md")
        File.write(src_file, markdown_content)

        # Write to site destination output directory
        write_markdown(site, config[:file], markdown_content)
      end
    end

    private

    def wrap_markdown(output, width: 88)
      output.flat_map do |line|
        next [line] if line.empty? || line.match?(/^\#{1,6}\s/) || line.match?(/^\*\*[^:]+:\*\*\s*$/)

        prefix = line.start_with?('- ') ? '- ' : ''
        text = prefix.empty? ? line : line.delete_prefix(prefix)
        wrapped = text.scan(/.{1,#{width - prefix.length}}(?:\s+|\z)/).map(&:strip)
        wrapped = [text] if wrapped.empty?
        [prefix + wrapped.first] + wrapped.drop(1).map { |part| (' ' * prefix.length) + part }
      end
    end

    def render_markdown(page, site, data_key)
      case data_key
      when 'resume'
        render_resume_markdown(site)
      when 'portfolio'
        render_portfolio_markdown(site)
      when 'history'
        render_history_markdown(site)
      else
        page.content
      end
    end

    def render_resume_markdown(site)
      resume = site.data['resume']
      return "" unless resume

      profile = resume['profile'] || {}
      output = []
      output << "# #{site.config.dig('author', 'name') || profile['name']}"
      output << profile['title'].to_s
      output << ""

      if resume['summary']
        output << "## Professional Summary"
        output << resume['summary']['text']
        output << ""
      end

      skills = resume.dig('ats', 'skills')
      if skills && !skills.empty?
        output << "## Core Skills"
        skills.each do |skill|
          output << "- #{skill}"
        end
        output << ""
      end

      ats = resume['ats'] || {}
      public_entries = Array(ats['positions']).map { |entry| entry['id'] }.compact.uniq
      if public_entries.any?
        output << "## Experience"
        output << ""
        public_entries.each do |position_id|
          position = site.data.dig('resume', 'positions', position_id)
          next unless position

          company = position.dig('company', 'name')
          location = position.dig('company', 'location')
          title = position['title']
          start_date = DateDisplay.human(position['start_date'])
          end_date = DateDisplay.human(position['end_date'])

          output << "### #{title} at #{company}"
          output << "**#{start_date} - #{end_date}**#{location ? " | #{location}" : ""}"
          output << ""
          summary = position['summary'] || position['public_summary'] || position['description']
          output << summary.to_s.strip if summary
          output << ""

          highlights = position['highlights'] || position['public_highlights']
          if highlights && !highlights.empty?
            output << "**Key Outcomes:**"
            highlights.each do |h|
              text = h.is_a?(Hash) ? h['text'] : h
              output << "- #{text.to_s.strip}" if text
            end
            output << ""
          end

          if position['skills'] && !position['skills'].empty?
            output << "**Skills:** #{position['skills'].join(', ')}"
            output << ""
          end
        end
      end

      add_items = Array(ats.dig('additional_experience', 'items'))
      if add_items.any?
        output << "## #{ats.dig('additional_experience', 'title') || 'Earlier Career Experience'}"
        output << ""
        add_items.each do |item|
          position = site.data.dig('resume', 'positions', item['id'])
          next unless position

          company = position.dig('company', 'name')
          location = position.dig('company', 'location')
          start_date = DateDisplay.human(position['start_date'])
          end_date = DateDisplay.human(position['end_date'])
          summary_text = (item['summary'] || position['summary']).to_s.strip
          output << "- **#{position['title']}**, #{company} (#{start_date} - #{end_date}#{location ? ", #{location}" : ""}): #{summary_text}"
        end
        output << ""
      end

      leadership = resume['leadership']
      if leadership && Array(leadership['items']).any?
        output << "## #{leadership['title'] || 'Technical Leadership & Community'}"
        output << ""
        Array(leadership['items']).each do |item|
          output << "- #{item}"
        end
        output << ""
      end

      wrap_markdown(output).join("\n")
    end

    def render_portfolio_markdown(site)
      portfolio = site.data['portfolio']
      return "" unless portfolio

      output = []
      output << "# Project Portfolio"
      output << ""

      portfolio.each do |project|
        title = project['title'] || project['name'] || "Project"
        output << "## #{title}"
        output << "**Role:** #{project['role']}" if project['role']
        output << "**Years:** #{project['years'] || project['year']}" if project['years'] || project['year']
        output << ""
        output << project['description'] if project['description']
        output << ""
      end

      wrap_markdown(output).join("\n")
    end

    def render_history_markdown(site)
      resume = site.data['resume']
      return "" unless resume

      output = []
      output << "# Complete Career Timeline"
      output << ""

      history_ids = Array(site.data.dig('resume', 'timeline', 'history'))
      history_ids.each do |position_id|
        position = site.data.dig('resume', 'positions', position_id)
        next unless position

        company = position.dig('company', 'name')
        location = position.dig('company', 'location')
        title = position['title']
        start_date = DateDisplay.human(position['start_date'])
        end_date = DateDisplay.human(position['end_date'])

        output << "## #{title}"
        output << "**#{company}**#{location ? " | #{location}" : ""} | #{start_date} - #{end_date}"
        output << ""
        summary = position['summary'] || position['description']
        output << summary.to_s.strip if summary

        if position['highlights'] && !position['highlights'].empty?
          output << ""
          output << "**Highlights:**"
          position['highlights'].each do |h|
            text = h.is_a?(Hash) ? h['text'] : h
            output << "- #{text.to_s.strip}" if text
          end
        end

        output << ""
      end

      wrap_markdown(output).join("\n")
    end

    def write_markdown(site, filename, content)
      output_dir = File.join(site.dest, "exports")
      FileUtils.mkdir_p(output_dir)

      output_file = File.join(output_dir, "#{filename}.md")
      File.write(output_file, content)
      Jekyll.logger.info "Markdown Export:", "Generated #{output_file}"
    end
  end

  Jekyll::Hooks.register :site, :post_write do |site|
    src_resumes_dir = File.join(site.source, 'exports', 'resumes')
    if Dir.exist?(src_resumes_dir)
      dest_exports_dir = File.join(site.dest, 'exports', 'resumes')
      dest_resumes_dir = File.join(site.dest, 'resumes')
      FileUtils.mkdir_p(dest_exports_dir)
      FileUtils.mkdir_p(dest_resumes_dir)

      Dir.glob(File.join(src_resumes_dir, '*.{md,json,txt}')).each do |src_file|
        FileUtils.cp(src_file, File.join(dest_exports_dir, File.basename(src_file)))
        FileUtils.cp(src_file, File.join(dest_resumes_dir, File.basename(src_file)))
      end
    end
  end
end
