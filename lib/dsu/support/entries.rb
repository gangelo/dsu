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

      validate :validate_entries

      def initialize(time: nil)
        time ||= Time.now.utc

        unless time.is_a? Time
          raise ':time is the wrong object type. ' \
                "\"Time\" was expected, but \"#{time.class}\" was received."
        end

        time = time.utc unless time.utc?
        entries = entries_for(time: time)
        hydrated_entries = hydrate_entries(entries_hash: entries, time: time)
        super(hash: hydrated_entries)
      end

      def required_fields
        %i[time entries version]
      end

      def to_h
        hash = super
        hash[:entries].tap do |entries|
          entries.each_with_index do |entry, index|
            entries[index] = entry.to_h
          end
          sort_entries! entries if entries.present?
        end
        hash
      end

      def to_h_localized
        hash = to_h
        hash[:time] = hash[:time].localtime
        hash[:entries].tap do |entries|
          entries.each do |entry|
            entry[:time] = entry[:time].localtime
          end
          sort_entries! entries if entries.present?
        end
        hash
      end

      private

      def sort_entries!(entries)
        entries.sort! { |entry| entry[:order] }
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
