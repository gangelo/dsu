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
          record.errors.add(:description, 'is the wrong object type. ' \
                                          "\"String\" was expected, but \"#{description.class}\" was received.")
          return
        end

        validate_description record
      end

      private

      def validate_description(record)
        description = record.description

        return if description.length.between?(2, 256)

        if description.length < 2
          # TODO: I18n.
          record.errors.add(:description, "is too short: \"#{record.short_description}\" (minimum is 2 characters).")
        elsif description.length > 256
          # TODO: I18n.
          record.errors.add(:description, "is too long: \"#{record.short_description}\" (maximum is 256 characters).")
        end
      end
    end
  end
end
