# frozen_string_literal: true

module Dsu
  module Validators
    class DescriptionValidator < ActiveModel::Validator
      def validate(record)
        raise 'options[:fields] is not defined.' unless options.key? :fields
        raise 'options[:fields] is not an Array.' unless options[:fields].is_a? Array
        raise 'options[:fields] elements are not Symbols.' unless options[:fields].all?(Symbol)

        options[:fields].each do |field|
          description = record.send(field)

          if description.blank?
            record.errors.add(field, :blank)
            next
          end

          unless description.is_a?(String)
            record.errors.add(field, 'is the wrong object type. ' \
                                     "\"String\" was expected, but \"#{description.class}\" was received.")
            next
          end

          validate_description field: field, description: description, record: record
        end
      end

      private

      def validate_description(field:, description:, record:)
        return if description.length.between?(2, 256)

        if description.length < 2
          record.errors.add(field, "is too short: \"#{record.short_description}\" (minimum is 2 characters).")
        elsif description.length > 256
          record.errors.add(field, "is too long: \"#{record.short_description}\" (maximum is 256 characters).")
        end
      end
    end
  end
end
