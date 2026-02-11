# frozen_string_literal: true

require "src/generators/core/text"

RSpec.describe Generators::Core::Text do
  describe ".yaml_quote" do
    it "quotes values and escapes inner double quotes" do
      expect(described_class.yaml_quote(%(a "quote"))).to eq(%("a \\"quote\\""))
    end

    it "replaces newlines with spaces" do
      expect(described_class.yaml_quote("a\nb")).to eq('"a b"')
    end
  end

  describe ".normalize_subject" do
    it "removes interview prefixes and normalizes whitespace" do
      value = " Interview with   Jane Doe  "
      expect(described_class.normalize_subject(value)).to eq("Jane Doe")
    end
  end
end
