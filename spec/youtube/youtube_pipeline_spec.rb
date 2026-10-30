# frozen_string_literal: true

require 'spec_helper'
require 'json'
require 'yaml'
require 'open3'

RSpec.describe 'YouTube Publishing Pipeline and Overview Dashboard' do
  let(:root_dir) { File.expand_path('../..', __dir__) }
  let(:dashboard_path) { File.join(root_dir, 'youtube', 'dashboard.html') }
  let(:cli_path) { File.join(root_dir, 'bin', 'youtube_pipeline.rb') }
  let(:teleprompter_cli) { File.join(root_dir, 'bin', 'generate_sound_above_teleprompter.rb') }
  let(:schedule_path) { File.join(root_dir, '_data', 'publication_schedule.yml') }
  let(:strategy_path) { File.join(root_dir, 'docs', 'the-sound-above-audience-and-funding-strategy.md') }

  describe 'Pipeline CLI (bin/youtube_pipeline.rb)' do
    it 'exists and is executable' do
      expect(File.exist?(cli_path)).to be true
      expect(File.executable?(cli_path)).to be true
    end

    it 'fails closed for publisher operations owned by media-pipeline' do
      %w[audit status telemetry quota resequence upload captions playlist].each do |command|
        _stdout, stderr, status = Open3.capture3('ruby', cli_path, command)
        expect(status.exitstatus).to eq(64)
        expect(stderr).to include('media-pipeline')
      end
    end

    it 'shows the flexible Season One working target without release dates' do
      output = `ruby #{cli_path} schedule`
      expect($?.success?).to be true
      expect(output).to include('SEASON ONE WORKING PLAN')
      expect(output).to include('No release dates are set.')
      expect(output).to include('17 interviews')
    end
  end

  describe 'Teleprompter Generator (bin/generate_sound_above_teleprompter.rb)' do
    it 'exists and is executable' do
      expect(File.exist?(teleprompter_cli)).to be true
      expect(File.executable?(teleprompter_cli)).to be true
    end

    it 'generates structured 6-act rundown for Episode 1' do
      output = `ruby #{teleprompter_cli} --episode 1`
      expect($?.success?).to be true
      expect(output).to include('THE SOUND ABOVE: TELEPROMPTER & PRODUCTION RUNDOWN')
      expect(output).to include('ACT 1: START WITH THE MOMENT')
      expect(output).to include('ACT 2: SET THE CONTEXT')
      expect(output).to include('ACT 6: CLOSE WITH WHAT CHANGED')
    end
  end

  describe 'Publication Schedule (_data/publication_schedule.yml)' do
    it 'exists and contains valid schedule structure' do
      expect(File.exist?(schedule_path)).to be true
      data = YAML.safe_load(File.read(schedule_path))
      expect(data['status']).to eq('working_plan')
      expect(data['target_interviews']).to eq(17)
      expect(data).to have_key('schedule')
      expect(data['schedule']).to eq([])
    end
  end

  describe 'Overview Dashboard (youtube/dashboard.html)' do
    let(:content) { File.read(dashboard_path) }

    it 'exists and has valid Jekyll frontmatter' do
      expect(File.exist?(dashboard_path)).to be true
      expect(content).to include('layout: base')
      expect(content).to include('permalink: /youtube/dashboard/')
      expect(content).to include('redirect_from:')
      expect(content).to include('/dashboard/youtube/')
    end

    it 'contains no em dashes in prose' do
      expect(content).not_to include("\u2014"), 'youtube/dashboard.html contains an em dash'
    end

    it 'contains teleprompter studio and publication schedule sections' do
      expect(content).to include('Season One working plan')
      expect(content).to include('Current outline')
    end

    it 'keeps YouTube publishing in media-pipeline' do
      expect(content).to include('https://media-pipeline.localhost/')
      expect(content).to include('This content repository holds scripts')
      expect(content).not_to include('API v3 Authorized')
      expect(content).not_to include('youtube.upload')
    end

    it 'links to key YouTube and site control surfaces' do
      expect(content).to include('/series/the-sound-above/')
      expect(content).to include('/obs/')
    end
  end

  describe 'Strategy & Architecture Document (docs/the-sound-above-audience-and-funding-strategy.md)' do
    let(:content) { File.read(strategy_path) }

    it 'exists and has valid structure' do
      expect(File.exist?(strategy_path)).to be true
      expect(content).to include('Season One Working Plan')
      expect(content).to include('17 interviews')
      expect(content).to include('Publishing boundary')
    end

    it 'contains zero em dashes' do
      expect(content).not_to include("\u2014")
    end
  end

  describe 'Platform Link Dashboard integration (dashboard.html)' do
    let(:dashboard_content) { File.read(File.join(root_dir, 'dashboard.html')) }

    it 'links directly to the YouTube Operations Cockpit' do
      expect(dashboard_content).to include('/youtube/dashboard/')
      expect(dashboard_content).to include('The Sound Above: Season One Plan')
    end
  end

  describe 'Publisher ownership boundary' do
    it 'retires the legacy sweeper entrypoint' do
      _stdout, stderr, status = Open3.capture3('ruby', File.join(root_dir, 'bin', 'youtube_sweeper.rb'))
      expect(status.exitstatus).to eq(64)
      expect(stderr).to include('media-pipeline')
    end
  end
end
