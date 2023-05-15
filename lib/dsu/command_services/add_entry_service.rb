# frozen_string_literal: true

require_relative '../services/entry_group_writer_service'
require_relative '../models/entry'
require_relative '../support/descriptable'
require_relative '../support/entry_group_loadable'
require_relative '../support/folder_locations'

module Dsu
  module CommandServices
    # This class adds (does NOT update) an entry to an entry group.
    class AddEntryService
      include Support::Descriptable
      include Support::EntryGroupLoadable
      include Support::FolderLocations

      attr_reader :entry, :entry_group, :time

      delegate :description, to: :entry

      # :entry is an Entry object
      # :time is a Time object; the time of the entry group.
      def initialize(entry:, time:)
        raise ArgumentError, 'entry is nil' if entry.nil?
        raise ArgumentError, 'entry is the wrong object type' unless entry.is_a?(Models::Entry)
        raise ArgumentError, 'time is nil' if time.nil?
        raise ArgumentError, 'time is the wrong object type' unless time.is_a?(Time)

        @entry = entry
        @time = time
        @entry_group = Models::EntryGroup.load(time: time)
      end

      def call
        entry.validate!
        save_entry_group!
        entry
      rescue ActiveModel::ValidationError
        puts "Error(s) encountered: #{entry.errors.full_messages}"
        raise
      end

      private

      attr_writer :entry, :entry_group, :time

      def entry_exists?
        @entry_exists ||= entry_group.entries.map(&:description).include?(entry.description)
      end

      def entry_group_hash
        @entry_group_hash ||= entry_group_hash_for time: time
      end

      def save_entry_group!
        raise "Entry with description \"#{short_description}\" already exists in entry group #{time}" if entry_exists?

        entry_group.entries << entry
        entry_group.validate!

        Services::EntryGroupWriterService.new(entry_group: entry_group).call
      end
    end
  end
end
