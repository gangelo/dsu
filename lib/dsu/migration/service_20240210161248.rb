# frozen_string_literal: true

require_relative 'service'
require_relative 'version'

module Dsu
  module Migration
    class Service20240210161248 < Service
      private

      def run_migration!
        super

        add_new_color_themes
        create_default_project
        update_configuration
        update_entry_groups
        update_color_themes
        delete_old_entry_folder

        puts 'Migration completed successfully.'
      end

      def from_migration_version
        20230613121411 # rubocop:disable Style/NumericLiterals
      end

      def to_migration_version
        20240210161248 # rubocop:disable Style/NumericLiterals
      end

      def add_new_color_themes
        puts 'Copying new color themes...'
        puts

        %w[light.json christmas.json].each do |theme_file|
          destination_theme_file_path = File.join(Dsu::Support::Fileable.themes_folder, theme_file)
          # next if File.exist?(destination_theme_file_path)

          source_theme_file_path = File.join(Dsu::Support::Fileable.seed_data_folder, 'themes', theme_file)
          FileUtils.cp(source_theme_file_path, destination_theme_file_path) unless pretend?
          puts I18n.t('migrations.information.theme_copied',
            from: source_theme_file_path, to: destination_theme_file_path)
        end
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

        return if pretend?

        Models::Configuration.new.tap do |configuration|
          configuration.version = Dsu::Migration::VERSION
          configuration.write!
        end
      end

      def update_entry_groups
        puts 'Updating entry groups...'
        puts

        return if pretend? || Dir.exist?(entries_folder)

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

        puts 'Copying color themes...'
        puts

        unless pretend?
          FileUtils.mkdir_p(themes_folder)
          FileUtils.cp_r(File.join(backup_folder, 'themes', '.'), themes_folder)
        end

        puts 'Updating color theme version...'
        puts

        Models::ColorTheme.all.each do |color_theme|
          puts "Updating color theme version: #{color_theme.theme_name}..."
          color_theme.update_version!
          color_theme.save! unless pretend?
        end
      end

      def delete_old_entry_folder
        puts 'Cleaning up old entries...'
        puts

        FileUtils.rm_rf(File.join(dsu_folder, 'entries')) unless pretend?
      end
    end
  end
end
