# frozen_string_literal: true

require 'spec_helper'
require 'tempfile'
require 'time'
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

  describe '#plan_rolling_horizon_retirement' do
    let(:now) { Time.parse('2026-10-19T12:00:00Z') }

    let(:items) do
      [
        # Item 0: Brand new today (Anchor)
        {
          'id' => 'pl_item_0',
          'snippet' => {
            'title' => "Ramblin' & Amblin' (2026-10-19): Today Video",
            'publishedAt' => '2026-10-19T10:00:00Z',
            'resourceId' => { 'videoId' => 'vid_today' }
          },
          'contentDetails' => { 'videoId' => 'vid_today' }
        },
        # Item 1: 1 day old (within 3-day window)
        {
          'id' => 'pl_item_1',
          'snippet' => {
            'title' => "Ramblin' & Amblin' (2026-10-18): Yesterday Video",
            'publishedAt' => '2026-10-18T10:00:00Z',
            'resourceId' => { 'videoId' => 'vid_yesterday' }
          },
          'contentDetails' => { 'videoId' => 'vid_yesterday' }
        },
        # Item 2: 2 days old (within 3-day window)
        {
          'id' => 'pl_item_2',
          'snippet' => {
            'title' => "Ramblin' & Amblin' (2026-10-17): 2 Days Ago Video",
            'publishedAt' => '2026-10-17T10:00:00Z',
            'resourceId' => { 'videoId' => 'vid_2days' }
          },
          'contentDetails' => { 'videoId' => 'vid_2days' }
        },
        # Item 3: 4 days old (outside 3-day window, but should be caught by carry_tail_count=2)
        {
          'id' => 'pl_item_3',
          'snippet' => {
            'title' => "Ramblin' & Amblin' (2026-10-15): 4 Days Ago Tail 1",
            'publishedAt' => '2026-10-15T10:00:00Z',
            'resourceId' => { 'videoId' => 'vid_tail_1' }
          },
          'contentDetails' => { 'videoId' => 'vid_tail_1' }
        },
        # Item 4: 5 days old (outside 3-day window, second carry tail video)
        {
          'id' => 'pl_item_4',
          'snippet' => {
            'title' => "Ramblin' & Amblin' (2026-10-14): 5 Days Ago Tail 2",
            'publishedAt' => '2026-10-14T10:00:00Z',
            'resourceId' => { 'videoId' => 'vid_tail_2' }
          },
          'contentDetails' => { 'videoId' => 'vid_tail_2' }
        },
        # Item 5: 6 days old (beyond window + carry tail, eligible for retirement)
        {
          'id' => 'pl_item_5',
          'snippet' => {
            'title' => "Ramblin' & Amblin' (2026-10-13): 6 Days Ago Retired",
            'publishedAt' => '2026-10-13T10:00:00Z',
            'resourceId' => { 'videoId' => 'vid_retired' }
          },
          'contentDetails' => { 'videoId' => 'vid_retired' }
        }
      ]
    end

    it 'keeps window videos plus carry tail, retiring older videos' do
      plan = deduplicator.plan_rolling_horizon_retirement(
        items,
        window_days: 3,
        carry_tail_count: 2,
        mode: 'anchor_gravitational_tail',
        now: now
      )

      expect(plan[:active].map { |i| i.dig('contentDetails', 'videoId') }).to eq(
        ['vid_today', 'vid_yesterday', 'vid_2days', 'vid_tail_1', 'vid_tail_2']
      )
      expect(plan[:retired].map { |i| i.dig('contentDetails', 'videoId') }).to eq(['vid_retired'])
    end

    it 'retires everything if anchor video is older than window_days and no evergreen videos exist' do
      old_items = [
        {
          'id' => 'pl_item_old1',
          'snippet' => {
            'title' => "Ramblin' & Amblin' (2026-10-01): Ancient 1",
            'publishedAt' => '2026-10-01T10:00:00Z',
            'resourceId' => { 'videoId' => 'vid_ancient_1' }
          },
          'contentDetails' => { 'videoId' => 'vid_ancient_1' }
        },
        {
          'id' => 'pl_item_old2',
          'snippet' => {
            'title' => "Ramblin' & Amblin' (2026-10-02): Ancient 2",
            'publishedAt' => '2026-10-02T10:00:00Z',
            'resourceId' => { 'videoId' => 'vid_ancient_2' }
          },
          'contentDetails' => { 'videoId' => 'vid_ancient_2' }
        }
      ]

      plan = deduplicator.plan_rolling_horizon_retirement(
        old_items,
        window_days: 3,
        carry_tail_count: 2,
        mode: 'anchor_gravitational_tail',
        now: now
      )

      expect(plan[:active]).to be_empty
      expect(plan[:retired].map { |i| i.dig('contentDetails', 'videoId') }).to eq(['vid_ancient_2', 'vid_ancient_1'])
    end

    it 'preserves evergreen videos in active set regardless of age' do
      assets_with_evergreen = [
        {
          'id' => 'ramblin-amblin-ancient-pinned',
          'title' => "Ramblin' & Amblin' (2026-10-01): Ancient Pinned",
          'evergreen' => true,
          'platforms' => [
            { 'platform' => 'youtube', 'asset_id' => 'vid_ancient_pinned' }
          ]
        }
      ]

      file = Tempfile.new(['video_assets_evergreen', '.yml'])
      file.write(YAML.dump(assets_with_evergreen))
      file.close

      custom_dedup = described_class.new(video_assets_path: file.path)

      items_with_pinned = [
        {
          'id' => 'pl_item_pinned',
          'snippet' => {
            'title' => "Ramblin' & Amblin' (2026-10-01): Ancient Pinned",
            'publishedAt' => '2026-10-01T10:00:00Z',
            'resourceId' => { 'videoId' => 'vid_ancient_pinned' }
          },
          'contentDetails' => { 'videoId' => 'vid_ancient_pinned' }
        },
        {
          'id' => 'pl_item_regular',
          'snippet' => {
            'title' => "Ramblin' & Amblin' (2026-10-01): Regular Old",
            'publishedAt' => '2026-10-01T10:00:00Z',
            'resourceId' => { 'videoId' => 'vid_regular' }
          },
          'contentDetails' => { 'videoId' => 'vid_regular' }
        }
      ]

      plan = custom_dedup.plan_rolling_horizon_retirement(
        items_with_pinned,
        window_days: 3,
        carry_tail_count: 2,
        mode: 'anchor_gravitational_tail',
        now: now
      )

      expect(plan[:active].map { |i| i.dig('contentDetails', 'videoId') }).to eq(['vid_ancient_pinned'])
      expect(plan[:retired].map { |i| i.dig('contentDetails', 'videoId') }).to eq(['vid_regular'])

      File.unlink(file.path) if File.exist?(file.path)
    end
  end
end
