# frozen_string_literal: true

require 'fileutils'

# _plugins/localhost_gate.rb — Localhost vs Production Surface Isolation Gate
#
# Enforces environment boundaries between:
# 1. Localhost Environment (`just3ws.localhost` / `JEKYLL_ENV=development`):
#    - Renders all internal surfaces: diagnostic operator tools (/tools/, /archive-status/),
#      and private strategy drafts.
# 2. Public Production Environment (`just3ws.com` / `JEKYLL_ENV=production`):
#    - Strips all pages, documents, and static files marked `localhost_only: true`.
#    - Executive pitch briefs (/exports/briefs/) are allowed on production as unlisted assets
#      (`robots: noindex,nofollow`, `sitemap: false`) so direct outreach links work for recipients.

module Jekyll
  class LocalhostGateGenerator < Generator
    safe true
    priority :lowest # Run after all other content generators have executed

    def generate(site)
      is_production = ENV['JEKYLL_ENV'] == 'production' || site.config['environment'] == 'production'

      if is_production
        # Filter out pages marked localhost_only: true
        initial_pages = site.pages.size
        site.pages.reject! { |page| localhost_only_item?(page) }
        pruned_pages = initial_pages - site.pages.size

        # Filter out collections/documents marked localhost_only: true
        initial_docs = site.documents.size
        site.documents.reject! { |doc| localhost_only_item?(doc) }
        pruned_docs = initial_docs - site.documents.size

        # Filter out static files marked localhost_only
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
      item.data['localhost_only'] == true
    end

    def localhost_only_static_file?(static_file)
      false
    end
  end
end

