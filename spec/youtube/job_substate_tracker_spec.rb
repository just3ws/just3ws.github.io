# spec/youtube/job_substate_tracker_spec.rb
# frozen_string_literal: true

require 'spec_helper'
require 'tmpdir'
require_relative '../../bin/lib/job_substate_tracker'

RSpec.describe JobSubstateTracker do
  let(:tmp_dir) { Dir.mktmpdir('job_tracker_spec') }
  let(:state_dir) { File.join(tmp_dir, 'state') }
  let(:media_file) { File.join(tmp_dir, 'VID_20261016_test.mp4') }
  let(:filename) { 'VID_20261016_test.mp4' }

  before do
    FileUtils.mkdir_p(state_dir)
    FileUtils.touch(media_file)
  end

  after do
    FileUtils.rm_rf(tmp_dir)
  end

  describe '.load' do
    it 'initializes a clean statechart when no state file exists' do
      tracker = described_class.load(filename, media_file, state_dir)
      expect(tracker.meta_phase).to eq('pending')
      expect(tracker.current_step).to eq('audio_dsp')
      expect(tracker.step_status('audio_dsp')).to eq('pending')
      expect(tracker.step_status('transcription')).to eq('pending')
      expect(tracker.step_completed?('audio_dsp')).to be false
    end

    it 'persists and reloads existing job substates across instances' do
      tracker1 = described_class.load(filename, media_file, state_dir)
      tracker1.start_step(:audio_dsp)
      tracker1.complete_step(:audio_dsp, 'scratch_wav' => '/tmp/test.wav')
      tracker1.start_step(:transcription)
      tracker1.complete_step(:transcription, 'vtt' => 'WEBVTT test', 'text' => 'Hello test')

      tracker2 = described_class.load(filename, media_file, state_dir)
      expect(tracker2.step_completed?(:audio_dsp)).to be true
      expect(tracker2.step_completed?(:transcription)).to be true
      expect(tracker2.step_data(:audio_dsp)['scratch_wav']).to eq('/tmp/test.wav')
      expect(tracker2.step_data(:transcription)['vtt']).to eq('WEBVTT test')
      expect(tracker2.next_pending_step).to eq('metadata_synthesis')
    end
  end

  describe '#start_step and #complete_step' do
    it 'tracks in_progress and completed transitions with timing' do
      tracker = described_class.load(filename, media_file, state_dir)
      tracker.start_step(:audio_dsp)
      expect(tracker.step_status(:audio_dsp)).to eq('in_progress')
      expect(tracker.step_data(:audio_dsp)['started_at']).not_to be_nil

      tracker.complete_step(:audio_dsp, 'duration_seconds' => 4.2)
      expect(tracker.step_status(:audio_dsp)).to eq('completed')
      expect(tracker.step_completed?(:audio_dsp)).to be true
      expect(tracker.step_data(:audio_dsp)['duration_seconds']).to eq(4.2)
    end
  end

  describe '#fail_step' do
    it 'marks step failed and transitions meta_phase to quarantined' do
      tracker = described_class.load(filename, media_file, state_dir)
      tracker.start_step(:youtube_upload)
      tracker.fail_step(:youtube_upload, 'Network timeout connecting to YouTube API', ['line 1', 'line 2'])

      expect(tracker.step_status(:youtube_upload)).to eq('failed')
      expect(tracker.meta_phase).to eq('quarantined')
      expect(tracker.step_data(:youtube_upload)['error']).to eq('Network timeout connecting to YouTube API')
      expect(tracker.step_data(:youtube_upload)['backtrace']).to eq(['line 1', 'line 2'])
    end
  end

  describe '#summary_badges' do
    it 'emits structured badges for dashboard HUD rendering' do
      tracker = described_class.load(filename, media_file, state_dir)
      tracker.complete_step(:audio_dsp)
      tracker.complete_step(:transcription)

      badges = tracker.summary_badges
      dsp_badge = badges.find { |b| b['id'] == 'audio_dsp' }
      stt_badge = badges.find { |b| b['id'] == 'transcription' }
      meta_badge = badges.find { |b| b['id'] == 'metadata_synthesis' }

      expect(dsp_badge['status']).to eq('completed')
      expect(dsp_badge['label']).to eq('DSP')
      expect(stt_badge['status']).to eq('completed')
      expect(stt_badge['label']).to eq('STT')
      expect(meta_badge['status']).to eq('pending')
    end
  end

  describe '#relocate_file_path!' do
    it 'moves the companion state file when media file moves to processing/' do
      tracker = described_class.load(filename, media_file, state_dir)
      tracker.start_step(:audio_dsp)

      proc_dir = File.join(tmp_dir, 'processing')
      FileUtils.mkdir_p(proc_dir)
      new_media_path = File.join(proc_dir, filename)
      FileUtils.mv(media_file, new_media_path)

      tracker.relocate_file_path!(new_media_path)
      expect(File.exist?("#{new_media_path}.state.json")).to be true
    end
  end

  describe 'idempotency and skip evaluation' do
    it 'evaluates can_skip_audio_dsp? correctly based on step status and file presence' do
      tracker = described_class.load(filename, media_file, state_dir)
      expect(tracker.can_skip_audio_dsp?).to be false

      tracker.start_step(:audio_dsp)
      wav_path = tracker.scratch_wav_path
      File.write(wav_path, 'RIFFfakeaudioheaderanddata' * 50)
      tracker.complete_step(:audio_dsp, 'wav_path' => wav_path)

      expect(tracker.can_skip_audio_dsp?).to be true

      # If file is deleted, it should not skip
      FileUtils.rm_f(wav_path)
      expect(tracker.can_skip_audio_dsp?).to be false
    end

    it 'evaluates can_skip_transcription? based on step status and transcript content' do
      tracker = described_class.load(filename, media_file, state_dir)
      expect(tracker.can_skip_transcription?).to be false

      tracker.start_step(:transcription)
      tracker.complete_step(:transcription, 'text' => 'Hello transcript', 'vtt' => "WEBVTT\n1\n00:00.000 --> 00:05.000\nHello transcript")

      expect(tracker.can_skip_transcription?).to be true
    end

    it 'evaluates can_skip_youtube_upload? with mock client check' do
      tracker = described_class.load(filename, media_file, state_dir)
      expect(tracker.can_skip_youtube_upload?).to be false

      tracker.start_step(:youtube_upload)
      tracker.complete_step(:youtube_upload, 'video_id' => 'abc123xyz')

      expect(tracker.can_skip_youtube_upload?).to be true

      # Mock client returning existing video
      mock_client = double('YouTubeClient')
      allow(mock_client).to receive(:get_video).with('abc123xyz').and_return({ 'id' => 'abc123xyz', 'snippet' => { 'title' => 'Test' } })
      expect(tracker.can_skip_youtube_upload?(mock_client)).to be true

      # If client reports video does not exist
      allow(mock_client).to receive(:get_video).with('abc123xyz').and_return(nil)
      expect(tracker.can_skip_youtube_upload?(mock_client)).to be false
    end
  end

  describe '#cleanup_on_success!' do
    it 'removes scratch files, companion state, and local state on success' do
      tracker = described_class.load(filename, media_file, state_dir)
      wav_path = tracker.scratch_wav_path
      File.write(wav_path, 'test')
      tracker.save!

      expect(File.exist?(tracker.local_state_path)).to be true
      expect(File.exist?(tracker.companion_state_path)).to be true
      expect(File.exist?(wav_path)).to be true

      tracker.cleanup_on_success!

      expect(File.exist?(tracker.local_state_path)).to be false
      expect(File.exist?(tracker.companion_state_path)).to be false
      expect(File.exist?(wav_path)).to be false
    end
  end
end
