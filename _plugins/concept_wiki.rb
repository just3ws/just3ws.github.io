# frozen_string_literal: true

# Turns the first useful occurrence of a registered concept into a small,
# accessible invitation to learn more. The plugin works on rendered article
# HTML, so Markdown, code blocks, diagrams, and existing links stay intact.

require 'json'
require 'fileutils'
require 'nokogiri'

module Jekyll
  module ConceptWiki
    SKIP_ANCESTORS = %w[a code pre script style].freeze

    def self.concepts(site)
      Array(site.data['concepts']).map do |concept|
        concept.transform_keys(&:to_s).merge('aliases' => Array(concept['aliases']))
      end
    end

    def self.link_page(site, page)
      return unless page.output_ext == '.html'
      return unless page.output.to_s.include?('post-body')

      registry = concepts(site)
      return if registry.empty?

      wiki_metadata = page.data['context_wiki'] || {}
      requested_slugs = Array(wiki_metadata['concepts']).map(&:to_s)
      registry = registry.select { |concept| requested_slugs.include?(concept['slug']) } unless requested_slugs.empty?
      return if registry.empty?

      document = Nokogiri::HTML::Document.parse(page.output)
      body = document.at_css('.post-body')
      return unless body

      by_alias = registry.flat_map do |concept|
        concept['aliases'].map { |alias_text| [alias_text, concept] }
      end.sort_by { |alias_text, _| -alias_text.length }
      linked = {}

      text_nodes(body).each do |node|
        next if node.text.strip.empty?

        replacements = []
        remaining = node.text
        cursor = 0
        pattern = Regexp.union(by_alias.map(&:first).sort_by { |term| -term.length })

        remaining.to_enum(:scan, /\b(?:#{pattern})\b/i).each do
          match = Regexp.last_match
          concept = by_alias.find { |alias_text, _| alias_text.casecmp?(match[0]) }&.last
          next unless concept && !linked[concept['slug']]
          next if concept['url'].to_s == page.url.to_s

          replacements << [cursor, match.begin(0), nil]
          replacements << [match.begin(0), match.end(0), concept]
          cursor = match.end(0)
          linked[concept['slug']] = true
        end
        next if replacements.empty?

        replacements << [cursor, remaining.length, nil] if cursor < remaining.length
        fragment = Nokogiri::HTML::DocumentFragment.new(document)
        replacements.each do |start_pos, end_pos, concept|
          text = remaining[start_pos...end_pos]
          if concept
            anchor = Nokogiri::XML::Node.new('a', document)
            anchor['href'] = concept['url']
            anchor['class'] = 'concept-link'
            anchor['data-concept'] = concept['slug']
            anchor['data-preview-url'] = "/assets/data/concepts/#{concept['slug']}.json"
            anchor['data-definition'] = concept['definition']
            anchor['aria-label'] = "Learn about #{concept['label']}"
            anchor.content = text
            fragment.add_child(anchor)
          else
            fragment.add_child(Nokogiri::XML::Text.new(text, document))
          end
        end
        node.replace(fragment)
      end

      page.output = document.to_html
    end

    def self.text_nodes(root)
      root.xpath('.//text()').reject do |node|
        node.ancestors.any? { |ancestor| SKIP_ANCESTORS.include?(ancestor.name) }
      end
    end

    Jekyll::Hooks.register :site, :post_render do |site|
      (site.pages + site.posts.docs).each { |page| link_page(site, page) }
    end

    Jekyll::Hooks.register :site, :post_write do |site|
      destination = File.join(site.dest, 'assets', 'data', 'concepts')
      FileUtils.mkdir_p(destination)
      registry = concepts(site)
      records = registry.map do |concept|
        related = Array(concept['related']).filter_map do |related_slug|
          related_concept = registry.find { |candidate| candidate['slug'] == related_slug }
          next unless related_concept

          {
            'slug' => related_concept['slug'],
            'label' => related_concept['label'],
            'url' => related_concept['url']
          }
        end
        payload = {
          '@context' => 'https://schema.org',
          '@type' => 'DefinedTerm',
          '@id' => "#{site.config['url']}#{concept['url']}#concept-#{concept['slug']}",
          'slug' => concept['slug'],
          'label' => concept['label'],
          'name' => concept['label'],
          'definition' => concept['definition'],
          'description' => concept['definition'],
          'url' => concept['url'],
          'related' => related,
          'graph_id' => concept['graph_id']
        }
        File.write(File.join(destination, "#{concept['slug']}.json"), JSON.pretty_generate(payload))
        payload
      end

      index = {
        '@context' => 'https://schema.org',
        '@type' => 'DataCatalog',
        '@id' => "#{site.config['url']}/assets/data/concepts/",
        'name' => 'Mike Hall Context Wiki Concept Registry',
        'description' => 'Open, article-backed definitions and relationships from the public engineering archive.',
        'license' => 'https://creativecommons.org/licenses/by/4.0/',
        'dataset' => records
      }
      File.write(File.join(destination, 'index.json'), JSON.pretty_generate(index))
    end
  end
end
