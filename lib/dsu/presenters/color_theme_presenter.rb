# frozen_string_literal: true

require_relative 'base_presenter'

module Dsu
  module Presenters
    class ColorThemePresenter < BasePresenter
      attr_reader :color_theme

      def initialize(color_theme, options: {})
        super

        @color_theme = color_theme
      end

      def header
        header = I18n.t('presenters.color_theme_presenter.headers.color_themes')
        apply_theme(header, theme_color: color_theme.subheader)
      end

      def footer
        header = I18n.t('presenters.color_theme_presenter.headers.current_theme')
        apply_theme(header, theme_color: color_theme.footer)
      end

      def detail
        "#{apply_theme(theme_name_formatted, theme_color: color_theme.body)} - " \
          "#{apply_theme(description, theme_color: color_theme.body)}"
      end

      def detail_with_index(index:)
        "#{formatted_index(index: index)} #{detail}"
      end

      private

      def theme_name_formatted
        return theme_name unless default_color_theme?

        "*#{theme_name}"
      end

      def default_color_theme?
        theme_name == default_color_theme.theme_name
      end

      def default_color_theme
        @default_color_theme ||= Models::ColorTheme.current_or_default
      end
    end
  end
end
