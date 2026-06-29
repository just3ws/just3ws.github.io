require "yaml"
require "date"

module Generators
  module Core
    module YamlIo
      module_function

      def load(path, key: nil)
        parsed = YAML.safe_load(File.read(path), permitted_classes: [Date, Time], aliases: true) || {}
        return parsed unless key

        parsed[key] || []
      end

      def dump(path, object, preserve_generated_at: false)
        payload = preserve_generated_at ? preserve_existing_generated_at(path, object) : object
        File.write(path, YAML.dump(payload))
      end

      def preserve_existing_generated_at(path, object)
        return object unless object.is_a?(Hash)
        return object unless object.key?("generated_at")
        return object unless File.file?(path)

        existing = load(path)
        return object unless existing.is_a?(Hash)
        return object unless existing.key?("generated_at")

        existing_without_generated_at = existing.reject { |key, _value| key == "generated_at" }
        object_without_generated_at = object.reject { |key, _value| key == "generated_at" }
        return object unless existing_without_generated_at == object_without_generated_at

        object.merge("generated_at" => existing["generated_at"])
      end
    end
  end
end
