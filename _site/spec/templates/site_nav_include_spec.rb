# frozen_string_literal: true

RSpec.describe "site nav include" do
  let(:template_path) { File.expand_path("../../_includes/site-nav.html", __dir__) }
  let(:template) { File.read(template_path) }

  it "loads navigation entries from data instead of inline literals" do
    expect(template).to include("{% assign nav_data = site.data.navigation.primary %}")
    expect(template).to include("{% assign nav_items = nav_data.items %}")
    expect(template).to include("{% assign nav_brand = nav_data.brand %}")
  end

  it "retains active-state logic by matching exact and prefix modes" do
    expect(template).to include('{% if mode == "exact" %}')
    expect(template).to include("{% if current_url == href or current_url contains href %}")
    expect(template).to include('aria-current="page"')
  end
end
