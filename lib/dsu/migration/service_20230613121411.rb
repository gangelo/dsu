# frozen_string_literal: true

require_relative '../support/fileable'
require_relative 'version'

# TODO: Read raw configuration .json file
# If default_project is not set...
#   - Add default_project to configuration .json file and write it out.
#   - Reload the configuration file.
#   - Create a Models::Project object for the default project and initialize/save it.
#   - Move the old entries folder into the default project folder.
# TODO: Add default_project to configuration .json file
module Dsu
  module Migration
    class Service20230613121411
      include Support::Fileable

      def initialize(options: {})
        @options = options || {}
      end

      def migrate!
        puts 'Running migrations...'
        puts

        puts "options[:pretend] is true\n" if pretend?

        raise_wrong_migration_version_error_if!

        puts "Migrating from: #{target_migration_version} to version: #{Migration::VERSION}"
        puts

        add_new_color_themes
        backup
        create_default_project
        update_configuration
        update_entry_groups
        update_color_themes
        delete_old_entry_folder
        delete_old_theme_folder

        puts 'Migration completed successfully.'
      end

      private

      attr_reader :options

      def pretend?
        options.fetch(:pretend, true)
      end

      def add_new_color_themes
        puts 'Copying new color themes...'
        puts

        %w[light.json christmas.json].each do |theme_file|
          destination_theme_file_path = File.join(Dsu::Support::Fileable.themes_folder, theme_file)
          next if File.exist?(destination_theme_file_path)

          source_theme_file_path = File.join(Dsu::Support::Fileable.seed_data_folder, 'themes', theme_file)
          FileUtils.cp(source_theme_file_path, destination_theme_file_path) unless pretend?
          puts I18n.t('migrations.information.theme_copied', from: source_theme_file_path, to: destination_theme_file_path)
        end
      end

      def backup
        return if Dir.exist?(backup_folder)

        puts 'Creating backup...'
        puts

        FileUtils.cp_r(dsu_folder, backup_folder) unless pretend?
      end

      def create_default_project
        default_project = Models::Configuration::DEFAULT_CONFIGURATION[:default_project]
        return if Models::Project.project_initialized?(project_name: default_project)

        puts "Creating default project \"#{default_project}\"..."
        puts

        Models::Project.create(project_name: default_project, options: options) unless pretend?
      end

      def update_configuration
        puts 'Updating configuration...'
        puts

        Models::Configuration.new.write! unless pretend?
      end

      def update_entry_groups
        puts 'Updating entry groups...'
        puts

        return if Dir.exist?(entries_folder) || pretend?

        puts 'Copying entries to default project...'
        puts

        FileUtils.mkdir_p(entries_folder)
        FileUtils.cp_r(File.join(backup_folder, 'entries', '.'), entries_folder)

        puts 'Updating entry group version...'
        puts

        Models::EntryGroup.all.each do |entry_group|
          puts "Updating entry group version: #{entry_group.time_yyyy_mm_dd}..."
          entry_group.version = Dsu::Migration::VERSION
          entry_group.save! unless pretend?
        end
      end

      def update_color_themes
        puts 'Updating color themes...'
        puts

        return if Dir.exist?(themes_folder) || pretend?

        puts 'Copying color themes...'
        puts

        FileUtils.mkdir_p(themes_folder)
        FileUtils.cp_r(File.join(backup_folder, 'themes', '.'), themes_folder)

        puts 'Updating color theme version...'
        puts

        Models::ColorTheme.all.each do |color_theme|
          puts "Updating color theme version: #{color_theme.theme_name}..."
          color_theme.version = Dsu::Migration::VERSION
          color_theme.save! unless pretend?
        end
      end

      def delete_old_entry_folder
        puts 'Cleaning up old entries...'
        puts

        FileUtils.rm_rf(File.join(dsu_folder, 'entries')) unless pretend?
      end

      def delete_old_theme_folder
        puts 'Cleaning up old themes...'
        puts

        FileUtils.rm_rf(File.join(dsu_folder, 'themes')) unless pretend?
      end

      def backup_folder
        @backup_folder ||= File.join(dsu_folder, target_migration_version.to_s)
      end

      def target_migration_version
        20230613121411 # rubocop:disable Style/NumericLiterals
      end

      def raise_wrong_migration_version_error_if!
        return if migration_version == target_migration_version

        raise "Actual migration version #{migration_version} " \
              "is not the expected migration version #{target_migration_version}."
      end

      def migration_version
        @migration_version ||= Models::MigrationVersion.new.version
      end
    end
  end
end
