# frozen_string_literal: true

require 'psych'

module Dsu
  module Migration
    module Version10
      # This is the base class for all migration services.
      class MigrationService
        class << self
          # To run migrations, run this class method.
          def run_migrations!
            puts "dsu version: #{Dsu::VERSION}"
            puts 'Running migrations...'
            puts "Migration version (before migrations): #{current_migration_version}"

            before_migration_version = current_migration_version

            migration_files_info.each_value { |file_path| run_migration!(migration_path: file_path) }

            puts "Migration version (after migrations): #{current_migration_version}"
            puts 'Nothing to do.' if current_migration_version == before_migration_version
          end

          def run_migration!(migration_path:)
            migration_path = migration_path.sub(/\.[^.]+\z/, '')
            puts "Running migration: #{File.basename(migration_path)}..."
            # Requiring the migration files will run the migrations in each file.
            require migration_path
          end

          # Migrate version file methods
          def migration_version_file_path
            @migration_version_file_path ||= File.join(migrate_folder, Migration::MIGRATION_VERSION_FILE_NAME)
          end

          private

          # This method returns the current migration version from the migration version file.
          def current_migration_version
            return 0 unless File.exist?(migration_version_file_path)

            Psych.safe_load(File.read(migration_version_file_path), [Symbol])[:migration_version]
          end

          def migrate_folder
            @migrate_folder ||= File.join(Gem.loaded_specs['dsu'].gem_dir, 'lib/migrate')
          end

          # Returns a hash of migration files that need to be applied, sorted asc by migration version.
          def migration_files_info
            migration_files_info = Dir.glob("#{migrate_folder}/*").filter_map do |file_path|
              migration_version = File.basename(file_path).match(Migration::MIGRATION_VERSION_REGEX).try(:[], 0)&.to_i
              next if migration_version.nil? || current_migration_version >= migration_version

              { migration_version: migration_version, file_path: file_path }
            end

            migration_files_info.sort_by do |migration_file_info|
              migration_file_info[:migration_version]
            end.to_h(&:values) || {}
          end
        end

        def version
          File.basename(__dir__).to_f
        end

        def call
          update_migration_version!
        end

        def migrate?
          migration_version > current_migration_version
        end

        private

        # This updates the migration version file with the current migration version.
        # This method is called from the #call method; however, you can call it directly
        # if your subclass does not need to call super#call for some reason, but still
        # want to mark the migration as having run.
        def update_migration_version!
          # Do nothing unless the migration version is greater than the current migration version.
          return unless migrate?

          File.write(migration_version_file_path, Psych.dump({ migration_version: migration_version }))
        end

        #
        # Below are migration version file methods
        #

        def current_migration_version
          self.class.send(:current_migration_version)
        end

        def migration_version
          # This method must be overridden and return the migration version of the current
          # migration file.
          raise NotImplementedError, 'You must implement the #migration_version method.'
        end

        def migration_version_file_path
          self.class.send(:migration_version_file_path)
        end
      end
    end
  end
end
