# frozen_string_literal: true

require 'active_model'
require 'singleton'
require_relative '../crud/json_file'
require_relative '../services/migration_version/hydrator_service'
require_relative '../validators/version_validator'

module Dsu
  module Models
    # This class represents a dsu migration_version.
    class MigrationVersion
      include ActiveModel::Model
      include Crud::JsonFile
      include Singleton
      include Support::Fileable

      def initialize
        FileUtils.mkdir_p migration_version_folder

        @file_path = migration_version_path
        file_hash = if exist?
          read do |migration_version_hash|
            hydrated_hash =
              Services::MigrationVersion::HydratorService.new(migration_version_hash: migration_version_hash).call
            migration_version_hash.merge!(hydrated_hash)
          end
        else
          { version: 0 }
        end

        self.version = file_hash[:version]
      end

      # Returns true if the current dsu install is the current
      # migration version.
      def current_migration?
        version == Dsu::Migration::VERSION
      end

      def to_h
        {
          version: version
        }
      end
    end
  end
end
