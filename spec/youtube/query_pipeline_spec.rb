# frozen_string_literal: true

require 'spec_helper'
require 'open3'
require 'tmpdir'

RSpec.describe 'Media status ownership boundary' do
  let(:root_dir) { File.expand_path('../..', __dir__) }
  let(:query_script) { File.join(root_dir, 'bin', 'query_pipeline.rb') }
  let(:pipeline_runner) { File.join(root_dir, 'bin', 'pipeline') }
  let(:mcp_server) { File.join(root_dir, 'bin', 'mcp_server.js') }

  it 'retires the local query fallback' do
    _stdout, stderr, status = Open3.capture3(query_script)
    expect(status.exitstatus).to eq(64)
    expect(stderr).to include('media-pipeline')
  end

  it 'fails closed when the media-pipeline CLI is unavailable' do
    Dir.mktmpdir('missing-media-pipeline') do |workdir|
      %w[query status].each do |command|
        _stdout, stderr, status = Open3.capture3(
          { 'MEDIA_PIPELINE_WORKDIR' => workdir },
          pipeline_runner, 'media', command
        )
        expect(status.success?).to be false
        expect(stderr).to include('media-pipeline')
      end
    end
  end

  it 'routes MCP status reads through the media-pipeline command' do
    content = File.read(mcp_server)
    expect(content).to include('["media", "status", ...argsList]')
    expect(content).to include('["media", "status", "--json"]')
    expect(content).not_to include('ruby bin/query_pipeline.rb')
  end
end
