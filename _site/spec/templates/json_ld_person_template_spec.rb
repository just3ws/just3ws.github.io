# frozen_string_literal: true

RSpec.describe "json-ld person template" do
  let(:template_path) { File.expand_path("../../_includes/json-ld.html", __dir__) }
  let(:template) { File.read(template_path) }

  it "defines Person schema with stable identity and ATS-relevant fields" do
    expect(template).to include('"@type": "Person"')
    expect(template).to include('"@id": "{{ person_id }}"')
    expect(template).to include('"description": {{ summary.text | strip | jsonify }}')
    expect(template).to include('"hasOccupation"')
    expect(template).to include('"subjectOf"')
    expect(template).to include('"@type": "ItemList"')
  end

  it "models history entries as ordered ListItem occupations" do
    expect(template).to include('{% for item in site.data.resume.timeline.history %}')
    expect(template).to include('"@type": "ListItem"')
    expect(template).to include('"@type": "Occupation"')
    expect(template).to include('{{ site_url }}/id/occupation/{{ item }}')
  end
end
