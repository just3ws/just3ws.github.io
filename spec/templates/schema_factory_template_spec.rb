# frozen_string_literal: true

RSpec.describe "schema-factory template" do
  let(:template_path) { File.expand_path("../../_includes/schema-factory.html", __dir__) }
  let(:template) { File.read(template_path) }

  it "defines @context and @type" do
    expect(template).to include('"@context": "https://schema.org"')
  end

  context "when type is resume" do
    it "defines Person schema fields" do
      expect(template).to include('type == \'resume\'')
      expect(template).to include('"@type": "Person"')
      expect(template).to include('"@id": "{{ site_url }}/id/person/mike-hall"')
      expect(template).to include('"hasOccupation": [')
    end
  end

  context "when type is interview" do
    it "defines CreativeWork/Interview schema fields" do
      expect(template).to include('type == \'interview\'')
      expect(template).to include('"@type": "CreativeWork"')
      expect(template).to include('"additionalType": "https://schema.org/Interview"')
      expect(template).to include('"@id": "{{ site_url }}/id/interview/{{ interview.id }}"')
    end
  end

  context "when items are provided (ItemList)" do
    it "defines ItemList schema fields" do
      expect(template).to include('include.items')
      expect(template).to include('"@type": "ItemList"')
      expect(template).to include('"itemListElement": [')
    end
  end

  context "when breadcrumbs are provided" do
    it "defines BreadcrumbList schema fields" do
      expect(template).to include('include.breadcrumbs')
      expect(template).to include('"@type": "BreadcrumbList"')
      expect(template).to include('"@type": "ListItem"')
    end
  end

  context "when type is video_asset" do
    it "defines VideoObject schema fields" do
      expect(template).to include('type == \'video_asset\'')
      expect(template).to include('"@type": "VideoObject"')
      expect(template).to include('"@id": "{{ site_url }}/id/video/{{ asset.id }}"')
    end
  end
end
