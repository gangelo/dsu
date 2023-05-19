# frozen_string_literal: true

require 'erb'
require 'yaml'
require_relative '../support/configuration'

module Dsu
  module Services
    # This class loads an entry group file.
    class ConfigurationLoaderService
      include Dsu::Support::Configuration

      def initialize(default_options: nil)
        unless default_options.nil? ||
               default_options.is_a?(Hash) ||
               default_options.is_a?(ActiveSupport::HashWithIndifferentAccess)
          raise ArgumentError, 'default_options must be a Hash or ActiveSupport::HashWithIndifferentAccess'
        end

        @default_options = default_options || {}
        @default_options = @default_options.with_indifferent_access if @default_options.is_a?(Hash)
      end

      def call
        config_options.merge(default_options).with_indifferent_access
      end

      private

      attr_reader :default_options

      def config_options
        return default_config unless config_file?

        @config_options ||= begin
          loaded_config = YAML.safe_load(ERB.new(File.read(config_file)).result)
          loaded_config = update_and_write_config_file!(loaded_config) unless loaded_config.keys == default_config.keys
          loaded_config
        end
      end

      def update_and_write_config_file!(loaded_config)
        loaded_config = default_config.merge(loaded_config)
        # TODO: Make this into a configuration writer service.
        # TODO: Test this
        File.write(config_file, loaded_config.to_yaml)
        loaded_config
      end

      def default_config
        Support::Configuration::DEFAULT_DSU_OPTIONS
      end
    end
  end
end
