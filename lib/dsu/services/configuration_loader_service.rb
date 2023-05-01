# frozen_string_literal: true

require 'erb'
require 'yaml'
require_relative '../support/configuration'

module Dsu
  module Services
    class ConfigurationLoaderService
      include Dsu::Support::Configuration

      attr_reader :default_options

      def initialize(default_options: Dsu::Support::Configuration::DEFAULT_DSU_OPTIONS)
        @default_options = default_options
      end

      def call
        load_config.merge(default_options || {}).presence&.with_indifferent_access || raise('No configuration options found')
      end

      private

      attr_writer :default_options

      def load_config
        return {} unless config_file?

        yaml_options = File.read(config_file)
        YAML.safe_load ERB.new(yaml_options).result
      end
    end
  end
end
