# frozen_string_literal: true

module Dsu
  module Support
    module ShortString
      SHORT_STRING_MAX_COUNT = 25

      module_function

      def short_string(string:, count: SHORT_STRING_MAX_COUNT, elipsis: '...')
        return '' if string.blank?
        return string if string.length <= count

        # Trim to max count and cut at the last space within the limit
        trimmed_string = string[0...count].rpartition(' ')[0]

        # If no space found, trim by characters
        trimmed_string = string[0...(count - elipsis.length)] if trimmed_string.empty? && !string.empty?

        "#{trimmed_string}#{elipsis}"
      end
    end
  end
end
