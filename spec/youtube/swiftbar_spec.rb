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

  describe 'SwiftBar Script (bin/youtube-swiftbar)' do
    it 'exists and is executable' do
      expect(File.exist?(swiftbar_script)).to be true
      expect(File.executable?(swiftbar_script)).to be true
    end

    it 'contains zero em dashes across script source' do
      content = File.read(swiftbar_script)
      expect(content).not_to include("\u2014")
      expect(content).not_to match(/\s--\s/)
    end

    it 'executes cleanly and emits valid SwiftBar dialect' do
      stdout, stderr, status = Open3.capture3(swiftbar_script)
      expect(status.success?).to be true
      expect(stderr).to be_empty

      lines = stdout.lines.map(&:strip)
      expect(lines.first).to match(/^🎬/)
      expect(lines).to include('---')
      expect(stdout).to include('Media Intake & YouTube Publishing Pipeline')
      expect(stdout).to include('Ingress Queues:')
      expect(stdout).to include('Ramblin')
      expect(stdout).to include('The Sound Above')
      expect(stdout).to include('Errata')
      expect(stdout).to include('Subsystems & SLO Health')
      expect(stdout).to include('Localhost Dashboards & Views')
      expect(stdout).to include('href=https://www.just3ws.localhost/youtube/dashboard/')
      expect(stdout).to include('href=https://www.just3ws.localhost/youtube/dashboard/#tab-bpmn')
      expect(stdout).to include('href=https://www.just3ws.localhost/youtube/dashboard/#tab-teleprompter')
      expect(stdout).to include('href=https://www.just3ws.localhost/dehum/dashboard.html')
      expect(stdout).to include('refresh=true')
    end

    it 'is callable via bin/pipeline swiftbar' do
      stdout, stderr, status = Open3.capture3(pipeline_runner, 'swiftbar')
      expect(status.success?).to be true
      expect(stderr).to be_empty
      expect(stdout.lines.first).to match(/^(🎬|⚡|⚠️|⏸️|🎥)/)
    end
  end

  describe 'SwiftBar User Shim (~/.swiftbar/youtube-pipeline.30s.sh)' do
    before do
      skip 'SwiftBar user shim is local macOS platform only' if ENV['CI'] || !File.exist?(swiftbar_shim)
    end
    it 'exists and is executable' do
      expect(File.exist?(swiftbar_shim)).to be true
      expect(File.executable?(swiftbar_shim)).to be true
    end

    it 'executes tracked swiftbar binary' do
      content = File.read(swiftbar_shim)
      expect(content).to match(%r{exec "(/Users/mike/github.com/just3ws/(media-pipeline/bin/media-pipeline-swiftbar|just3ws.github.io/bin/youtube-swiftbar))"})
    end

    it 'contains zero em dashes' do
      content = File.read(swiftbar_shim)
      expect(content).not_to include("\u2014")
      expect(content).not_to match(/\s--\s/)
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
