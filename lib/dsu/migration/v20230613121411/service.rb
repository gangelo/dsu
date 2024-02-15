# frozen_string_literal: true

require_relative '../base_service'
require_relative '../raw_helpers/entry_group_hash'
require_relative '../version'

module Dsu
  module Migration
    module V20230613121411
      class Service < BaseService
        class << self
          def from_migration_version
            0
          end

          def to_migration_version
            20230613121411 # rubocop:disable Style/NumericLiterals
          end
        end

        private

        def run_migration!
          super

          raise_backup_folder_does_not_exist_error_if!

          delete_old_config_file
          delete_old_themes_folder

          copy_new_dsu_folders
          copy_new_dsu_configuration
          migrate_entry_groups
        end

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

        def copy_new_dsu_folders
          puts 'Copying new dsu folders...'

          FileUtils.cp_r(File.join(seed_data_folder, '.'), File.join(root_folder, 'dsu')) unless pretend?
        end

        def copy_new_dsu_configuration
          puts 'Copying new dsu configuration...'

          FileUtils.cp(seed_data_configuration, config_folder) unless pretend?
        end

        def migrate_entry_groups
          puts 'Migrating entry groups...'

          return if pretend?

          puts "\tUpdating entry group version..."

          RawJsonFiles.new(entries_folder_from).each_file(regex: /\d{4}-\d{2}-\d{2}.json/) do |raw_entry_group|
            raw_entry_group.extend(RawHelpers::EntryGroupHash)
            raw_entry_group.version = to_migration_version
            raw_entry_group.save!
          end
        end

        def delete_old_config_file
          puts 'Deleting old configuration file...'

          return if pretend?

          File.delete(config_file_from) if File.file?(config_file_from)
        end

        def delete_old_themes_folder
          puts 'Deleting old themes folder...'

          FileUtils.rm_rf(themes_folder_from) unless pretend?
        end
      end
    end
  end
end
