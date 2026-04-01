# frozen_string_literal: true

require 'spec_helper'
require 'jekyll'
require '_plugins/generate_taxonomy'

RSpec.describe Jekyll::TaxonomyGenerator do
  let(:site) { instance_double(Jekyll::Site, data: data, pages: [], source: '/tmp') }
  let(:data) do
    {
      'interviews' => {
        'items' => [
          { 'id' => 'i1', 'conference' => 'Conf A', 'community' => 'Comm A' }
        ]
      },
      'interview_conferences' => {
        'conferences' => [
          { 'name' => 'Conf A', 'slug' => 'conf-a' }
        ]
      },
      'interview_communities' => {
        'communities' => [
          { 'name' => 'Comm A', 'slug' => 'comm-a' }
        ]
      },
      'index_summaries' => {},
      'interviewee_signals' => { 'contributors' => [] }
    }
  end

  subject { described_class.new }

  before do
    allow(Jekyll::TaxonomyPage).to receive(:new).and_return(instance_double(Jekyll::Page))
  end

  describe '#generate' do
    it 'creates index and detail pages for conferences and communities' do
      subject.generate(site)
      # 1 conf index + 1 comm index + 1 conf detail + 1 comm detail = 4
      expect(site.pages.size).to eq(4)
    end

    it 'assigns correct layouts to taxonomy pages' do
      expect(Jekyll::TaxonomyPage).to receive(:new).with(
        site, site.source, "interviews/conferences", "taxonomy_index.html", any_args
      )
      expect(Jekyll::TaxonomyPage).to receive(:new).with(
        site, site.source, "interviews/conferences/conf-a", "taxonomy_detail.html", any_args
      )
      subject.generate(site)
    end
  end
end
