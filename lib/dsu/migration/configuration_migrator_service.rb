# frozen_string_literal: true

require_relative '../services/configuration_loader_service'
require_relative '../services/configuration/writer_service'
require_relative '../support/configuration_fileable'
require_relative 'migrator_service'

module Dsu
  module Migration
    # This service migrates Configuration files from one version
    # to another.
    class ConfigurationMigratorService < MigratorService
      include Support::ConfigurationFileable

      def initialize(config_hash: nil)
        config_hash ||= Services::ConfigurationLoaderService.new.call

        super(object: config_hash)
      end

      alias config_hash object

      def call
        update_migration_version! and return config_hash unless config_file_exist?

        # NOTE: This method must be implemented by the subclass. The subclass is responsible for
        # making any updates necessary to the object before calling super!

        super
      end

      private

      def save_model!
        Services::Configuration::WriterService.new(config_hash: config_hash).call
      end
    end
  end
end
