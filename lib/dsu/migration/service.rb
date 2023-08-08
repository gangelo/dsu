# frozen_string_literal: true

require 'fileutils'
require 'json'
require_relative '../models/configuration'
require_relative '../models/migration_version'
require_relative '../support/fileable'

module Dsu
  module Migration
    MIGRATION_VERSION_REGEX = /(\A\d+)/

    class Service
      class << self
        def run_migrations?
          !Models::MigrationVersion.instance.current_migration_version?
        end

        def run_migrations!
          puts "dsu version: #{Dsu::VERSION}"
          puts 'Running migrations...'
          puts "Migration version is #{before_migration_version}."

          # TODO: Run migrations here.
          # TODO: Update migration version here.

          backup!
          migrate!

          puts "Migration version after migration is #{current_migration_version}."
          puts 'Done.' if current_migration_version > before_migration_version
          puts 'Nothing to do.' if current_migration_version == before_migration_version
        end

        private

        def before_migration_version
          @before_migration_version ||= Models::MigrationVersion.instance.version
        end

        def current_migration_version
          Models::MigrationVersion.instance.version
        end

        # Backup

        def backup!
          backup_config!
          backup_entry_groups!
          backup_themes!
        end

        def backup_config!
        end

        def backup_entry_groups!
        end

        def backup_themes!
        end

        # Migrate

        def migrate!
          migrate_config!
          migrate_entry_groups!
          migrate_themes!
        end

        def migrate_config!
        end

        def migrate_entry_groups!
        end

        def migrate_themes!
        end
      end
    end
  end
end
