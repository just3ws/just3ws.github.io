module Generators
  module Core
    module Text
      module_function

      def yaml_quote(value)
        str = value.to_s.tr("\n", " ")
        "\"#{str.gsub('"', '\"')}\""
      end

      def normalize_subject(value)
        value.to_s.strip
             .sub(/\AInterview with\s+/i, "")
             .sub(/\AInterview\s*[-:]\s+/i, "")
             .gsub(/\s+/, " ")
             .strip
      end
    end
  end
end
