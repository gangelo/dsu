# frozen_string_literal: true

require 'json'
require 'psych'
require_relative '../models/entry_group'
require_relative '../services/entry_group/hydrator_service'

module Dsu
  module Crud
    module EntryGroup
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
        def delete!(time:)
          unless exist?(time: time)
            raise "Entry group file does not exist for time \"#{time}\": " \
                  "\"#{entry_group_path(time: time)}\""
          end

          delete(time: time)
        end

        def delete(time:)
          return false unless exist?(time: time)

          entry_group_path = entry_group_path(time: time)
          File.delete(entry_group_path)

          true
        end

        def exist?(time:)
          entry_group_path = entry_group_path(time: time)
          File.exist?(entry_group_path)
        end

        def find(time:)
          raise "Entry group does not exist for time \"#{time}\"" unless exist?(time: time)

          entry_group_path = entry_group_path(time: time)
          entry_group_json = File.read(entry_group_path)
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

          ensure_entry_group_folder_exists!
          entry_group_path = entry_group_path(time: entry_group.time)
          File.write(entry_group_path, JSON.pretty_generate(entry_group.to_h))

          true
        end

        def save!(entry_group:)
          delete! and return if entry_group.entries.empty?

          entry_group.validate!

          save(entry_group: entry_group)

          entry_group
        end

        def hash_for(time:)
          entry_group_path = entry_group_path(time: time)
          unless exist?(time: time)
            raise "Entry group file does not exist for time \"#{time}\": " \
                  "\"#{entry_group_path}\""
          end

          # Do not load the class because it is possible
          entry_group_json = File.read(entry_group_path)
          raise "TODO: return a hash."
        end

        def entry_group_file(time:)
          time.strftime(configuration.entries_file_name)
        end

        def entry_group_path(time:)
          File.join(entry_group_folder, entry_group_file(time: time))
        end

        def entry_group_folder
          configuration.entries_folder
        end

        private

        def ensure_entry_group_folder_exists!
          FileUtils.mkdir_p(entry_group_folder)
        end

        def configuration
          # NOTE: Do not memoize this, as it will cause issues if
          # the configuration is updated (e.g. themes_folder,
          # entries_folder, etc.); in this case, a memoized
          # configuration would not reflect the updated values.
          Models::Configuration.current_or_default
        end
      end
    end
  end
end
