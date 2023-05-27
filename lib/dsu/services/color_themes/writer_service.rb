# frozen_string_literal: true

require 'psych'
require_relative '../../models/color_theme'
require_relative '../../support/color_theme_locatable'

module Dsu
  module Services
    module ColorThemes
      # This class writes a color theme to disk.
      class WriterService
        include Support::ColorThemeLocatable

        def initialize(theme:)
          raise ArgumentError, 'theme is nil.' if theme.nil?
          unless theme.is_a?(Models::ColorTheme::Theme)
            raise ArgumentError, "theme is the wrong object type: \"#{theme}\"."
          end

          @theme = theme
        end

        # Does the same thing as #call, but raises an error if the theme
        # file already exists.
        def call!
          if theme_file?(theme_name: theme_name)
            error_message = "Theme file already exists for theme \"#{theme_name}\": " \
                            "\"#{theme_file(theme_name: theme_name)}\"."
            raise ArgumentError, error_message
          end

          call
        end

        def call
          theme.validate!

          write_theme_file!
        end

        private

        attr_reader :theme

        def write_theme_file!
          theme_file = theme_file(theme_name: theme_name)
          File.write(theme_file, Psych.dump(theme.to_h))
        end

        def theme_name
          theme.theme_name
        end
      end
    end
  end
end
