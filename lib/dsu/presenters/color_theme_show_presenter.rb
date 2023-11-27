# frozen_string_literal: true

require_relative 'base_presenter'

module Dsu
  module Presenters
    class ColorThemeShowPresenter < BasePresenter
      def initialize(color_theme, options: {})
        super(color_theme, options: options.merge(theme_name: color_theme.theme_name))
      end

      def detail
        headers = [I18n.t('presenters.color_theme_show_presenter.headers.number'),
                   I18n.t('presenters.color_theme_show_presenter.headers.color'),
                   I18n.t('presenters.color_theme_show_presenter.headers.values')]
        puts_detail(*headers, header: true)

        Models::ColorTheme::DEFAULT_THEME_COLORS.keys.each_with_index do |color_key, index|
          index = formatted_index(index: index)
          color_hash = color_theme.public_send(color_key)
          puts_detail(index, color_key, color_hash)
        end
      end

      def detail_with_index(index:)
        "#{formatted_index(index: index)} #{detail}"
      end

      def footer
        header = I18n.t('presenters.color_theme_show_presenter.headers.footer_example')
        apply_theme(header, theme_color: color_theme.footer)
      end

      def header
        header = I18n.t('presenters.color_theme_show_presenter.headers.viewing_color_theme', theme_name: color_theme.theme_name)
        apply_theme(header, theme_color: color_theme.subheader)
      end

      private

      def puts_detail(index, color_key, color_hash, header: false)
        if header
          puts "#{apply_theme(index.to_s.ljust(4), theme_color: color_theme.index.bold!)} " \
               "#{apply_theme(color_key.to_s.ljust(15), theme_color: color_theme.index.bold!)} " \
               "#{apply_theme(color_hash.to_s.ljust(10), theme_color: color_theme.index.bold!)}"
        else
          puts "#{apply_theme(index.to_s.ljust(4), theme_color: color_theme.index)} " \
               "#{apply_theme(color_key.to_s.ljust(15), theme_color: color_hash)} " \
               "#{apply_theme(color_hash.to_s.ljust(10), theme_color: color_theme.body)}"
        end
      end
    end
  end
end
