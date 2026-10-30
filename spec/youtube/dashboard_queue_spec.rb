# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Season One planning page boundary' do
  let(:root_dir) { File.expand_path('../..', __dir__) }
  let(:content) { File.read(File.join(root_dir, 'youtube', 'dashboard.html')) }

  it 'shows a flexible 17-interview target without a release calendar' do
    expect(content).to include('Season One working plan')
    expect(content).to include('17 interviews')
    expect(content).to include('no release schedule')
    expect(content).to include('No episodes in this series have been published yet.')
  end

  it 'routes YouTube publication to media-pipeline' do
    expect(content).to include('https://media-pipeline.localhost/')
    expect(content).to include('Video uploads, captions, playlist changes, metadata updates')
    expect(content).not_to include('youtube.upload')
    expect(content).not_to include('quota-reset-pill')
    expect(content).not_to include('triggerPipelineAction')
  end
end
