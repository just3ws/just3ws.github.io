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
    # Strip series prefixes like: Ramblin' & Amblin' (2026-10-15):
    cleaned = cleaned.gsub(/\A[A-Za-z0-9'\s&]+(\(\d{4}-\d{2}-\d{2}\))?:?\s*/i, '')
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

    {
      total_items: items.size,
      unique_videos: by_vid.size,
      duplicate_item_groups: duplicate_item_groups,
      duplicate_video_groups: duplicate_video_groups
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

    asset['asset_id']
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
    return [] unless @receipts_dir && Dir.exist?(@receipts_dir)

    receipt_paths = Dir.glob(File.join(@receipts_dir, '**', '*.receipt.json'))
    receipt_paths.map do |path|
      data = JSON.parse(File.read(path)) rescue {}
      data['video_id']
    end.compact
  end
end
