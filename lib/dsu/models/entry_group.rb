# frozen_string_literal: true

require 'active_model'
require_relative '../crud/json_file'
require_relative '../migration/version'
require_relative '../services/entry_group/editor_service'
require_relative '../support/fileable'
require_relative '../support/presentable'
require_relative '../support/time_comparable'
require_relative '../support/time_formatable'
require_relative '../validators/entries_validator'
require_relative '../validators/time_validator'
require_relative '../validators/version_validator'
require_relative 'entry'

module Dsu
  module Models
    # This class represents a group of entries for a given day. IOW,
    # things someone might want to share at their daily standup (DSU).
    class EntryGroup < Crud::JsonFile
      include Support::Fileable
      include Support::Presentable
      include Support::TimeComparable
      include Support::TimeFormatable

      ENTRIES_FILE_NAME_REGEX = /\d{4}-\d{2}-\d{2}.json/
      ENTRIES_FILE_NAME_TIME_REGEX = /\d{4}-\d{2}-\d{2}/
      VERSION = Migration::VERSION

      attr_accessor :time, :version
      attr_reader :entries, :options

      validates_with Validators::EntriesValidator
      validates_with Validators::TimeValidator
      validates_with Validators::VersionValidator

      def initialize(time: nil, entries: nil, version: nil, options: {})
        raise ArgumentError, 'time is the wrong object type' unless time.is_a?(Time) || time.nil?
        raise ArgumentError, 'version is the wrong object type' unless version.is_a?(Integer) || version.nil?

        FileUtils.mkdir_p(entries_folder)

        @time = ensure_local_time(time)

        super(entries_path(time: @time))

        @version = version || VERSION
        self.entries = entries || []
        @options = options || {}
      end

      # Override == and hash so that we can compare Entry Group objects.
      def ==(other)
        return false unless other.is_a?(EntryGroup) &&
                            version == other.version &&
                            time_equal?(other_time: other.time)

        entries == other.entries
      end
      alias eql? ==

      def clone
        self.class.new(time: time, entries: entries.map(&:clone), version: version)
      end

      def delete
        self.class.delete(time: time)
        entries.clear
      end

      def delete!
        self.class.delete!(time: time)
        entries.clear
      end

      def entries=(entries)
        entries ||= []

        raise ArgumentError, 'entries is the wrong object type' unless entries.is_a?(Array)
        raise ArgumentError, 'entries contains the wrong object type' unless entries.all?(Entry)

        @entries = entries.map(&:clone)
      end

      def exist?
        self.class.exist?(time: time)
      end

      def hash
        entries.map(&:hash).tap do |hashes|
          hashes << version.hash
          hashes << time_equal_compare_string_for(time: time)
        end.hash
      end

      def time_formatted
        formatted_time(time: time)
      end

      def time_yyyy_mm_dd
        yyyy_mm_dd(time: time)
      end

      def to_h
        {
          version: version,
          time: time.dup,
          entries: entries.map(&:to_h)
        }
      end

      def valid_unique_entries
        entries&.select(&:valid?)&.uniq(&:description)
      end

      class << self
        def all
          entry_files.filter_map do |file_path|
            entry_file_name = File.basename(file_path)
            next unless entry_file_name.match?(ENTRIES_FILE_NAME_REGEX)

            entry_date = File.basename(entry_file_name, '.*')
            find time: Time.parse(entry_date)
          end
        end

        def any?
          entry_files.any? do |file_path|
            entry_date = File.basename(file_path, '.*')
            entry_date.match?(ENTRIES_FILE_NAME_TIME_REGEX)
          end
        end

        def delete(time:)
          superclass.delete(file_path: entries_path_for(time: time))
        end

        def delete!(time:)
          superclass.delete!(file_path: entries_path_for(time: time))
        end

        def edit(time:, options: {})
          # NOTE: Uncomment this line to prohibit edits on
          # Entry Groups that do not exist (i.e. have no entries).
          # return new(time: time) unless exists?(time: time)

          find_or_initialize(time: time).tap do |entry_group|
            Services::EntryGroup::EditorService.new(entry_group: entry_group, options: options).call
          end
        end

        def exist?(time:)
          superclass.file_exist?(file_path: entries_path_for(time: time))
        end

        def entry_group_times(between: nil)
          entry_files.filter_map do |file_path|
            entry_file_name = File.basename(file_path)
            next unless entry_file_name.match?(ENTRIES_FILE_NAME_REGEX)

            time = File.basename(entry_file_name, '.*')
            next if between && !Time.parse(time).between?(between.min, between.max)

            time
          end
        end

        def entry_groups(between:)
          entry_group_times(between: between).filter_map do |time|
            Models::EntryGroup.find(time: Time.parse(time))
          end
        end

        def find(time:)
          file_path = entries_path_for(time: time)
          entry_group_hash = read!(file_path: file_path)
          Services::EntryGroup::HydratorService.new(entry_group_hash: entry_group_hash).call
        end

        def find_or_create(time:)
          find_or_initialize(time: time).tap do |entry_group|
            entry_group.write! unless entry_group.exist?
          end
        end

        def find_or_initialize(time:)
          file_path = entries_path_for(time: time)
          read(file_path: file_path) do |entry_group_hash|
            Services::EntryGroup::HydratorService.new(entry_group_hash: entry_group_hash).call
          end || new(time: time)
        end

        def write(file_data:, file_path:)
          if file_data[:entries].empty?
            superclass.delete(file_path: file_path)
            return true
          end

          super
        end

        def write!(file_data:, file_path:)
          if file_data[:entries].empty?
            superclass.delete!(file_path: file_path)
            return
          end

          super
        end

        private

        def entries_path_for(time:)
          Support::Fileable.entries_path(time: time)
        end

        def entry_files
          Dir.glob("#{Support::Fileable.entries_folder}/*")
        end
      end

      private

      def ensure_local_time(time)
        time ||= Time.now
        time.in_time_zone
      end
    end
  end
end
