# frozen_string_literal: true

require "src/generators/core/text"

RSpec.describe "interview taxonomy detail template" do
  let(:template_path) { File.expand_path("../../_templates/generated/interview-taxonomy-detail.erb", __dir__) }

  it "renders breadcrumb hierarchy, highlight list, and liquid assignment" do
    output = render_template(
      template_path,
      title: "SCNA 2012",
      intro: "Interviews recorded at SCNA 2012.",
      liquid_assign: '{% assign items = site.data.interviews.items | where: "conference", "SCNA" %}',
      conference_slug: "scna-2012",
      highlights: ["Talked about testing", "", "Discussed craftsmanship"],
      parent_name: "Interviews by Conference",
      parent_url: "/interviews/conferences/",
      grandparent_name: "Interviews",
      grandparent_url: "/interviews/"
    )

    expect(output).to include("breadcrumb_grandparent_name: \"Interviews\"")
    expect(output).to include("breadcrumb_parent_name: \"Interviews by Conference\"")
    expect(output).to include("<h1>SCNA 2012</h1>")
    expect(output).to include("<li>Talked about testing</li>")
    expect(output).to include("<li>Discussed craftsmanship</li>")
    expect(output).not_to include("<li></li>")
    expect(output).to include('{% assign items = site.data.interviews.items | where: "conference", "SCNA" %}')
    expect(output).to include('{% assign conference_resources = site.data.resources.conferences["scna-2012"] %}')
    expect(output).to include("<h2>Trusted Sources</h2>")
    expect(output).to include("{% include interview-card.html interview=interview %}")
  end

  it "omits highlights section when no highlights are present" do
    output = render_template(
      template_path,
      title: "General",
      intro: "Interviews recorded with the General community.",
      liquid_assign: '{% assign items = site.data.interviews.items | where: "community", "General" %}',
      conference_slug: nil,
      highlights: [],
      parent_name: "Interviews by Community",
      parent_url: "/interviews/communities/",
      grandparent_name: "Interviews",
      grandparent_url: "/interviews/"
    )

    expect(output).not_to include('<section class="index-summary">')
  end
end
