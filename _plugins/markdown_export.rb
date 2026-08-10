# frozen_string_literal: true

require 'jekyll'
require 'fileutils'

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

        # Register StaticFile so Jekyll site.write phase writes/preserves it in destination
        site.static_files << Jekyll::StaticFile.new(site, site.source, "exports", "#{config[:file]}.md")

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
      output << site.config['description']
      output << ""

      if resume['summary']
        output << "## Summary"
        output << resume['summary']['text']
        output << ""
      end

      if resume['skills']
        output << "## Skills"
        resume['skills'].each do |skill|
          output << "- #{skill}"
        end
        output << ""
      end

      timeline = site.data.dig('resume', 'timeline', 'history') || site.data.dig('resume', 'timeline')
      if timeline
        output << "## Experience"
        output << ""
        timeline.each do |position_id|
          position = site.data.dig('resume', 'positions', position_id)
          next unless position

          company = position.dig('company', 'name')
          title = position['title']
          start_date = position['start_date']
          end_date = position['end_date'] || 'Present'

          output << "### #{title} at #{company}"
          output << "**#{start_date} — #{end_date}**"
          output << ""
          summary = position['summary'] || position['description']
          output << summary if summary
          output << ""

          if position['highlights'] && !position['highlights'].empty?
            output << "**Key Outcomes:**"
            position['highlights'].each do |h|
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
        output << "## #{project['name']}"
        output << "**Type:** #{project['type']}" if project['type']
        output << "**Year:** #{project['year']}" if project['year']
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
          start_date = position['start_date']
          end_date = position['end_date'] || 'Present'

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
end
