# frozen_string_literal: true

require_relative '../base_service'
require_relative '../raw_helpers/color_theme_hash'
require_relative '../raw_helpers/configuration_hash'
require_relative '../raw_helpers/entry_group_hash'
require_relative '../raw_json_file'
require_relative '../version'

module Dsu
  module Migration
    module V20240210161248
      class Service < BaseService
        class << self
          def from_migration_version
            20230613121411 # rubocop:disable Style/NumericLiterals
          end

          def to_migration_version
            20240210161248 # rubocop:disable Style/NumericLiterals
          end
        end

        private

        def run_migration!
          super

          raise_backup_folder_does_not_exist_error_if!

          add_new_color_themes
          create_default_project
          create_current_project_file
          update_configuration
          update_entry_groups
          update_color_themes
          delete_old_entry_folder

          puts 'Migration completed successfully.'
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

        def add_new_color_themes
          puts 'Copying new color themes...'

          FileUtils.mkdir_p(themes_folder_from) unless pretend?

          %w[light.json christmas.json].each do |theme_file|
            destination_theme_file_path = File.join(themes_folder_from, theme_file)
            # Don't skip these theme files because they were deployed in the previous
            # dsu version with bugs. We need to overwrite them with this new version.
            # next if File.exist?(destination_theme_file_path)

            source_theme_file_path = File.join(seed_data_folder, 'themes', theme_file)
            FileUtils.cp(source_theme_file_path, destination_theme_file_path) unless pretend?
          end
        end

        def create_default_project
          puts "Creating default project \"#{default_project_name}\"..."

          return if pretend?

          FileUtils.cp_r(File.join(seed_data_folder, 'projects', '.'),
            File.join(dsu_folder, 'projects'))
        end

        def create_current_project_file
          puts 'Creating current project file...'

          return if pretend?

          # NOTE: dsu_folder won't change and is safe to use here.
          FileUtils.cp(File.join(seed_data_folder, 'current_project.json'), dsu_folder)
        end

        def update_configuration
          puts 'Updating configuration...'

          return if pretend?

          # NOTE: config_path won't change and is safe to use here.
          RawJsonFile.new(config_path).tap do |configuration_file|
            configuration_file.extend(RawHelpers::ConfigurationHash)
            configuration_file.version = to_migration_version
            configuration_file.default_project = default_project_name
          end.save!
        end

        def update_entry_groups
          puts 'Updating entry groups...'

          return if pretend?

          puts "\tCopying entries to default project \"#{default_project_name}\"..."

          entries_folder_to = File.join(dsu_folder, 'projects', default_project_name, 'entries')
          FileUtils.cp_r(File.join(entries_folder_from, '.'), entries_folder_to)

          puts "\tUpdating entry group version..."

          RawJsonFiles.new(entries_folder_to).each_file(regex: /\d{4}-\d{2}-\d{2}.json/) do |raw_entry_group|
            raw_entry_group.extend(RawHelpers::EntryGroupHash)
            raw_entry_group.version = to_migration_version
            raw_entry_group.save!
          end
        end

        def update_color_themes
          puts 'Updating color themes...'

          FileUtils.cp_r(File.join(backup_folder, 'themes', '.'), themes_folder) unless pretend?

          puts "\tUpdating color theme version..."

          themes_folder_to = File.join(dsu_folder, 'themes')

          RawJsonFiles.new(themes_folder_to).each_file(regex: /.+.json/) do |raw_entry_group|
            raw_entry_group.extend(RawHelpers::ColorThemeHash)
            raw_entry_group.version = to_migration_version
            raw_entry_group.save! unless pretend?
          end
        end

        def delete_old_entry_folder
          puts 'Cleaning up old entries...'

          FileUtils.rm_rf(File.join(entries_folder_from)) unless pretend?
        end

        def default_project_name
          'default'
        end
      end
    end
  end
end
