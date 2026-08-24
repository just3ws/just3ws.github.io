# frozen_string_literal: true

RSpec.describe "head base template" do
  let(:template_path) { File.expand_path("../../_includes/head/base.html", __dir__) }
  let(:template) { File.read(template_path) }

  it "normalizes SEO title length bounds" do
    expect(template).to include("{% if seo_title.size < 30 %}")
    expect(template).to include("{% if seo_title.size > 70 %}")
    expect(template).to include('| append: " | Mike Hall Technical Archive"')
    expect(template).to include('| truncate: 70, "…"')
  end

  it "normalizes SEO description length bounds" do
    expect(template).to include("{% if seo_description.size < 70 %}")
    expect(template).to include("{% if seo_description.size > 155 %}")
    expect(template).to include("Curated from Mike Hall's engineering archive.")
    expect(template).to include('| truncate: 155, "…"')
  end
end
