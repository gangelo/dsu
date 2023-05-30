# frozen_string_literal: true

require 'psych'
require_relative '../../models/color_theme'

module Dsu
  module Services
    module ColorThemes
      # This class writes a color theme to disk.
      class WriterService
        delegate :theme_file_exist?, :theme_file, to: Models::ColorTheme

        def initialize(theme:)
          raise ArgumentError, 'theme is nil.' if theme.nil?
          raise ArgumentError, "theme is the wrong object type: \"#{theme}\"." unless theme.is_a?(Models::ColorTheme)

          @theme = theme
        end

        # Does the same thing as #call, but raises an error if the theme
        # file already exists.
        def call!
          if theme_file_exist?(theme_name: theme_name)
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
