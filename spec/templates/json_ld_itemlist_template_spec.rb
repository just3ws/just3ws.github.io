# frozen_string_literal: true

RSpec.describe "json-ld itemlist template" do
  let(:template_path) { File.expand_path("../../_includes/json-ld-itemlist.html", __dir__) }
  let(:template) { File.read(template_path) }

  it "defines collection page and item list schema blocks" do
    expect(template).to include('"@type": "CollectionPage"')
    expect(template).to include('"mainEntity"')
    expect(template).to include('"@type": "ItemList"')
    expect(template).to include('"itemListElement"')
  end

  it "supports configurable id/name/url key mapping via include locals" do
    expect(template).to include('{% assign item_id_key = include.item_id_key | default: "id" %}')
    expect(template).to include('{% assign item_name_key = include.item_name_key | default: "title" %}')
    expect(template).to include('{% assign item_id = item[item_id_key] %}')
    expect(template).to include('{% assign item_name = item[item_name_key] | default: item.title | default: item_id %}')
  end
end
