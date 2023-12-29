# frozen_string_literal: true

require_relative '../models/entry'
require_relative '../support/field_errors'

# https://guides.rubyonrails.org/active_record_validations.html#validates-with
module Dsu
  module Validators
    # TODO: I18n.
    class EntriesValidator < ActiveModel::Validator
      include Support::FieldErrors

      def validate(record)
        unless record.entries.is_a?(Array)
          record.errors.add(:entries, 'is the wrong object type. ' \
                                      "\"Array\" was expected, but \"#{record.entries.class}\" was received.")
          return
        end

        return if validate_entry_types record

        validate_unique_entry record
        validate_entries record
      end

      private

      def validate_entry_types(record)
        record.entries.each do |entry|
          next if entry.is_a? Dsu::Models::Entry

          record.errors.add(:entries, 'Array element is the wrong object type. ' \
                                      "\"Entry\" was expected, but \"#{entry.class}\" was received.",
            type: Support::FieldErrors::FIELD_TYPE_ERROR)
        end

        record.errors.any?
      end

      def validate_unique_entry(record)
        return unless record.entries.is_a? Array

        entry_objects = record.entries.select { |entry| entry.is_a?(Dsu::Models::Entry) }

        descriptions = entry_objects.map(&:description)
        return if descriptions.uniq.length == descriptions.length

        non_unique_descriptions = descriptions.select { |description| descriptions.count(description) > 1 }.uniq
        non_unique_descriptions.each do |non_unique_description|
          # TODO: I18n.
          record.errors.add(:entries,
            "array contains duplicate entry: \"#{short_description(non_unique_description)}\".",
            type: Support::FieldErrors::FIELD_DUPLICATE_ERROR)
        end

        record.errors.any?
      end

      def validate_entries(record)
        entries = record.entries
        return if entries.none?

        entries.each do |entry|
          next if entry.valid?

          entry.errors.each do |error|
            record.errors.add(:entries_entry, error.full_message)
          end
        end
      end

      def short_description(description)
        Models::Entry.short_description(string: description)
      end
    end
  end
end
