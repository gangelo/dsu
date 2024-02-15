# frozen_string_literal: true

require_relative '../models/migration_version'
require_relative '../support/fileable'
require_relative 'version'

module Dsu
  module Migration
    class Service
      include Support::Fileable

      def initialize(options: {})
        @options = options || {}
      end

      def migrate_if!
        return unless run_migration?

        puts "Running migrations #{from_migration_version} -> #{to_migration_version}..."
        puts "pretend?: #{pretend?}" if pretend?

        run_migration!
        update_migration_version!

        puts "Migration #{from_migration_version} -> #{to_migration_version} complete."
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
        raise NotImplementedError, 'You must implement the #from_migration_version method in your subclass'
      end

      # The migration version that this migration is upgrading to.
      def to_migration_version
        raise NotImplementedError, 'You must implement the #to_migration_version method in your subclass'
      end

      # The migration version before running this migration.
      def migration_version
        @migration_version ||= Models::MigrationVersion.new.version
      end

      def create_backup
        puts "Creating backup #{backup_folder}..."

        return puts 'Skipping: backup already exists.' if backup_exist?

        FileUtils.cp_r(dsu_folder, backup_folder) unless pretend?
        puts 'Done.'
      end

      def backup_exist?
        Dir.exist?(backup_folder)
      end

      def backup_folder
        @backup_folder ||= File.join(root_folder, "dsu-#{from_migration_version}-backup")
      end

      def update_migration_version
        puts 'Updating migration version...'
        puts

        return if pretend? || migration_version == Migration::VERSION

        Models::MigrationVersion.new(version: Migration::VERSION).save!
      end
    end
  end
end
