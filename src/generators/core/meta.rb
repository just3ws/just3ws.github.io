module Generators
  module Core
    module Meta
      module_function

      def clamp(text, max_length)
        clean = text.to_s.gsub(/\s+/, " ").strip
        return clean if max_length <= 0
        return clean if clean.length <= max_length

        # If it fits perfectly after stripping trailing punctuation
        trimmed = clean[0, max_length].strip
        return trimmed if clean.length <= max_length + 3 && clean =~ /[.!?]$/

        # Standard truncation at word boundary
        truncated = clean[0, max_length - 1]
        return "" if truncated.nil? || truncated.empty?
        
        # Find last word boundary
        last_space = truncated.rindex(" ")
        if last_space && last_space > (max_length * 0.7)
          truncated = truncated[0, last_space]
        end

        "#{truncated.strip}…"
      end

      def ensure_unique(value, max_length, disambiguator, seen)
        candidate = value
        unless seen[candidate]
          seen[candidate] = true
          return candidate
        end

        suffix = " (#{disambiguator})"
        base_limit = max_length - suffix.length
        base = clamp(value, base_limit)
        base = base.gsub(/…\z/, "").strip
        candidate = "#{base}#{suffix}"
        candidate = clamp(candidate, max_length)

        if seen[candidate]
          candidate = clamp("#{value} #{disambiguator}", max_length)
        end

        seen[candidate] = true
        candidate
      end

      def ensure_min_length(value, min_length, extension)
        clean = value.to_s.gsub(/\s+/, " ").strip
        return clean if clean.length >= min_length

        joined = "#{clean} #{extension}".gsub(/\s+/, " ").strip
        joined
      end
    end
  end
end
