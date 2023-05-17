# frozen_string_literal: true

require_relative '../models/entry'
require_relative '../support/field_errors'

# https://guides.rubyonrails.org/active_record_validations.html#validates-with
module Dsu
  module Validators
    class EntriesValidator < ActiveModel::Validator
      include Support::FieldErrors

      def validate(record)
        raise 'options[:fields] is not defined.' unless options.key? :fields
        raise 'options[:fields] is not an Array.' unless options[:fields].is_a? Array
        raise 'options[:fields] elements are not Symbols.' unless options[:fields].all?(Symbol)

        options[:fields].each do |field|
          entries = record.send(field)

          unless entries.is_a?(Array)
            record.errors.add(field, 'is the wrong object type. ' \
                                     "\"Array\" was expected, but \"#{entries.class}\" was received.")
            next
          end

          validate_entry_types field, entries, record
          validate_unique_entry_attr :description, field, entries, record
        end
      end

      private

      def validate_entry_types(field, entries, record)
        entries.each do |entry|
          next if entry.is_a? Dsu::Models::Entry

          record.errors.add(field, 'entry Array element is the wrong object type. ' \
                                   "\"Entry\" was expected, but \"#{entry.class}\" was received.",
            type: Support::FieldErrors::FIELD_TYPE_ERROR)

          next
        end
      end

      def validate_unique_entry_attr(attr, field, entries, record)
        return unless entries.is_a? Array

        entry_objects = entries.select { |entry| entry.is_a?(Dsu::Models::Entry) }

        attrs = entry_objects.map(&attr)
        return if attrs.uniq.length == attrs.length

        non_unique_attrs = attrs.select { |attr| attrs.count(attr) > 1 }.uniq # rubocop:disable Lint/ShadowingOuterLocalVariable
        if non_unique_attrs.any?
          record.errors.add(field, "contains a duplicate ##{attr}: \"#{non_unique_attrs.join(', ')}\".",
            type: Support::FieldErrors::FIELD_DUPLICATE_ERROR)
        end
      end
    end
  end
end
