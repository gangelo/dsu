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
