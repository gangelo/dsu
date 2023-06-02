# frozen_string_literal: true

require_relative '../models/entry'
require_relative '../services/entry_group/writer_service'
require_relative '../support/colorable'
require_relative '../support/descriptable'
require_relative '../support/entry_group_loadable'
require_relative '../support/folder_locations'
require_relative '../support/say'
require_relative '../views/shared/messages'

module Dsu
  module CommandServices
    # This class adds (does NOT update) an entry to an entry group by
    # writing it to the appropriate entry group json file.
    class AddEntryService
      include Support::Colorable
      include Support::Descriptable
      include Support::EntryGroupLoadable
      include Support::FolderLocations
      include Support::Say

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
      rescue ActiveModel::ValidationError => e
        header = 'An error was encountered; the entry could not be added added:'
        Views::Shared::Messages.new(messages: e.message, message_type: :error, options: { header: header }).render
      end

      private

      attr_writer :entry, :entry_group, :time

      def save_entry_group!
        entry_group.entries << entry
        entry_group.validate!

        Services::EntryGroup::WriterService.new(entry_group: entry_group).call
      end
    end
  end
end
