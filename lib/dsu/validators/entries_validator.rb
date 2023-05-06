# frozen_string_literal: true

require_relative '../models/entry'
require_relative '../support/field_errors'

# https://guides.rubyonrails.org/active_record_validations.html#validates-with
module Dsu
  module Validators
    class EntriesValidator < ActiveModel::Validator
      include Dsu::Support::FieldErrors

      def validate(record)
        raise 'options[:fields] is not defined.' unless options.key? :fields
        raise 'options[:fields] is not an Array.' unless options[:fields].is_a? Array
        raise 'options[:fields] elements are not Symbols.' unless options[:fields].all? { |field| field.is_a? Symbol }

        options[:fields].each do |field|
          entries = record.send(field)

          unless entries.is_a?(Array)
            record.errors.add(field, 'is the wrong object type. ' \
                  "\"Array\" was expected, but \"#{entries.class}\" was received.")
            next
          end

          validate_entry_types field, entries, record
          validate_unique_entry_uuids field, entries, record
        end
      end

      private

      def validate_entry_types(field, entries, record)
        entries.each do |entry|
          next if entry.is_a? Dsu::Models::Entry

          record.errors.add(field, 'entry Array element is the wrong object type. ' \
                                "\"Entry\" was expected, but \"#{entry.class}\" was received.",
            type: Dsu::Support::FieldErrors::FIELD_TYPE_ERROR)

          next
        end
      end

      def validate_unique_entry_uuids(field, entries, record)
        return unless entries.is_a? Array

        entry_objects = entries.select { |entry| entry.is_a?(Dsu::Models::Entry) }

        entry_objects.map(&:uuid).tap do |uuids|
          return if uuids.uniq.length == uuids.length
        end

        entry_objects.map(&:uuid).tap do |uuids|
          non_unique_uuids = uuids.select{ |element| uuids.count(element) > 1 }.uniq
          if non_unique_uuids.any?
            record.errors.add(field, "contains duplicate UUIDs: #{non_unique_uuids.join(', ')}.",
              type: Dsu::Support::FieldErrors::FIELD_DUPLICATE_ERROR)
          end
        end
      end
    end
  end
end
