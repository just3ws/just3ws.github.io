# frozen_string_literal: true

require 'spec_helper'
require 'open3'

RSpec.describe 'Retired content-repository YouTube metadata generator' do
  it 'fails closed and directs metadata work to media-pipeline' do
    root_dir = File.expand_path('../..', __dir__)
    script = File.join(root_dir, 'bin', 'generate_youtube_metadata.rb')
    _stdout, stderr, status = Open3.capture3('ruby', script)

    expect(status.exitstatus).to eq(64)
    expect(stderr).to include('media-pipeline')
  end
end
