# frozen_string_literal: true

require_relative '../../models/configuration'
require_relative '../../views/shared/messages'

module Dsu
  module Services
    module Configuration
      class HydratorService
        def initialize(config_hash:, options: {})
          raise ArgumentError, 'config_hash is nil' if config_hash.nil?

          unless config_hash.is_a?(Hash)
            raise ArgumentError,
              "config_hash is the wrong object type: \"#{config_hash}\""
          end
          raise ArgumentError, 'options is nil' if options.nil?
          raise ArgumentError, "options is the wrong object type:\"#{options}\"" unless options.is_a?(Hash)

          @config_hash = config_hash.dup
          @options = options || {}
        end

        def call
          hydrate
        end

        private

        attr_reader :config_hash, :options

        def hydrate
          config_hash[:version] = config_hash[:version].to_i
          config_hash[:entries_display_order] = config_hash[:entries_display_order].to_sym
          config_hash
        rescue JSON::ParserError => _e
          Models::Configuration::DEFAULT_CONFIGURATION
        end
      end
    end
  end
end
