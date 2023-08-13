# frozen_string_literal: true

require 'pry-byebug'
require 'fileutils'
require 'json'
require_relative '../models/configuration'
require_relative '../models/migration_version'
require_relative '../support/fileable'

module Dsu
  module Migration
    MIGRATION_VERSION_REGEX = /(\A\d+)/

    class Service
      extend Support::Fileable

      class << self
        def run_migrations?
          !Models::MigrationVersion.instance.current_migration?
        end

        def run_migrations!
          puts "dsu version: #{Dsu::VERSION}"
          puts

          puts 'Running migrations...'
          puts "Migration version is #{before_migration_version}."
          puts

          # TODO: Run migrations here.
          # TODO: Update migration version here.

          backup!
          migrate!

          puts "Migration version after migration is #{current_migration_version}."
          puts 'Done.' if current_migration_version > before_migration_version
          puts 'Nothing to do.' if current_migration_version == before_migration_version
        end

        private

        def backup!
          backup_config!
          puts

          backup_entry_groups!
          puts

          backup_themes!
          puts
        end

        def backup_config!
          puts 'Backing up config...'
          if File.exist?(config_path)
            backup_path = File.join(current_backup_folder, config_file_name)
            puts "Backing up #{config_path} to #{backup_path}..."
            # FileUtils.cp(config_path, "#{config_path}.bak")
          else
            puts 'No config to backup.'
          end
        end

        def backup_entry_groups!
          puts 'Backing up entry groups...'
          if Dir.exist?(entries_folder)
            backup_folder = File.join(current_backup_folder, File.basename(entries_folder))
            puts "Backing up #{entries_folder} to #{backup_folder}..."
            # FileUtils.cp_r(entries_folder, backup_path)
          else
            puts 'No entries to backup.'
          end
        end

        def backup_themes!
          puts 'Backing up themes...'
          if Dir.exist?(themes_folder)
            backup_folder = File.join(current_backup_folder, File.basename(themes_folder))
            puts "Backing up #{themes_folder} to #{backup_folder}..."
            # FileUtils.cp_r(entries_folder, backup_path)
          else
            puts 'No entries to backup.'
          end
        end

        def before_migration_version
          @before_migration_version ||= Models::MigrationVersion.instance.version
        end

        def create_backup_folder!
          FileUtils.mkdir_p(backup_folder(version: current_migration_version))
        end

        def current_backup_folder
          @current_backup_folder ||= begin
            create_backup_folder!
            backup_folder(version: current_migration_version)
          end
        end

        def current_migration_version
          Models::MigrationVersion.instance.version
        end

        # Migrate

        def migrate!
          migrate_config!
          migrate_entry_groups!
          migrate_themes!
        end

        def migrate_config!
          puts 'Migrating config...'
        end

        def migrate_entry_groups!
          puts 'Migrating entry groups...'
        end

        def migrate_themes!
          puts 'Migrating themes...'
        end
      end
    end
  end
end
