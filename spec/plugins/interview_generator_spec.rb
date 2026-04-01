# frozen_string_literal: true

require 'spec_helper'
require 'jekyll'
require '_plugins/generate_interviews'

RSpec.describe Jekyll::InterviewGenerator do
  let(:site) { instance_double(Jekyll::Site, data: data, pages: [], source: '/tmp') }
  let(:data) do
    {
      'interviews' => {
        'items' => [
          {
            'id' => 'test-interview-1',
            'title' => 'Test Interview One',
            'conference' => 'TestConf',
            'conference_year' => 2026,
            'recorded_date' => '2026-04-01'
          }
        ]
      }
    }
  end

  subject { described_class.new }

  before do
    allow(Jekyll::InterviewPage).to receive(:new).and_return(instance_double(Jekyll::Page))
  end

  describe '#generate' do
    it 'creates virtual pages for interviews' do
      subject.generate(site)
      expect(site.pages.size).to eq(1)
    end

    it 'assigns correct metadata to virtual pages' do
      expect(Jekyll::InterviewPage).to receive(:new).with(
        site, site.source, 'test-interview-1', hash_including(
          'title' => include('Test Interview One'),
          'breadcrumb' => 'Test Interview One',
          'interview_id' => 'test-interview-1'
        )
      )
      subject.generate(site)
    end

    it 'handles missing interviews data gracefully' do
      allow(site).to receive(:data).and_return({})
      expect { subject.generate(site) }.not_to raise_error
    end

    it 'handles missing optional fields (conference, recorded_date)' do
      data['interviews']['items'] << {
        'id' => 'minimal-interview',
        'title' => 'Minimal'
      }
      expect(Jekyll::InterviewPage).to receive(:new).with(
        any_args, 'minimal-interview', hash_including('title' => include('Minimal'))
      )
      subject.generate(site)
    end
  end
end
