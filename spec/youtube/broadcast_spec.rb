# frozen_string_literal: true

require 'spec_helper'
require 'fileutils'
require 'json'
require 'open3'
require 'tmpdir'

# rubocop:disable-next Metrics/BlockLength
RSpec.describe 'Broadcast episode resolution' do
  let(:root_dir) { File.expand_path('../..', __dir__) }

  it 'resolves the semantic Minus One slug to its dossier instead of episode zero' do
    Dir.mktmpdir('broadcast-spec') do |sandbox|
      FileUtils.mkdir_p(File.join(sandbox, 'bin'))
      FileUtils.mkdir_p(File.join(sandbox, 'obs', 'curation'))
      FileUtils.mkdir_p(File.join(sandbox, 'obs', 'overlays'))
      FileUtils.mkdir_p(File.join(sandbox, '_data', 'episodes'))
      [
        ['bin/broadcast', 'bin/broadcast'],
        ['obs/curation/sequence-manifest.json', 'obs/curation/sequence-manifest.json'],
        ['obs/overlays/overlay-state.json', 'obs/overlays/overlay-state.json'],
        ['_data/episodes/errata-fluffle-precursor.yml', '_data/episodes/errata-fluffle-precursor.yml']
      ].each do |source, destination|
        FileUtils.cp(File.join(root_dir, source), File.join(sandbox, destination))
      end

      stdout, stderr, status = Open3.capture3(
        File.join(sandbox, 'bin', 'broadcast'), '--rewatch', 'errata-fluffle-precursor'
      )

      expect(status.success?).to be(true), stderr
      expect(stdout).to include('Successfully cued Episode #-1')
      state = JSON.parse(File.read(File.join(sandbox, 'obs', 'overlays', 'overlay-state.json')))
      expect(state.dig('episode', 'title')).to include('Fluffle Precursor')
      expect(state.dig('episode', 'number')).to eq(-1)
    end
  end

  it 'rejects an invalid episode identifier without cueing episode zero' do
    Dir.mktmpdir('broadcast-spec') do |sandbox|
      FileUtils.mkdir_p(File.join(sandbox, 'bin'))
      FileUtils.mkdir_p(File.join(sandbox, 'obs', 'curation'))
      FileUtils.mkdir_p(File.join(sandbox, 'obs', 'overlays'))
      FileUtils.cp(File.join(root_dir, 'bin/broadcast'), File.join(sandbox, 'bin/broadcast'))
      FileUtils.cp(
        File.join(root_dir, 'obs/curation/sequence-manifest.json'),
        File.join(sandbox, 'obs/curation/sequence-manifest.json')
      )
      FileUtils.cp(
        File.join(root_dir, 'obs/overlays/overlay-state.json'),
        File.join(sandbox, 'obs/overlays/overlay-state.json')
      )

      stdout, stderr, status = Open3.capture3(
        File.join(sandbox, 'bin', 'broadcast'), '--rewatch', 'not-an-episode'
      )

      expect(status.success?).to be false
      expect(stderr).to include('not found in sequence manifest or episode dossiers')
      expect(stdout).not_to include('Successfully cued Episode #0')
    end
  end
end
