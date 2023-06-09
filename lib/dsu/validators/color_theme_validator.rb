# frozen_string_literal: true

require 'colorize'
require_relative '../support/hash_key_comparable'

# rubocop:disable Layout/LineLength
module Dsu
  module Validators
    class ColorThemeValidator < ActiveModel::Validator
      delegate :compare_keys, to: Support::HashKeyComparable

      def validate(record)
        default_theme_colors = record.class::DEFAULT_THEME_COLORS

        # return unless validate_color_theme_keys!(record, default_theme_colors)

        default_theme_colors.each_key do |key|
          theme_color = record.public_send(key)

          next unless validate_theme_color_type!(record, key, theme_color)

          if theme_color.empty?
            record.errors.add(:base, ":#{key} colors Array is empty")
            next
          end

          validate_theme_colors!(record, key, theme_color)
        end
      end

      private

      def colors
        @colors ||= String.colors
      end

      def modes
        @modes ||= String.modes
      end

      # NOTE: This method is unused because we can never run into this scenario the way the ColorTheme class is
      # currently coded. However, I'm leaving it here in case things change.
      # def validate_color_theme_keys!(record, default_theme_colors)
      #   compare_keys(expected_hash: default_theme_colors, hash: record.to_theme_colors_h) do |_, missing, extra|
      #     missing.each { |theme_color_key| record.errors.add(:base, "theme color :#{theme_color_key} is missing") }
      #     extra.each { |theme_color_key| record.errors.add(:base, "theme color :#{theme_color_key} is an extra, invalid theme color key") }
      #
      #     return false
      #   end
      #
      #   true
      # end

      def validate_theme_color_type!(record, theme_color_key, theme_color)
        return true if theme_color.is_a?(Array)

        record.errors.add(:base, ":#{theme_color_key} is the wrong object type. " \
                                 "\"Array\" was expected, but \"#{theme_color.class}\" was received.")
        false
      end

      def validate_theme_colors!(record, theme_color_key, theme_color)
        unless colors.include?(theme_color[0])
          record.errors.add(:base, "color value (#{theme_color_key}: value[0]) is not a valid color. " \
                                   "One of #{colors.wrap_and_join(wrapper: [':', ''])} was expected, but :#{theme_color[0]} was received.")
        end

        unless theme_color[1].nil? || modes.include?(theme_color[1])
          record.errors.add(:base, "mode value (#{theme_color_key}: value[1]) is not a valid mode. " \
                                   "One of #{modes.wrap_and_join(wrapper: [':', ''])} was expected, but :#{theme_color[1]} was received.")
        end

        unless theme_color[2].nil? || colors.include?(theme_color[2])
          record.errors.add(:base, "background color value (#{theme_color_key}: value[2]) is not a valid color. " \
                                   "One of #{colors.wrap_and_join(wrapper: [':', ''])} was expected, but :#{theme_color[2]} was received.")
        end
      end
    end
  end
end
# rubocop:enable Layout/LineLength
