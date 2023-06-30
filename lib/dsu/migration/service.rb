# frozen_string_literal: true

require 'fileutils'
require 'json'
require_relative '../models/configuration'
require_relative '../services/migration_version/hydrator_service'
require_relative '../support/fileable'

module Dsu
  module Migration
    MIGRATION_VERSION_REGEX = /(\A\d+)/

    class Service
      class << self
        def [](version)
          version = current_migration_version if version == :current
          require_relative "#{version}/migration_service"

          "Dsu::Migration::Version#{version.to_s.delete('.')}::MigrationService".constantize
        end

        def run_migrations?
          latest_migration_version = migration_files_to_run_info.last.try(:[], :version) || 0
          current_migration_version < latest_migration_version
        end

        def run_migrations!
          puts "dsu version: #{Dsu::VERSION}"
          puts 'Running migrations...'
          puts "Migration version is #{current_migration_version}."

          before_migration_version = current_migration_version

          migration_files_to_run_info.each do |migration_file_info|
            run_migration!(migration_file_info: migration_file_info)
          end

          puts "Migration version is now #{current_migration_version}."
          puts 'Done.' if current_migration_version > before_migration_version
          puts 'Nothing to do.' if current_migration_version == before_migration_version
        end

        def run_migration!(migration_file_info:)
          require migration_file_info[:require_file]

          migration = migration_file_info[:migration_class].constantize.new
          if migration.migrate?
            puts "Running migration: #{File.basename(migration_file_info[:require_file])}..."
            migration.call
          else
            puts 'Bypassing migration: ' \
                 "#{File.basename(migration_file_info[:require_file])}, #migrate? returned false."
          end
        end

        def all_migration_files_info
          @all_migration_files_info ||= begin
            migration_files_info = Dir.glob("#{Support::Fileable.migrate_folder}/*").filter_map do |file_path|
              file_name = File.basename(file_path)
              match = file_name.match(/\A\d+_(.+)\.rb\z/)
              next unless match

              version = file_name.match(Migration::MIGRATION_VERSION_REGEX).try(:[], 0)&.to_i
              migration_class = match[1].camelize
              {
                migration_class: "Dsu::Migrate::#{migration_class}",
                path: file_path,
                require_file: file_path.sub(/\.[^.]+\z/, ''),
                version: version
              }
            end

            migration_files_info.sort_by do |migration_file_info|
              migration_file_info[:version]
            end || {}
          end
        end

        def current_migration_version
          migration_version_path = Support::Fileable.migration_version_path
          return 0 unless File.exist?(migration_version_path)

          migration_version_json = File.read(migration_version_path)
          migration_version_hash = Services::MigrationVersion::HydratorService.new(migration_version_json: migration_version_json).call
          migration_version_hash[:migration_version]
        end

        private

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

        # Returns the most recent migration service version.
        def migration_service_version
          folder_path = File.join(Support::Fileable.gem_dir, 'lib/dsu/migration')
          subfolders = Dir.entries(folder_path)
            .select { |entry| File.directory?(File.join(folder_path, entry)) }
            .reject { |entry| entry.start_with?('.') }
          subfolders.filter_map do |folder|
            next unless /\A\d+\.\d+(\.\d+)?\z/.match?(folder)

            folder.to_f
          end.max
        end
      end

      def current_migration_version
        self.class.current_migration_version
      end

      MIGRATION_SERVICE_VERSION = migration_service_version.freeze # rubocop:disable Layout/ClassStructure
    end
  end
end
