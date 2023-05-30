# frozen_string_literal: true

require 'active_support/core_ext/hash/indifferent_access'
require 'psych'
require_relative '../migration/configuration_migrator_service'
require_relative '../support/configuration_fileable'

module Dsu
  module Services
    # This class loads an entry group file.
    class ConfigurationLoaderService
      include Support::ConfigurationFileable

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
        config_hash.merge(default_options).with_indifferent_access
      end

      private

      attr_reader :default_options

      def config_hash
        return default_config_hash unless config_file_exist?

        # @config_hash ||= begin
        #   config_hash = load_config_file
        #   if migrate?(config_hash)
        #     Migration::ConfigurationMigratorService.new(config_hash: config_hash).call
        #     config_hash = load_config_file
        #     if migrate?(config_hash)
        #       raise "Configuration migration from \"#{config_hash['version']}\" " \
        #             "to \"#{default_config_hash['version']}\" could not be applied."
        #     end
        #   end
        #   config_hash
        # end

        @config_hash = load_config_file
      end

      def load_config_file
        Psych.safe_load(File.read(config_file), [Symbol])
      end

      # def migrate?(config_hash)
      #   config_hash['version'] != default_config_hash['version']
      # end

      def default_config_hash
        Support::Configuration::DEFAULT_DSU_OPTIONS
      end
    end
  end
end
