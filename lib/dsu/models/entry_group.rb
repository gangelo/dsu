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
    class EntryGroup
      include ActiveModel::Model
      extend Support::EntryGroupLoadable
      include Support::TimeFormatable

      attr_accessor :time
      attr_reader :entries

      validates_with Validators::EntriesValidator, fields: [:entries]
      validates_with Validators::TimeValidator, fields: [:time]

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
            entry_group.edit(options: options)
          end
        end

        # def entry_info_by_description(entries:)
        #   entries.each_with_index.with_object({}) do |entry_index, hash|
        #     entry, index = entry_index
        #     description = entry.description
        #     hash[description] = { at: [], count: 0 } unless hash.key? description
        #     count = entries.count { |e| e.description == description }
        #     hash[description][:at] << index
        #     hash[description][:count] = count
        #     hash
        #   end
        # end

        # def duplicate_entries_by_description(entries:)
        #   entries.each_with_object({}) do |entry, hash|
        #     description = entry.description
        #     hash[description] = [] unless hash.key? description
        #     hash[description] << entry
        #   end
        # end

        def exists?(time:)
          Dsu::Services::EntryGroupReaderService.entry_group_file_exists?(time: time)
        end

        # def invalid_entries
        #   entries.select(&:invalid?)
        # end

        # def duplicate_entries
        #   return [] if entries.none?

        #   # entries.select(&:valid?) - entries.select(&:valid?).uniq(&:description)
        #   entries - entries.uniq(&:description)
        # end

        # def valid_unique_entries
        #   return [] if entries.none?

        #   entries.select(&:valid?) - duplicate_entries
        # end

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

      # def different_entries(other_entries:)
      #   entries.reject do |entry|
      #     other_entries.any? { |other_entry| entry.description == other_entry.description }
      #   end
      # end

      # def valid_unique_entries
      #   return [] if entries.none?

      #   entries.select(&:valid?) - duplicate_entries
      # end

      def clone
        clone = super

        clone.entries = clone.entries.map(&:clone)
        clone
      end

      def edit(options: {})
        Services::EntryGroupEditorService.new(entry_group: self, options: options).call
        self
      end

      def entries?
        entries.any?
      end

      def entries=(entries)
        entries ||= []

        raise ArgumentError, 'entries is the wrong object type' unless entries.is_a?(Array)
        raise ArgumentError, 'entries contains the wrong object type' unless entries.all?(Entry)

        @entries = entries.map(&:clone)
      end

      # def entry_info_by_description
      #   self.class.entry_info_by_description(entries: entries)
      # end

      # def duplicate_entries_by_description
      #   self.class.duplicate_entries_by_description(entries: entries)
      # end

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
