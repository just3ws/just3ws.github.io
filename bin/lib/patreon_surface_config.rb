# frozen_string_literal: true

# Read-only view and consistency checks for the canonical Patreon surface data.
class PatreonSurfaceConfig
  def initialize(campaign)
    @campaign = campaign
    @surface = campaign.fetch('surface_management')
  end

  def show
    puts 'PATREON SURFACE CONFIGURATION'
    show_identity
    show_page
    show_membership
    show_posts
  end

  def validate
    errors = validation_errors
    return puts('Patreon surface configuration is internally consistent.') if errors.empty?

    errors.each { |error| warn "- #{error}" }
    exit 1
  end

  private

  def show_identity
    identity = @surface.fetch('identity')
    puts "Campaign:       #{identity['campaign_url']}"
    puts "Creator:        #{identity['display_name']} (#{identity['handle']})"
    puts "Last verified:  #{@surface['last_verified_at']} via #{@surface['verified_from']}"
  end

  def show_page
    page = @surface.fetch('page')
    puts "Page:           desired #{page['desired_status']}, observed #{page['observed_status']}"
    puts "Brand color:    #{page.dig('color', 'observed')}"
    puts "Cover:          #{page.dig('cover', 'observed_status')} (#{@campaign['cover_image']})"
    puts "Home sections:  #{@surface.dig('home_layout', 'visible_sections').join(', ')}"
  end

  def show_membership
    puts 'Paid tiers:'
    @surface.dig('membership', 'paid_tiers').each do |tier|
      puts format('  $%<price>s %<name>s: %<status>s',
                  price: tier['price_usd'], name: tier['name'],
                  status: tier['observed_status'])
    end
  end

  def show_posts
    puts 'Posts:'
    @surface.fetch('posts').each do |post|
      puts "  #{post['id']}: #{post['observed_status']} / #{post['observed_visibility']}"
    end
  end

  def validation_errors
    [schema_error, identity_error, color_error, page_copy_error, tier_error, post_error].compact
  end

  def schema_error
    'unsupported surface schema version' unless @surface['schema_version'] == 1
  end

  def identity_error
    expected = @campaign.fetch('campaign_url')
    'campaign identity does not match creator identity' unless @surface.dig('identity', 'campaign_url') == expected
  end

  def color_error
    expected = @campaign.fetch('brand_color')
    'page color differs from canonical brand color' unless @surface.dig('page', 'color', 'desired') == expected
  end

  def page_copy_error
    return 'page title is not mapped to canonical copy' unless @surface.dig('page', 'title_source') == 'title'

    'page About copy is not mapped to canonical copy' unless @surface.dig('page', 'about_source') == 'about'
  end

  def tier_error
    tier = @surface.dig('membership', 'paid_tiers').find { |item| item['id'] == 'studio-notes' }
    recommendation = @campaign.fetch('membership_recommendation')
    return 'Studio Notes tier is missing' unless tier
    unless tier['name'] == recommendation['paid_tier_name']
      return 'Studio Notes tier name differs from the recommendation'
    end

    unless tier['price_usd'] == recommendation['paid_tier_price_usd'] &&
           tier['description_source'] == 'membership_recommendation.paid_tier_description'
      'Studio Notes tier price or copy source differs from the recommendation'
    end
  end

  def post_error
    post = @surface.fetch('posts').find { |item| item['id'] == 'welcome' }
    return 'welcome post is missing from the surface inventory' unless post
    return 'welcome post title is not mapped to canonical copy' unless post['title_source'] == 'welcome_post.title'

    'welcome post body is not mapped to canonical copy' unless post['body_source'] == 'welcome_post.body'
  end
end
