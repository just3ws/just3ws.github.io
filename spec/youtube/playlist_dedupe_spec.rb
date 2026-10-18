# frozen_string_literal: true

require 'spec_helper'
require 'tempfile'
require 'yaml'
require_relative '../../bin/lib/youtube_deduplicator'

RSpec.describe YouTubeDeduplicator do
  let(:mock_assets) do
    [
      {
        'id' => 'ramblin-amblin-hello',
        'title' => "Ramblin' & Amblin' (2026-10-15): Hello",
        'platforms' => [
          { 'platform' => 'youtube', 'asset_id' => 'canonical_hello_id' }
        ]
      }
    ]
  end

  let(:assets_file) do
    file = Tempfile.new(['video_assets_test', '.yml'])
    file.write(YAML.dump(mock_assets))
    file.close
    file.path
  end

  after do
    File.unlink(assets_file) if File.exist?(assets_file)
  end

  subject(:deduplicator) { described_class.new(video_assets_path: assets_file) }

  describe '#normalize_title' do
    it 'strips series prefixes and dates from Ramblin & Amblin titles' do
      t1 = "Ramblin' & Amblin' (2026-10-15): Hello"
      expect(deduplicator.normalize_title(t1)).to eq('hello')

      t2 = "Ramblin' & Amblin' (2026-10-16): Recording this video and the way you're going"
      expect(deduplicator.normalize_title(t2)).to eq('recordingthisvideoandthewayyouregoing')
    end

    it 'handles nil and empty titles safely' do
      expect(deduplicator.normalize_title(nil)).to eq('')
      expect(deduplicator.normalize_title('')).to eq('')
    end
  end

  describe '#audit_playlist_items' do
    let(:items) do
      [
        # Item 1: canonical hello
        {
          'id' => 'item_1',
          'snippet' => { 'title' => "Ramblin' & Amblin' (2026-10-15): Hello", 'position' => 0 },
          'contentDetails' => { 'videoId' => 'canonical_hello_id' }
        },
        # Item 2: duplicate upload of hello (different video ID)
        {
          'id' => 'item_2',
          'snippet' => { 'title' => "Ramblin' & Amblin' (2026-10-15): Hello", 'position' => 1 },
          'contentDetails' => { 'videoId' => 'redundant_hello_id' }
        },
        # Item 3: repeat of canonical hello (same video ID)
        {
          'id' => 'item_3',
          'snippet' => { 'title' => "Ramblin' & Amblin' (2026-10-15): Hello", 'position' => 2 },
          'contentDetails' => { 'videoId' => 'canonical_hello_id' }
        },
        # Item 4: distinct unique video
        {
          'id' => 'item_4',
          'snippet' => { 'title' => "Ramblin' & Amblin' (2026-10-15): Incident Response", 'position' => 3 },
          'contentDetails' => { 'videoId' => 'unique_incident_id' }
        }
      ]
    end

    it 'detects both duplicate items of same video ID and duplicate uploads of same title' do
      audit = deduplicator.audit_playlist_items(items)

      expect(audit[:total_items]).to eq(4)
      expect(audit[:unique_videos]).to eq(3)

      # Duplicate items of same video ID
      expect(audit[:duplicate_item_groups]).to have_key('canonical_hello_id')
      expect(audit[:duplicate_item_groups]['canonical_hello_id'].size).to eq(2)

      # Duplicate uploads with same normalized title
      expect(audit[:duplicate_video_groups]).to have_key('hello')
      group = audit[:duplicate_video_groups]['hello']
      expect(group[:canonical_id]).to eq('canonical_hello_id')
      expect(group[:redundant_ids]).to eq(['redundant_hello_id'])
    end
  end

  describe '#plan_playlist_deletions' do
    let(:items) do
      [
        {
          'id' => 'item_1',
          'snippet' => { 'title' => "Ramblin' & Amblin' (2026-10-15): Hello", 'position' => 0 },
          'contentDetails' => { 'videoId' => 'canonical_hello_id' }
        },
        {
          'id' => 'item_2',
          'snippet' => { 'title' => "Ramblin' & Amblin' (2026-10-15): Hello", 'position' => 1 },
          'contentDetails' => { 'videoId' => 'redundant_hello_id' }
        },
        {
          'id' => 'item_3',
          'snippet' => { 'title' => "Ramblin' & Amblin' (2026-10-15): Hello", 'position' => 2 },
          'contentDetails' => { 'videoId' => 'canonical_hello_id' }
        }
      ]
    end

    it 'plans deletions for repeated items and redundant duplicate uploads' do
      audit = deduplicator.audit_playlist_items(items)
      deletions = deduplicator.plan_playlist_deletions(audit)

      deleted_item_ids = deletions.map { |d| d[:playlist_item_id] }

      # Should delete item_3 (repeated item of canonical_hello_id)
      # Should delete item_2 (redundant duplicate upload)
      # Should keep item_1 (first occurrence of canonical_hello_id)
      expect(deleted_item_ids).to contain_exactly('item_2', 'item_3')
      expect(deleted_item_ids).not_to include('item_1')
    end
  end

  describe 'Cross-reference reconciliation with _data/video_assets.yml' do
    let(:single_mismatched_item) do
      [
        {
          'id' => 'item_mismatch',
          'snippet' => { 'title' => "Ramblin' & Amblin' (2026-10-15): Hello", 'position' => 0 },
          'contentDetails' => { 'videoId' => 'unregistered_hello_id' }
        }
      ]
    end

    it 'detects single items that point to non-canonical video uploads' do
      audit = deduplicator.audit_playlist_items(single_mismatched_item)

      expect(audit[:duplicate_video_groups]).to have_key('hello')
      group = audit[:duplicate_video_groups]['hello']
      expect(group[:canonical_id]).to eq('canonical_hello_id')
      expect(group[:redundant_ids]).to eq(['unregistered_hello_id'])
      expect(audit[:missing_canonicals].first[:canonical_id]).to eq('canonical_hello_id')
    end

    it 'plans playlist reconciliation to add missing canonical videos' do
      audit = deduplicator.audit_playlist_items(single_mismatched_item)
      reconciliation = deduplicator.plan_playlist_reconciliation(audit, 'PL_TARGET_ID')

      expect(reconciliation.size).to eq(1)
      expect(reconciliation.first[:video_id]).to eq('canonical_hello_id')
      expect(reconciliation.first[:playlist_id]).to eq('PL_TARGET_ID')
    end
  end
end
