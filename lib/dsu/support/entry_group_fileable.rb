# frozen_string_literal: true

require_relative '../services/configuration_loader_service'

module Dsu
  module Support
    module EntryGroupFileable
      module_function

      def entry_group_file_exists?
        File.exist?(entry_group_file_path)
      end

      def entry_group_path_exists?
        Dir.exist?(entries_folder)
      end

      def entry_group_file_path
        File.join(entries_folder, entries_file_name)
      end

      def entries_folder
        @entries_folder ||= configuration[:entries_folder]
      end

      def entries_file_name
        @entries_file_name ||= time.strftime(configuration[:entries_file_name])
      end

      def create_entry_group_path_if!
        FileUtils.mkdir_p(entries_folder) unless entry_group_path_exists?
      end

      private

      def configuration
        @configuration ||= options[:configuration] || Dsu::Services::ConfigurationLoaderService.new.call
      end
    end
  end
end
