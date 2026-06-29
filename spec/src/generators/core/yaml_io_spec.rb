# frozen_string_literal: true

require "date"
require "src/generators/core/yaml_io"

RSpec.describe Generators::Core::YamlIo do
  it "loads keyed content from yaml" do
    Dir.mktmpdir do |dir|
      path = File.join(dir, "sample.yml")
      File.write(path, { "items" => [{ "id" => "x1" }] }.to_yaml)

      result = described_class.load(path, key: "items")
      expect(result).to eq([{ "id" => "x1" }])
    end
  end

  it "dumps and reloads plain objects" do
    Dir.mktmpdir do |dir|
      path = File.join(dir, "roundtrip.yml")
      input = { "name" => "test", "count" => 2 }

      described_class.dump(path, input)
      output = described_class.load(path)

      expect(output).to eq(input)
    end
  end

  it "preserves generated_at when the generated payload is otherwise unchanged" do
    Dir.mktmpdir do |dir|
      path = File.join(dir, "generated.yml")
      existing = { "generated_at" => "2026-06-28T22:35:05Z", "items" => [{ "id" => "x1" }] }
      input = { "generated_at" => "2026-06-29T01:00:00Z", "items" => [{ "id" => "x1" }] }
      File.write(path, existing.to_yaml)

      described_class.dump(path, input, preserve_generated_at: true)
      output = described_class.load(path)

      expect(output).to eq(existing)
    end
  end

  it "updates generated_at when the generated payload changes" do
    Dir.mktmpdir do |dir|
      path = File.join(dir, "generated.yml")
      existing = { "generated_at" => "2026-06-28T22:35:05Z", "items" => [{ "id" => "x1" }] }
      input = { "generated_at" => "2026-06-29T01:00:00Z", "items" => [{ "id" => "x2" }] }
      File.write(path, existing.to_yaml)

      described_class.dump(path, input, preserve_generated_at: true)
      output = described_class.load(path)

      expect(output).to eq(input)
    end
  end
end
