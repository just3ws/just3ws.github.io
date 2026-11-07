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
      expect(state.dig('episode', 'title')).to include('Fluffle')
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

  it 'cues a Studio Dispatch with dynamic date stamping when called without arguments' do
    Dir.mktmpdir('broadcast-spec') do |sandbox|
      FileUtils.mkdir_p(File.join(sandbox, 'bin'))
      FileUtils.mkdir_p(File.join(sandbox, 'obs', 'curation'))
      FileUtils.mkdir_p(File.join(sandbox, 'obs', 'overlays'))
      FileUtils.cp(File.join(root_dir, 'bin/broadcast'), File.join(sandbox, 'bin/broadcast'))
      FileUtils.cp(File.join(root_dir, 'obs/overlays/overlay-state.json'), File.join(sandbox, 'obs/overlays/overlay-state.json'))

      stdout, stderr, status = Open3.capture3(
        File.join(sandbox, 'bin', 'broadcast'), '--dispatch'
      )

      expect(status.success?).to be(true), stderr
      expect(stdout).to include('Successfully cued Studio Dispatch')
      state = JSON.parse(File.read(File.join(sandbox, 'obs', 'overlays', 'overlay-state.json')))
      expect(state.dig('errata', 'mode')).to eq('dispatch')
      expect(state.dig('errata', 'title')).to match(/^Studio Dispatch · \w+ \d+, \d{4}$/)
      expect(state.dig('stream', 'series_title')).to eq('Mike Hall')
    end
  end

  it 'cues a Studio Dispatch with sequence counter and custom topic' do
    Dir.mktmpdir('broadcast-spec') do |sandbox|
      FileUtils.mkdir_p(File.join(sandbox, 'bin'))
      FileUtils.mkdir_p(File.join(sandbox, 'obs', 'curation'))
      FileUtils.mkdir_p(File.join(sandbox, 'obs', 'overlays'))
      FileUtils.cp(File.join(root_dir, 'bin/broadcast'), File.join(sandbox, 'bin/broadcast'))
      FileUtils.cp(File.join(root_dir, 'obs/overlays/overlay-state.json'), File.join(sandbox, 'obs/overlays/overlay-state.json'))

      stdout, stderr, status = Open3.capture3(
        File.join(sandbox, 'bin', 'broadcast'), '--dispatch', '1', '-t', 'Series Introduction', '-s', 'Plans and roadmap'
      )

      expect(status.success?).to be(true), stderr
      state = JSON.parse(File.read(File.join(sandbox, 'obs', 'overlays', 'overlay-state.json')))
      expect(state.dig('errata', 'mode')).to eq('dispatch')
      expect(state.dig('errata', 'title')).to eq('Studio Dispatch #1: Series Introduction')
      expect(state.dig('errata', 'subtitle')).to eq('Plans and roadmap')
    end
  end

  it 'cues an unspecified episode for The Sound Above via --intro' do
    Dir.mktmpdir('broadcast-spec') do |sandbox|
      FileUtils.mkdir_p(File.join(sandbox, 'bin'))
      FileUtils.mkdir_p(File.join(sandbox, 'obs', 'curation'))
      FileUtils.mkdir_p(File.join(sandbox, 'obs', 'overlays'))
      FileUtils.cp(File.join(root_dir, 'bin/broadcast'), File.join(sandbox, 'bin/broadcast'))
      FileUtils.cp(File.join(root_dir, 'obs/overlays/overlay-state.json'), File.join(sandbox, 'obs/overlays/overlay-state.json'))

      stdout, stderr, status = Open3.capture3(
        File.join(sandbox, 'bin', 'broadcast'), '--intro', '-s', 'Plans, ideas, and general structure'
      )

      expect(status.success?).to be(true), stderr
      expect(stdout).to include('Successfully cued unspecified episode (Series Introduction)')
      state = JSON.parse(File.read(File.join(sandbox, 'obs', 'overlays', 'overlay-state.json')))
      expect(state['broadcast_type']).to eq('rewatch')
      expect(state.dig('stream', 'series_title')).to eq('The Sound Above')
      expect(state.dig('episode', 'number')).to be_nil
      expect(state.dig('episode', 'title')).to eq('Series Introduction')
      expect(state.dig('episode', 'interviewee')).to eq('Mike Hall')
      expect(state.dig('episode', 'sound_above_prompt')).to eq('Plans, ideas, and general structure')
    end
  end
end
