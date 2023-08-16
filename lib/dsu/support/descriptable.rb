# frozen_string_literal: true

module Dsu
  module Support
    module Descriptable
      DESCRIPTION_MAX_COUNT = 25

      class << self
        def included(base)
          base.extend(ClassMethods)
        end
      end

      def short_description
        return '' if description.blank?

        self.class.short_description(string: description)
      end

      module ClassMethods
        def short_description(string:, count: DESCRIPTION_MAX_COUNT, elipsis: '...')
          return elipsis unless string.is_a?(String)

          elipsis_length = elipsis.length
          count = elipsis_length if count.nil? || count < elipsis_length

          return string if string.length <= count

          tokens = string.split
          string = ''

          return "#{tokens.first[0...(count - elipsis_length)]}#{elipsis}" if tokens.count == 1

          tokens.each do |token|
            break if string.length + token.length + elipsis_length > count

            string = "#{string} #{token}"
          end

          "#{string.strip}#{elipsis}"
        end
      end
    end
  end
end
