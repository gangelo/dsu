# frozen_string_literal: true

require 'erb'
require 'yaml'
require_relative '../support/configuration'

module Dsu
  module Services
    class ConfigurationLoaderService
      include Dsu::Support::Configuration

      attr_reader :default_options

      def initialize(default_options: nil)
        unless default_options.nil? ||
               default_options.is_a?(Hash) ||
               default_options.is_a?(ActiveSupport::HashWithIndifferentAccess)
          raise ArgumentError, 'default_options must be a Hash'
        end

        @default_options = default_options || Support::Configuration::DEFAULT_DSU_OPTIONS
        @default_options = @default_options.with_indifferent_access if @default_options.is_a?(Hash)
      end

      def call
        return default_options unless config_file?

        config_options.with_indifferent_access
      end

      private

      attr_writer :default_options

      def config_options
        @config_options ||= YAML.safe_load(ERB.new(File.read(config_file)).result)
      end
    end
  end
end
