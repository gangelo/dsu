# frozen_string_literal: true

require 'psych'
require_relative '../../models/color_theme'

module Dsu
  module Services
    module ColorThemes
      # This class loads a color theme from disk.
      class LoaderService
        delegate :theme_file_exist?, :theme_file, to: Models::ColorTheme

        def initialize(theme_name: nil)
          unless theme_name.nil? || theme_name.is_a?(String)
            raise ArgumentError, "theme_name must be a String: \"#{theme_name}\"."
          end

          @theme_name = theme_name || Models::ColorTheme::DEFAULT_THEME_NAME
        end

        def call
          unless theme_file_exist?(theme_name: theme_name)
            return Models::ColorTheme.new(theme_name: theme_name, theme_hash: default_color_theme_hash)
          end

          Models::ColorTheme.new(theme_name: theme_name, theme_hash: color_theme_hash)
        end

        private

        attr_reader :theme_name

        def color_theme_hash
          @color_theme_hash ||= load_theme_file
        end

        def load_theme_file
          theme_file = theme_file(theme_name: theme_name)
          Psych.safe_load(File.read(theme_file), [Symbol])
        end

        def migrate?(color_theme_hash)
          color_theme_hash[:version] != default_color_theme_hash[:version]
        end

        def default_color_theme_hash
          Models::ColorTheme::DEFAULT_THEME
        end
      end
    end
  end
end
