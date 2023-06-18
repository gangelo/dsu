# frozen_string_literal: true

require 'psych'
require_relative '../service'

module Dsu
  module Migration
    module Version10
      # This is the base class for all migration services.
      class MigrationService < Migration::Service
        class << self
          # To run migrations, run this class method.
          def run_migrations!
            puts "dsu version: #{Dsu::VERSION}"
            puts 'Running migrations...'
            puts "Migration version (before migrations): #{current_migration_version}"

            before_migration_version = current_migration_version

            migration_files_to_run_info.each do |migration_file_info|
              run_migration!(migration_file_info: migration_file_info)
            end

            puts "Migration version (after migrations): #{current_migration_version}"
            puts 'Nothing to do.' if current_migration_version == before_migration_version
          end

          def run_migration!(migration_file_info:)
            require migration_file_info[:require_file]
binding.pry
            migration = migration_file_info[:migration_class].constantize.new
            if migration.migrate?
              puts "Running migration: #{File.basename(migration_file_info[:require_file])}..."
              migration.call
            else
              puts "Bypassing migration: #{File.basename(migration_file_info[:require_file])}, #migrate? returned false."
            end
          end

          # Migrate version file methods
          # def migration_version_path
          #   @migration_version_path ||= File.join(migrate_folder, Migration::MIGRATION_VERSION_FILE_NAME)
          # end

          private

          # This method returns the current migration version from the migration version file.
          # def current_migration_version
          #   return 0 unless File.exist?(migration_version_path)

          #   Psych.safe_load(File.read(migration_version_path), [Symbol])[:migration_version]
          # end

          # def migrate_folder
          #   @migrate_folder ||= File.join(Gem.loaded_specs['dsu'].gem_dir, 'lib/migrate')
          # end

          # Returns a hash of migration files that need to be applied, sorted asc by migration version.
          def migration_files_to_run_info
            # NOTE: super.all_migration_files_info returns an array sorted ascending order
             # of migration version. Below, #select will maintain the order in which the
             # migrations are returned which is wnat we want, because the migrations need to
             # be run in ascending version order.
            @migration_files_to_run_info ||= all_migration_files_info.select do |migration_file_info|
              migration_file_version = migration_file_info[:version]
              migration_file_version && (migration_file_version > current_migration_version)
            end
          end
        end

        def version
          File.basename(__dir__).to_f
        end

        def call
          update_migration_version!
        end

        def migrate?
          migration_version > self.class.current_migration_version
        end

        private

        # This updates the migration version file with the current migration version.
        # This method is called from the #call method; however, you can call it directly
        # if your subclass does not need to call super#call for some reason, but still
        # want to mark the migration as having run.
        def update_migration_version!
          # Do nothing unless the migration version is greater than the current migration version.
          return unless migrate?

          migration_version_path = self.class.migration_version_path
          File.write(migration_version_path, Psych.dump({ migration_version: migration_version }))
        end

        #
        # Below are migration version file methods
        #

        # def current_migration_version
        #   self.class.send(:current_migration_version)
        # end

        def migration_version
          # This method must be overridden and return the migration version of the current
          # migration file.
          raise NotImplementedError, 'You must implement the #migration_version method.'
        end

        # def migration_version_path
        #   self.class.send(:migration_version_path)
        # end
      end
    end
  end
end
