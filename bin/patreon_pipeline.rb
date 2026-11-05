#!/usr/bin/env ruby
# frozen_string_literal: true

# Read-only Patreon API reporting. Membership identities are neither persisted
# nor printed; the local summary contains aggregate counts only.

require 'fileutils'
require 'json'
require 'net/http'
require 'time'
require 'uri'

class PatreonPipeline
  ROOT_DIR = File.expand_path('..', __dir__)
  SUMMARY_PATH = File.join(Dir.home, '.local', 'share', 'just3ws', 'patreon', 'summary.json')
  API_BASE = 'https://www.patreon.com/api/oauth2/v2'
  CAMPAIGN_URL = 'https://www.patreon.com/c/just3ws'

  def initialize(env = ENV)
    @token = env['PATREON_CREATOR_TOKEN']
    @campaign_id = env['PATREON_CAMPAIGN_ID']
  end

  def run(args = ARGV.dup)
    case args.shift || 'status'
    when 'status' then show_status
    when 'campaign', 'id' then show_campaign
    when 'members', 'list' then show_member_counts
    when 'credits' then show_thank_you_copy
    when 'sync' then sync_summary
    when 'help', '-h', '--help' then print_help
    else
      warn "Unknown command: #{args.first}"
      print_help
      exit 1
    end
  end

  private

  def api_configured?
    @token && !@token.strip.empty?
  end

  def show_status
    data = load_summary
    puts 'PATREON CAMPAIGN STATUS'
    puts "Campaign:    #{CAMPAIGN_URL}"
    puts "API access:  #{api_configured? ? 'configured' : 'not configured'}"
    puts "Last synced: #{data['synced_at'] || 'never'}"
    puts "Paid members: #{data.fetch('active_paid_members', 'unknown')}"
    puts 'Revenue is not estimated by this report.'
    show_tier_counts(data)
  end

  def show_campaign
    campaign = fetch_campaigns.find { |item| item['id'] == @campaign_id } if @campaign_id
    campaign ||= fetch_campaigns.first
    unless campaign
      warn 'No Patreon campaign found. Check creator API access and campaign configuration.'
      exit 2
    end

    attrs = campaign['attributes'] || {}
    puts "Campaign ID: #{campaign['id']}"
    puts "Campaign:    #{attrs['creation_name']}"
    puts "URL:         #{attrs['url']}"
    puts "Members:     #{attrs['patron_count']}"
  rescue StandardError => e
    warn "Patreon campaign lookup failed: #{e.class}"
    exit 2
  end

  def show_member_counts
    data = load_summary
    puts 'PATREON COUNTS BY TIER'
    puts 'Member names and individual membership details are not stored or displayed.'
    show_tier_counts(data)
  end

  def show_tier_counts(data)
    counts = data['tier_counts'] || {}
    if counts.empty?
      puts 'No aggregate snapshot. Run `bin/pipeline patreon sync` with API access configured.'
      return
    end

    counts.sort.each { |name, count| puts "  #{name}: #{count}" }
  end

  def show_thank_you_copy
    puts 'TELEPROMPTER'
    puts 'Thanks for following and supporting my independent work.'
    puts "If you'd like to follow along, I'm at patreon.com/c/just3ws."
    puts
    puts 'YOUTUBE DESCRIPTION'
    puts 'Follow Mike Hall’s work across Ramblin’ & Amblin’, the interview archive, and independent projects:'
    puts CAMPAIGN_URL
    puts 'Named credits require an explicit, permissioned list; Patreon membership data is not used for attribution.'
  end

  def sync_summary
    unless api_configured?
      warn 'API access is not configured. Set PATREON_CREATOR_TOKEN in the process environment.'
      exit 2
    end

    campaign_id = configured_campaign_id
    result = aggregate_members(campaign_id)
    result['campaign_url'] = CAMPAIGN_URL
    result['campaign_id'] = campaign_id
    result['source'] = 'Patreon API v2 aggregate'
    result['synced_at'] = Time.now.utc.iso8601

    FileUtils.mkdir_p(File.dirname(SUMMARY_PATH), mode: 0o700)
    File.write(SUMMARY_PATH, JSON.pretty_generate(result) + "\n", perm: 0o600)
    File.chmod(0o600, SUMMARY_PATH)
    puts "Saved aggregate counts to #{SUMMARY_PATH}; no member names or IDs were stored."
  rescue StandardError => e
    warn "Patreon aggregate sync failed: #{e.class}"
    exit 2
  end

  def load_summary
    JSON.parse(File.read(SUMMARY_PATH))
  rescue Errno::ENOENT, JSON::ParserError
    { 'tier_counts' => {} }
  end

  def configured_campaign_id
    return @campaign_id if @campaign_id && @campaign_id.match?(/\A\d+\z/)

    fetch_campaigns.first&.fetch('id') || raise('campaign unavailable')
  end

  def fetch_campaigns
    payload = get_json("#{API_BASE}/campaigns?fields%5Bcampaign%5D=creation_name,url,patron_count")
    payload.fetch('data', [])
  end

  def aggregate_members(campaign_id)
    uri = URI("#{API_BASE}/campaigns/#{campaign_id}/members?include=currently_entitled_tiers&fields%5Bmember%5D=patron_status&fields%5Btier%5D=title")
    counts = Hash.new(0)
    active_paid_members = 0

    loop do
      payload = get_json(uri.to_s)
      tiers = (payload['included'] || []).to_h do |tier|
        [tier['id'], tier.dig('attributes', 'title')]
      end

      (payload['data'] || []).each do |member|
        next unless member.dig('attributes', 'patron_status') == 'active_patron'

        entitled = member.dig('relationships', 'currently_entitled_tiers', 'data') || []
        title = entitled.filter_map { |tier| tiers[tier['id']] }.first || 'Unassigned'
        counts[title] += 1
        active_paid_members += 1
      end

      next_link = payload.dig('links', 'next')
      break unless next_link

      uri = URI(next_link)
      raise 'unexpected pagination host' unless uri.scheme == 'https' && uri.host == 'www.patreon.com'
    end

    { 'active_paid_members' => active_paid_members, 'tier_counts' => counts }
  end

  def get_json(url)
    raise 'API access is not configured' unless api_configured?

    uri = URI(url)
    raise 'unexpected API host' unless uri.scheme == 'https' && uri.host == 'www.patreon.com'

    request = Net::HTTP::Get.new(uri)
    request['Authorization'] = "Bearer #{@token}"
    request['User-Agent'] = 'just3ws-patreon-report/1.0'
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |http| http.request(request) }
    raise "Patreon returned HTTP #{response.code}" unless response.is_a?(Net::HTTPSuccess)

    JSON.parse(response.body)
  end

  def print_help
    puts <<~HELP
      Usage: bin/pipeline patreon <command>

      Commands:
        status    Show the local aggregate snapshot; no revenue estimate
        campaign  Inspect campaign metadata through Patreon API v2
        members   Show aggregate member counts by tier
        credits   Print generic thank-you copy; no patron names
        sync      Save aggregate counts outside the public repository
        help      Show this help

      Credentials are read from process environment only:
        PATREON_CREATOR_TOKEN
        PATREON_CAMPAIGN_ID (optional; otherwise discovered from the account)
    HELP
  end
end

PatreonPipeline.new.run if $PROGRAM_NAME == __FILE__
