# frozen_string_literal: true

require 'json'
require 'psych'
require_relative '../models/configuration'
require_relative '../support/fileable'

module Dsu
  module Migration
    MIGRATION_VERSION_REGEX = /(\A\d+)/
    MIGRATION_VERSION_FILE_NAME = 'migration_version.yml'

    class Service
      include Support::Fileable

      class << self
        def [](version)
          require_relative "#{version}/migration_service"

          "Dsu::Migration::Version#{version.to_s.delete('.')}::MigrationService".constantize
        end

        # The folder where generated migration files should be stored
        # (i.e. dsu/lib/migrate).
        def migrate_folder
          @migrate_folder ||= File.join(Gem.loaded_specs['dsu'].gem_dir, 'lib/migrate')
        end

        def migration_version_folder
          @migration_version_folder ||= migrate_folder
        end

        def migration_version_path
          @migration_version_path ||= File.join(migration_version_folder, MIGRATION_VERSION_FILE_NAME)
        end

        def all_migration_files_info
          @all_migration_files_info ||= begin
            migration_files_info = Dir.glob("#{migrate_folder}/*").filter_map do |file_path|
              file_name = File.basename(file_path)
              version = file_name.match(Migration::MIGRATION_VERSION_REGEX).try(:[], 0)&.to_i
              migration_class = file_name.match(/\A\d+_(.+)\.rb\z/)[1].camelize
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

        # def configuration_hash
        #   config_file_path = File.join(Support::Fileable.root_folder, '.dsu')
        #   return Psych.safe_load(File.read(config_file_path), [Symbol]) if File.exist?(config_file_path)

        #   Models::Configuration::DEFAULT_CONFIGURATION
        # end

        # def each_hash_for_file_in(folder:, having_extension:)
        #   raise ArgumentError, 'no block was given' unless block_given?

        #   Dir.foreach(folder) do |file_name|
        #     next unless having_extension && file_name.end_with?(having_extension)

        #     file_path = File.join(folder, file_name)
        #     file_json = File.read(file_path)

        #     yield JSON.parse(file_json, symbolize_names: true)
        #   end
        # end

        private

        # Returns the latest migration service version.
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

      MIGRATION_SERVICE_VERSION = migration_service_version.freeze
    end
  end
end
