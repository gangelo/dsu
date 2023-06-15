# frozen_string_literal: true

require_relative '../../models/configuration'
require_relative '../../views/shared/messages'

module Dsu
  module Services
    module Configuration
      class HydratorService
        def initialize(config_json:, options: {})
          raise ArgumentError, 'config_json is nil' if config_json.nil?

          unless config_json.is_a?(String)
            raise ArgumentError,
              "config_json is the wrong object type: \"#{config_json}\""
          end
          raise ArgumentError, 'options is nil' if options.nil?
          raise ArgumentError, "options is the wrong object type:\"#{options}\"" unless options.is_a?(Hash)

          @config_json = config_json
          @options = options || {}
        end

        def call
          hydrate
        end

        private

        attr_reader :config_json, :options

        # Returns a Hash with all the keys as symbols and datatypes
        # hydrated from the JSON string.
        def hydrate
          JSON.parse(config_json, symbolize_names: true).tap do |hash|
            hash[:version] = hash[:version].to_i
            hash[:entries_display_order] = hash[:entries_display_order].to_sym
            hash[:carry_over_entries_to_today] = hash[:carry_over_entries_to_today] == 'true'
            hash[:include_all] = hash[:include_all] == 'true'
          end
        rescue JSON::ParserError => e
          Models::Configuration::DEFAULT_CONFIGURATION
        end
      end
    end
  end
end
