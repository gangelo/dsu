# frozen_string_literal: true

module Dsu
  module Validators
    class DescriptionValidator < ActiveModel::Validator
      def validate(record)
        description = record.description

        if description.blank?
          record.errors.add(:description, :blank)
          return
        end

        unless description.is_a?(String)
          # TODO: I18n.
          record.errors.add(:description, 'is the wrong object type. ' \
                                          "\"String\" was expected, but \"#{description.class}\" was received.")
          return
        end

        validate_description record
      end

      private

      def validate_description(record)
        description = record.description

        return if description.length.between?(min_description_length(record), max_description_length(record))

        if description.length < min_description_length(record)
          # TODO: I18n.
          record.errors.add(:description, "is too short: \"#{record.short_description}\" " \
                                          "(minimum is #{min_description_length(record)} characters).")
        elsif description.length > max_description_length(record)
          # TODO: I18n.
          record.errors.add(:description, "is too long: \"#{record.short_description}\" " \
                                          "(maximum is #{max_description_length(record)} characters).")
        end
      end

      def min_description_length(record)
        record.class::MIN_DESCRIPTION_LENGTH
      end

      def max_description_length(record)
        record.class::MAX_DESCRIPTION_LENGTH
      end
    end
  end
end
