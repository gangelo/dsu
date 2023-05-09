# frozen_string_literal: true

require 'deco_lite'
require_relative '../support/entry_group_loadable'
require_relative '../services/entry_group_reader_service'
require_relative '../services/entry_group_writer_service'
require_relative '../validators/entries_validator'
require_relative '../validators/time_validator'

module Dsu
  module Models
    class EntryGroup < DecoLite::Model
      extend Support::EntryGroupLoadable

      validates_with Validators::EntriesValidator, fields: [:entries]
      validates_with Validators::TimeValidator, fields: [:time]

      def initialize(time: nil, entries: [])
        raise ArgumentError, 'time is the wrong object type' unless time.is_a?(Time) || time.nil?
        raise ArgumentError, 'entries is the wrong object type' unless entries.is_a?(Array) || entries.nil?

        time ||= Time.now
        time = time.localtime if time.utc?

        entries ||= []

        super(hash: {
          time: time,
          entries: entries
        })
      end

      class << self
        def exists?(time:)
          Dsu::Services::EntryGroupReaderService.entry_group_file_exists?(time: time)
        end

        # Loads the EntryGroup from the file system and returns an
        # instantiated EntryGroup object.
        def load(time: nil)
          new(**hydrated_entry_group_hash_for(time: time))
        end

        # This function returns a hash whose :time and :entries
        # key values are hydrated with instantiated Time and Entry
        # objects.
        def hydrated_entry_group_hash_for(time:)
          entry_group_hash = entry_group_hash_for(time: time)
          hydrate_entry_group_hash(entry_group_hash: entry_group_hash, time: time)
        end
      end

      def required_fields
        %i[time entries]
      end

      def save!
        validate!
        Dsu::Services::EntryGroupWriterService.new(entry_group: self).call
      end

      def to_h
        super.tap do |hash|
          hash[:entries] = hash[:entries].dup
          hash[:entries].each_with_index do |entry, index|
            hash[:entries][index] = entry.to_h
          end
        end
      end

      def to_h_localized
        to_h.tap do |hash|
          hash[:time] = hash[:time].localtime
        end
      end
    end
  end
end
