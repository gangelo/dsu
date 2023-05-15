# frozen_string_literal: true

require_relative '../models/entry'
require_relative '../support/field_errors'

module Dsu
  module Validators
    class EntryUniqueValidator < ActiveModel::Validator
      include Support::FieldErrors

      def validate(record)
        return if record.entry_group.entries.empty?
        return unless record.entry_group.entries.map(&:description).include?(record.description)

        record.errors.add(:description, 'for this entry already exists within the entry group: ' \
                                        "\"#{record.short_description}\".",
                                        type: Support::FieldErrors::FIELD_DUPLICATE_ERROR)
      end
    end
  end
end
