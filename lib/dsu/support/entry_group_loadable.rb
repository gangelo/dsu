# frozen_string_literal: true

require 'pathname'
require_relative '../services/entry_group_reader_service'
require_relative '../models/entry'

module Dsu
  module Support
    module EntryGroupLoadable
      module_function

      # returns a Hash having :time and :entries
      # where entries == an Array of Entry Hashes
      # representing the JSON Entry objects for :time.
      def entry_group_hash_for(time:)
        entry_group_json = Services::EntryGroupReaderService.new(time: time).call
        if entry_group_json.present?
          return JSON.parse(entry_group_json, symbolize_names: true).tap do |hash|
            hash[:time] = Time.parse(hash[:time])
          end
        end

        {
          time: time,
          entries: []
        }
      end

      private

      # Accepts an entry group hash and returns a
      # hydrated entry group hash:
      #
      # {
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
        entries = entry_group_hash.fetch(:entries, [])
        entries = entries.map { |entry_hash| Models::Entry.new(**entry_hash) }

        { time: time, entries: entries }
      end
    end
  end
end
