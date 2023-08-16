# frozen_string_literal: true

module Dsu
  module Support
    module Fileable
      MIGRATION_VERSION_FILE_NAME = 'migration_version.json'

      def dsu_folder
        File.join(root_folder, 'dsu')
      end

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
        File.join(dsu_folder, 'entries')
      end

      def entries_file_name(time:, file_name_format: nil)
        file_name_format ||= '%Y-%m-%d.json'
        time.strftime(file_name_format)
      end

      def entries_path(time:, file_name_format: nil)
        File.join(entries_folder, entries_file_name(time: time, file_name_format: file_name_format))
      end

      # Themes

      def themes_folder
        File.join(dsu_folder, 'themes')
      end

      def themes_path(theme_name:)
        File.join(themes_folder, theme_file_name(theme_name: theme_name))
      end

      def theme_file_name(theme_name:)
        "#{theme_name}.json"
      end

      # Migration

      def migration_version_folder
        File.join(dsu_folder)
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
        Gem.loaded_specs['dsu'].gem_dir
      end

      # Back up folder

      def backup_folder(version:)
        File.join(dsu_folder, 'backup', version.to_s)
      end

      # Seed data folders

      def seed_data_folder
        File.join(gem_dir, 'lib/seed_data')
      end

      extend self # rubocop:disable Style/ModuleFunction
    end
  end
end
