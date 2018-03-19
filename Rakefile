# frozen_string_literal: true

require 'html-proofer'

task :htmlproofer do
  sh 'bundle exec jekyll build'
  options = { assume_extension: true }
  HTMLProofer.check_directory('./_site', options).run
end
