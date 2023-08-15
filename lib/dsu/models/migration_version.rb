# frozen_string_literal: true

require 'active_model'
require_relative '../crud/json_file'
require_relative '../services/migration_version/hydrator_service'
require_relative '../validators/version_validator'

module Dsu
  module Models
    # This class represents a dsu migration_version.
    class MigrationVersion < Crud::JsonFile
      include Support::Fileable

      attr_reader :options

      def initialize(version: nil, options: {})
        super(migration_version_path)

        FileUtils.mkdir_p migration_version_folder

        @options = options || {}
        @version = version and return if version

        file_hash = if exist?
          read do |migration_version_hash|
            hydrated_hash =
              Services::MigrationVersion::HydratorService.new(migration_version_hash: migration_version_hash).call
            migration_version_hash.merge!(hydrated_hash)
          end
        end

        self.version = file_hash.try(:[], :version) || 0
      end

      # Returns true if the current dsu install is the
      # current migration version.
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
