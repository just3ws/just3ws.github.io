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

      output = []
      output << "# #{site.config['author']['name']}"
      output << resume.dig('profile', 'title')
      output << ""

      if resume['summary']
        output << "## Summary"
        output << resume['summary']['text']
        output << ""
      end

      skills = resume.dig('ats', 'skills')
      if skills && !skills.empty?
        output << "## Skills"
        skills.each do |skill|
          output << "- #{skill}"
        end
        output << ""
      end

      ats = resume['ats'] || {}
      public_entries = Array(ats['positions']).map { |entry| entry['id'] }
      public_entries += Array(ats.dig('selected_projects', 'items')).map { |entry| entry['id'] }
      public_entries = public_entries.compact.uniq
      if public_entries.any?
        output << "## Experience"
        output << ""
        public_entries.each do |position_id|
          position = site.data.dig('resume', 'positions', position_id)
          next unless position

          company = position.dig('company', 'name')
          title = position['title']
          is_recent = position['start_date'].to_s >= '2018-01-01'

          output << "### #{title} at #{company}"
          if is_recent
            start_date = DateDisplay.human(position['start_date'])
            end_date = DateDisplay.human(position['end_date'])
            output << "**#{start_date} - #{end_date}**"
          else
            output << "**Selected project**" if position['type'].to_s.casecmp('project').zero?
          end
          output << ""
          summary = position['public_summary'] || position['summary'] || position['description']
          output << summary if summary
          output << ""

          highlights = position['public_highlights'] || position['highlights']
          if highlights && !highlights.empty?
            output << "**Key Outcomes:**"
            highlights.each do |h|
              text = h.is_a?(Hash) ? h['text'] : h
              output << "- #{text}" if text
            end
            output << ""
          end

          if position['skills'] && !position['skills'].empty?
            output << "**Skills:** #{position['skills'].join(', ')}"
            output << ""
          end
        end
      end

      output.join("\n")
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

      output.join("\n")
    end

    def render_history_markdown(site)
      resume = site.data['resume']
      return "" unless resume

      output = []
      output << "# Complete Career Timeline"
      output << ""

      timeline = site.data.dig('resume', 'timeline')
      if timeline
        timeline.each do |position_id|
          position = site.data.dig('resume', 'positions', position_id)
          next unless position

          company = position.dig('company', 'name')
          title = position['title']
          start_date = DateDisplay.human(position['start_date'])
          end_date = DateDisplay.human(position['end_date'])

          output << "## #{title}"
          output << "**#{company}** | #{start_date} — #{end_date}"
          output << ""
          output << position['description'] if position['description']

          if position['highlights']
            output << ""
            output << "**Highlights:**"
            position['highlights'].each do |h|
              output << "- #{h['text']}" if h['text']
            end
          end

          output << ""
        end
      end

      output.join("\n")
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
    # Copy raw archetype resume exports to _site/exports/resumes/ and _site/resumes/
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
