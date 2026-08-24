# frozen_string_literal: true

require 'fileutils'

# _plugins/localhost_gate.rb — Localhost vs Production Surface Isolation Gate
#
# Enforces environment boundaries between:
# 1. Localhost Environment (`just3ws.localhost` / `JEKYLL_ENV=development`):
#    - Renders all internal surfaces: executive pitch briefs (/exports/briefs/),
#      diagnostic operator tools (/tools/, /archive-status/), and CareerOS APIs.
# 2. Public Production Environment (`just3ws.com` / `JEKYLL_ENV=production`):
#    - Strips all pages, documents, and static files marked `localhost_only: true`
#      or located under localhost-only paths (/exports/briefs/).
#    - Guarantees private company pitches and diagnostic logs are never emitted
#      to public web artifacts.

module Jekyll
  class LocalhostGateGenerator < Generator
    safe true
    priority :lowest # Run after all other content generators have executed

    def generate(site)
      is_production = ENV['JEKYLL_ENV'] == 'production' || site.config['environment'] == 'production'

      if is_production
        # Filter out pages marked localhost_only: true or under localhost-only routes
        initial_pages = site.pages.size
        site.pages.reject! { |page| localhost_only_item?(page) }
        pruned_pages = initial_pages - site.pages.size

        # Filter out collections/documents marked localhost_only: true
        initial_docs = site.documents.size
        site.documents.reject! { |doc| localhost_only_item?(doc) }
        pruned_docs = initial_docs - site.documents.size

        # Filter out static files under localhost-only routes
        initial_static = site.static_files.size
        site.static_files.reject! { |static_file| localhost_only_static_file?(static_file) }
        pruned_static = initial_static - site.static_files.size

        if pruned_pages > 0 || pruned_docs > 0 || pruned_static > 0
          Jekyll.logger.info "🔒 [Localhost Gate]", "Production mode active: Filtered #{pruned_pages} pages, #{pruned_docs} documents, and #{pruned_static} static files."
        end
      else
        Jekyll.logger.info "🔓 [Localhost Gate]", "Localhost mode active: All internal surfaces, briefs, and diagnostic tools are enabled."
      end
    end

    private

    def localhost_only_item?(item)
      return true if item.data['localhost_only'] == true
      url = item.url.to_s
      return true if url.start_with?('/exports/briefs/')
      path = item.path.to_s
      return true if path.start_with?('exports/briefs/') || path.start_with?('/exports/briefs/')
      false
    end

    def localhost_only_static_file?(static_file)
      rel_path = static_file.relative_path.to_s
      return true if rel_path.start_with?('/exports/briefs/') || rel_path.start_with?('exports/briefs/')
      false
    end
  end

  # Post-write safeguard: remove localhost-only directories from _site destination if built in production
  Jekyll::Hooks.register :site, :post_write do |site|
    is_production = ENV['JEKYLL_ENV'] == 'production' || site.config['environment'] == 'production'
    if is_production
      briefs_dest = File.join(site.dest, 'exports', 'briefs')
      if Dir.exist?(briefs_dest)
        FileUtils.rm_rf(briefs_dest)
        Jekyll.logger.info "🔒 [Localhost Gate]", "Purged #{briefs_dest} from production _site destination."
      end
    end
  end
end
