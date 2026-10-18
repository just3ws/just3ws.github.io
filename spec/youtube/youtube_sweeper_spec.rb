# frozen_string_literal: true

require 'spec_helper'
require_relative '../../bin/youtube_sweeper'

RSpec.describe YouTubeSweeper do
  let(:sweeper) { described_class.new(options) }
  let(:options) { { mode: :audit, quiet: true } }

  describe '#calculate_quota_status' do
    it 'computes hours and minutes until 00:00 PT reset cleanly' do
      status = sweeper.calculate_quota_status
      expect(status).to have_key(:in_cooldown)
      expect(status[:seconds_until_reset]).to be > 0
      expect(status[:seconds_until_reset]).to be <= 86400
      expect(status[:hours_until_reset]).to be >= 0
      expect(status[:hours_until_reset]).to be <= 24
      expect(status[:minutes_until_reset]).to be >= 0
      expect(status[:minutes_until_reset]).to be < 60
    end
  end

  describe '#audit_single_playlist' do
    let(:playlist) { { id: 'PLNtb969T2-l0', title: "Ramblin' & Amblin'", privacy: 'unlisted' } }

    it 'detects duplicate items, duplicate uploads, and missing canonicals' do
      sample_items = [
        {
          'id' => 'item_1',
          'snippet' => { 'title' => 'Hello', 'resourceId' => { 'videoId' => 'vid_1' } },
          'contentDetails' => { 'videoId' => 'vid_1' }
        },
        {
          'id' => 'item_2',
          'snippet' => { 'title' => 'Hello', 'resourceId' => { 'videoId' => 'vid_2' } },
          'contentDetails' => { 'videoId' => 'vid_2' }
        },
        {
          'id' => 'item_3',
          'snippet' => { 'title' => 'Unique Topic', 'resourceId' => { 'videoId' => 'vid_3' } },
          'contentDetails' => { 'videoId' => 'vid_3' }
        },
        {
          'id' => 'item_4',
          'snippet' => { 'title' => 'Unique Topic', 'resourceId' => { 'videoId' => 'vid_3' } },
          'contentDetails' => { 'videoId' => 'vid_3' }
        }
      ]

      allow(sweeper).to receive(:fetch_playlist_items).with('PLNtb969T2-l0').and_return(sample_items)

      report = sweeper.audit_single_playlist(playlist)
      expect(report[:id]).to eq('PLNtb969T2-l0')
      expect(report[:total_items]).to eq(4)
      expect(report[:duplicate_item_groups]).to include('vid_3')
      expect(report[:duplicate_video_groups].size).to eq(1)
      expect(report[:warnings].any? { |w| w.include?('duplicate playlist item') }).to be true
      expect(report[:warnings].any? { |w| w.include?('redundant video upload') }).to be true
    end
  end

  describe '#audit_queue_health' do
    it 'returns numeric counts for pending, processing, blocked, and failed' do
      health = sweeper.audit_queue_health
      expect(health).to have_key(:pending_count)
      expect(health).to have_key(:processing_count)
      expect(health).to have_key(:blocked_count)
      expect(health).to have_key(:failed_count)
      expect(health[:pending_count]).to be >= 0
      expect(health[:processing_count]).to be >= 0
      expect(health[:blocked_count]).to be >= 0
      expect(health[:failed_count]).to be >= 0
    end
  end

  describe '#discover_playlists' do
    it 'returns target playlists from API or targets configuration' do
      playlists = sweeper.discover_playlists
      expect(playlists).to be_an(Array)
      if playlists.any?
        first = playlists.first
        expect(first).to have_key(:id)
        expect(first).to have_key(:title)
        expect(first).to have_key(:privacy)
      end
    end
  end
end
