# frozen_string_literal: true

require 'spec_helper'
require 'yaml'
require 'json'
require 'open3'

RSpec.describe 'Media Intake & Cloud-Streaming Publishing Pipeline' do
  let(:root_dir) { File.expand_path('../..', __dir__) }
  let(:config_path) { File.join(root_dir, '_data', 'media_intake_targets.yml') }
  let(:cli_path) { File.join(root_dir, 'bin', 'intake_drive_video.rb') }
  let(:pipeline_runner) { File.join(root_dir, 'bin', 'pipeline') }

  describe 'Configuration (_data/media_intake_targets.yml)' do
    it 'exists and parses as valid YAML' do
      expect(File.exist?(config_path)).to be true
      config = YAML.safe_load(File.read(config_path))
      expect(config).to be_a(Hash)
      expect(config).to have_key('base_path')
      expect(config).to have_key('channels')
    end

    it 'defines whoistechcmty targets with required playlists and categories' do
      config = YAML.safe_load(File.read(config_path))
      targets = config.dig('channels', 'whoistechcmty', 'targets')
      expect(targets).to be_a(Hash)
      expect(targets.keys).to include('ramblin-amblin', 'the-sound-above', 'errata')

      ramblin = targets['ramblin-amblin']
      expect(ramblin['playlist_id']).to eq('PLNtb969T2-l0')
      expect(ramblin['category_id']).to eq('28')
      expect(ramblin['tags']).to be_an(Array)
      expect(ramblin['auto_title_from_speech']).to be true

      sound_above = targets['the-sound-above']
      expect(sound_above['playlist_id']).to eq('PLVcmLmfz2uyA')
      expect(sound_above['dossier_lookup']).to be true

      errata = targets['errata']
      expect(errata['playlist_id']).to eq('PLKPAHha6I990')
    end

    it 'contains zero em dashes across configuration file' do
      content = File.read(config_path)
      expect(content).not_to include("\u2014")
      expect(content).not_to match(/\s--\s/)
      # Ensure no spaced hyphens used as em-dash substitutes in prose
      prose_lines = content.lines.reject { |l| l.strip.start_with?('-') || l.strip.start_with?('#') }
      expect(prose_lines.join).not_to match(/\s-\s/)
    end
  end

  describe 'CLI (bin/intake_drive_video.rb)' do
    it 'exists and is executable' do
      expect(File.exist?(cli_path)).to be true
      expect(File.executable?(cli_path)).to be true
    end

    it 'contains zero em dashes across CLI source code' do
      content = File.read(cli_path)
      expect(content).not_to include("\u2014")
      expect(content).not_to match(/\s--\s/)
      expect(content).not_to match(/\s-\s/)
    end

    it 'executes --status command cleanly' do
      stdout, stderr, status = Open3.capture3("ruby #{cli_path} --status")
      expect(status.success?).to be true
      expect(stdout).to include('MEDIA INTAKE QUEUE STATUS')
      expect(stdout).to include('whoistechcmty')
      expect(stdout).to include('ramblin-amblin')
      expect(stdout).to include('the-sound-above')
      expect(stdout).to include('errata')
      expect(stdout).to include('[pending]')
    end

    it 'executes --dry-run cleanly when queue is empty' do
      stdout, stderr, status = Open3.capture3("ruby #{cli_path} --dry-run")
      expect(status.success?).to be true
      expect(stdout).to include('Intake queue is clear')
    end

    it 'integrates with bin/pipeline intake command' do
      stdout, stderr, status = Open3.capture3("#{pipeline_runner} intake")
      expect(status.success?).to be true
      expect(stdout).to include('MEDIA INTAKE QUEUE STATUS')
    end
  end

  describe 'Metadata & Speech Synthesis Unit Logic' do
    require_relative '../../bin/intake_drive_video'

    let(:pipeline) { MediaIntakePipeline.new({ dry_run: true }) }

    it 'extracts clean spoken hooks from conversational transcripts' do
      transcript = "Hey, so today we are walking through the park and thinking about distributed consensus and raft protocols."
      hook = pipeline.extract_hook_from_text(transcript)
      expect(hook).to eq("Walking through the park and thinking about distributed")
    end

    it 'strictly caps synthesized YouTube titles to under 100 characters' do
      long_hook = "A" * 120
      transcript_data = { text: long_hook, vtt: "" }
      target_info = {
        'series_name' => "Ramblin' & Amblin'",
        'auto_title_from_speech' => true,
        'title_prefix' => "Ramblin' & Amblin'"
      }

      meta = pipeline.synthesize_metadata("/dummy/path/PXL_20261015.mp4", "ramblin-amblin", target_info, transcript_data, {})
      expect(meta[:title].length).to be <= 100
      expect(meta[:title]).to end_with('...')
    end

    it 'resolves episode dossiers for The Sound Above recordings' do
      target_info = {
        'series_name' => "The Sound Above",
        'dossier_lookup' => true
      }

      meta = pipeline.synthesize_metadata("/dummy/path/2026-10-15_episode-01.mov", "the-sound-above", target_info, { text: "", vtt: "" }, {})
      expect(meta[:title]).to include('The First Room')
      expect(meta[:description]).to include('Sergio Pereira')
      expect(meta[:tags]).to include('The Sound Above')
    end

    it 'allows sidecar notes to override title and prompt' do
      sidecar_data = {
        'title' => "Special Field Note on Latency",
        'prompt' => "Reflecting on high latency network links"
      }
      target_info = {
        'series_name' => "Ramblin' & Amblin'",
        'default_privacy' => "unlisted"
      }

      meta = pipeline.synthesize_metadata("/dummy/path/PXL_1234.mp4", "ramblin-amblin", target_info, { text: "", vtt: "" }, sidecar_data)
      expect(meta[:title]).to eq("Special Field Note on Latency")
      expect(meta[:description]).to include("Reflecting on high latency network links")
    end
  end

  describe 'BPMN 2.0 Specification & SLO Architecture' do
    let(:bpmn_xml_path) { File.join(root_dir, 'docs', 'bpmn', 'media-intake-pipeline.bpmn') }
    let(:slo_doc_path) { File.join(root_dir, 'docs', 'bpmn', 'README.md') }
    let(:dashboard_path) { File.join(root_dir, 'youtube', 'dashboard.html') }

    it 'defines valid BPMN 2.0 XML with process and service task definitions' do
      expect(File.exist?(bpmn_xml_path)).to be true
      xml_content = File.read(bpmn_xml_path)
      expect(xml_content).to include('<bpmn:definitions')
      expect(xml_content).to include('id="Process_MediaIntakePipeline"')
      expect(xml_content).to include('Task_DetectDrop')
      expect(xml_content).to include('Task_WhisperTranscription')
      expect(xml_content).to include('Task_ResumableUpload')
      expect(xml_content).to include('BoundaryEvent_UploadError')
    end

    it 'provides comprehensive SLO, SLI, and alert specifications' do
      expect(File.exist?(slo_doc_path)).to be true
      doc = File.read(slo_doc_path)
      expect(doc).to include('Service Level Indicators (SLIs)')
      expect(doc).to include('ERR_INGRESS_DISCOVERY_TIMEOUT')
      expect(doc).to include('ERR_WHISPER_TIMEOUT')
      expect(doc).to include('ERR_YOUTUBE_RESUMABLE_UPLOAD')
      expect(doc).not_to include("\u2014")
    end

    it 'integrates interactive BPMN workflow canvas into youtube/dashboard.html' do
      expect(File.exist?(dashboard_path)).to be true
      dash = File.read(dashboard_path)
      expect(dash).to include('tab-pane-bpmn')
      expect(dash).to include('bpmn-svg-canvas')
      expect(dash).to include('simulateBpmnFlow()')
      expect(dash).to include('inspectBpmnNode')
    end
  end
end
