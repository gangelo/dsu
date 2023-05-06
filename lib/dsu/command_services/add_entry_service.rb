# frozen_string_literal: true

require_relative '../services/entry_group_writer_service'
require_relative '../models/entry'
require_relative '../support/entry_group_loadable'
require_relative '../support/folder_locations'

module Dsu
  module CommandServices
    # This class adds (does NOT update) an entry to an entry group.
    class AddEntryService
      include Dsu::Support::EntryGroupLoadable
      include Dsu::Support::FolderLocations

      attr_reader :entry, :entry_group, :time

      # :entry is an Entry object
      # :time is a Time object; the time of the entry group.
      def initialize(entry:, time:)
        raise ArgumentError, 'entry is nil' if entry.nil?
        raise ArgumentError, 'entry is the wrong object type' unless entry.is_a?(Dsu::Models::Entry)
        raise ArgumentError, 'time is nil' if time.nil?
        raise ArgumentError, 'time is the wrong object type' unless time.is_a?(Time)

        @entry = entry
        @time = time
        @entry_group = Dsu::Models::EntryGroup.load(time: time)
      end

      def call
        entry.validate!
        save_entry_group!
        entry.uuid
      rescue ActiveModel::ValidationError
        puts "Error(s) encountered: #{entry.errors.full_messages}"
        raise
      end

      private

      attr_writer :entry, :entry_group, :time

      def entry_exists?
        @entry_exists ||= entry_group.entries.include? entry.uuid
      end

      def entry_group_hash
        @entry_group_hash ||= entry_group_hash_for time: time
      end

      def save_entry_group!
        raise "Entry #{entry.uuid} already exists in entry group #{time}" if entry_exists?

        entry_group.entries << entry
        entry_group.validate!

        Dsu::Services::EntryGroupWriterService.new(entry_group: entry_group).call
      end
    end
  end
end
