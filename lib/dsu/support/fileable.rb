# frozen_string_literal: true

module Dsu
  module Support
    module Fileable
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

      def entries_file_name(time:)
        time.strftime('%Y-%m-%d.json')
      end

      def entries_path(time:)
        File.join(entries_folder, entries_file_name(time: time))
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
