# frozen_string_literal: true

RSpec.describe "json-ld interview template" do
  let(:template_path) { File.expand_path("../../_includes/json-ld-interview.html", __dir__) }
  let(:template) { File.read(template_path) }

  it "defines interview JSON-LD contract fields" do
    expect(template).to include('"@type": "CreativeWork"')
    expect(template).to include('"additionalType": "https://schema.org/Interview"')
    expect(template).to include('"@id": "{{ site_url }}/id/interview/{{ interview.id }}"')
    expect(template).to include('"datePublished": "{{ interview.recorded_date | date: "%Y-%m-%d" }}"')
    expect(template).to include('"description": {{ page.description | jsonify }}')
    expect(template).to include('"inLanguage": "en"')
    expect(template).to include('"mainEntityOfPage"')
    expect(template).to include('"subjectOf"')
    expect(template).to include('{{ site_url }}/id/video/{{ asset.id }}')
  end

  it "guards optional blocks behind liquid conditions" do
    expect(template).to include('{% if interview.interviewees and interview.interviewees.size > 0 %}')
    expect(template).to include('{% if asset and asset.id %}')
    expect(template).to include('{% if about_payload != "" %}')
    expect(template).to include('{{ site_url }}/id/person/{{ name | slugify }}')
    expect(template).to include('{{ interview.interviewer | default: "Mike Hall" | jsonify }}')
  end
end
