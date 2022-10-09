# frozen_string_literal: true

require 'pathname'
require_relative 'entries_version'

module Dsu
  module Support
    module EntriesLoader
      include EntriesVersion

      module_function

      # returns a Hash having :date, :version and :entries
      # where entries == an Array of Entry Hashes
      # representing the JSON Entry objects for :date and
      # :version.
      def entries_for(date:)
        # TODO: If the entry data version is not current, update the entry? or
        # do this in bin/setup?
        entries = entries_json_for date: date
        return JSON.parse(entries, symbolize_names: true) if entries

        {
          date: date,
          version: ENTRIES_VERSION,
          entries: []
        }
      end

      private

      # Accepts a Hash of Entries data and returns the
      # hydrated version:
      #
      # {
      #   version: 'xxx',
      #   date: 'xxx',
      #   entries [
      #     <Entry object 0>,
      #     <Entry object 1>,
      #     ...
      #   ]
      # }
      def hydrate_entries(entries_hash:, date:)
        date = entries_hash.fetch(:date, date)
        date = Time.parse(date) unless date.is_a? Time
        version = entries_hash.fetch(:version, ENTRIES_VERSION)
        entries = entries_hash.fetch(:entries, [])
        entries = entries.map do |entry|
          entry[:time] = Time.parse(entry[:time])
          Entry.new(**entry)
        end

        { date: date, version: version, entries: entries }
      end

      # Loads and returns JSON Entries data from a file for :date if
      # the file exists; nil, otherwise.
      def entries_json_for(date:)
        date = date.utc unless date.utc?

        json_file = entries_json_file_name_for(date: date)
        return File.read(json_file) if File.exist? json_file
      end

      def entries_json_file_name_for(date:)
        json_file = "#{date.strftime('%Y-%m-%d')}.json"
        File.join(entries_json_file_path, json_file)
      end

      def entries_json_file_path
        File.join(Dir.home, 'dsu')
      end
    end
  end
end
