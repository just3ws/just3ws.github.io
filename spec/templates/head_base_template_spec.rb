# frozen_string_literal: true

RSpec.describe "head base template" do
  let(:template_path) { File.expand_path("../../_includes/head/base.html", __dir__) }
  let(:template) { File.read(template_path) }

  it "normalizes SEO title length bounds" do
    expect(template).to include("{% if seo_title.size < 30 %}")
    expect(template).to include("{% if seo_title.size > 70 %}")
    expect(template).to include('| append: " | Mike Hall Archive"')
    expect(template).to include('| truncate: 70, "…"')
  end

  it "normalizes SEO description length bounds" do
    expect(template).to include("{% if seo_description.size < 70 %}")
    expect(template).to include("{% if seo_description.size > 160 %}")
    expect(template).to include("This page is part of Mike Hall's curated engineering archive and resume.")
    expect(template).to include('| truncate: 160, "…"')
  end
end
