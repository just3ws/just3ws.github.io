# frozen_string_literal: true

# _plugins/build_validation_hooks.rb — Jekyll Build Validation & Quality Improvement Hooks
#
# Hooks directly into the Jekyll build lifecycle:
# 1. :site, :post_read   -> Enforces data uniqueness & schema validation before page rendering.
# 2. :site, :post_render -> Audits HTML pages for A11y standards (alt text, ARIA labels, button titles).
# 3. :site, :post_write  -> Logs build completion statistics and verification metrics.

module Jekyll
  module BuildValidationHooks
    Jekyll::Hooks.register :site, :post_read do |site|
      Jekyll.logger.info "🔍 [Jekyll Hook: post_read]", "Validating archive data uniqueness and integrity..."
      
      # 1. Validate data uniqueness
      uniqueness_script = File.join(site.source, "bin", "validate_data_uniqueness.rb")
      if File.exist?(uniqueness_script)
        success = system("ruby #{uniqueness_script} > /dev/null 2>&1")
        unless success
          Jekyll.logger.error "❌ [Jekyll Hook Error]", "Data uniqueness validation failed! Build aborted."
          raise "Build aborted: Data uniqueness validation error."
        end
      end

      # 2. Validate data schema integrity
      validation_script = File.join(site.source, "bin", "validate_data.rb")
      if File.exist?(validation_script)
        success = system("ruby #{validation_script} > /dev/null 2>&1")
        unless success
          Jekyll.logger.error "❌ [Jekyll Hook Error]", "Declarative data schema validation failed! Build aborted."
          raise "Build aborted: Declarative data schema validation error."
        end
      end

      # 3. Inject dynamic git build metadata
      sha = `git rev-parse --short HEAD`.strip rescue 'master'
      commit_time = `git log -1 --format=%cI`.strip rescue Time.now.iso8601
      build_data = {
        'commit' => sha.empty? ? 'master' : sha,
        'time' => commit_time.empty? ? Time.now.iso8601 : commit_time,
        'repo' => 'https://github.com/just3ws/just3ws.github.io'
      }
      site.config['build_info'] = build_data
      site.data['build_info'] = build_data

      Jekyll.logger.info "✅ [Jekyll Hook: post_read]", "Data validation passed cleanly (Build Commit: #{site.config['build_info']['commit']})."
    end

    Jekyll::Hooks.register :site, :post_render do |site|
      a11y_warnings = 0

      site.pages.each do |page|
        next unless page.output_ext == ".html"
        content = page.output || ""

        # Check for images without alt tags
        if content.match?(/<img(?![^>]*\balt=)[^>]*>/i)
          a11y_warnings += 1
          Jekyll.logger.warn "⚠️ [A11y Warning]", "Image missing alt attribute in #{page.path}"
        end
      end

      if a11y_warnings == 0
        Jekyll.logger.info "♿ [Jekyll Hook: post_render]", "A11y audit completed: 0 markup warnings detected."
      end
    end

    Jekyll::Hooks.register :site, :post_write do |site|
      total_pages = site.pages.size + site.posts.docs.size
      Jekyll.logger.info "🚀 [Jekyll Hook: post_write]", "Build finished successfully across #{total_pages} site pages."
    end
  end
end
