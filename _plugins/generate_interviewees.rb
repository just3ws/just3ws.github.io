# frozen_string_literal: true

require 'jekyll'
require_relative '../src/generators/core/meta'

module Jekyll
  class IntervieweeGenerator < Generator
    safe true
    priority :low

    def generate(site)
      people = site.data.dig('interviewees_index', 'items') || []

      site.pages << IntervieweeIndexPage.new(site, site.source)

      people.each do |person|
        slug = person['slug'].to_s
        next if slug.empty?

        name = person['name'].to_s
        title = Generators::Core::Meta.clamp("#{name} Interviews", 70)
        description = "Interview archive page for #{name}, including appearances, related conference profiles, and presentation links."
        description = Generators::Core::Meta.clamp(description, 160)

        site.pages << IntervieweeDetailPage.new(site, site.source, slug, {
          'title' => title,
          'description' => description,
          'breadcrumb' => name,
          'breadcrumb_parent_name' => 'Interviewees',
          'breadcrumb_parent_url' => '/interviews/people/',
          'interviewee' => person
        })
      end

      # Historical alias redirect for Adam Lear (formerly recorded as Anna Lear)
      if people.any? { |p| p['slug'] == 'adam-lear' }
        site.pages << IntervieweeRedirectPage.new(
          site,
          site.source,
          'anna-lear',
          '/interviews/people/adam-lear/'
        )
      end
    end
  end

  class IntervieweeIndexPage < Page
    def initialize(site, base)
      @site = site
      @base = base
      @dir = 'interviews/people'
      @name = 'index.html'

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'interviewee_index.html')
      self.data.merge!(
        'title' => 'Interviewees',
        'description' => 'People-first index of interviewees with appearance counts and direct links into related conversations.',
        'breadcrumb' => 'Interviewees',
        'breadcrumb_parent_name' => 'Interviews',
        'breadcrumb_parent_url' => '/interviews/'
      )
    end
  end

  class IntervieweeDetailPage < Page
    def initialize(site, base, slug, data)
      @site = site
      @base = base
      @dir = "interviews/people/#{slug}"
      @name = 'index.html'

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'interviewee_detail.html')
      self.data.merge!(data)
    end
  end

  class IntervieweeRedirectPage < Page
    def initialize(site, base, slug, target_url)
      @site = site
      @base = base
      @dir = "interviews/people/#{slug}"
      @name = 'index.html'

      site_url = (site.respond_to?(:config) && site.config && site.config['url']) ? site.config['url'] : 'https://www.just3ws.com'
      canonical_url = target_url.start_with?('http') ? target_url : "#{site_url}#{target_url}"

      self.process(@name)
      self.data = {
        'layout' => nil,
        'sitemap' => false,
        'title' => 'Redirecting...'
      }
      self.content = <<~HTML
        <!DOCTYPE html>
        <html lang="en">
        <head>
          <meta charset="utf-8">
          <title>Redirecting...</title>
          <link rel="canonical" href="#{canonical_url}">
          <meta http-equiv="refresh" content="0; url=#{target_url}">
        </head>
        <body>
          <h1>Redirecting...</h1>
          <p><a href="#{target_url}">Click here if you are not redirected.</a></p>
        </body>
        </html>
      HTML
    end

    def render(_layouts, _site_payload)
      self.output = self.content
    end
  end
end
