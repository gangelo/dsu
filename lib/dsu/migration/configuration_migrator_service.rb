# frozen_string_literal: true

require_relative '../models/configuration'
require_relative '../services/configuration/loader_service'
require_relative '../services/configuration/writer_service'
require_relative 'migrator_service'

module Dsu
  module Migration
    # This service migrates Configuration files from one version
    # to another.
    class ConfigurationMigratorService < MigratorService
      def initialize(config_hash: nil)
        config_hash ||= Services::ConfigurationLoaderService.new.call

        raise ArgumentError, "config_hash must be a Hash: \"#{config_hash}\"" unless config_hash.is_a?(Hash)
        raise ArgumentError, 'config_hash is empty' if config_hash.empty?

        super(object: config_hash)
      end

      alias config_hash object

      def call
        update_migration_version! and return config_hash unless Models::Configuration.config_file_exist?

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
