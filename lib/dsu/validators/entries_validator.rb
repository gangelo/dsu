# frozen_string_literal: true

require_relative '../models/entry'
require_relative '../support/field_errors'

# https://guides.rubyonrails.org/active_record_validations.html#validates-with
module Dsu
  module Validators
    class EntriesValidator < ActiveModel::Validator
      include Support::FieldErrors

      def validate(record)
        unless record.entries.is_a?(Array)
          record.errors.add(:entries, 'is the wrong object type. ' \
                                      "\"Array\" was expected, but \"#{record.entries.class}\" was received.")
        end

        validate_entry_types record
        validate_unique_entry_attr record
      end

      private

      def validate_entry_types(record)
        record.entries.each do |entry|
          next if entry.is_a? Dsu::Models::Entry

          record.errors.add(:entries, 'entry Array element is the wrong object type. ' \
                                      "\"Entry\" was expected, but \"#{entry.class}\" was received.",
            type: Support::FieldErrors::FIELD_TYPE_ERROR)
        end
      end

      def validate_unique_entry_attr(record)
        return unless record.entries.is_a? Array

        entry_objects = record.entries.select { |entry| entry.is_a?(Dsu::Models::Entry) }

        descriptions = entry_objects.map(&:description)
        return if descriptions.uniq.length == descriptions.length

        non_unique_descriptions = descriptions.select { |description| descriptions.count(description) > 1 }.uniq
        if non_unique_descriptions.any?
          record.errors.add(:entries, 'contains a duplicate entry: ' \
                                      "#{format_non_unique_descriptions(non_unique_descriptions)}.",
            type: Support::FieldErrors::FIELD_DUPLICATE_ERROR)
        end
      end

      def format_non_unique_descriptions(non_unique_descriptions)
        non_unique_descriptions.map { |description| "\"#{short_description(description)}\"" }.join(', ')
      end

      def short_description(description)
        Models::Entry.short_description(string: description)
      end
    end
  end
end
