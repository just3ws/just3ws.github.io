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
end
