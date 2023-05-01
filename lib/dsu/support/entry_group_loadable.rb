# frozen_string_literal: true

require 'pathname'
require_relative '../services/entry_group_reader_service'
require_relative 'entries_version'

module Dsu
  module Support
    module EntryGroupLoadable
      include EntriesVersion

      module_function

      # returns a Hash having :time, :version and :entries
      # where entries == an Array of Entry Hashes
      # representing the JSON Entry objects for :time and
      # :version.
      def entry_group_hash_for(time:)
        # TODO: If the entry data version is not current, update the entry? or
        # do this in bin/setup?
        # entry_group = entry_group_json_for time: time
        entry_group_json = Dsu::Services::EntryGroupReaderService.new(time: time).call
        if entry_group_json.present?
          return JSON.parse(entry_group_json, symbolize_names: true).tap do |hash|
            hash[:time] = Time.parse(hash[:time])
            hash[:entries].each do |entry|
              entry[:time] = Time.parse(entry[:time])
            end
          end
        end

        {
          time: time,
          version: ENTRIES_VERSION,
          entries: []
        }
      end

      private

      # Accepts an entry group hash and returns a
      # hydrated entry group hash:
      #
      # {
      #   version: 'xxx',
      #   time: <Time object>,
      #   entries [
      #     <Entry object 0>,
      #     <Entry object 1>,
      #     ...
      #   ]
      # }
      def hydrate_entry_group_hash(entry_group_hash:, time:)
        time = entry_group_hash.fetch(:time, time)
        time = Time.parse(time) unless time.is_a? Time
        version = entry_group_hash.fetch(:version, ENTRIES_VERSION)
        entries = entry_group_hash.fetch(:entries, [])
        entries = entries.map do |entry|
          entry[:time] = Time.parse(entry[:time]) unless entry[:time].is_a? Time
          Entry.new(**entry)
        end

        { time: time, version: version, entries: entries }
      end
    end
  end
end
