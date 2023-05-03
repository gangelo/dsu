# frozen_string_literal: true

require_relative '../services/entry_group_writer_service'
require_relative '../support/entry'
require_relative '../support/entry_group_loadable'
require_relative '../support/folder_locations'

module Dsu
  module CommandServices
    # This class adds (does NOT update) an entry to an entry group.
    class Add
      include Dsu::Support::EntryGroupLoadable
      include Dsu::Support::FolderLocations

      attr_reader :entry, :time

      # :entry is an Entry object
      # :time is a Time object; the time of the entry group.
      def initialize(entry:, time:)
        @entry = entry
        @time = time
      end

      def call
        entry.validate!
        save_entry_group! unless entry_exists?
        entry.uuid
      rescue ActiveModel::ValidationError
        puts "Error(s) encountered: #{entry.errors.full_messages}"
        raise
      end

      private

      attr_writer :entry, :time

      def entry_exists?
        @entry_exists ||= entry_group_hash[:entries].any? { |e| e[:uuid] == entry.uuid }
      end

      def entry_group_hash
        @entry_group_hash ||= entry_group_hash_for time: time
      end

      def save_entry_group!
        raise "Entry #{entry.uuid} already exists in entry group #{time}" if entry_exists?

        entry_group_hash[:entries] << entry.to_h

        Dsu::Services::EntryGroupWriterService.new(entry_group: entry_group_hash).call
      end
    end
  end
end
