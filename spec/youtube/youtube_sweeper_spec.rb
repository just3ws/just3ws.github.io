# frozen_string_literal: true

require 'spec_helper'
require 'open3'

RSpec.describe 'Retired content-repository YouTube sweeper' do
  it 'fails closed and directs publishing work to media-pipeline' do
    root_dir = File.expand_path('../..', __dir__)
    _stdout, stderr, status = Open3.capture3('ruby', File.join(root_dir, 'bin', 'youtube_sweeper.rb'))

    expect(status.exitstatus).to eq(64)
    expect(stderr).to include('media-pipeline')
  end
end
