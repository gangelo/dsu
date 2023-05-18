# frozen_string_literal: true

require 'pathname'
require_relative '../services/entry_group_reader_service'
require_relative '../models/entry'
require_relative '../models/entry_group'

module Dsu
  module Support
    module EntryGroupLoadable
      # returns an EntryGroup object loaded from
      # the entry group json file.
      def load(time:)
        entry_group_json = Services::EntryGroupReaderService.new(time: time).call
        hash = if entry_group_json.present?
          JSON.parse(entry_group_json, symbolize_names: true).tap do |hash|
            hash[:time] = Time.parse(hash[:time])
          end
        else
          { time: time, entries: [] }
        end

        Models::EntryGroup.new(**hydrate_entry_group_hash(hash: hash, time: time))
      end

      module_function

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
      def hydrate_entry_group_hash(hash:, time:)
        time = hash.fetch(:time, time)
        time = Time.parse(time) unless time.is_a? Time
        entries = hash.fetch(:entries, [])
        entries = entries.map { |entry_hash| Models::Entry.new(**entry_hash) }

        { time: time, entries: entries }
      end
    end
  end
end
