# frozen_string_literal: true

module Dsu
  module Support
    module Fileable
      ENTRIES_FILE_NAME_FORMAT = '%Y-%m-%d.json'
      MIGRATION_VERSION_FILE_NAME = 'migration_version.json'

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
        File.join(root_folder, 'dsu', 'entries')
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
        File.join(root_folder, 'dsu', 'themes')
      end

      def themes_path(theme_name:)
        File.join(themes_folder, "#{theme_name}.json")
      end

      # Migration

      # The folder where generated migration files will be stored (i.e. dsu/lib/migrate).
      def migrate_folder
        File.join(gem_dir, 'lib/migrate')
      end

      def migration_version_folder
        File.join(root_folder, 'dsu')
      end

      def migration_version_path
        File.join(migration_version_folder, MIGRATION_VERSION_FILE_NAME)
      end

      # Base folders

      def root_folder
        Dir.home
      end

      def temp_folder
        Dir.tmpdir
      end

      def gem_dir
        @gem_dir ||= Gem.loaded_specs['dsu'].gem_dir
      end

      # Display

      def display_all
        <<~INFO
          DSU Folder/Path Information:
          ----------------------------------------------
                     Root folder: #{root_folder}
                     Config path: #{config_path}
                  Entries folder: #{entries_folder}
                   Themes folder: #{themes_folder}
          Migration version path: #{migration_version_path}
                     Temp folder: #{temp_folder}
                      Gem folder: #{gem_dir}
        INFO
      end

      extend self # rubocop:disable Style/ModuleFunction
    end
  end
end
