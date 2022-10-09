# frozen_string_literal: true

require 'deco_lite'
require_relative 'entries_loader'
require_relative 'entries_version'
require_relative 'field_errors'
require_relative 'validate_time'
require_relative 'validate_version'

module Dsu
  module Support
    class Entries < DecoLite::Model
      include EntriesLoader
      include EntriesVersion
      include FieldErrors
      include ValidateTime
      include ValidateVersion

      validates :date, presence: true
      validate :validate_date
      validate :validate_entries

      def initialize(date: Time.now.utc)
        validate_date! date: date

        date = date.utc unless date.utc?
        entries = entries_for(date: date)
        hydrated_entries = hydrate_entries(entries_hash: entries, date: date)
        super(hash: hydrated_entries)
      end

      def required_fields
        %i[date entries version]
      end

      def to_h
        hash = super
        hash[:entries].each_with_index do |entry, index|
          hash[:entries][index] = entry.to_h
        end
        hash
      end

      private

      def validate_date
        return if date.is_a? Time

        errors.add(:date, 'is the wrong object type. ' \
                          "\"Time\" was expected, but \"#{date.class}\" was received.",
          type: FIELD_TYPE_ERROR)
      end

      def validate_entries
        if entries.is_a? Array
          entries.each do |entry|
            next if entry.is_a? Entry

            errors.add(:entries, 'entry Array element is the wrong object type. ' \
                                 "\"Entry\" was expected, but \"#{entry.class}\" was received.",
              type: FIELD_TYPE_ERROR)
          end

          return
        end

        errors.add(:entries, 'is the wrong object type. ' \
                             "\"Array\" was expected, but \"#{entries.class}\" was received.",
          type: FIELD_TYPE_ERROR)
      end
    end
  end
end
