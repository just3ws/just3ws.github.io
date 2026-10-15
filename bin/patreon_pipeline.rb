#!/usr/bin/env ruby
# frozen_string_literal: true

# ==============================================================================
# bin/patreon_pipeline.rb
# Patreon API v2 Integration & Patron Credit Automation for The Sound Above
#
# Connects to Patreon API v2 to fetch campaign statistics, active memberships,
# calculate monthly recurring archive compute funding, and generate on-screen
# closing credits for Act 6 teleprompter scripts and video descriptions.
#
# Supported commands:
#   bin/patreon_pipeline.rb status      # Show campaign stats, member count, and compute funding
#   bin/patreon_pipeline.rb members     # List active patrons and tier classifications
#   bin/patreon_pipeline.rb credits     # Format broadcast outro closing credits
#   bin/patreon_pipeline.rb sync        # Cache patron roster to _data/patreon_roster.json
#   bin/patreon_pipeline.rb help        # Show usage help
# ==============================================================================

require 'json'
require 'yaml'
require 'net/http'
require 'uri'
require 'optparse'
require 'date'

class PatreonPipeline
  ROOT_DIR = File.expand_path('..', __dir__)
  ROSTER_PATH = File.join(ROOT_DIR, '_data', 'patreon_roster.json')
  PATREON_API_BASE = 'https://www.patreon.com/api/oauth2/v2'

  CAMPAIGN_URL = 'https://patreon.com/whoistechcmty'

  # Calibrated Tiers:
  TIERS = {
    'tier_7' => { name: 'Archive Preservationist', amount: 7.00, desc: 'Compute & Hosting Underwriting' },
    'tier_19' => { name: 'Workbench Craftsman', amount: 19.00, desc: 'Audio DSP & Engineering Marginalia' },
    'tier_97' => { name: 'Engineering Patron', amount: 97.00, desc: 'Institutional Underwriting & Advisory' }
  }.freeze

  def initialize
    @token = ENV['PATREON_CREATOR_TOKEN']
    @campaign_id = ENV['PATREON_CAMPAIGN_ID']
  end

  def run(args = ARGV)
    command = args.shift || 'status'

    case command
    when 'status'
      show_status
    when 'members', 'list'
      list_members
    when 'credits'
      format_credits
    when 'sync'
      sync_roster
    when 'help', '-h', '--help'
      print_help
    else
      warn "Unknown command: #{command}"
      print_help
      exit 1
    end
  end

  # Displays current campaign status, active patrons, and recurring compute funding
  def show_status
    data = load_roster_data
    puts '=================================================================='
    puts ' 💰 PATREON CAMPAIGN STATUS & RECURRING COMPUTE FUNDING'
    puts '=================================================================='
    puts "Campaign:       WHOIS Tech Community (#{CAMPAIGN_URL})"
    puts "API Connection: #{api_configured? ? 'Live Patreon API v2' : 'Local Sandbox / Staged Fixture'}"
    puts "Last Synced:    #{data['synced_at'] || 'Never'}"
    puts '------------------------------------------------------------------'

    members = data['members'] || []
    active = members.select { |m| m['status'] == 'active_patron' }

    total_monthly = active.sum { |m| (m['pledge_amount'] || 0.0) }
    puts "Active Patrons:         #{active.size}"
    puts "Monthly Compute Fund:   $#{sprintf('%.2f', total_monthly)} / month"
    puts '------------------------------------------------------------------'
    puts 'TIER DISTRIBUTION:'
    TIERS.each do |key, meta|
      tier_members = active.select { |m| m['tier_id'] == key || m['tier_name'] == meta[:name] }
      subtotal = tier_members.size * meta[:amount]
      printf "  • %-26s ($%2d/mo): %2d patrons  (Subtotal: $%6.2f/mo)\n",
             meta[:name], meta[:amount].to_i, tier_members.size, subtotal
    end
    puts '=================================================================='
  end

  # Lists members with tier classification
  def list_members
    data = load_roster_data
    members = data['members'] || []
    puts '=================================================================='
    puts ' 👥 ACTIVE PATREON MEMBERS & TIERS'
    puts '=================================================================='
    printf "%-24s %-24s %-12s %s\n", 'NAME', 'TIER', 'PLEDGE', 'JOIN DATE'
    puts '------------------------------------------------------------------'

    if members.empty?
      puts '  (No patrons recorded yet. Run `bin/patreon_pipeline.rb sync` to refresh.)'
    else
      members.each do |m|
        printf "%-24s %-24s $%-11.2f %s\n",
               (m['full_name'] || 'Anonymous Patron')[0..22],
               (m['tier_name'] || 'Archive Supporter')[0..22],
               m['pledge_amount'] || 0.0,
               m['joined_at'] || 'Unknown'
      end
    end
    puts '=================================================================='
  end

  # Formats closing credit attribution for Act 6 teleprompter and YouTube description
  def format_credits
    data = load_roster_data
    members = data['members'] || []
    active = members.select { |m| m['status'] == 'active_patron' }

    patrons_97 = active.select { |m| (m['pledge_amount'] || 0) >= 90.0 }
    patrons_19 = active.select { |m| (m['pledge_amount'] || 0) >= 15.0 && (m['pledge_amount'] || 0) < 90.0 }
    patrons_7 = active.select { |m| (m['pledge_amount'] || 0) < 15.0 }

    puts '=================================================================='
    puts ' 📜 BROADCAST OUTRO CLOSING CREDITS (ACT 6 ATTRIBUTION)'
    puts '=================================================================='
    puts ''
    puts '--- FOR TELEPROMPTER READ-ALONG ---'
    if patrons_97.any?
      names = patrons_97.map { |m| m['full_name'] }.join(', ')
      puts "Special gratitude to our Engineering Patrons: #{names}."
    end
    puts "The Sound Above is underwritten by the patrons of WHOIS Tech Community at patreon.com/whoistechcmty."
    puts ''
    puts '--- FOR YOUTUBE DESCRIPTION ---'
    puts "COMMUNITY ARCHIVE PATRONS:"
    if patrons_97.any?
      puts "• Engineering Patrons: " + patrons_97.map { |m| m['full_name'] }.join(', ')
    end
    if patrons_19.any?
      puts "• Workbench Craftsmen: " + patrons_19.map { |m| m['full_name'] }.join(', ')
    end
    if patrons_7.any?
      puts "• Archive Preservationists: " + patrons_7.map { |m| m['full_name'] }.join(', ')
    end
    puts "Join the archive and underwrite compute costs: https://patreon.com/whoistechcmty"
    puts '=================================================================='
  end

  # Caches roster to _data/patreon_roster.json
  def sync_roster
    puts "Syncing Patreon roster from #{api_configured? ? 'Patreon API v2' : 'staged fixture data'}..."
    data = fetch_or_build_roster
    data['synced_at'] = Time.now.strftime('%Y-%m-%d %H:%M:%S UTC')
    File.write(ROSTER_PATH, JSON.pretty_generate(data) + "\n")
    puts "✅ Successfully synced Patreon roster to #{ROSTER_PATH}."
  end

  private

  def api_configured?
    !@token.nil? && !@token.strip.empty?
  end

  def load_roster_data
    if File.exist?(ROSTER_PATH)
      JSON.parse(File.read(ROSTER_PATH)) rescue build_sandbox_roster
    else
      build_sandbox_roster
    end
  end

  def fetch_or_build_roster
    return build_sandbox_roster unless api_configured?

    # Live API v2 call
    uri = URI("#{PATREON_API_BASE}/campaigns/#{@campaign_id}/members?include=currently_entitled_tiers&fields[member]=full_name,patron_status,lifetime_support_cents,pledge_cadence&fields[tier]=title,amount_cents")
    req = Net::HTTP::Get.new(uri)
    req['Authorization'] = "Bearer #{@token}"
    req['User-Agent'] = 'just3ws-the-sound-above-pipeline/1.0'

    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }

    if res.is_a?(Net::HTTPSuccess)
      parsed = JSON.parse(res.body)
      parse_live_members(parsed)
    else
      warn "Patreon API returned HTTP #{res.code}: #{res.body}. Falling back to cached/sandbox roster."
      build_sandbox_roster
    end
  rescue StandardError => e
    warn "Patreon API connection error: #{e.message}. Falling back to cached/sandbox roster."
    build_sandbox_roster
  end

  def parse_live_members(payload)
    members = []
    tiers_lookup = {}
    (payload['included'] || []).each do |inc|
      tiers_lookup[inc['id']] = inc.dig('attributes', 'title') if inc['type'] == 'tier'
    end

    (payload['data'] || []).each do |m|
      attrs = m['attributes'] || {}
      tier_ids = (m.dig('relationships', 'currently_entitled_tiers', 'data') || []).map { |t| t['id'] }
      tier_name = tier_ids.map { |tid| tiers_lookup[tid] }.compact.first || 'Archive Supporter'

      members << {
        'full_name' => attrs['full_name'],
        'status' => attrs['patron_status'],
        'tier_name' => tier_name,
        'pledge_amount' => (attrs['lifetime_support_cents'] || 0) / 100.0,
        'joined_at' => Date.today.to_s
      }
    end

    {
      'campaign_url' => CAMPAIGN_URL,
      'members' => members
    }
  end

  # Realistic foundation sandbox roster for local staging and rehearsal
  def build_sandbox_roster
    {
      'campaign_url' => CAMPAIGN_URL,
      'synced_at' => Time.now.strftime('%Y-%m-%d %H:%M:%S UTC'),
      'members' => [
        {
          'full_name' => 'Chicago Craftsmanship Veteran',
          'status' => 'active_patron',
          'tier_id' => 'tier_19',
          'tier_name' => 'Workbench Craftsman',
          'pledge_amount' => 19.00,
          'joined_at' => '2026-10-10'
        },
        {
          'full_name' => 'Independent Systems Architect',
          'status' => 'active_patron',
          'tier_id' => 'tier_97',
          'tier_name' => 'Engineering Patron',
          'pledge_amount' => 97.00,
          'joined_at' => '2026-10-12'
        },
        {
          'full_name' => 'Digital Humanities Supporter',
          'status' => 'active_patron',
          'tier_id' => 'tier_7',
          'tier_name' => 'Archive Preservationist',
          'pledge_amount' => 7.00,
          'joined_at' => '2026-10-13'
        }
      ]
    }
  end

  def print_help
    puts <<~HELP
      Usage: bin/patreon_pipeline.rb <command> [options]

      Commands:
        status      Display campaign member counts, tier breakdowns, and compute funding
        members     List active patrons, tier classifications, and join dates
        credits     Generate closing credit attribution for teleprompter and YouTube description
        sync        Cache roster data to _data/patreon_roster.json
        help        Show this help message

      Environment Variables:
        PATREON_CREATOR_TOKEN   Creator access token from Patreon Developer Portal
        PATREON_CAMPAIGN_ID     Numeric campaign ID for whoistechcmty
    HELP
  end
end

PatreonPipeline.new.run if __FILE__ == $PROGRAM_NAME
