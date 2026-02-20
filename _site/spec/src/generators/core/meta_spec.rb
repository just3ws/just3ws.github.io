# frozen_string_literal: true

require "src/generators/core/meta"

RSpec.describe Generators::Core::Meta do
  describe ".clamp" do
    it "normalizes whitespace and returns unchanged when under limit" do
      expect(described_class.clamp("  hello   world  ", 20)).to eq("hello world")
    end

    it "truncates long text and appends an ellipsis" do
      value = "This is a long sentence that should be truncated cleanly"
      clamped = described_class.clamp(value, 25)

      expect(clamped.length).to be <= 25
      expect(clamped).to end_with("…")
    end
  end

  describe ".ensure_unique" do
    it "returns original value when unseen and disambiguates duplicates" do
      seen = {}

      first = described_class.ensure_unique("Interview title", 70, "abc", seen)
      second = described_class.ensure_unique("Interview title", 70, "def", seen)

      expect(first).to eq("Interview title")
      expect(second).to include("(def)")
      expect(second).not_to eq(first)
    end
  end
end
