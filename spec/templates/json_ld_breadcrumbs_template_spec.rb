# frozen_string_literal: true

RSpec.describe "json-ld breadcrumbs template" do
  let(:template_path) { File.expand_path("../../_includes/json-ld-breadcrumbs.html", __dir__) }
  let(:template) { File.read(template_path) }

  it "defines BreadcrumbList JSON-LD with ordered ListItem entries" do
    expect(template).to include('"@type": "BreadcrumbList"')
    expect(template).to include('"@type": "ListItem"')
    expect(template).to include('"position"')
    expect(template).to include('"item": "{{ site_url }}{{ breadcrumb_root_url }}"')
  end

  it "avoids duplicate current/root item when current route is root route" do
    expect(template).to include("{% if breadcrumb_current_url == breadcrumb_root_url %}")
    expect(template).to include("{% else %}")
  end
end
