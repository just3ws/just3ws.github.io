# frozen_string_literal: true

# bin/lib/youtube_deduplicator.rb - YouTube Playlist and Video Deduplication Engine
#
# Provides detection, auditing, and cleanup planning for:
# 1. Duplicate playlist items (same video ID repeated in a playlist).
# 2. Duplicate video uploads (different video IDs with matching normalized titles / durations).
# 3. Canonical selection and local asset reconciliation.

require 'yaml'
require 'json'

class YouTubeDeduplicator
  attr_reader :video_assets_path, :receipts_dir

  def initialize(opts = {})
    root_dir = File.expand_path('../..', __dir__)
    @video_assets_path = opts[:video_assets_path] || File.join(root_dir, '_data', 'video_assets.yml')
    @receipts_dir = opts[:receipts_dir]
    @registered_assets = load_video_assets
  end

  # Normalize video title to strip series prefixes and timestamps
  def normalize_title(title)
    return '' if title.nil?

    cleaned = title.to_s.strip
    # Strip series prefixes with date or colon like: Ramblin' & Amblin' (2026-10-15):
    cleaned = cleaned.gsub(/\A[A-Za-z0-9'\s&]*\(\d{4}-\d{2}-\d{2}\):?\s*/i, '')
    cleaned = cleaned.gsub(/\A[A-Za-z0-9'\s&]+:\s*/i, '') if cleaned.include?(':')
    # Strip non-alphanumeric characters and lowercase
    cleaned.downcase.gsub(/[^a-z0-9]/, '')
  end

  # Audit a list of playlist items
  # items: array of hashes as returned by YouTube Data API v3 playlistItems.list
  def audit_playlist_items(items)
    by_vid = Hash.new { |h, k| h[k] = [] }
    by_title = Hash.new { |h, k| h[k] = [] }

    items.each do |it|
      v_id = it.dig('contentDetails', 'videoId') || it.dig('snippet', 'resourceId', 'videoId')
      next unless v_id

      by_vid[v_id] << it

      raw_title = it.dig('snippet', 'title').to_s
      norm = normalize_title(raw_title)
      norm = v_id if norm.empty? # fallback to video ID if no title
      by_title[norm] << it
    end

    # 1. Same video ID repeated in playlist
    duplicate_item_groups = by_vid.select { |_k, v| v.size > 1 }

    # 2. Different video IDs with identical normalized titles (duplicate uploads in playlist)
    duplicate_video_groups = {}
    by_title.each do |norm_key, group_items|
      unique_vids = group_items.map { |it| it.dig('contentDetails', 'videoId') || it.dig('snippet', 'resourceId', 'videoId') }.uniq
      next unless unique_vids.size > 1

      canonical_id = select_canonical_video_id(unique_vids, group_items)
      redundant_vids = unique_vids.reject { |v| v == canonical_id }

      duplicate_video_groups[norm_key] = {
        title: group_items.first.dig('snippet', 'title'),
        canonical_id: canonical_id,
        redundant_ids: redundant_vids,
        items: group_items
      }
    end

    # 3. Check for items whose video ID does not match canonical asset in _data/video_assets.yml
    missing_canonicals = []
    @registered_assets.each do |asset|
      canon_id = extract_youtube_id(asset)
      next unless canon_id

      asset_norm = normalize_title(asset['title'])
      next if asset_norm.empty?

      matching_items = by_title[asset_norm] || []
      next if matching_items.empty?

      unique_vids = matching_items.map { |it| it.dig('contentDetails', 'videoId') || it.dig('snippet', 'resourceId', 'videoId') }.uniq
      redundant_vids = unique_vids.reject { |v| v == canon_id }
      next if redundant_vids.empty?

      duplicate_video_groups[asset_norm] ||= {
        title: asset['title'],
        canonical_id: canon_id,
        redundant_ids: [],
        items: []
      }
      duplicate_video_groups[asset_norm][:canonical_id] = canon_id
      duplicate_video_groups[asset_norm][:redundant_ids] = (duplicate_video_groups[asset_norm][:redundant_ids] + redundant_vids).uniq
      duplicate_video_groups[asset_norm][:items] = (duplicate_video_groups[asset_norm][:items] + matching_items).uniq

      unless unique_vids.include?(canon_id)
        missing_canonicals << {
          title: asset['title'],
          canonical_id: canon_id,
          redundant_ids: redundant_vids
        }
      end
    end

    {
      total_items: items.size,
      unique_videos: by_vid.size,
      duplicate_item_groups: duplicate_item_groups,
      duplicate_video_groups: duplicate_video_groups,
      missing_canonicals: missing_canonicals
    }
  end

  # Plan playlist item deletions to leave each unique video once, and leave only the canonical video
  def plan_playlist_deletions(audit_result)
    items_to_delete = []

    # A. Delete repeated items for the same video ID (keep first occurrence)
    audit_result[:duplicate_item_groups].each do |_vid, dup_list|
      # Keep the first item by position or index
      sorted = dup_list.sort_by { |it| it.dig('snippet', 'position') || 0 }
      to_remove = sorted[1..-1] || []
      to_remove.each do |it|
        items_to_delete << {
          reason: 'duplicate_playlist_item',
          playlist_item_id: it['id'],
          video_id: it.dig('contentDetails', 'videoId') || it.dig('snippet', 'resourceId', 'videoId'),
          title: it.dig('snippet', 'title'),
          position: it.dig('snippet', 'position')
        }
      end
    end

    # B. Delete playlist items pointing to redundant duplicate videos
    audit_result[:duplicate_video_groups].each do |_norm, group|
      redundant_ids = group[:redundant_ids]
      group[:items].each do |it|
        v_id = it.dig('contentDetails', 'videoId') || it.dig('snippet', 'resourceId', 'videoId')
        if redundant_ids.include?(v_id)
          # Avoid adding duplicates if already marked by rule A
          next if items_to_delete.any? { |d| d[:playlist_item_id] == it['id'] }

          items_to_delete << {
            reason: 'redundant_duplicate_upload',
            playlist_item_id: it['id'],
            video_id: v_id,
            title: it.dig('snippet', 'title'),
            position: it.dig('snippet', 'position')
          }
        end
      end
    end

    items_to_delete
  end

  # Plan playlist additions to restore missing canonical videos
  def plan_playlist_reconciliation(audit_result, playlist_id)
    (audit_result[:missing_canonicals] || []).map do |m|
      {
        playlist_id: playlist_id,
        video_id: m[:canonical_id],
        title: m[:title],
        reason: 'missing_canonical_replacement'
      }
    end
  end

  # Select which video ID should be considered canonical among multiple duplicate uploads
  def select_canonical_video_id(candidate_vids, items)
    # Priority 1: Video ID explicitly recorded in _data/video_assets.yml
    registered_ids = @registered_assets.map { |a| extract_youtube_id(a) }.compact
    matched_registered = candidate_vids.find { |vid| registered_ids.include?(vid) }
    return matched_registered if matched_registered

    # Priority 2: Video ID recorded in receipts
    receipt_vids = load_receipt_video_ids
    matched_receipt = candidate_vids.find { |vid| receipt_vids.include?(vid) }
    return matched_receipt if matched_receipt

    # Priority 3: First video item in the group
    first_item = items.first
    first_item.dig('contentDetails', 'videoId') || first_item.dig('snippet', 'resourceId', 'videoId') || candidate_vids.first
  end

  # Extract YouTube video ID from a video_assets.yml entry
  def extract_youtube_id(asset)
    platforms = asset['platforms'] || []
    yt = platforms.find { |p| p['platform'] == 'youtube' }
    return yt['asset_id'] if yt && yt['asset_id']
    return yt['video_id'] if yt && yt['video_id']
    if yt && yt['url'] =~ /v=([a-zA-Z0-9_-]{11})/
      return $1
    end

    asset['asset_id']
  end

  # Plan rolling horizon retirement based on anchor and gravitational tail policy
  # items: array of playlist items (with snippet.publishedAt, contentDetails.videoId)
  # policy: hash containing :window_days, :carry_tail_count, :mode
  # now: Time object for age calculations (default Time.now)
  def plan_rolling_horizon_retirement(items, policy = {}, now = Time.now)
    return { active: [], retired: [], anchor: nil } if items.nil? || items.empty?

    window_days = policy[:window_days] || 3
    carry_tail_count = policy[:carry_tail_count] || 2
    window_seconds = window_days * 86_400

    # Sort items by publishedAt descending (newest first)
    sorted_items = items.sort_by do |it|
      published_str = it.dig('contentDetails', 'videoPublishedAt') || it.dig('snippet', 'publishedAt')
      published_str ? Time.parse(published_str).to_i : 0
    end.reverse

    anchor_item = sorted_items.first
    anchor_published_str = anchor_item.dig('contentDetails', 'videoPublishedAt') || anchor_item.dig('snippet', 'publishedAt')
    anchor_time = anchor_published_str ? Time.parse(anchor_published_str) : now
    anchor_age_seconds = now - anchor_time

    active_items = []
    retired_items = []

    # Map registered assets to check evergreen / pinned flags
    evergreen_ids = @registered_assets.select do |a|
      a['evergreen'] == true || a['pinned'] == true
    end.map { |a| extract_youtube_id(a) }.compact

    if anchor_age_seconds > window_seconds
      # Anchor itself has expired: all unpinned videos roll out
      sorted_items.each do |it|
        v_id = it.dig('contentDetails', 'videoId') || it.dig('snippet', 'resourceId', 'videoId')
        if evergreen_ids.include?(v_id)
          active_items << it
        else
          retired_items << it
        end
      end
    else
      # Anchor is still live: videos within window_days of anchor are retained
      # plus up to carry_tail_count older videos carried along by gravity
      tail_count = 0

      sorted_items.each do |it|
        v_id = it.dig('contentDetails', 'videoId') || it.dig('snippet', 'resourceId', 'videoId')

        if evergreen_ids.include?(v_id)
          active_items << it
          next
        end

        it_published_str = it.dig('contentDetails', 'videoPublishedAt') || it.dig('snippet', 'publishedAt')
        it_time = it_published_str ? Time.parse(it_published_str) : anchor_time
        age_from_anchor = anchor_time - it_time

        if age_from_anchor <= window_seconds
          active_items << it
        elsif tail_count < carry_tail_count
          active_items << it
          tail_count += 1
        else
          retired_items << it
        end
      end
    end

    {
      anchor: anchor_item,
      anchor_age_days: (anchor_age_seconds / 86_400.0).round(2),
      active: active_items,
      retired: retired_items
    }
  end

  private

  def load_video_assets
    return [] unless File.exist?(@video_assets_path)

    raw = YAML.safe_load(File.read(@video_assets_path), permitted_classes: [Date, Time], aliases: true) rescue nil
    if raw.is_a?(Hash) && raw['items'].is_a?(Array)
      raw['items']
    elsif raw.is_a?(Array)
      raw
    else
      []
    end
  end

  def load_receipt_video_ids
    default_dir = "/Users/mike/Library/CloudStorage/GoogleDrive-mike@just3ws.com/My Drive/Media Intake"
    dir = @receipts_dir || (Dir.exist?(default_dir) ? default_dir : nil)
    return [] unless dir && Dir.exist?(dir)

    receipt_paths = Dir.glob(File.join(dir, '**', '*.receipt.json'))
    receipt_paths.map do |path|
      data = JSON.parse(File.read(path)) rescue {}
      data['video_id']
    end.compact
  end
end
