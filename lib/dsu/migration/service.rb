# frozen_string_literal: true

require 'fileutils'
require 'json'
require 'psych'
require_relative '../models/configuration'
require_relative '../support/fileable'

module Dsu
  module Migration
    MIGRATION_VERSION_REGEX = /(\A\d+)/

    class Service
      include Support::Fileable

      class << self
        def [](version)
          version = current_migration_version if version == :current
          require_relative "#{version}/migration_service"

          "Dsu::Migration::Version#{version.to_s.delete('.')}::MigrationService".constantize
        end

        def migrate_folder
          Support::Fileable.migrate_folder
        end

        def migration_version_folder
          Support::Fileable.migration_version_folder
        end

        def migration_version_path
          Support::Fileable.migration_version_path
        end

        def all_migration_files_info
          @all_migration_files_info ||= begin
            migration_files_info = Dir.glob("#{migrate_folder}/*").filter_map do |file_path|
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
          return 0 unless File.exist?(migration_version_path)

          Psych.safe_load(File.read(migration_version_path), [Symbol])[:migration_version]
        end

        private

        # Returns the current migration service version.
        def migration_service_version
          folder_path = File.join(Gem.loaded_specs['dsu'].gem_dir, 'lib/dsu/migration')
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

      MIGRATION_SERVICE_VERSION = migration_service_version.freeze
    end
  end
end
