# frozen_string_literal: true

module Dsu
  module Support
    module Fileable
      ENTRIES_FILE_NAME_FORMAT = '%Y-%m-%d.json'

      # Configuration

      def config_folder
        root_folder
      end

      def config_file_name
        '.dsu'
      end

      def config_path
        File.join(config_folder, config_file_name)
      end

      # Entries

      def entries_folder
        "#{root_folder}/dsu/entries"
      end

      def entries_file_name(time:, file_name_format: nil)
        file_name_format ||= ENTRIES_FILE_NAME_FORMAT
        time.strftime(file_name_format)
      end

      def entries_path(time:, file_name_format: nil)
        File.join(entries_folder, entries_file_name(time: time, file_name_format: file_name_format))
      end

      # Themes

      def themes_folder
        "#{root_folder}/dsu/themes"
      end

      def themes_path(theme_name:)
        File.join(themes_folder, "#{theme_name}.yml")
      end

      # Base folders

      def root_folder
        Dir.home
      end

      def temp_folder
        Dir.tmpdir
      end

      extend self # rubocop:disable Style/ModuleFunction
    end
  end
end
