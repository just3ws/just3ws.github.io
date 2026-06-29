# frozen_string_literal: true

RSpec.describe 'validate_seo_metadata_budget' do
  let(:script_path) { File.expand_path('../../bin/validate_seo_metadata_budget.rb', __dir__) }
  let(:script) { File.read(script_path) }

  it 'budgets current SEO metadata report debt' do
    expect(script).to include("ENV.fetch('SEO_MAX_TITLE_OUTLIERS', '16')")
    expect(script).to include("ENV.fetch('SEO_MAX_DESC_OUTLIERS', '56')")
    expect(script).to include("ENV.fetch('SEO_MAX_DUPLICATE_TITLES', '0')")
    expect(script).to include("ENV.fetch('SEO_MAX_DUPLICATE_DESCS', '200')")
  end

  it 'fails by default when budgets are exceeded' do
    expect(script).to include("ENV.fetch('SEO_METADATA_BUDGET_MODE', 'error')")
    expect(script).to include("warn 'SEO metadata budget failed:'")
  end
end
