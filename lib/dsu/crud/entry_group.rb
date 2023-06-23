# frozen_string_literal: true

require 'json'
require 'psych'
require_relative '../models/entry_group'
require_relative '../services/entry_group/hydrator_service'
require_relative '../support/fileable'

module Dsu
  module Crud
    module EntryGroup
      include Support::Fileable

      ENTRIES_FILE_NAME_REGEX = /\d{4}-\d{2}-\d{2}.json/
      ENTRIES_FILE_NAME_TIME_REGEX = /\d{4}-\d{2}-\d{2}/

      class << self
        def included(base)
          base.extend(ClassMethods)
        end
      end

      def delete
        entries.clear
        self.class.delete(time: time)
      end

      def delete!
        self.class.delete!(time: time)
        entries.clear
      end

      def exist?
        self.class.exist?(time: time)
      end

      def save
        self.class.save(entry_group: self)
      end

      def save!
        self.class.save!(entry_group: self)
      end

      module ClassMethods
        def all
          entry_files.filter_map do |file_path|
            entry_file_name = File.basename(file_path)
            next unless entry_file_name.match?(ENTRIES_FILE_NAME_REGEX)

            entry_date = File.basename(entry_file_name, '.*')
            find(time: Time.parse(entry_date))
          end
        end

        def any?
          entry_files.any? do |file_path|
            entry_date = File.basename(file_path, '.*')
            entry_date.match?(ENTRIES_FILE_NAME_TIME_REGEX)
          end
        end

        def delete!(time:)
          raise file_does_not_exist_message(time) unless exist?(time: time)

          delete(time: time)
        end

        def delete(time:)
          return false unless exist?(time: time)

          entries_path = entries_path(time: time)
          File.delete(entries_path)

          true
        end

        def exist?(time:)
          entries_path = entries_path(time: time)
          File.exist?(entries_path)
        end

        def find(time:)
          raise file_does_not_exist_message(time) unless exist?(time: time)

          entries_path = entries_path(time: time)
          entry_group_json = File.read(entries_path)
          Services::EntryGroup::HydratorService.new(entry_group_json: entry_group_json).call
        end

        def find_or_create(time:)
          return find(time: time) if exist?(time: time)

          new(time: time).save!
        end

        def find_or_initialize(time:)
          return find(time: time) if exist?(time: time)

          new(time: time)
        end

        def save(entry_group:)
          return false unless entry_group.valid?
          delete and return true if entry_group.entries.empty?

          FileUtils.mkdir_p(entries_folder)
          entries_path = entries_path(time: entry_group.time)
          File.write(entries_path, JSON.pretty_generate(entry_group.to_h))

          true
        end

        def save!(entry_group:)
          delete! and return if entry_group.entries.empty?

          entry_group.validate!

          save(entry_group: entry_group)

          entry_group
        end

        private

        def configuration
          Models::Configuration.instance
        end

        def entry_files
          Dir.glob("#{entries_folder}/*")
        end

        def file_does_not_exist_message(time)
          "Entry group file does not exist for time \"#{time}\": " \
            "\"#{entries_path(time: time)}\""
        end
      end
    end
  end
end
