# frozen_string_literal: true

require 'colorize'

# rubocop:disable Layout/LineLength
module Dsu
  module Validators
    class ColorThemeValidator < ActiveModel::Validator
      def validate(record)
        default_theme_colors = record.class::DEFAULT_THEME_COLORS

        # return unless validate_color_theme_keys!(record, default_theme_colors)

        default_theme_colors.each_key do |theme_color_key|
          theme_colors_hash = record.public_send(theme_color_key)

          next unless validate_theme_color_type!(record, theme_color_key, theme_colors_hash)

          if theme_colors_hash.empty?
            record.errors.add(:base, ":#{theme_color_key} colors Hash is empty")
            next
          end

          validate_theme_colors!(record, theme_colors_hash)
        end
      end

      private

      def colors
        @colors ||= String.colors
      end

      def modes
        @modes ||= String.modes
      end

      def validate_theme_color_type!(record, theme_color_key, theme_colors_hash)
        return true if theme_colors_hash.is_a?(Hash)

        record.errors.add(:base, ":#{theme_color_key} value is the wrong object type. " \
                                 "\"Hash\" was expected, but \"#{theme_colors_hash.class}\" was received.")
        false
      end

      def validate_theme_colors!(record, theme_colors_hash)
        unless colors.include?(theme_colors_hash[:color])
          value = theme_color_value_to_s(theme_colors_hash[:color])
          record.errors.add(:base, ":color key value #{value} in theme color Hash #{theme_colors_hash} is not a valid color. " \
                                   "One of #{colors.wrap_and_join(wrapper: [':', ''])} was expected, but #{value} was received.")
        end

        unless theme_colors_hash[:mode].nil? || modes.include?(theme_colors_hash[:mode])
          value = theme_color_value_to_s(theme_colors_hash[:mode])
          record.errors.add(:base, ":mode key value #{value} in theme color Hash #{theme_colors_hash} is not a valid mode value. " \
                                   "One of #{modes.wrap_and_join(wrapper: [':', ''])} was expected, but #{value} was received.")
        end

        unless theme_colors_hash[:background].nil? || colors.include?(theme_colors_hash[:background])
          value = theme_color_value_to_s(theme_colors_hash[:background])
          record.errors.add(:base, ":background key value #{value} in theme color Hash #{theme_colors_hash} is not a valid color. " \
                                   "One of #{colors.wrap_and_join(wrapper: [':', ''])} was expected, but #{value} was received.")
        end
      end

      def theme_color_value_to_s(theme_color_value)
        return ":#{theme_color_value}" if theme_color_value.is_a?(Symbol)

        "'#{theme_color_value}'"
      end
    end
  end
end
# rubocop:enable Layout/LineLength
