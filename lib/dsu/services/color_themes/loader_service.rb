# frozen_string_literal: true

require 'psych'
require_relative '../../models/color_theme'
require_relative '../../support/color_theme_locatable'

module Dsu
  module Services
    module ColorThemes
      # This class loads an color theme from disk.
      class LoaderService
        include Support::ColorThemeLocatable

        def initialize(theme_name: nil)
          unless theme_name.nil? || theme_name.is_a?(String)
            raise ArgumentError, "theme_name must be a String: \"#{theme_name}\"."
          end

          @theme_name = theme_name || Models::ColorTheme::DEFAULT_THEME_NAME
        end

        def call
          unless theme_file?(theme_name: theme_name)
            return Models::ColorTheme::Theme.new(theme_name: theme_name, theme_hash: default_color_theme_hash)
          end

          Models::ColorTheme::Theme.new(theme_name: theme_name, theme_hash: loaded_color_theme_hash)
        end

        private

        attr_reader :theme_name

        def loaded_color_theme_hash
          @loaded_color_theme_hash ||= begin
            theme_file = theme_file(theme_name: theme_name)
            loaded_color_theme_hash = Psych.safe_load(File.read(theme_file), [Symbol])
            unless loaded_color_theme_hash.keys == default_color_theme_hash.keys
              loaded_color_theme_hash = update_and_write_theme_file!(loaded_color_theme_hash: loaded_color_theme_hash, theme_file: theme_file)
            end
            loaded_color_theme_hash
          end
        end

        def update_and_write_theme_file!(loaded_color_theme_hash:, theme_file:)
          loaded_color_theme_hash = default_theme.merge(loaded_color_theme_hash)
          # TODO: Make this into a configuration writer service.
          File.write(theme_file, loaded_color_theme_hash.to_yaml)
          loaded_color_theme_hash
        end

        def default_color_theme_hash
          Models::ColorTheme::DEFAULT_THEME_HASH
        end
      end
    end
  end
end
