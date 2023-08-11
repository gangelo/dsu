# frozen_string_literal: true

require 'colorized_string'

module Dsu
  module Support
    module ColorThemable
      def prompt_with_options(prompt:, options:)
        options = "[#{options.join('/')}]"
        "#{apply_theme(prompt, theme_color: self.prompt)} " \
          "#{apply_theme(options, theme_color: prompt_options)}" \
          "#{apply_theme('>', theme_color: self.prompt)}"
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
