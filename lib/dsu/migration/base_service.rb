# frozen_string_literal: true

require_relative '../models/migration_version'
require_relative '../support/fileable'
require_relative 'version'

module Dsu
  module Migration
    class BaseService
      include Support::Fileable

      def initialize(options: {})
        @options = options || {}
      end

      class << self
        def migrates_to_latest_migration_version?
          to_migration_version == Migration::VERSION
        end

        # The migration version that this migration is upgrading from.
        def from_migration_version
          raise NotImplementedError, 'You must implement the #from_migration_version method in your subclass'
        end

        # The migration version that this migration is upgrading to.
        def to_migration_version
          raise NotImplementedError, 'You must implement the #to_migration_version method in your subclass'
        end
      end

      def migrate_if!
        return unless run_migration?

        puts "Running migrations #{from_migration_version} -> #{to_migration_version}..."
        puts "\tpretend?: #{pretend?}" if pretend?

        run_migration!
        update_migration_version!

        puts "\tMigration #{from_migration_version} -> #{to_migration_version} complete."
      end

      private

      attr_accessor :options

      # You must implement your own migration logic in your subclass and call this method.
      def run_migration!
        create_backup
      end

      def pretend?
        options.fetch(:pretend, true)
      end

      def run_migration?
        migration_version == from_migration_version
      end

      # The migration version that this migration is upgrading from.
      def from_migration_version
        self.class.from_migration_version
      end

      # The migration version that this migration is upgrading to.
      def to_migration_version
        self.class.to_migration_version
      end

      # The migration version before running this migration.
      def migration_version
        # Typically we should not be using models in any of the migration services
        # because if these change, the migrations will break. However, using
        # the MigrationVersion model is an exception because it is a very simple
        # model and is unlikely to change.
        Models::MigrationVersion.new.version
      end

      def create_backup
        puts "Creating backup #{backup_folder}..."

        return puts "\tSkipping: backup already exists." if backup_exist?

        FileUtils.cp_r(dsu_folder, backup_folder)
        FileUtils.cp(config_path, backup_folder)
      end

      def backup_exist?
        Dir.exist?(backup_folder)
      end

      def backup_folder
        @backup_folder ||= backup_folder_for(migration_version: from_migration_version)
      end

      def update_migration_version!
        puts 'Updating migration version...'

        return if pretend? || migration_version == to_migration_version

        Models::MigrationVersion.new(version: to_migration_version).save!
      end

      def seed_data_folder
        seed_data_dsu_folder_for(migration_version: to_migration_version)
      end

      def seed_data_configuration
        seed_data_dsu_configuration_for(migration_version: to_migration_version)
      end

      def raise_backup_folder_does_not_exist_error_if!
        raise "Backup folder #{backup_folder} does not exist, cannot continue" unless backup_exist?
      end
    end
  end
end
