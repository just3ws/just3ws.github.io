# frozen_string_literal: true

require 'spec_helper'
require 'jekyll'
require '_plugins/generate_video_assets'

RSpec.describe Jekyll::VideoAssetGenerator do
  let(:site) { instance_double(Jekyll::Site, data: data, pages: [], source: '/tmp') }
  let(:data) do
    {
      'video_assets' => {
        'items' => [
          {
            'id' => 'test-asset-1',
            'title' => 'Test Video',
            'interview_id' => 'test-interview-1'
          }
        ]
      },
      'interviews' => {
        'items' => [
          {
            'id' => 'test-interview-1',
            'conference' => 'TestConf'
          }
        ]
      }
    }
  end

  subject { described_class.new }

  before do
    allow(Jekyll::VideoAssetPage).to receive(:new).and_return(instance_double(Jekyll::Page))
  end

  describe '#generate' do
    it 'creates virtual pages for video assets' do
      subject.generate(site)
      expect(site.pages.size).to eq(1)
    end

    it 'assigns correct metadata to video asset pages' do
      expect(Jekyll::VideoAssetPage).to receive(:new).with(
        site, site.source, 'test-asset-1', hash_including(
          'title' => include('Test Video'),
          'asset_id' => 'test-asset-1'
        )
      )
      subject.generate(site)
    end
  end
end
