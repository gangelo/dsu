# frozen_string_literal: true

require 'colorized_string'

module Dsu
  module Support
    module ColorThemable
      def prompt_with_options(prompt:, options:)
        # HACK: This module needs to be refactored to be more generic.
        target_color_theme = defined?(color_theme) ? color_theme : self
        options = "[#{options.join('/')}]"
        "#{apply_theme(prompt, theme_color: target_color_theme.prompt)} " \
          "#{apply_theme(options, theme_color: target_color_theme.prompt_options)}" \
          "#{apply_theme('>', theme_color: target_color_theme.prompt)}"
      end

      module_function

      def apply_theme(input, theme_color:)
        if input.is_a?(Array)
          return input.map do |string|
            colorize_string(string, theme_color: theme_color)
          end.join("\n")
        end

        colorize_string(input, theme_color: theme_color)
      end

      private

      def colorize_string(input, theme_color:)
        ColorizedString[input].colorize(**theme_color)
      end
    end
  end
end
