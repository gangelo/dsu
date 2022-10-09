# frozen_string_literal: true

require_relative 'entries_version'
require_relative 'field_errors'

module Dsu
  module Support
    module ValidateVersion
      include EntriesVersion
      include FieldErrors

      class << self
        def included(base)
          base.module_eval '
            validate :validate_version
          ', __FILE__, __LINE__ - 2
        end
      end

      def validate_version
        unless version.is_a? String
          errors.add(:version, 'is the wrong object type. ' \
                               "\"String\" was expected, but \"#{version.class}\" was received.",
            type: FIELD_TYPE_ERROR)
          return
        end

        if version.blank?
          errors.add(:version, "can't be blank", type: :blank)
          return
        end

        unless ENTRIES_VERSION_REGEXP.match?(version)
          errors.add(:version, 'is the wrong format. ' \
                               "#{ENTRIES_VERSION_REGEXP.source} format was expected, but \"#{version}\" was received.",
            type: FIELD_FORMAT_ERROR)
        end
      end
    end
  end
end
