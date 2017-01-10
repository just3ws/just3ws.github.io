source 'https://rubygems.org'

ruby '2.1.5'

source 'https://rubygems.org'

require 'json'
require 'open-uri'
versions_url = 'https://pages.github.com/versions.json'
versions = JSON.parse(open(versions_url).read)

gem 'github-pages', versions['github-pages'] , group: :jekyll_plugins
