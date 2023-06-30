# frozen_string_literal: true

require_relative '../../models/color_theme'

module Dsu
  module Services
    module ColorTheme
      class HydratorService
        def initialize(theme_name:, theme_json:, options: {})
          raise ArgumentError, 'theme_name is nil.' if theme_name.nil?
          raise ArgumentError, "theme_name is the wrong object type: \"#{theme_name}\"." unless theme_name.is_a?(String)
          raise ArgumentError, 'theme_json is nil' if theme_json.nil?
          raise ArgumentError, "theme_json is the wrong object type: \"#{theme_json}\"" unless theme_json.is_a?(String)
          raise ArgumentError, 'options is nil' if options.nil?
          raise ArgumentError, "options is the wrong object type:\"#{options}\"" unless options.is_a?(Hash)

          @theme_name = theme_name
          @theme_json = theme_json
          @options = options || {}
        end

        def call
          Models::ColorTheme.new(theme_name: theme_name, theme_hash: hydrate)
        end

        private

        attr_reader :theme_json, :theme_name, :options

        def hydrate
          JSON.parse(theme_json, symbolize_names: true).tap do |hash|
            hash.each_pair do |key, value|
              next if %i[version description].include?(key)

              value.each_pair do |k, _v|
                value[k] = value[k].to_sym
              end
            end
          end
        end
      end
    end
  end
end
