# frozen_string_literal: true

require_relative '../support/configurable'

module Dsu
  module Support
    # TODO: I hate this module; refactor it!!!
    # This module expects the following attributes to be defined: :time, :options
    module EntryGroupFileable
      include Support::Configurable

      def entry_group_file_exists?
        File.exist?(entry_group_file_path)
      end

      def entry_group_file_exists_for?(time:)
        entries_file_name = time.strftime(configuration_or_options_configuration[:entries_file_name])
        File.join(entries_folder, entries_file_name)
      end

      private

      def entry_group_path_exists?
        Dir.exist?(entries_folder)
      end

      def entry_group_file_path
        File.join(entries_folder, entries_file_name)
      end

      def entries_folder
        @entries_folder ||= merged_configuration.entries_folder
      end

      def entries_file_name
        @entries_file_name ||= time.strftime(merged_configuration.entries_file_name)
      end

      def create_entry_group_path_if!
        FileUtils.mkdir_p(entries_folder) unless entry_group_path_exists?
      end

      def merged_configuration
        @merged_configuration ||= if options[:configuration]
          Models::Configuration(config_hash: configuration.merge(options[:configuration]))
        else
          configuration
        end
      end
    end
  end
end
