# frozen_string_literal: true

require "src/generators/core/text"

RSpec.describe "interview taxonomy index template" do
  let(:template_path) { File.expand_path("../../_templates/generated/interview-taxonomy-index.erb", __dir__) }

  it "renders summary, highlights, and card metadata" do
    output = render_template(
      template_path,
      title: "Interviews by Conference",
      intro: "Browse interviews grouped by conference.",
      cards: [
        {
          name: "SCNA 2012",
          link: "/interviews/conferences/scna-2012/",
          summary: "Conference summary",
          location: "Chicago, IL",
          dates: "2012-04-12 – 2012-04-13",
          count_label: "3 interviews"
        }
      ],
      summary: "Index summary",
      highlights: ["Highlight one", "", "Highlight two"],
      parent_name: "Interviews",
      parent_url: "/interviews/",
      grandparent_name: nil,
      grandparent_url: nil
    )

    expect(output).to include('title: "Interviews by Conference"')
    expect(output).to include("breadcrumb_parent_name: \"Interviews\"")
    expect(output).to include('<section class="index-summary">')
    expect(output).to include("<li>Highlight one</li>")
    expect(output).to include("<li>Highlight two</li>")
    expect(output).not_to include("<li></li>")
    expect(output).to include('<h2><a href="/interviews/conferences/scna-2012/">SCNA 2012</a></h2>')
    expect(output).to include('<div class="conference-meta">Chicago, IL</div>')
    expect(output).to include('<div class="conference-dates">2012-04-12 – 2012-04-13</div>')
    expect(output).to include('<div class="conference-count">3 interviews</div>')
  end

  it "omits optional sections when summary and optional fields are empty" do
    output = render_template(
      template_path,
      title: "Interviews by Community",
      intro: "Browse interviews grouped by community.",
      cards: [
        {
          name: "General",
          link: "/interviews/communities/general/",
          summary: "",
          location: "",
          dates: nil,
          count_label: "1 interview"
        }
      ],
      summary: "   ",
      highlights: [],
      parent_name: "Interviews",
      parent_url: "/interviews/",
      grandparent_name: nil,
      grandparent_url: nil
    )

    expect(output).not_to include('<section class="index-summary">')
    expect(output).not_to include('<div class="conference-meta">')
    expect(output).not_to include('<div class="conference-dates">')
    expect(output).to include('<div class="conference-count">1 interview</div>')
  end
end
