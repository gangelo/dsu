# frozen_string_literal: true

require_relative 'short_string'

module Dsu
  module Support
    module Descriptable
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
        include ShortString

        def short_description(string:, count: ShortString::SHORT_STRING_MAX_COUNT, elipsis: '...')
          short_string(string: string, count: count, elipsis: elipsis)
        end
      end
    end
  end
end
