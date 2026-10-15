# frozen_string_literal: true

require 'spec_helper'
require 'json'
require 'yaml'
require 'open3'

RSpec.describe 'YouTube Publishing Pipeline and Overview Dashboard' do
  let(:root_dir) { File.expand_path('../..', __dir__) }
  let(:telemetry_path) { File.join(root_dir, '_data', 'youtube_pipeline_telemetry.json') }
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

    it 'executes status command cleanly with zero exit code' do
      output = `ruby #{cli_path} status`
      expect($?.success?).to be true
      expect(output).to include('YOUTUBE PUBLISHING PIPELINE & OPERATIONAL STATUS')
      expect(output).to include('@whoistechcmty')
      expect(output).to include('ASSET & PUBLICATION FUNNEL')
    end

    it 'executes audit command and reports zero em-dash violations' do
      output = `ruby #{cli_path} audit`
      expect($?.success?).to be true
      expect(output).to include('Zero Em-Dash Invariant:   ✅ PASS (0 violations)')
      expect(output).to include('Overall Compliance Score:')
    end

    it 'executes schedule command and displays publication calendar' do
      output = `ruby #{cli_path} schedule`
      expect($?.success?).to be true
      expect(output).to include('MEDIA PUBLICATION CALENDAR & RELEASE TIMELINE')
      expect(output).to include('LIVESTREAM SCHEDULING & ORCHESTRATION')
    end

    it 'executes telemetry command and generates valid telemetry' do
      output = `ruby #{cli_path} telemetry`
      expect($?.success?).to be true
      expect(output).to include('Telemetry generated successfully')
      expect(File.exist?(telemetry_path)).to be true
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
      expect(output).to include('ACT 1: COLD OPEN & PERSONAL GROUNDING')
      expect(output).to include('ACT 2: SETTING THE HISTORICAL SCENE')
      expect(output).to include('ACT 3: THE CORE INQUIRY: THE SOUND ABOVE')
      expect(output).to include('ACT 4: HALLWAY REWATCH & VIDEO REACTION')
      expect(output).to include('ACT 5: THE AI-ERA PARALLEL & TERMINAL WORKBENCH')
      expect(output).to include('ACT 6: COMMUNITY CODA, OUTRO & NEXT STREAM')
    end
  end

  describe 'Publication Schedule (_data/publication_schedule.yml)' do
    it 'exists and contains valid schedule structure' do
      expect(File.exist?(schedule_path)).to be true
      data = YAML.safe_load(File.read(schedule_path))
      expect(data).to have_key('cadence')
      expect(data).to have_key('schedule')
      expect(data['schedule'].size).to be >= 4
    end
  end

  describe 'Telemetry Dataset (_data/youtube_pipeline_telemetry.json)' do
    let(:telemetry) { JSON.parse(File.read(telemetry_path)) }

    it 'contains required top-level schema keys' do
      expect(telemetry).to have_key('generated_at')
      expect(telemetry).to have_key('channel')
      expect(telemetry).to have_key('metrics')
      expect(telemetry).to have_key('conferences')
      expect(telemetry).to have_key('overlay_state')
      expect(telemetry).to have_key('publication_schedule')
      expect(telemetry).to have_key('sound_above_sequence')
      expect(telemetry).to have_key('errata_catalog')
      expect(telemetry).to have_key('episode_dossiers')
      expect(telemetry['episode_dossiers'].size).to eq(38)
      expect(telemetry).to have_key('assets')
    end

    it 'contains accurate asset metrics' do
      metrics = telemetry['metrics']
      expect(metrics['total_canonical_assets']).to be >= 200
      expect(metrics['youtube_live_videos']).to be >= 200
      expect(metrics['daily_quota_budget']).to eq(10_000)
    end

    it 'contains zero em dashes across all staged assets' do
      telemetry['assets'].each do |asset|
        expect(asset['title']).not_to include("\u2014"), "Asset #{asset['id']} title contains an em dash: #{asset['title']}"
      end
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
      expect(content).to include('The Sound Above: 6-Act Production Rundown Studio')
      expect(content).to include('Thematic Release Sequence & Media Pipeline')
      expect(content).to include('Sustainable Funding Channels for Independent Engineering Craft')
    end

    it 'contains Episode Studio and Narrative Workshop controls' do
      expect(content).to include('tab-btn-workshop')
      expect(content).to include('tab-pane-workshop')
      expect(content).to include('ws-input-title')
      expect(content).to include('ws-input-theme')
      expect(content).to include('ws-input-inquiry')
      expect(content).to include('ws-input-parallel')
      expect(content).to include('ws-story-act1')
      expect(content).to include('ws-preview-pane-rundown')
      expect(content).to include('ws-preview-pane-desc')
      expect(content).to include('ws-preview-pane-yaml')
    end

    it 'links to key YouTube and site control surfaces' do
      expect(content).to include('https://studio.youtube.com')
      expect(content).to include('https://www.youtube.com/@whoistechcmty')
      expect(content).to include('/dashboard/')
    end
  end

  describe 'Strategy & Architecture Document (docs/the-sound-above-audience-and-funding-strategy.md)' do
    let(:content) { File.read(strategy_path) }

    it 'exists and has valid structure' do
      expect(File.exist?(strategy_path)).to be true
      expect(content).to include('The Core Narrative Flywheel: Tri-Format Architecture')
      expect(content).to include('Audience Sequencing: The Six-Movement Narrative Arc')
      expect(content).to include('Sustainable Funding & Monetization Architecture')
    end

    it 'contains zero em dashes' do
      expect(content).not_to include("\u2014")
    end
  end

  describe 'Platform Link Dashboard integration (dashboard.html)' do
    let(:dashboard_content) { File.read(File.join(root_dir, 'dashboard.html')) }

    it 'links directly to the YouTube Operations Cockpit' do
      expect(dashboard_content).to include('/youtube/dashboard/')
      expect(dashboard_content).to include('YouTube Publishing Cockpit')
    end
  end

  describe 'Schedule Resequencer & Task Coordinator (TASK-289)' do
    it 'classifies release milestones with human or autonomous executor' do
      schedule = YAML.safe_load(File.read(schedule_path), permitted_classes: [Date, Time], aliases: true)
      schedule['schedule'].each do |week|
        week['releases'].each do |rel|
          expect(rel).to have_key('executor')
          expect(%w[human autonomous]).to include(rel['executor'])
        end
      end
    end

    it 'supports resequence --set command and syncs dates to episode dossiers' do
      cmd = [cli_path, 'resequence', '--set', '2,2026-10-20']
      stdout, stderr, status = Open3.capture3(*cmd)
      expect(status.success?).to be true
      expect(stdout).to include('Successfully set Episode 2 date to 2026-10-20')

      ep2_dossier = YAML.safe_load(File.read(File.join(root_dir, '_data', 'episodes', 'episode-02.yml')), permitted_classes: [Date, Time], aliases: true)
      expect(ep2_dossier['target_broadcast_date']).to eq('2026-10-20')
    end
  end
end
