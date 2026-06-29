# frozen_string_literal: true

require 'spec_helper'
require 'jekyll'
require '_plugins/generate_interviewees'

RSpec.describe Jekyll::IntervieweeGenerator do
  let(:site) { instance_double(Jekyll::Site, data: data, pages: [], source: '/tmp') }
  let(:data) do
    {
      'interviewees_index' => {
        'items' => [
          {
            'slug' => 'sandro-mancuso',
            'name' => 'Sandro Mancuso',
            'count' => 3
          }
        ]
      }
    }
  end

  subject { described_class.new }

  before do
    allow(Jekyll::IntervieweeIndexPage).to receive(:new).and_return(instance_double(Jekyll::Page))
    allow(Jekyll::IntervieweeDetailPage).to receive(:new).and_return(instance_double(Jekyll::Page))
  end

  describe '#generate' do
    it 'creates an index page and virtual pages for interviewees' do
      subject.generate(site)
      expect(site.pages.size).to eq(2)
    end

    it 'assigns correct metadata to interviewee pages' do
      expect(Jekyll::IntervieweeDetailPage).to receive(:new).with(
        site, site.source, 'sandro-mancuso', hash_including(
          'title' => 'Sandro Mancuso Interviews',
          'breadcrumb' => 'Sandro Mancuso',
          'interviewee' => hash_including('slug' => 'sandro-mancuso')
        )
      )
      subject.generate(site)
    end

    it 'skips malformed interviewee entries without slugs' do
      data['interviewees_index']['items'] << { 'name' => 'No Slug' }
      subject.generate(site)
      expect(site.pages.size).to eq(2)
    end
  end
end
