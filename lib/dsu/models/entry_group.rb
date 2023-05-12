# frozen_string_literal: true

require 'deco_lite'
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
    class EntryGroup < DecoLite::Model
      extend Support::EntryGroupLoadable
      include Support::TimeFormatable

      validates_with Validators::EntriesValidator, fields: [:entries]
      validates_with Validators::TimeValidator, fields: [:time]

      def initialize(time: nil, entries: [])
        raise ArgumentError, 'time is the wrong object type' unless time.is_a?(Time) || time.nil?
        raise ArgumentError, 'entries is the wrong object type' unless entries.is_a?(Array) || entries.nil?

        time ||= Time.now
        time = time.localtime if time.utc?

        entries ||= []

        super(hash: {
          time: time,
          entries: entries
        })
      end

      class << self
        def delete(time:, options: {})
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

        def exists?(time:)
          Dsu::Services::EntryGroupReaderService.entry_group_file_exists?(time: time)
        end

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

        def unique?(entry:)

        end
      end

      def required_fields
        %i[time entries]
      end

      def edit(options: {})
        Services::EntryGroupEditorService.new(entry_group: self, options: options).call
        self
      end

      # Deletes the entry group file from the file system.
      def delete
        self.class.delete(time: time)
        self
      end

      def entries?
        entries.any?
      end

      def save!
        validate!
        Services::EntryGroupWriterService.new(entry_group: self).call
      end

      def to_h
        super.tap do |hash|
          hash[:entries] = hash[:entries].dup
          hash[:entries].each_with_index do |entry, index|
            hash[:entries][index] = entry.to_h
          end
        end
      end

      def check_unique(sha_or_editor_command:, description:)
        raise ArgumentError, 'sha_or_editor_command is nil' if sha_or_editor_command.nil?
        raise ArgumentError, 'description is nil' if description.nil?
        raise ArgumentError, 'sha_or_editor_command is the wrong object type' unless sha_or_editor_command.is_a?(String)
        raise ArgumentError, 'description is the wrong object type' unless description.is_a?(String)

        if entries.blank?
          entry_unique_hash = entry_unique_hash_for(uuid_unique: true, description_unique: true)
          return entry_unique_struct_from(entry_unique_hash: entry_unique_hash)
        end

        entry_hash = entries.each_with_object({}) do |entry_group_entry, hash|
          hash[entry_group_entry.uuid] = entry_group_entry.description
        end

        # It is possible that sha_or_editor_command may have an editor command (e.g. +|a|add). If this
        # is the case, just treat it as unique because when the entry is added, it will get a unique uuid.
        uuid_unique = !sha_or_editor_command.match?(Entry::ENTRY_UUID_REGEX) || !entry_hash.key?(sha_or_editor_command)
        entry_unique_hash = entry_unique_hash_for(
          uuid: sha_or_editor_command,
          uuid_unique: uuid_unique,
          description: description,
          description_unique: !entry_hash.value?(description)
        )
        entry_unique_struct_from(entry_unique_hash: entry_unique_hash)
      end

      def entry_unique_hash_for(uuid_unique:, description_unique:, uuid: nil, description: nil)
        {
          uuid: uuid,
          uuid_unique: uuid_unique,
          description: description,
          description_unique: description_unique,
          formatted_time: Support::TimeFormatable.formatted_time(time: time)
        }
      end

      def entry_unique_struct_from(entry_unique_hash:)
        Struct.new(*entry_unique_hash.keys, keyword_init: true) do
          def unique?
            uuid_unique? && description_unique?
          end

          def uuid_unique?
            uuid_unique
          end

          def description_unique?
            description_unique
          end

          def messages
            return [] if unique?

            short_description = Models::Entry.short_description(string: description)

            messages = []
            messages << "#uuid is not unique: \"#{uuid} #{short_description}\"" unless uuid_unique?
            messages << "#description is not unique: \"#{uuid} #{short_description}\""
          end
        end.new(**entry_unique_hash)
      end
    end
  end
end
