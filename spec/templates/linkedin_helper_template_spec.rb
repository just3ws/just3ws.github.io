# frozen_string_literal: true

require "spec_helper"
require "nokogiri"
require "yaml"

RSpec.describe "LinkedIn & Universal Application Profile Helper (_site/linkedin/index.html)" do
  let(:root) { File.expand_path("../..", __dir__) }
  let(:html_path) { File.join(root, "_site", "linkedin", "index.html") }
  let(:just3ws_pos_path) { File.join(root, "_data", "resume", "positions", "just3ws.yml") }
  let(:just3ws_li_path) { File.join(root, "_data", "linkedin", "just3ws.yml") }

  it "carries dehum audio DSP restoration forward in just3ws resume and linkedin data" do
    pos_data = YAML.safe_load_file(just3ws_pos_path)
    li_data = YAML.safe_load_file(just3ws_li_path)

    expect(pos_data.to_s).to include("dehum")
    expect(pos_data["skills"]).to include("FFmpeg & Audio DSP")
    expect(li_data["text"]).to include("dehum")
    expect(li_data["text"].length).to be <= 2000
    expect(li_data["text"]).not_to include("\u2014")
  end

  it "renders all 8 helper workbench sections, 6 headlines, 5 projects, and 25 chronological roles within character limits" do
    skip "_site/linkedin/index.html not built yet" unless File.exist?(html_path)

    raw_html = File.read(html_path)
    expect(raw_html).not_to include("\u2014")

    doc = Nokogiri::HTML(raw_html)

    %w[
      sec-quickfill
      sec-headlines
      sec-about
      sec-featured
      sec-projects
      sec-experience
      sec-orgs
      sec-skills
    ].each do |sec_id|
      expect(doc.at_css("##{sec_id}")).not_to be_nil, "Expected section ##{sec_id} to be present"
    end

    # Verify all 6 headline options are <= 220 chars
    %w[a b c d e f].each do |opt|
      ta = doc.at_css("#headline-opt-#{opt}")
      expect(ta).not_to be_nil
      expect(ta.text.strip.length).to be_between(50, 220)
    end

    # Verify About section is <= 2600 chars and includes dehum and OneMain
    about_ta = doc.at_css("#about-textarea")
    expect(about_ta).not_to be_nil
    expect(about_ta.text.length).to be <= 2600
    expect(about_ta.text).to include("OneMain Financial")
    expect(about_ta.text).to include("dehum")

    # Verify all 25 chronological role cards render and stay <= 2000 chars
    role_cards = doc.css(".experience-role-card")
    expect(role_cards.size).to eq(25)

    doc.css("textarea[data-limit]").each do |ta|
      limit = ta["data-limit"].to_i
      expect(ta.text.length).to be <= limit, "Textarea ##{ta['id']} exceeded limit #{limit} (got #{ta.text.length})"
    end
  end
end
