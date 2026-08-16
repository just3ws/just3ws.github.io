# frozen_string_literal: true

require_relative '../bin/lib/diarization_map'

RSpec.describe DiarizationMap do
  describe '.validate_transcript_diarization' do
    it 'returns true for valid diarization data' do
      data = {
        'diarization' => {
          'engine' => 'pyannote-3.1',
          'model' => 'pyannote/speaker-diarization-3.1',
          'asr' => 'whisper.cpp',
          'generated_at' => '2026-08-16T12:00:00Z',
          'audio_duration' => 600.0,
          'num_speakers_hint' => 2,
          'segments' => [
            {
              'speaker' => 'SPEAKER_00',
              'start' => 0.0,
              'end' => 10.5,
              'text' => 'Welcome to the interview.'
            }
          ]
        }
      }

      expect(DiarizationMap.validate_transcript_diarization(data)).to be true
    end

    it 'raises ValidationError when missing required diarization keys' do
      data = {
        'diarization' => {
          'engine' => 'pyannote-3.1'
        }
      }

      expect { DiarizationMap.validate_transcript_diarization(data) }
        .to raise_error(DiarizationMap::ValidationError, /missing keys/)
    end
  end

  describe '.map_acoustic_labels' do
    it 'maps acoustic speaker IDs to named speakers' do
      segments = [
        { 'speaker' => 'SPEAKER_00', 'text' => 'Hello' },
        { 'speaker' => 'SPEAKER_01', 'text' => 'Hi there' }
      ]
      speaker_map = { 'SPEAKER_00' => 'Mike Hall', 'SPEAKER_01' => 'Dave Thomas' }

      result = DiarizationMap.map_acoustic_labels(segments, speaker_map)
      expect(result.first['named_speaker']).to eq('Mike Hall')
      expect(result.last['named_speaker']).to eq('Dave Thomas')
    end
  end
end
