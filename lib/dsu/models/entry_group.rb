# frozen_string_literal: true

require 'active_model'
require_relative '../services/entry_group_editor_service'
require_relative '../services/entry_group_deleter_service'
require_relative '../services/entry_group_reader_service'
require_relative '../services/entry_group_writer_service'
require_relative '../support/entry_group_loadable'
require_relative '../support/time_formatable'
require_relative '../validators/entries_validator'
require_relative '../validators/time_validator'
require_relative 'entry'

module Dsu
  module Models
    # This class represents a group of entries for a given day. IOW,
    # things someone might want to share at their daily standup (DSU).
    class EntryGroup
      include ActiveModel::Model
      extend Support::EntryGroupLoadable
      include Support::TimeFormatable

      attr_accessor :time
      attr_reader :entries

      validates_with Validators::EntriesValidator
      validates_with Validators::TimeValidator

      def initialize(time: nil, entries: [])
        raise ArgumentError, 'time is the wrong object type' unless time.is_a?(Time) || time.nil?

        @time = ensure_local_time(time)
        self.entries = entries || []
      end

      class << self
        def delete!(time:, options: {})
          Services::EntryGroupDeleterService.new(time: time, options: options).call
        end

        def edit(time:, options: {})
          # NOTE: Uncomment this line to prohibit edits on
          # Entry Groups that do not exist (i.e. have no entries).
          # return new(time: time) unless exists?(time: time)

          load(time: time).tap do |entry_group|
            Services::EntryGroupEditorService.new(entry_group: entry_group, options: options).call
          end
        end

        def exists?(time:)
          Dsu::Services::EntryGroupReaderService.entry_group_file_exists?(time: time)
        end
      end

      def valid_unique_entries
        entries&.select(&:valid?)&.uniq(&:description)
      end

      def clone
        clone = super

        clone.entries = clone.entries.map(&:clone)
        clone
      end

      def entries=(entries)
        entries ||= []

        raise ArgumentError, 'entries is the wrong object type' unless entries.is_a?(Array)
        raise ArgumentError, 'entries contains the wrong object type' unless entries.all?(Entry)

        @entries = entries.map(&:clone)
      end

      # Deletes the entry group file from the file system.
      def delete!
        self.class.delete!(time: time)
        self.entries = []
        self
      end

      def save!
        delete! and return if entries.empty?

        validate!
        Services::EntryGroupWriterService.new(entry_group: self).call
        self
      end

      def to_h
        {
          time: time.dup,
          entries: entries.map(&:to_h)
        }
      end

      private

      def ensure_local_time(time)
        time.nil? ? Time.now : time.dup.localtime
      end
    end
  end
end
