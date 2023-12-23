# frozen_string_literal: true

# https://guides.rubyonrails.org/active_record_validations.html#validates-with
module Dsu
  module Validators
    class TimeValidator < ActiveModel::Validator
      def validate(record)
        time = record.time

        if time.nil?
          record.errors.add(:time, :blank)
          return
        end

        unless time.is_a?(Time)
          record.errors.add(:time, 'is the wrong object type. ' \
                                   "\"Time\" was expected, but \"#{time.class}\" was received.")
          return
        end

        record.errors.add(:time, 'is not in localtime format.') unless time == time.in_time_zone
      end
    end
  end
end
