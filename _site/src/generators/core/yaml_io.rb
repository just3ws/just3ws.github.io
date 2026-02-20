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

      def dump(path, object)
        File.write(path, YAML.dump(object))
      end
    end
  end
end
