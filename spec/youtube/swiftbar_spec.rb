# frozen_string_literal: true

require 'spec_helper'
require 'open3'
require 'yaml'
require 'json'

RSpec.describe 'SwiftBar Integration & Localhost Navigation' do
  let(:root_dir) { File.expand_path('../..', __dir__) }
  let(:swiftbar_script) { File.join(root_dir, 'bin', 'youtube-swiftbar') }
  let(:swiftbar_shim) { File.expand_path('~/.swiftbar/youtube-pipeline.30s.sh') }
  let(:pipeline_runner) { File.join(root_dir, 'bin', 'pipeline') }
  let(:localhost_subnav) { File.join(root_dir, '_includes', 'localhost-subnav.html') }
  let(:navigation_yml) { File.join(root_dir, '_data', 'navigation.yml') }
  let(:command_palette) { File.join(root_dir, '_includes', 'command-palette.html') }
  let(:dashboard_html) { File.join(root_dir, 'dashboard.html') }

  describe 'SwiftBar application plugins' do
    let(:site_plugin) { File.join(root_dir, 'bin', 'just3ws-site-swiftbar') }

    it 'provides a named, executable site health plugin' do
      expect(File.executable?(site_plugin)).to be true
      stdout, stderr, status = Open3.capture3(
        { 'JUST3WS_SITE_URL' => 'http://127.0.0.1:1', 'MEDIA_PIPELINE_INTERNAL_URL' => 'http://127.0.0.1:1' },
        site_plugin
      )
      expect(status.success?).to be true
      expect(stderr).to be_empty
      expect(stdout).to include('just3ws Site')
      expect(stdout).to include('The Sound Above: UNAVAILABLE')
      expect(stdout).to include('Pipeline API: UNAVAILABLE')
    end

    it 'keeps the legacy site plugin as a compatibility entrypoint to media-pipeline' do
      content = File.read(swiftbar_script)
      expect(content).to include('just3ws-media-pipeline-swiftbar')
      expect(File.executable?(swiftbar_script)).to be true
    end

    it 'contains no em dash in the canonical site plugin' do
      expect(File.read(site_plugin)).not_to include("\u2014")
    end
  end

  describe 'Localhost Site Navigation Integration' do
    it 'includes YouTube Operations Cockpit and sub-dashboards in localhost-subnav.html' do
      content = File.read(localhost_subnav)
      expect(content).to include('/youtube/dashboard/')
      expect(content).to include('/youtube/dashboard/#tab-bpmn')
      expect(content).to include('/youtube/dashboard/#tab-teleprompter')
      expect(content).to include('/youtube/dashboard/#tab-funnel')
      expect(content).to include('/dehum/dashboard.html')
    end

    it 'includes Operations Cockpit in _data/navigation.yml' do
      content = File.read(navigation_yml)
      nav = YAML.safe_load(content)
      sound_above_item = nav.dig('primary', 'items').find { |item| item['label'] == 'The Sound Above' }
      expect(sound_above_item).not_to be_nil
      children_hrefs = sound_above_item['children'].map { |c| c['href'] }
      expect(children_hrefs).to include('/youtube/dashboard/')
    end

    it 'includes YouTube Operations Cockpit in command-palette.html' do
      content = File.read(command_palette)
      expect(content).to include('/youtube/dashboard/')
      expect(content).to include('data-search="youtube operations cockpit publishing pipeline bpmn workflow')
    end

    it 'includes direct BPMN and teleprompter chips in dashboard.html Card 0' do
      content = File.read(dashboard_html)
      expect(content).to include('/youtube/dashboard/#tab-bpmn')
      expect(content).to include('/youtube/dashboard/#tab-teleprompter')
      expect(content).to include('/youtube/dashboard/#tab-funnel')
    end

    it 'normalizes metadata_status and caption_status to strings across all assets in telemetry' do
      telemetry_path = File.join(root_dir, '_data', 'youtube_pipeline_telemetry.json')
      telemetry = JSON.parse(File.read(telemetry_path))
      assets = telemetry['assets'] || []
      expect(assets).not_to be_empty

      assets.each do |asset|
        expect(asset['metadata_status']).to be_a(String)
        expect(asset['caption_status']).to be_a(String)
      end
    end
  end
end
