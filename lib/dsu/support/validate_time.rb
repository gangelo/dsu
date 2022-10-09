# frozen_string_literal: true

require_relative 'field_errors'

module Dsu
  module Support
    module ValidateTime
      include FieldErrors

      class << self
        def included(base)
          base.module_eval '
            validate :validate_time
            validates :time, presence: true
          ', __FILE__, __LINE__ - 3
        end
      end

      def validate_time
        unless time.is_a? Time
          errors.add(:time, 'is the wrong object type. ' \
                            "\"Time\" was expected, but \"#{time.class}\" was received.",
            type: FIELD_TYPE_ERROR)
        end
      end
    end
  end
end
