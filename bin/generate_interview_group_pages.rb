#!/usr/bin/env ruby
# frozen_string_literal: true

warn '[DEPRECATED] bin/generate_interview_group_pages.rb -> use bin/generate_interview_taxonomy_pages.rb'
exec(File.expand_path('generate_interview_taxonomy_pages.rb', __dir__))
