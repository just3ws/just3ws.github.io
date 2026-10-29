# frozen_string_literal: true

require 'spec_helper'
require 'fileutils'
require 'json'
require 'open3'
require 'tmpdir'

# rubocop:disable-next Metrics/BlockLength
RSpec.describe 'Broadcast episode resolution' do
  let(:root_dir) { File.expand_path('../..', __dir__) }

  it 'exposes recording preflight and playbook through help and playbook options' do
    stdout, stderr, status = Open3.capture3('ruby', File.join(root_dir, 'bin/broadcast'), '--help')
    expect(status.success?).to be(true), stderr
    expect(stdout).to include('--preflight')
    expect(stdout).to include('--playbook')
    expect(stdout).to include('does not start OBS or a stream')

    playbook, playbook_stderr, playbook_status = Open3.capture3(
      'ruby', File.join(root_dir, 'bin/broadcast'), '--playbook'
    )
    expect(playbook_status.success?).to be(true), playbook_stderr
    expect(playbook).to include('# The Sound Above Recording Playbook')
    expect(playbook).to include('Session close checklist')
  end

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
