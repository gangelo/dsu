# frozen_string_literal: true

require_relative 'base_presenter'

module Dsu
  module Presenters
    class ColorThemeShowPresenter < BasePresenter
      def initialize(color_theme, options: {})
        super(color_theme, options: options.merge(theme_name: color_theme.theme_name))
      end

      def header
        apply_color_theme("Viewing color theme: #{color_theme.theme_name}", color_theme_color: color_theme.subheader)
      end

      def footer
        apply_color_theme('Footer: TODO', color_theme_color: color_theme.footer)
      end

      def detail
        puts_detail('No.', 'Color', 'Values', header: true)

        Models::ColorTheme::DEFAULT_THEME_COLORS.keys.each_with_index do |color_key, index|
          index = formatted_index(index: index)
          color_hash = color_theme.public_send(color_key)
          puts_detail(index, color_key, color_hash)
        end
      end

      def detail_with_index(index:)
        "#{formatted_index(index: index)} #{detail}"
      end

      private

      def puts_detail(index, color_key, color_hash, header: false)
        if header
          puts "#{apply_color_theme(index.to_s.ljust(4), color_theme_color: color_theme.index.bold!)} " \
               "#{apply_color_theme(color_key.to_s.ljust(15), color_theme_color: color_theme.index.bold!)} " \
               "#{apply_color_theme(color_hash.to_s.ljust(10), color_theme_color: color_theme.index.bold!)}"
        else
          puts "#{apply_color_theme(index.to_s.ljust(4), color_theme_color: color_theme.index)} " \
               "#{apply_color_theme(color_key.to_s.ljust(15), color_theme_color: color_hash)} " \
               "#{apply_color_theme(color_hash.to_s.ljust(10), color_theme_color: color_theme.body)}"
        end
      end
    end
  end
end
