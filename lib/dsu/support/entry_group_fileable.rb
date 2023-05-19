# frozen_string_literal: true

require_relative '../services/configuration_loader_service'
require_relative '../support/configurable'

module Dsu
  module Support
    # TODO: I hate this module; refactor it!!!
    # This module expects the following attributes to be defined: :time, :options
    module EntryGroupFileable
      extend Support::Configurable

      class << self
        def entry_group_file_exists?(time:)
          File.exist?(entry_group_file_path(time: time))
        end

        def entry_group_file_path(time:)
          File.join(entries_folder, entries_file_name(time: time))
        end

        def entries_folder
          configuration[:entries_folder]
        end

        def entries_file_name(time:)
          time.strftime(configuration[:entries_file_name])
        end

        # def configuration
        #   Services::ConfigurationLoaderService.new.call
        # end
      end

      def entry_group_file_exists?
        EntryGroupFileable.entry_group_file_exists?(time: time)
      end

      def entry_group_path_exists?
        Dir.exist?(entries_folder)
      end

      def entry_group_file_path
        EntryGroupFileable.entry_group_file_path(time: time)
      end

      def entries_folder
        @entries_folder ||= EntryGroupFileable.entries_folder
      end

      def entries_file_name
        @entries_file_name ||= EntryGroupFileable.entries_file_name(time: time)
      end

      def create_entry_group_path_if!
        FileUtils.mkdir_p(entries_folder) unless entry_group_path_exists?
      end

      private

      def configuration
        @configuration ||= options[:configuration] || EntryGroupFileable.configuration
      end
    end
  end
end
