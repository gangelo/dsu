# frozen_string_literal: true

require_relative 'service'
require_relative 'version'

module Dsu
  module Migration
    class Service20230613121411 < Service
      private

      def run_migration!
        super

        raise "Backup folder #{backup_folder} does not exist, cannot continue" unless backup_exist?

        # TODO: save old dsu entries to migrate them to the new dsu entries
        delete_old_config_file
        delete_old_entries_folder
        delete_old_themes_folder

        create_new_dsu_folders
      end

      def from_migration_version
        0
      end

      def to_migration_version
        20230613121411 # rubocop:disable Style/NumericLiterals
      end

      # From files/folders

      def config_file_from
        File.join(root_folder, '.dsu')
      end

      def dsu_folder_from
        File.join(root_folder, 'dsu')
      end

      def entries_folder_from
        File.join(dsu_folder_from, 'entries')
      end

      def themes_folder_from
        File.join(dsu_folder_from, 'themes')
      end

      # To folders

      def dsu_folder_to
        File.join(root_folder, 'dsu')
      end

      def entries_folder_to
        File.join(dsu_folder_to, 'entries')
      end

      def themes_folder_to
        File.join(dsu_folder_to, 'entries')
      end

      def seed_data_folder20230613121411
        File.join(seed_data_folder, to_migration_version)
      end

      def create_new_dsu_folders
        puts 'Creating new dsu folders...'
        puts

        if pretend?
          FileUtils.cp_r(File.join(seed_data_folder20230613121411, '.'),
            root_folder, noop: true, verbose: true)
        else
          FileUtils.cp_r(File.join(seed_data_folder20230613121411, '.'),
            root_folder)
        end
      end

      # Deletes

      def delete_old_config_file
        puts 'Deleting old configuration file...'
        puts

        return if pretend?

        File.delete(config_file_from) if File.file?(config_file_from)
      end

      def delete_old_entries_folder
        puts 'Deleting old entry folder...'
        puts

        FileUtils.rm_rf(entries_folder_from) unless pretend?
      end

      def delete_old_themes_folder
        puts 'Deleting old themes folder...'
        puts

        FileUtils.rm_rf(themes_folder_from) unless pretend?
      end
    end
  end
end
