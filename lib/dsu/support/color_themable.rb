# frozen_string_literal: true

require 'colorized_string'

module Dsu
  module Support
    module ColorThemable
      module_function

      def apply_color_theme(input, color_theme_color:)
        if input.is_a?(Array)
          return input.map do |string|
            colorize_string(string, color_theme_color: color_theme_color)
          end.join("\n")
        end

        colorize_string(input, color_theme_color: color_theme_color)
      end

      private

      def colorize_string(input, color_theme_color:)
        ColorizedString[input].colorize(**color_theme_color)
      end
    end
  end
end
